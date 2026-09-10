import 'dart:convert';

import 'package:bankid_app/features/authenticator/data/models/authenticator_settings.dart';
import 'package:bankid_app/features/authenticator/data/models/totp_account.dart';
import 'package:bankid_app/features/authenticator/data/repositories/account_repository.dart';
import 'package:bankid_app/features/authenticator/data/services/backup_service.dart';
import 'package:bankid_app/features/authenticator/data/services/otp_uri_parser.dart';
import 'package:bankid_app/features/authenticator/data/services/secure_storage_service.dart';
import 'package:bankid_app/features/authenticator/data/services/totp_service.dart';
import 'package:bankid_app/features/authenticator/presentation/providers/authenticator_provider.dart';
import 'package:bankid_app/features/authenticator/presentation/providers/authenticator_settings_provider.dart';
import 'package:bankid_app/features/authenticator/presentation/providers/timer_provider.dart';
import 'package:bankid_app/features/authenticator/presentation/screens/add_account_screen.dart';
import 'package:bankid_app/features/authenticator/presentation/screens/authenticator_home_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// T044 automated coverage for quickstart V5–V10 (emulator-safe).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secret = 'JBSWY3DPEHPK3PXP';
  late Map<String, String> memoryStore;
  late AccountRepository repository;
  late AuthenticatorProvider authProvider;
  late AuthenticatorSettingsProvider settingsProvider;
  late TimerProvider timerProvider;
  late bool secureFlagEnabled;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    memoryStore = {};
    repository = AccountRepository(
      storageService: SecureStorageService(memoryStore: memoryStore),
    );
    authProvider = AuthenticatorProvider(repository: repository);
    settingsProvider = AuthenticatorSettingsProvider();
    await settingsProvider.load();
    timerProvider = TimerProvider()..start();
    secureFlagEnabled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.bankid_app/secure_flag'),
      (call) async {
        if (call.method == 'setSecureFlag') {
          secureFlagEnabled = true;
        } else if (call.method == 'clearSecureFlag') {
          secureFlagEnabled = false;
        }
        return null;
      },
    );
  });

  tearDown(() {
    timerProvider.stop();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.example.bankid_app/secure_flag'),
      null,
    );
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: timerProvider),
          ChangeNotifierProvider.value(value: settingsProvider),
        ],
        child: child,
      ),
    );
  }

  TotpAccount makeAccount({
    required String id,
    required String issuer,
    required String accountName,
    required String secretValue,
  }) {
    return TotpAccount(
      id: id,
      issuer: issuer,
      accountName: accountName,
      secret: secretValue,
    );
  }

  group('T044 / V5 Manual account entry', () {
    test('adds account and generates live rotating code', () async {
      final account = await repository.add(
        makeAccount(
          id: '1',
          issuer: 'TestService',
          accountName: 'test@example.com',
          secretValue: secret,
        ),
      );
      await authProvider.loadAccounts();
      expect(authProvider.accounts, hasLength(1));
      expect(authProvider.accounts.first.issuer, 'TestService');

      final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final formatted = TotpService().generateCode(account, epoch);
      expect(formatted.replaceAll(' ', '').length, 6);

      final remaining = TotpService().remainingSeconds(30, epoch);
      expect(remaining, inInclusiveRange(1, 30));
    });

    testWidgets('home empty state offers add account CTA', (tester) async {
      await authProvider.loadAccounts();
      await tester.pumpWidget(wrap(const AuthenticatorHomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('No accounts yet'), findsOneWidget);
      expect(find.text('Add account'), findsNWidgets(2));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      timerProvider.stop();
    });

    testWidgets('manual add form validates and opens preview', (tester) async {
      await authProvider.loadAccounts();
      await tester.pumpWidget(wrap(const AddAccountScreen()));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(3));
      await tester.enterText(fields.at(0), 'test@example.com');
      await tester.enterText(fields.at(1), 'TestService');
      await tester.enterText(fields.at(2), secret);
      await tester.tap(find.text('Preview account'));
      await tester.pumpAndSettle();

      expect(find.text('Live preview'), findsOneWidget);
      expect(find.text('TestService'), findsWidgets);
      expect(find.text('test@example.com'), findsWidgets);
      expect(find.textContaining(RegExp(r'\d{3}\s\d{3}')), findsOneWidget);

      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();
      await authProvider.loadAccounts();
      expect(authProvider.accounts, hasLength(1));
      timerProvider.stop();
    });
  });

  group('T044 / V6 QR URI payload', () {
    test('parses GitHub otpauth URI from QR payload', () {
      const uri =
          'otpauth://totp/GitHub:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub';
      final account = OtpUriParser().parse(uri);
      expect(account.issuer, 'GitHub');
      expect(account.accountName, 'user@example.com');
      expect(account.secret, secret);
      expect(account.algorithm, TotpAlgorithm.sha1);
      expect(account.digits, 6);
      expect(account.period, 30);
    });
  });

  group('T044 / V7 App lock', () {
    test('onLaunch requires lock; never does not', () async {
      await settingsProvider.setAppLockTimeout(AppLockTimeout.onLaunch);
      expect(settingsProvider.shouldLockOnResume(), isTrue);

      await settingsProvider.setAppLockTimeout(AppLockTimeout.never);
      expect(settingsProvider.shouldLockOnResume(), isFalse);
    });

    testWidgets('lock overlay hides accounts until unlocked', (tester) async {
      await repository.add(
        makeAccount(
          id: '1',
          issuer: 'TestService',
          accountName: 'test@example.com',
          secretValue: secret,
        ),
      );
      await authProvider.loadAccounts();
      await settingsProvider.setAppLockTimeout(AppLockTimeout.onLaunch);
      settingsProvider.lock();

      await tester.pumpWidget(wrap(const AuthenticatorHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Authenticator locked'), findsOneWidget);
      expect(find.text('Unlock'), findsOneWidget);
      expect(find.text('TestService'), findsNothing);
      expect(find.textContaining(RegExp(r'\d{3}\s\d{3}')), findsNothing);

      settingsProvider.unlock();
      await tester.pumpAndSettle();
      expect(find.text('TestService'), findsOneWidget);
      expect(find.textContaining(RegExp(r'\d{3}\s\d{3}')), findsOneWidget);
      timerProvider.stop();
    });
  });

  group('T044 / V8 Export & Import', () {
    test('encrypted backup round-trip and wrong password failure', () async {
      await repository.add(
        makeAccount(
          id: '1',
          issuer: 'Bank',
          accountName: 'a@x.com',
          secretValue: secret,
        ),
      );
      await repository.add(
        makeAccount(
          id: '2',
          issuer: 'Work',
          accountName: 'b@x.com',
          secretValue: 'GEZDGNBVGY3TQOJQ',
        ),
      );
      final accounts = await repository.getAll();
      final backup = BackupService();
      final json = backup.exportAccounts(accounts, 'TestPass123!');
      final envelope = jsonDecode(json) as Map<String, dynamic>;
      expect(envelope['format'], 'bankid-totp-backup');
      expect(envelope['ciphertext'], isNotEmpty);

      final restored = backup.importAccounts(json, 'TestPass123!');
      expect(restored, hasLength(2));
      expect(restored.map((a) => a.issuer), containsAll(['Bank', 'Work']));

      expect(
        () => backup.importAccounts(json, 'wrong'),
        throwsA(isA<BackupException>()),
      );

      final afterFail = await repository.getAll();
      expect(afterFail, hasLength(2));
    });
  });

  group('T044 / V9 Search & Reorder', () {
    test('search filters and reorder persists', () async {
      await repository.add(
        makeAccount(
          id: '1',
          issuer: 'Alpha',
          accountName: 'a@x.com',
          secretValue: secret,
        ),
      );
      await repository.add(
        makeAccount(
          id: '2',
          issuer: 'Beta',
          accountName: 'b@x.com',
          secretValue: 'GEZDGNBVGY3TQOJQ',
        ),
      );
      await repository.add(
        makeAccount(
          id: '3',
          issuer: 'Gamma',
          accountName: 'c@x.com',
          secretValue: 'KRSXG5CTMVRXEZLU',
        ),
      );
      await authProvider.loadAccounts();

      authProvider.setSearchQuery('Beta');
      expect(authProvider.filteredAccounts, hasLength(1));
      expect(authProvider.filteredAccounts.first.issuer, 'Beta');

      authProvider.setSearchQuery('');
      expect(authProvider.filteredAccounts, hasLength(3));

      await authProvider.reorderAccounts(0, 2);
      final reloaded = await repository.getAll();
      expect(reloaded.map((a) => a.sortOrder).toList(), [0, 1, 2]);
      expect(reloaded.first.issuer, isNot('Alpha'));
    });
  });

  group('T044 / V10 Security', () {
    testWidgets('enables FLAG_SECURE on authenticator home', (tester) async {
      await authProvider.loadAccounts();
      await tester.pumpWidget(wrap(const AuthenticatorHomeScreen()));
      await tester.pumpAndSettle();
      expect(secureFlagEnabled, isTrue);
      timerProvider.stop();
    });

    test('secret never appears in backup envelope plaintext', () {
      final accounts = [
        makeAccount(
          id: '1',
          issuer: 'Bank',
          accountName: 'a@x.com',
          secretValue: secret,
        ),
      ];
      final json = BackupService().exportAccounts(accounts, 'TestPass123!');
      expect(json.contains(secret), isFalse);
      expect(json.contains('a@x.com'), isFalse);
    });

    test('duplicate secret is blocked', () async {
      await repository.add(
        makeAccount(
          id: '1',
          issuer: 'One',
          accountName: 'a@x.com',
          secretValue: secret,
        ),
      );
      expect(
        () => repository.add(
          makeAccount(
            id: '2',
            issuer: 'Two',
            accountName: 'b@x.com',
            secretValue: secret.toLowerCase(),
          ),
        ),
        throwsA(isA<DuplicateSecretException>()),
      );
    });
  });
}
