import 'package:flutter/material.dart';
import 'package:bankid_app/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:bankid_app/providers/signature_provider.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/services/auth_repository.dart';
import 'package:bankid_app/services/signature_service.dart';
import 'package:bankid_app/config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bankid_app/firebase_options.dart';
import 'package:bankid_app/services/device_api.dart';
import 'package:bankid_app/repositories/device_repository.dart'; // Import DeviceApi

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission for notifications
  NotificationSettings settings = await FirebaseMessaging.instance
      .requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
        'Message also contained a notification: ${message.notification}',
      );
    }
  });

  // Listen for token refreshes
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint("FCM Token refreshed: $newToken");
    final apiService = ApiService(baseUrl: AppConfig.baseUrl);
    final storedAuthToken = await apiService.getPublicToken();
    if (storedAuthToken != null) {
      await DeviceApi().registerDevice(authToken: storedAuthToken);
    } else {
      debugPrint(
        "No stored auth token found, skipping device registration on token refresh.",
      );
    }
  });

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final apiService = ApiService(baseUrl: AppConfig.baseUrl);
  final authRepository = AuthRepository(apiService: apiService);
  final signatureService = SignatureService(apiService: apiService);

  // Define the onUnauthorized callback
  void onUnauthorizedCallback() {
    authRepository.deleteToken(); // This will clear the token
    // Optionally, navigate to login screen or show a message
  }

  final deviceApi = DeviceApi(onUnauthorized: onUnauthorizedCallback);
  final deviceRepository = DeviceRepository(deviceApi: deviceApi);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(deviceRepository, authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SignatureProvider(signatureService: signatureService)..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'BankID App',
          debugShowCheckedModeBanner: false,
          // Localization support
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
          // Use the current locale from the provider
          locale: languageProvider.currentLocale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF37C293),
              primary: const Color(0xFF37C293),
            ),
            primaryColor: const Color(0xFF37C293),
            scaffoldBackgroundColor: Colors.white,
            textTheme: GoogleFonts.rubikTextTheme(),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37C293),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF37C293),
                side: const BorderSide(color: Color(0xFF37C293)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
          // Enable RTL text direction based on locale
          builder: (context, child) {
            return Directionality(
              textDirection:
                  Localizations.localeOf(context).languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
        );
      },
    );
  }
}
