// notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bankid_app/firebase_options.dart';
import 'package:bankid_app/screens/contract_screen.dart';
import 'package:bankid_app/core/utils/app_logger.dart';

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase messaging, permissions, and local notifications
  Future<void> initialize() async {
    // 1. Initialize Firebase (Redundant if done in main.dart, but good for standalone use)
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 2. Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.log('User granted permission: ${settings.authorizationStatus}');

    // 3. Initialize local notifications
    final AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    final InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: (response) {
      // Navigate if payload exists
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        _navigateToContract(payload);
      }
    });

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.log('📩 Foreground push received!');
      AppLogger.log('Data: ${message.data}');
      final title = message.notification?.title ?? "Notification";
      final body = message.notification?.body ?? "";

      // Show local notification
      await _localNotifications.show(
        0,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'bankid_channel',
            'BankID Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: message.data['contract_id'] ?? '',
      );
    });

    // 5. Handle background/tapped messages (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.log('📩 Push tapped (background)!');
      _handleMessage(message);
    });

    // 6. Handle app opened from terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.log('📩 Push opened app from terminated state!');
      _handleMessage(initialMessage);
    }

    // 7. Get FCM token (with error handling for FIS_AUTH_ERROR)
    try {
      final token = await _messaging.getToken();
      AppLogger.log('FCM Token: $token');
    } catch (e) {
      AppLogger.log('❌ Error getting FCM token: $e');
      AppLogger.log(
          '💡 Check if "Firebase Installations API" is enabled in Google Cloud Console.');
    }
  }

  /// Handle push message navigation
  void _handleMessage(RemoteMessage message) {
    final type = message.data['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'new_contract':
      case 'contract_signed':
      case 'contract_rejected':
      case 'contract_expired':
        final contractId = message.data['contract_id'] as String?;
        if (contractId != null) {
          _navigateToContract(contractId);
        }
        break;
      case 'qr_approved':
      case 'qr_rejected':
        final sessionId = message.data['session_id'] as String?;
        AppLogger.log('QR session result received: $sessionId for type $type');
        break;
      default:
        AppLogger.log('Unknown push type: $type');
        break;
    }
  }

  /// Navigate to contract screen using navigator key
  void _navigateToContract(String contractId) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => ContractScreen(contractId: contractId),
      ),
    );
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.log("📩 Handling background message: ${message.messageId}");
}
