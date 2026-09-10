import 'package:flutter/services.dart';

class SecureFlagService {
  static const MethodChannel _channel =
      MethodChannel('com.example.bankid_app/secure_flag');

  Future<void> enableSecureFlag() async {
    try {
      await _channel.invokeMethod<void>('setSecureFlag');
    } on PlatformException {
      // Ignore on unsupported platforms.
    }
  }

  Future<void> disableSecureFlag() async {
    try {
      await _channel.invokeMethod<void>('clearSecureFlag');
    } on PlatformException {
      // Ignore on unsupported platforms.
    }
  }
}
