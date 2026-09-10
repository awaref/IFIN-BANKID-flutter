import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:bankid_app/config.dart';
import 'package:bankid_app/services/device_service.dart';
import 'package:bankid_app/core/utils/app_logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.log("🔥 BACKGROUND PUSH RECEIVED");
  AppLogger.log("Message ID: ${message.messageId}");
  AppLogger.log("Title: ${message.notification?.title}");
  AppLogger.log("Body: ${message.notification?.body}");
  AppLogger.log("Data: ${message.data}");
}

class DeviceApi {
  final DeviceService _deviceService = DeviceService();
  final String _baseUrl = AppConfig.baseUrl;
  final VoidCallback? onUnauthorized;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _storedTokenKey = 'fcm_push_token';

  DeviceApi({this.onUnauthorized});

  /// Initialize Push Notifications & Automatic Device Registration in Firebase
  Future<void> initializePushNotifications({required String authToken}) async {
    AppLogger.log("🚀 Initializing Push Notifications");

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.log("🔔 Permission status: ${settings.authorizationStatus}");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.log("📩 FOREGROUND PUSH RECEIVED: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.log("👆 USER TAPPED PUSH: ${message.notification?.title}");
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await _getFcmTokenWithRetry();
    if (token != null) {
      AppLogger.log("📱 FCM TOKEN: $token");
      await _secureStorage.write(key: _storedTokenKey, value: token);
    } else {
      AppLogger.log("❌ Failed to get FCM token after retries");
    }

    // Register even when FCM token is missing (required for QR device trust)
    await registerDevice(authToken: authToken);

    messaging.onTokenRefresh.listen((newToken) async {
      AppLogger.log("🔄 FCM TOKEN REFRESHED: $newToken");
      await _secureStorage.write(key: _storedTokenKey, value: newToken);
      await registerDevice(authToken: authToken);
    });
  }

  Future<String?> _getFcmTokenWithRetry({int maxRetries = 5}) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token;
    try {
      token = await messaging.getToken();
    } catch (e) {
      AppLogger.log("❌ Error getting FCM token: $e");
    }
    int retry = 0;

    while (token == null && retry < maxRetries) {
      AppLogger.log("⏳ Waiting for FCM token... Retry ${retry + 1}");
      await Future.delayed(const Duration(seconds: 2));
      try {
        token = await messaging.getToken();
      } catch (e) {
        AppLogger.log("❌ Error getting FCM token during retry: $e");
      }
      retry++;
    }
    return token;
  }

  /// Register / upsert device. Push token is optional — registration must
  /// succeed without FCM so QR scan can bind to a trusted device_id.
  Future<void> registerDevice({required String authToken}) async {
    final deviceId = await _deviceService.getDeviceId();
    String? pushToken;
    try {
      pushToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      AppLogger.log("❌ Error getting FCM token for registration: $e");
    }
    final appVersion = await _deviceService.getAppVersion();
    final deviceModel = await _deviceService.getDeviceModel();
    final deviceName = await _deviceService.getDeviceName();

    AppLogger.log("🚀 Registering device");
    AppLogger.log("Device ID length: ${deviceId.length}, Push Token present: ${pushToken != null}");

    if (pushToken == null) {
      AppLogger.log("⚠️ Push token is NULL — registering device without push_token");
    }

    try {
      final body = <String, dynamic>{
        "device_id": deviceId,
        "device_name": deviceName,
        "platform": Platform.isAndroid ? "android" : "ios",
        "app_version": appVersion,
        "device_model": deviceModel,
      };
      if (pushToken != null) {
        body["push_token"] = pushToken;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/devices/register'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      AppLogger.log("📡 Backend register status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.log("✅ Device registered successfully");
      } else if (response.statusCode == 401) {
        AppLogger.log("❌ Unauthorized during registration");
        onUnauthorized?.call();
      } else {
        AppLogger.log("⚠️ Unexpected register response: ${response.statusCode}");
      }
    } on SocketException {
      AppLogger.log("🌐 No internet connection during registration");
    } catch (e) {
      AppLogger.log("❌ Device registration error: $e");
    }
  }

  /// Mark this device as trusted after local PIN / biometric enrollment.
  Future<bool> trustDevice({required String authToken}) async {
    final deviceId = await _deviceService.getDeviceId();
    AppLogger.log("🔐 Trusting device (id length: ${deviceId.length})");

    try {
      final encodedId = Uri.encodeComponent(deviceId);
      final response = await http.post(
        Uri.parse('$_baseUrl/devices/$encodedId/trust'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      AppLogger.log("📡 Backend trust status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.log("✅ Device trusted successfully");
        return true;
      } else if (response.statusCode == 401) {
        AppLogger.log("❌ Unauthorized during trust");
        onUnauthorized?.call();
        return false;
      } else {
        AppLogger.log("⚠️ Unexpected trust response: ${response.statusCode}");
        return false;
      }
    } on SocketException {
      AppLogger.log("🌐 No internet connection during trust");
      return false;
    } catch (e) {
      AppLogger.log("❌ Device trust error: $e");
      return false;
    }
  }

  Future<String?> getStoredToken() async {
    final token = await _secureStorage.read(key: _storedTokenKey);
    AppLogger.log("🔐 Stored FCM Token present: ${token != null}");
    return token;
  }
}
