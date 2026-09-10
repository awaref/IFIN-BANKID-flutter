import 'package:uuid/uuid.dart';

import '../models/totp_account.dart';
import '../services/secure_storage_service.dart';

class AccountRepository {
  AccountRepository({
    SecureStorageService? storageService,
    Uuid? uuid,
  })  : _storageService = storageService ?? SecureStorageService(),
        _uuid = uuid ?? const Uuid();

  final SecureStorageService _storageService;
  final Uuid _uuid;

  Future<List<TotpAccount>> getAll() => _storageService.readAccounts();

  Future<TotpAccount> add(TotpAccount account) async {
    final accounts = await getAll();
    _assertUniqueSecret(accounts, account.secret);
    TotpAccount.validateFields(
      issuer: account.issuer,
      accountName: account.accountName,
      secret: account.secret,
      algorithm: account.algorithm,
      digits: account.digits,
      period: account.period,
    );

    final normalized = account.copyWith(
      id: account.id.isEmpty ? _uuid.v4() : account.id,
      secret: TotpAccount.normalizeSecret(account.secret),
      sortOrder: accounts.length,
      updatedAt: DateTime.now().toUtc(),
      createdAt: DateTime.now().toUtc(),
    );

    accounts.add(normalized);
    await _storageService.writeAccounts(accounts);
    return normalized;
  }

  Future<TotpAccount> update(TotpAccount account) async {
    final accounts = await getAll();
    final index = accounts.indexWhere((item) => item.id == account.id);
    if (index == -1) {
      throw TotpValidationException('Account not found');
    }

    final normalizedSecret = TotpAccount.normalizeSecret(account.secret);
    _assertUniqueSecret(accounts, normalizedSecret, exceptId: account.id);

    TotpAccount.validateFields(
      issuer: account.issuer,
      accountName: account.accountName,
      secret: normalizedSecret,
      algorithm: account.algorithm,
      digits: account.digits,
      period: account.period,
    );

    final updated = account.copyWith(
      secret: normalizedSecret,
      updatedAt: DateTime.now().toUtc(),
    );
    accounts[index] = updated;
    await _storageService.writeAccounts(accounts);
    return updated;
  }

  Future<void> delete(String id) async {
    final accounts = await getAll()..removeWhere((item) => item.id == id);
    for (var i = 0; i < accounts.length; i++) {
      accounts[i] = accounts[i].copyWith(sortOrder: i);
    }
    await _storageService.writeAccounts(accounts);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final accounts = await getAll();
    if (oldIndex < 0 ||
        oldIndex >= accounts.length ||
        newIndex < 0 ||
        newIndex >= accounts.length) {
      return;
    }
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = accounts.removeAt(oldIndex);
    accounts.insert(newIndex, item);
    for (var i = 0; i < accounts.length; i++) {
      accounts[i] = accounts[i].copyWith(sortOrder: i);
    }
    await _storageService.writeAccounts(accounts);
  }

  Future<void> replaceAll(List<TotpAccount> accounts) async {
    final normalized = <TotpAccount>[];
    final seenSecrets = <String>{};
    for (var i = 0; i < accounts.length; i++) {
      final account = accounts[i];
      final secret = TotpAccount.normalizeSecret(account.secret);
      if (seenSecrets.contains(secret)) {
        continue;
      }
      seenSecrets.add(secret);
      normalized.add(
        account.copyWith(
          secret: secret,
          sortOrder: normalized.length,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
    await _storageService.writeAccounts(normalized);
  }

  Future<List<TotpAccount>> mergeImported(List<TotpAccount> imported) async {
    final existing = await getAll();
    final existingSecrets =
        existing.map((a) => TotpAccount.normalizeSecret(a.secret)).toSet();

    final merged = List<TotpAccount>.from(existing);
    for (final account in imported) {
      final secret = TotpAccount.normalizeSecret(account.secret);
      if (existingSecrets.contains(secret)) {
        continue;
      }
      existingSecrets.add(secret);
      merged.add(
        account.copyWith(
          id: _uuid.v4(),
          secret: secret,
          sortOrder: merged.length,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
    await _storageService.writeAccounts(merged);
    return merged;
  }

  bool hasDuplicateSecret(List<TotpAccount> accounts, String secret, {String? exceptId}) {
    final normalized = TotpAccount.normalizeSecret(secret);
    return accounts.any(
      (account) =>
          account.id != exceptId &&
          TotpAccount.normalizeSecret(account.secret) == normalized,
    );
  }

  void _assertUniqueSecret(
    List<TotpAccount> accounts,
    String secret, {
    String? exceptId,
  }) {
    if (hasDuplicateSecret(accounts, secret, exceptId: exceptId)) {
      throw DuplicateSecretException();
    }
  }
}
