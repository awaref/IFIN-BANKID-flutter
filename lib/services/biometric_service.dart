import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricKey = 'biometric_enabled';

  Future<bool> isBiometricEnabledByUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to false so user has to explicitly enable it in Settings
    return prefs.getBool(_biometricKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }

  /// Returns true if the device supports biometrics AND has them enrolled.
  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _auth.canCheckBiometrics;
      return canCheck;
    } on LocalAuthException {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on LocalAuthException {
      return [];
    }
  }

  /// Shows the system biometric prompt. Returns true on success.
  /// Falls back to PIN/pattern/passcode if [biometricOnly] is false (default).
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      // e.code: noBiometricHardware, biometricLockout, temporaryLockout, etc.
      return false;
    }
  }

  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}
