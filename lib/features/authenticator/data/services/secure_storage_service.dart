import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/totp_account.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage, Map<String, String>? memoryStore})
      : _storage = storage ?? const FlutterSecureStorage(),
        _memoryStore = memoryStore;

  static const String accountsKey = 'totp_accounts';

  final FlutterSecureStorage? _storage;
  final Map<String, String>? _memoryStore;

  Future<List<TotpAccount>> readAccounts() async {
    final raw = await _readRaw();
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TotpAccount.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<void> writeAccounts(List<TotpAccount> accounts) async {
    final payload = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _writeRaw(payload);
  }

  Future<String?> _readRaw() async {
    if (_memoryStore != null) {
      return _memoryStore[accountsKey];
    }
    return _storage!.read(key: accountsKey);
  }

  Future<void> _writeRaw(String value) async {
    if (_memoryStore != null) {
      _memoryStore[accountsKey] = value;
      return;
    }
    await _storage!.write(key: accountsKey, value: value);
  }
}
