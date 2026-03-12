// notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bankid_app/firebase_options.dart';
import 'package:bankid_app/screens/contract_screen.dart';

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
    // 1. Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // 2. Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');

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
      debugPrint('📩 Foreground push received!');
      debugPrint('Data: ${message.data}');
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
      debugPrint('📩 Push tapped (background)!');
      _handleMessage(message);
    });

    // 6. Handle app opened from terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📩 Push opened app from terminated state!');
      _handleMessage(initialMessage);
    }

    // Optional: print current FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
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
        debugPrint('QR session result received: $sessionId for type $type');
        break;
      default:
        debugPrint('Unknown push type: $type');
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
  debugPrint("📩 Handling background message: ${message.messageId}");
}