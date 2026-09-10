import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceService {
  static const String _deviceIdKey = 'device_id';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Returns a stable device id persisted in secure storage.
  /// Migrates once from SharedPreferences if a legacy value exists.
  Future<String> getDeviceId() async {
    final secureId = await _secureStorage.read(key: _deviceIdKey);
    if (secureId != null && secureId.isNotEmpty) {
      return secureId;
    }

    final prefs = await SharedPreferences.getInstance();
    final legacyId = prefs.getString(_deviceIdKey);
    if (legacyId != null && legacyId.isNotEmpty) {
      await _secureStorage.write(key: _deviceIdKey, value: legacyId);
      await prefs.remove(_deviceIdKey);
      return legacyId;
    }

    final deviceInfo = DeviceInfoPlugin();
    String deviceId;
    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      deviceId = android.id;
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor ?? '';
    } else {
      deviceId = 'unknown_device';
    }

    if (deviceId.isEmpty) {
      deviceId = 'unknown_device';
    }

    await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    return deviceId;
  }

  Future<String?> getFcmToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model;
    }
    return 'Unknown Device';
  }

  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return 'Unknown Device Name';
  }

  Future<String> getOsVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    }
    return 'Unknown';
  }

  Future<String> getDeviceFingerprint() async {
    final deviceId = await getDeviceId();
    final deviceModel = await getDeviceModel();
    return '${deviceId}_$deviceModel'.replaceAll(RegExp(r'\s+'), '_');
  }
}
