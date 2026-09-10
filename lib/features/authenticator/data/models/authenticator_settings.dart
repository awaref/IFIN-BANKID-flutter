enum AppLockTimeout { never, onLaunch, after1Min, after5Min }

enum AuthenticatorThemeMode { light, dark, system }

class AuthenticatorSettings {
  const AuthenticatorSettings({
    this.appLockTimeout = AppLockTimeout.never,
    this.clipboardClearSeconds = 30,
    this.themeMode = AuthenticatorThemeMode.system,
    this.lastBackgroundedMs = 0,
  });

  final AppLockTimeout appLockTimeout;
  final int clipboardClearSeconds;
  final AuthenticatorThemeMode themeMode;
  final int lastBackgroundedMs;

  AuthenticatorSettings copyWith({
    AppLockTimeout? appLockTimeout,
    int? clipboardClearSeconds,
    AuthenticatorThemeMode? themeMode,
    int? lastBackgroundedMs,
  }) {
    return AuthenticatorSettings(
      appLockTimeout: appLockTimeout ?? this.appLockTimeout,
      clipboardClearSeconds: clipboardClearSeconds ?? this.clipboardClearSeconds,
      themeMode: themeMode ?? this.themeMode,
      lastBackgroundedMs: lastBackgroundedMs ?? this.lastBackgroundedMs,
    );
  }

  Duration? get lockTimeoutDuration {
    switch (appLockTimeout) {
      case AppLockTimeout.never:
        return null;
      case AppLockTimeout.onLaunch:
        return Duration.zero;
      case AppLockTimeout.after1Min:
        return const Duration(minutes: 1);
      case AppLockTimeout.after5Min:
        return const Duration(minutes: 5);
    }
  }
}
