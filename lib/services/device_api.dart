import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:bankid_app/config.dart';
import 'package:bankid_app/services/device_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔥 BACKGROUND PUSH RECEIVED");
  debugPrint("Message ID: ${message.messageId}");
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body: ${message.notification?.body}");
  debugPrint("Data: ${message.data}");
}

class DeviceApi {
  final DeviceService _deviceService = DeviceService();
  final String _baseUrl = AppConfig.baseUrl;
  final VoidCallback? onUnauthorized;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  static const String _storedTokenKey = 'fcm_push_token';

  DeviceApi({this.onUnauthorized});

  /// Initialize Push Notifications & Automatic Device Registration in Firebase
  Future<void> initializePushNotifications({required String authToken}) async {
    debugPrint("🚀 Initializing Push Notifications");

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions (iOS + Android 13+)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("🔔 Permission status: ${settings.authorizationStatus}");

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 FOREGROUND PUSH RECEIVED: ${message.notification?.title}");
    });

    // Notification tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("👆 USER TAPPED PUSH: ${message.notification?.title}");
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Ensure token is available
    String? token = await _getFcmTokenWithRetry();
    if (token != null) {
      debugPrint("📱 FCM TOKEN: $token");
      await _secureStorage.write(key: _storedTokenKey, value: token);

      // Register in backend AND automatically in Firebase
      await registerDevice(authToken: authToken);
    } else {
      debugPrint("❌ Failed to get FCM token after retries");
    }

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 FCM TOKEN REFRESHED: $newToken");
      await _secureStorage.write(key: _storedTokenKey, value: newToken);
      await registerDevice(authToken: authToken);
    });
  }

  /// Retry helper to ensure we get FCM token
  Future<String?> _getFcmTokenWithRetry({int maxRetries = 5}) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    int retry = 0;

    while (token == null && retry < maxRetries) {
      debugPrint("⏳ Waiting for FCM token... Retry ${retry + 1}");
      await Future.delayed(const Duration(seconds: 2));
      token = await messaging.getToken();
      retry++;
    }
    return token;
  }

  /// Register device with backend AND ensure FCM registration is active
  Future<void> registerDevice({required String authToken}) async {
    final deviceId = await _deviceService.getDeviceId();
    final pushToken = await FirebaseMessaging.instance.getToken(); // Ensure latest
    final appVersion = await _deviceService.getAppVersion();
    final deviceModel = await _deviceService.getDeviceModel();
    final deviceName = await _deviceService.getDeviceName();

    debugPrint("🚀 Registering device");
    debugPrint("Device ID: $deviceId, Push Token: $pushToken");

    if (pushToken == null) {
      debugPrint("⚠️ Push token is NULL, registration skipped");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/devices/register'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "device_id": deviceId,
          "device_name": deviceName,
          "platform": Platform.isAndroid ? "android" : "ios",
          "push_token": pushToken,
          "app_version": appVersion,
          "device_model": deviceModel,
        }),
      );

      debugPrint("📡 Backend register status: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Device registered successfully");
      } else if (response.statusCode == 401) {
        debugPrint("❌ Unauthorized during registration");
        onUnauthorized?.call();
      } else {
        debugPrint("⚠️ Unexpected response: ${response.body}");
      }
    } on SocketException {
      debugPrint("🌐 No internet connection during registration");
    } catch (e) {
      debugPrint("❌ Device registration error: $e");
    }
  }

  /// Get stored FCM token
  Future<String?> getStoredToken() async {
    final token = await _secureStorage.read(key: _storedTokenKey);
    debugPrint("🔐 Stored FCM Token: $token");
    return token;
  }
}