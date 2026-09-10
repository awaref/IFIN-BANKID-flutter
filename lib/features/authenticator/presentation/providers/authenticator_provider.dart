import 'package:flutter/foundation.dart';

import '../../data/models/totp_account.dart';
import '../../data/repositories/account_repository.dart';
import '../../data/services/clipboard_service.dart';
import '../../data/services/totp_service.dart';

class AuthenticatorProvider extends ChangeNotifier {
  AuthenticatorProvider({
    AccountRepository? repository,
    TotpService? totpService,
    ClipboardService? clipboardService,
  })  : _repository = repository ?? AccountRepository(),
        _totpService = totpService ?? TotpService(),
        _clipboardService = clipboardService ?? ClipboardService();

  final AccountRepository _repository;
  final TotpService _totpService;
  final ClipboardService _clipboardService;

  List<TotpAccount> _accounts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<TotpAccount> get accounts => _accounts;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TotpService get totpService => _totpService;

  List<TotpAccount> get filteredAccounts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _accounts;
    }
    return _accounts
        .where(
          (account) =>
              account.issuer.toLowerCase().contains(query) ||
              account.accountName.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _accounts = await _repository.getAll();
    } catch (_) {
      _errorMessage = 'load_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<TotpAccount> addAccount(TotpAccount account) async {
    final saved = await _repository.add(account);
    _accounts = await _repository.getAll();
    notifyListeners();
    return saved;
  }

  Future<TotpAccount> updateAccount(TotpAccount account) async {
    final saved = await _repository.update(account);
    _accounts = await _repository.getAll();
    notifyListeners();
    return saved;
  }

  Future<void> deleteAccount(String id) async {
    await _repository.delete(id);
    _accounts = await _repository.getAll();
    notifyListeners();
  }

  Future<void> reorderAccounts(int oldIndex, int newIndex) async {
    await _repository.reorder(oldIndex, newIndex);
    _accounts = await _repository.getAll();
    notifyListeners();
  }

  bool isDuplicateSecret(String secret, {String? exceptId}) {
    return _repository.hasDuplicateSecret(_accounts, secret, exceptId: exceptId);
  }

  Future<void> copyCode(String code, {required int clearAfterSeconds}) async {
    await _clipboardService.copyCode(code, clearAfterSeconds: clearAfterSeconds);
  }

  Future<void> mergeImportedAccounts(List<TotpAccount> imported) async {
    _accounts = await _repository.mergeImported(imported);
    notifyListeners();
  }

  @override
  void dispose() {
    _clipboardService.dispose();
    super.dispose();
  }
}
