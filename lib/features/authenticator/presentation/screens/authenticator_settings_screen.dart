import 'dart:io';

import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/models/authenticator_settings.dart';
import '../../data/services/backup_service.dart';
import '../providers/authenticator_provider.dart';
import '../providers/authenticator_settings_provider.dart';

class AuthenticatorSettingsScreen extends StatefulWidget {
  const AuthenticatorSettingsScreen({super.key});

  @override
  State<AuthenticatorSettingsScreen> createState() =>
      _AuthenticatorSettingsScreenState();
}

class _AuthenticatorSettingsScreenState extends State<AuthenticatorSettingsScreen> {
  final BackupService _backupService = BackupService();

  Future<void> _exportAccounts() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<AuthenticatorProvider>();
    final password = await _promptPassword(confirm: true);
    if (password == null || password.isEmpty) return;

    final accounts = provider.accounts;
    if (accounts.isEmpty) {
      _showMessage(l10n.authenticatorExportEmpty);
      return;
    }

    try {
      final payload = _backupService.exportAccounts(accounts, password);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/bankid-totp-backup.json');
      await file.writeAsString(payload);
      if (!mounted) return;
      _showMessage(l10n.authenticatorExportSuccess);
    } on BackupException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage(l10n.authenticatorExportFailed);
    }
  }

  Future<void> _importAccounts() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<AuthenticatorProvider>();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    final password = await _promptPassword();
    if (password == null || password.isEmpty) return;

    try {
      final raw = await File(result.files.single.path!).readAsString();
      final imported = _backupService.importAccounts(raw, password);
      await provider.mergeImportedAccounts(imported);
      if (!mounted) return;
      _showMessage(l10n.authenticatorImportSuccess(imported.length));
    } on BackupException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage(l10n.authenticatorImportFailed);
    }
  }

  Future<String?> _promptPassword({bool confirm = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authenticatorBackupPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.authenticatorBackupPassword),
            ),
            if (confirm)
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration:
                    InputDecoration(labelText: l10n.authenticatorBackupPasswordConfirm),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              if (confirm && passwordController.text != confirmController.text) {
                Navigator.pop(context);
                _showMessage(l10n.authenticatorBackupPasswordMismatch);
                return;
              }
              Navigator.pop(context, passwordController.text);
            },
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<AuthenticatorSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authenticatorSettingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.authenticatorSecuritySection),
            subtitle: Text(l10n.authenticatorAppLockSection),
          ),
          RadioGroup<AppLockTimeout>(
            groupValue: settingsProvider.settings.appLockTimeout,
            onChanged: (value) {
              if (value != null) settingsProvider.setAppLockTimeout(value);
            },
            child: Column(
              children: AppLockTimeout.values.map(
                (timeout) => RadioListTile<AppLockTimeout>(
                  title: Text(_lockLabel(l10n, timeout)),
                  value: timeout,
                ),
              ).toList(),
            ),
          ),
          ListTile(title: Text(l10n.authenticatorClipboardSection)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int>(
              key: ValueKey(settingsProvider.settings.clipboardClearSeconds),
              initialValue: settingsProvider.settings.clipboardClearSeconds,
              decoration: InputDecoration(labelText: l10n.authenticatorClipboardDuration),
              items: [
                DropdownMenuItem(value: 30, child: Text(l10n.authenticatorClipboard30)),
                DropdownMenuItem(value: 60, child: Text(l10n.authenticatorClipboard60)),
                DropdownMenuItem(value: 0, child: Text(l10n.authenticatorClipboardDisabled)),
              ],
              onChanged: (value) {
                if (value != null) settingsProvider.setClipboardClearSeconds(value);
              },
            ),
          ),
          ListTile(title: Text(l10n.authenticatorAppearanceSection)),
          RadioGroup<AuthenticatorThemeMode>(
            groupValue: settingsProvider.settings.themeMode,
            onChanged: (value) {
              if (value != null) settingsProvider.setThemeMode(value);
            },
            child: Column(
              children: AuthenticatorThemeMode.values.map(
                (mode) => RadioListTile<AuthenticatorThemeMode>(
                  title: Text(_themeLabel(l10n, mode)),
                  value: mode,
                ),
              ).toList(),
            ),
          ),
          ListTile(title: Text(l10n.authenticatorBackupSection)),
          ListTile(
            title: Text(l10n.authenticatorExportAccounts),
            trailing: const Icon(Icons.upload_file),
            onTap: _exportAccounts,
          ),
          ListTile(
            title: Text(l10n.authenticatorImportAccounts),
            trailing: const Icon(Icons.download),
            onTap: _importAccounts,
          ),
        ],
      ),
    );
  }

  String _lockLabel(AppLocalizations l10n, AppLockTimeout timeout) {
    switch (timeout) {
      case AppLockTimeout.never:
        return l10n.authenticatorLockNever;
      case AppLockTimeout.onLaunch:
        return l10n.authenticatorLockOnLaunch;
      case AppLockTimeout.after1Min:
        return l10n.authenticatorLockAfter1Min;
      case AppLockTimeout.after5Min:
        return l10n.authenticatorLockAfter5Min;
    }
  }

  String _themeLabel(AppLocalizations l10n, AuthenticatorThemeMode mode) {
    switch (mode) {
      case AuthenticatorThemeMode.light:
        return l10n.authenticatorThemeLight;
      case AuthenticatorThemeMode.dark:
        return l10n.authenticatorThemeDark;
      case AuthenticatorThemeMode.system:
        return l10n.authenticatorThemeSystem;
    }
  }
}
