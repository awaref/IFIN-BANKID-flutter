import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/authenticator_settings.dart';

class AuthenticatorSettingsProvider extends ChangeNotifier {
  AuthenticatorSettingsProvider({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  AuthenticatorSettings _settings = const AuthenticatorSettings();
  bool _isLocked = false;

  AuthenticatorSettings get settings => _settings;
  bool get isLocked => _isLocked;

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final timeoutName =
        _prefs!.getString('authenticator_app_lock_timeout') ?? 'never';
    final clipboardSeconds =
        _prefs!.getInt('authenticator_clipboard_clear_seconds') ?? 30;
    final themeName = _prefs!.getString('authenticator_theme_mode') ?? 'system';
    final lastBackgrounded =
        _prefs!.getInt('authenticator_last_backgrounded') ?? 0;

    _settings = AuthenticatorSettings(
      appLockTimeout: AppLockTimeout.values.firstWhere(
        (value) => value.name == timeoutName,
        orElse: () => AppLockTimeout.never,
      ),
      clipboardClearSeconds: clipboardSeconds,
      themeMode: AuthenticatorThemeMode.values.firstWhere(
        (value) => value.name == themeName,
        orElse: () => AuthenticatorThemeMode.system,
      ),
      lastBackgroundedMs: lastBackgrounded,
    );
    notifyListeners();
  }

  Future<void> setAppLockTimeout(AppLockTimeout timeout) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('authenticator_app_lock_timeout', timeout.name);
    _settings = _settings.copyWith(appLockTimeout: timeout);
    notifyListeners();
  }

  Future<void> setClipboardClearSeconds(int seconds) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt('authenticator_clipboard_clear_seconds', seconds);
    _settings = _settings.copyWith(clipboardClearSeconds: seconds);
    notifyListeners();
  }

  Future<void> setThemeMode(AuthenticatorThemeMode mode) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('authenticator_theme_mode', mode.name);
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
  }

  Future<void> recordBackgrounded() async {
    _prefs ??= await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs!.setInt('authenticator_last_backgrounded', now);
    _settings = _settings.copyWith(lastBackgroundedMs: now);
    notifyListeners();
  }

  bool shouldLockOnResume() {
    final duration = _settings.lockTimeoutDuration;
    if (duration == null) {
      return false;
    }
    if (duration == Duration.zero) {
      return true;
    }
    if (_settings.lastBackgroundedMs <= 0) {
      return false;
    }
    final elapsed = DateTime.now().millisecondsSinceEpoch -
        _settings.lastBackgroundedMs;
    return elapsed >= duration.inMilliseconds;
  }

  void lock() {
    _isLocked = true;
    notifyListeners();
  }

  void unlock() {
    _isLocked = false;
    notifyListeners();
  }

  ThemeMode get materialThemeMode {
    switch (_settings.themeMode) {
      case AuthenticatorThemeMode.light:
        return ThemeMode.light;
      case AuthenticatorThemeMode.dark:
        return ThemeMode.dark;
      case AuthenticatorThemeMode.system:
        return ThemeMode.system;
    }
  }
}
