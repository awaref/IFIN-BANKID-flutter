import 'dart:convert';

import 'package:bankid_app/features/authenticator/data/models/totp_account.dart';
import 'package:bankid_app/features/authenticator/data/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = BackupService();

  List<TotpAccount> sampleAccounts() => [
        TotpAccount(
          id: '1',
          issuer: 'Bank',
          accountName: 'user@example.com',
          secret: 'JBSWY3DPEHPK3PXP',
          sortOrder: 0,
        ),
        TotpAccount(
          id: '2',
          issuer: 'Work',
          accountName: 'alice',
          secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          sortOrder: 1,
        ),
      ];

  test('export produces valid encrypted envelope', () {
    final json = service.exportAccounts(sampleAccounts(), 'test-password');
    final envelope = jsonDecode(json) as Map<String, dynamic>;
    expect(envelope['version'], 1);
    expect(envelope['format'], 'bankid-totp-backup');
    expect(envelope['salt'], isNotEmpty);
    expect(envelope['nonce'], isNotEmpty);
    expect(envelope['ciphertext'], isNotEmpty);
    expect(envelope['tag'], isNotEmpty);
  });

  test('import with correct password restores accounts and order', () {
    final accounts = sampleAccounts();
    final json = service.exportAccounts(accounts, 'correct-password');
    final restored = service.importAccounts(json, 'correct-password');
    expect(restored, hasLength(2));
    expect(restored.first.issuer, 'Bank');
    expect(restored.last.issuer, 'Work');
    expect(restored.first.sortOrder, lessThan(restored.last.sortOrder));
  });

  test('import with wrong password fails safely', () {
    final json = service.exportAccounts(sampleAccounts(), 'correct-password');
    expect(
      () => service.importAccounts(json, 'wrong-password'),
      throwsA(isA<BackupException>()),
    );
  });

  test('corrupted ciphertext fails integrity check', () {
    final json = service.exportAccounts(sampleAccounts(), 'password');
    final envelope = jsonDecode(json) as Map<String, dynamic>;
    envelope['ciphertext'] = 'AAAA';
    final corrupted = jsonEncode(envelope);
    expect(
      () => service.importAccounts(corrupted, 'password'),
      throwsA(isA<BackupException>()),
    );
  });

  test('invalid JSON format is rejected', () {
    expect(
      () => service.importAccounts('{not valid json', 'password'),
      throwsA(isA<BackupException>()),
    );
  });

  test('wrong envelope format is rejected', () {
    expect(
      () => service.importAccounts('{"version":1,"format":"other"}', 'password'),
      throwsA(isA<BackupException>()),
    );
  });
}
