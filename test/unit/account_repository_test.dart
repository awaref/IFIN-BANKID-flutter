import 'package:bankid_app/features/authenticator/data/models/totp_account.dart';
import 'package:bankid_app/features/authenticator/data/repositories/account_repository.dart';
import 'package:bankid_app/features/authenticator/data/services/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  late Map<String, String> memoryStore;
  late AccountRepository repository;

  TotpAccount sample({
    String id = 'a1',
    String secret = 'JBSWY3DPEHPK3PXP',
    String issuer = 'Issuer A',
    String accountName = 'user@a.com',
    int sortOrder = 0,
  }) {
    return TotpAccount(
      id: id,
      issuer: issuer,
      accountName: accountName,
      secret: secret,
      sortOrder: sortOrder,
    );
  }

  setUp(() {
    memoryStore = {};
    repository = AccountRepository(
      storageService: SecureStorageService(memoryStore: memoryStore),
      uuid: const Uuid(),
    );
  });

  test('add and load accounts', () async {
    await repository.add(sample());
    final accounts = await repository.getAll();
    expect(accounts, hasLength(1));
    expect(accounts.first.issuer, 'Issuer A');
  });

  test('update account metadata', () async {
    final saved = await repository.add(sample());
    final updated = saved.copyWith(issuer: 'Updated Issuer');
    await repository.update(updated);
    final accounts = await repository.getAll();
    expect(accounts.single.issuer, 'Updated Issuer');
  });

  test('delete account reindexes sort order', () async {
    await repository.add(sample(id: 'a1', sortOrder: 0));
    await repository.add(
      sample(id: 'a2', secret: 'GEZDGNBVGY3TQOJQ', sortOrder: 1),
    );
    await repository.delete('a1');
    final accounts = await repository.getAll();
    expect(accounts, hasLength(1));
    expect(accounts.single.sortOrder, 0);
  });

  test('reorder swaps sortOrder', () async {
    await repository.add(sample(id: 'a1', issuer: 'First'));
    await repository.add(
      sample(id: 'a2', secret: 'GEZDGNBVGY3TQOJQ', issuer: 'Second'),
    );
    await repository.reorder(1, 0);
    final accounts = await repository.getAll();
    expect(accounts.first.issuer, 'Second');
    expect(accounts.last.issuer, 'First');
  });

  test('blocks duplicate secret on add', () async {
    await repository.add(sample(secret: 'JBSWY3DPEHPK3PXP'));
    expect(
      () => repository.add(
        sample(
          id: 'a2',
          issuer: 'Other',
          accountName: 'other@x.com',
          secret: 'jbswy3dpehpk3pxp',
        ),
      ),
      throwsA(isA<DuplicateSecretException>()),
    );
  });

  test('mergeImported skips duplicate secrets', () async {
    await repository.add(sample());
    final merged = await repository.mergeImported([
      sample(id: 'imported', secret: 'JBSWY3DPEHPK3PXP'),
      sample(
        id: 'new',
        secret: 'GEZDGNBVGY3TQOJQ',
        issuer: 'Imported',
        accountName: 'new@x.com',
      ),
    ]);
    expect(merged, hasLength(2));
    expect(merged.any((a) => a.issuer == 'Imported'), isTrue);
  });
}
