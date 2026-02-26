# Flutter App: Push Notifications Setup (Step by Step)

This guide covers what to do in the Flutter app so it receives and handles push notifications from the IFIN-BANKID backend (FCM), including contract and QR login notifications.

---

## 1. Add Dependencies

In your Flutter app's `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  # Optional, for when user taps notification and you need to open a specific screen:
  go_router: ^14.2.0  # or your existing router
```

Then run:

```bash
flutter pub get
```

---

## 2. Connect the App to the Same Firebase Project

- Use the **same** Firebase project as the one whose service account JSON is in `storage/app/firebase-credentials.json` (backend).
- In the Flutter project root, run:
  ```bash
  dart run flutterfire configure
  ```
- Pick that project and let it create/update `lib/firebase_options.dart` and native configs (Android `google-services.json`, iOS `GoogleService-Info.plugin`).

---

## 3. Initialize Firebase and Request Permission

In `main.dart` (or before `runApp`):

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
```

Request FCM permission (needed on iOS, harmless on Android):

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

final messaging = FirebaseMessaging.instance;
await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);
```

---

## 4. Get the FCM Token and Send It to Your Backend

After the user is logged in, get the token and register/update the device with your API (same as your backend expects for push):

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getFcmTokenAndRegisterDevice() async {
  final messaging = FirebaseMessaging.instance;

  // Optional: only if you use multiple projects
  // final token = await messaging.getToken(vapidKey: 'your-web-key');

  final token = await messaging.getToken();
  if (token == null) return null;

  // Call your backend: POST /api/v1/devices (or register/update device endpoint)
  // with push_token in the body. Use your existing auth (Bearer token).
  final response = await http.post(
    Uri.parse('https://your-api.com/api/v1/devices'),
    headers: {
      'Authorization': 'Bearer $yourAuthToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'device_id': 'unique-device-id', // e.g. from device_info_plus
      'device_name': 'iPhone 15',
      'platform': Platform.isIOS ? 'ios' : 'android',
      'push_token': token,
      // ... other fields your API expects
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return token;
  }
  return null;
}
```

- Call this after login (and optionally on app startup if the user is already logged in).
- When the token refreshes (see step 6), call the same endpoint again with the new `push_token`.

---

## 5. Handle Incoming Notifications (Foreground / Background / Terminated)

Define a **top-level** handler (outside any class) for **background/terminated** messages:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Optional: log or persist message for when user opens app
  debugPrint('Background: ${message.notification?.title}');
}
```

In `main()` (after `Firebase.initializeApp`):

```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

Then set up listeners:

```dart
void setupPushListeners() {
  final messaging = FirebaseMessaging.instance;

  // When app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    // Show in-app banner/snackbar or ignore (user sees it in tray when in background)
    showInAppNotification(title, body);
  });

  // When user taps notification (app was in background or terminated)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationTap(message.data);
  });

  // If app was terminated and opened by tapping a notification
  messaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      handleNotificationTap(message.data);
    }
  });
}
```

Implement `handleNotificationTap` using the same `data` map your backend sends (see step 7).

---

## 6. Refresh Token and Update Backend

FCM tokens can change. Listen for token refresh and update your backend:

```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  await updateDevicePushTokenOnBackend(newToken);
});
```

`updateDevicePushTokenOnBackend` should call the same device registration/update endpoint with the new `push_token`.

---

## 7. Handle Notification Data (Deep Link by Type)

Your backend sends a `data` payload with `type` and ids. Use that to open the right screen:

```dart
void handleNotificationTap(Map<String, dynamic> data) {
  final type = data['type'] as String?;
  if (type == null) return;

  switch (type) {
    case 'new_contract':
    case 'contract_signed':
    case 'contract_rejected':
    case 'contract_expired':
      final contractId = data['contract_id'] as String?;
      if (contractId != null) {
        navigatorKey.currentState?.pushNamed('/contracts/$contractId');
      }
      break;
    case 'qr_approved':
    case 'qr_rejected':
      final sessionId = data['session_id'] as String?;
      // e.g. show a "Login approved" / "Login rejected" screen or go home
      navigatorKey.currentState?.pushNamed('/qr-result', arguments: {'session_id': sessionId, 'approved': type == 'qr_approved'});
      break;
    default:
      break;
  }
}
```

Adjust route names and arguments to match your app (e.g. GoRouter routes, contract detail screen, QR result screen).

---

## 8. Platform-Specific Setup

### Android

- In `android/app/build.gradle`, ensure `minSdkVersion` is at least 21.
- FCM works with the default `google-services` setup from `flutterfire configure`.

### iOS

- Enable Push Notifications: Xcode → app target → **Signing & Capabilities** → **+ Capability** → **Push Notifications**.
- Upload APNs key (or certificate) in Firebase Console → Project Settings → Cloud Messaging → Apple app config.
- Request permission at runtime (step 3).

---

## 9. When to Register the Device

- **Right after successful login:** get FCM token and call `POST /api/v1/devices` with `push_token`.
- **On app startup:** if the user is already logged in, get token and update the same endpoint (so the backend always has the latest token).
- **On token refresh:** in `onTokenRefresh`, call the same endpoint with the new token.

---

## 10. Quick Checklist

| Step | Action |
|------|--------|
| 1 | Add `firebase_core`, `firebase_messaging` (and router if needed). |
| 2 | Run `dart run flutterfire configure` with the same Firebase project as the backend. |
| 3 | `Firebase.initializeApp()` and request notification permission. |
| 4 | Get FCM token and send it to backend as `push_token` in device registration/update. |
| 5 | Set `onBackgroundMessage`, `onMessage`, `onMessageOpenedApp`, `getInitialMessage`. |
| 6 | On token refresh, update device `push_token` on backend. |
| 7 | In tap handler, read `data['type']` and `contract_id` / `session_id`, then navigate. |
| 8 | iOS: Push capability + APNs in Firebase; Android: minSdk 21 + google-services. |

---

## Backend Payload Reference

All push payloads use string values and include:

- **`type`**: `new_contract` \| `contract_signed` \| `contract_rejected` \| `contract_expired` \| `qr_approved` \| `qr_rejected`
- **`contract_id`**: present for contract-related types
- **`session_id`**: present for `qr_approved` / `qr_rejected`

Use these in `handleNotificationTap` to route the user to the correct screen.
