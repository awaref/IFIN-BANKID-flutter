import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../data/models/authenticator_settings.dart';
import '../../data/services/secure_flag_service.dart';
import '../providers/authenticator_provider.dart';
import '../providers/authenticator_settings_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/totp_account_card.dart';
import 'add_account_screen.dart';
import 'authenticator_settings_screen.dart';
import 'edit_account_screen.dart';

class AuthenticatorScope extends StatelessWidget {
  const AuthenticatorScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticatorProvider()..loadAccounts()),
        ChangeNotifierProvider(create: (_) => TimerProvider()..start()),
        ChangeNotifierProvider(create: (_) => AuthenticatorSettingsProvider()..load()),
      ],
      child: child,
    );
  }
}

class AuthenticatorHomeScreen extends StatefulWidget {
  const AuthenticatorHomeScreen({super.key});

  @override
  State<AuthenticatorHomeScreen> createState() => _AuthenticatorHomeScreenState();
}

class _AuthenticatorHomeScreenState extends State<AuthenticatorHomeScreen>
    with WidgetsBindingObserver {
  final SecureFlagService _secureFlagService = SecureFlagService();
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _secureFlagService.enableSecureFlag();
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluateLock(force: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _secureFlagService.disableSecureFlag();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = context.read<AuthenticatorSettingsProvider>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      settings.recordBackgrounded();
    }
    if (state == AppLifecycleState.resumed) {
      _evaluateLock();
    }
  }

  Future<void> _evaluateLock({bool force = false}) async {
    final settings = context.read<AuthenticatorSettingsProvider>();
    if (!force && !settings.shouldLockOnResume()) {
      return;
    }
    if (settings.settings.appLockTimeout == AppLockTimeout.never) {
      settings.unlock();
      return;
    }
    if (!settings.shouldLockOnResume() && !force) {
      return;
    }
    settings.lock();
    final l10n = AppLocalizations.of(context)!;
    final authenticated = await _biometricService.authenticate(
      reason: l10n.authenticatorAppLockReason,
    );
    if (!mounted) return;
    if (authenticated) {
      settings.unlock();
    }
  }

  Future<void> _copyCode(String code) async {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.read<AuthenticatorSettingsProvider>().settings;
    await context.read<AuthenticatorProvider>().copyCode(
          code,
          clearAfterSeconds: settings.clipboardClearSeconds,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.authenticatorCodeCopied),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  Future<void> _confirmDelete(String id, String issuer, String accountName) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authenticatorDeleteTitle),
        content: Text(
          l10n.authenticatorDeleteMessage(issuer, accountName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.authenticatorDeleteConfirm,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthenticatorProvider>().deleteAccount(id);
    }
  }

  void _openAddAccount() {
    final provider = context.read<AuthenticatorProvider>();
    final timer = context.read<TimerProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider.value(value: timer),
          ],
          child: const AddAccountScreen(),
        ),
      ),
    );
  }

  void _openSettings() {
    final settings = context.read<AuthenticatorSettingsProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<AuthenticatorProvider>(),
            ),
            ChangeNotifierProvider.value(value: settings),
          ],
          child: const AuthenticatorSettingsScreen(),
        ),
      ),
    );
  }

  Widget _emptyState({
    required List<List<dynamic>> hugeIcon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: HugeIcon(
                icon: hugeIcon,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAdd01,
                  size: 20,
                  color: Colors.white,
                ),
                label: Text(actionLabel),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<AuthenticatorSettingsProvider>();
    final themeMode = settingsProvider.materialThemeMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: switch (themeMode) {
          ThemeMode.dark => Brightness.dark,
          ThemeMode.light => Brightness.light,
          ThemeMode.system => Theme.of(context).brightness,
        },
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.authenticatorTitle),
          actions: [
            IconButton(
              tooltip: l10n.authenticatorSearchHint,
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    context.read<AuthenticatorProvider>().setSearchQuery('');
                  }
                });
              },
              icon: HugeIcon(
                icon: _showSearch
                    ? HugeIcons.strokeRoundedCancel01
                    : HugeIcons.strokeRoundedSearch01,
              ),
            ),
            IconButton(
              tooltip: l10n.authenticatorSettingsTitle,
              onPressed: _openSettings,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedSettings01),
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: settingsProvider.isLocked
            ? null
            : FloatingActionButton.extended(
                onPressed: _openAddAccount,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedAdd01,
                  color: Colors.white,
                  size: 22,
                ),
                label: Text(l10n.authenticatorAddAccount),
              ),
        body: Stack(
          children: [
            Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _showSearch
                      ? AuthenticatorSearchBar(
                          key: const ValueKey('search-open'),
                          controller: _searchController,
                          hintText: l10n.authenticatorSearchHint,
                          onChanged:
                              context.read<AuthenticatorProvider>().setSearchQuery,
                          onClear: () {
                            _searchController.clear();
                            context
                                .read<AuthenticatorProvider>()
                                .setSearchQuery('');
                          },
                        )
                      : const SizedBox.shrink(key: ValueKey('search-closed')),
                ),
                Expanded(
                  child: settingsProvider.isLocked
                      ? const SizedBox.shrink()
                      : Consumer2<AuthenticatorProvider, TimerProvider>(
                          builder: (context, provider, timer, _) {
                            if (provider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final accounts = provider.filteredAccounts;
                            final hasQuery =
                                provider.searchQuery.trim().isNotEmpty;
                            if (accounts.isEmpty) {
                              if (hasQuery) {
                                return _emptyState(
                                  hugeIcon: HugeIcons.strokeRoundedSearch01,
                                  title: l10n.authenticatorNoSearchResults,
                                  subtitle:
                                      l10n.authenticatorNoSearchResultsSubtitle,
                                );
                              }
                              return _emptyState(
                                hugeIcon: HugeIcons.strokeRoundedShield01,
                                title: l10n.authenticatorEmptyTitle,
                                subtitle: l10n.authenticatorEmptySubtitle,
                                actionLabel: l10n.authenticatorAddAccount,
                                onAction: _openAddAccount,
                              );
                            }
                            return ReorderableListView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 96),
                              itemCount: accounts.length,
                              onReorder: provider.reorderAccounts,
                              proxyDecorator: (child, index, animation) {
                                return Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(16),
                                  color: colorScheme.surface,
                                  child: child,
                                );
                              },
                              itemBuilder: (context, index) {
                                final account = accounts[index];
                                return TotpAccountCard(
                                  key: ValueKey(account.id),
                                  account: account,
                                  epochSeconds: timer.epochSeconds,
                                  totpService: provider.totpService,
                                  onCopy: () => _copyCode(
                                    provider.totpService.generateCode(
                                      account,
                                      timer.epochSeconds,
                                    ),
                                  ),
                                  onEdit: () {
                                    final authProvider =
                                        context.read<AuthenticatorProvider>();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ChangeNotifierProvider.value(
                                          value: authProvider,
                                          child: EditAccountScreen(
                                            account: account,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () => _confirmDelete(
                                    account.id,
                                    account.issuer,
                                    account.accountName,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            if (settingsProvider.isLocked)
              Positioned.fill(
                child: Material(
                  color: colorScheme.surface,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedLock,
                              size: 40,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.authenticatorLockedTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.authenticatorAppLockReason,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => _evaluateLock(force: true),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedLock,
                              size: 20,
                              color: Colors.white,
                            ),
                            label: Text(l10n.authenticatorUnlock),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(180, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
