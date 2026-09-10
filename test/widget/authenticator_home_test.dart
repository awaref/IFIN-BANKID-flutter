import 'package:bankid_app/features/authenticator/data/models/totp_account.dart';
import 'package:bankid_app/features/authenticator/data/repositories/account_repository.dart';
import 'package:bankid_app/features/authenticator/data/services/secure_storage_service.dart';
import 'package:bankid_app/features/authenticator/presentation/providers/authenticator_provider.dart';
import 'package:bankid_app/features/authenticator/presentation/providers/authenticator_settings_provider.dart';
import 'package:bankid_app/features/authenticator/presentation/providers/timer_provider.dart';
import 'package:bankid_app/features/authenticator/presentation/screens/authenticator_home_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({
    required AuthenticatorProvider authenticatorProvider,
    required TimerProvider timerProvider,
    AuthenticatorSettingsProvider? settingsProvider,
  }) {
    final settings = settingsProvider ?? AuthenticatorSettingsProvider();
    settings.load();
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
          ChangeNotifierProvider.value(value: authenticatorProvider),
          ChangeNotifierProvider.value(value: timerProvider),
          ChangeNotifierProvider.value(value: settings),
        ],
        child: const AuthenticatorHomeScreen(),
      ),
    );
  }

  testWidgets('shows empty state when no accounts', (tester) async {
    final provider = AuthenticatorProvider(
      repository: AccountRepository(
        storageService: SecureStorageService(memoryStore: {}),
      ),
    );
    await provider.loadAccounts();
    final timer = TimerProvider()..start();

    await tester.pumpWidget(buildTestApp(
      authenticatorProvider: provider,
      timerProvider: timer,
    ));
    await tester.pumpAndSettle();

    expect(find.text('No accounts yet'), findsOneWidget);
    expect(find.text('Add an account to generate verification codes'), findsOneWidget);
    timer.stop();
  });

  testWidgets('renders account card with issuer and countdown', (tester) async {
    final memoryStore = <String, String>{};
    final repository = AccountRepository(
      storageService: SecureStorageService(memoryStore: memoryStore),
    );
    final provider = AuthenticatorProvider(repository: repository);
    await repository.add(
      TotpAccount(
        id: '1',
        issuer: 'Test Bank',
        accountName: 'user@example.com',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    await provider.loadAccounts();
    final timer = TimerProvider()..start();

    await tester.pumpWidget(buildTestApp(
      authenticatorProvider: provider,
      timerProvider: timer,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Test Bank'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d{3}\s\d{3}')), findsOneWidget);
    expect(find.textContaining('s'), findsWidgets);
    timer.stop();
  });
}
