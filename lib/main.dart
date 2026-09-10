import 'package:flutter/material.dart';
import 'package:bankid_app/screens/splash_screen.dart';
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
import 'package:bankid_app/repositories/device_repository.dart';
import 'package:bankid_app/services/notification_service.dart';
import 'package:bankid_app/core/utils/app_logger.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  AppLogger.log("🔥 BACKGROUND PUSH RECEIVED");
  AppLogger.log("Message ID: ${message.messageId}");
  AppLogger.log("Title: ${message.notification?.title}");
  AppLogger.log("Body: ${message.notification?.body}");
  AppLogger.log("Data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();

  // Initialize API & Repositories
  late final AuthRepository authRepository;
  final apiService = ApiService(
    baseUrl: AppConfig.baseUrl,
    onSessionExpired: () {
      AppLogger.log("🚨 Session expired! Navigating to SplashScreen...");
      authRepository.deleteToken();
      notificationService.navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    },
  );
  authRepository = AuthRepository(apiService: apiService);
  final signatureService = SignatureService(apiService: apiService);

  // Callback for unauthorized responses
  void onUnauthorizedCallback() {
    authRepository.deleteToken();
  }

  final deviceApi = DeviceApi(onUnauthorized: onUnauthorizedCallback);
  final deviceRepository = DeviceRepository(deviceApi: deviceApi);

  // Setup Firebase background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // Defer non-critical startup work until after the first frame to improve TTFF
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await notificationService.initialize();

    final storedAuthToken = await authRepository.getToken();
    if (storedAuthToken != null) {
      await deviceRepository.registerDevice(authToken: storedAuthToken);
    }

    // Listen for token refresh and re-register in Firebase
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      AppLogger.log("🔄 FCM Token refreshed: $newToken");
      final storedAuthToken = await authRepository.getToken();
      if (storedAuthToken != null) {
        await deviceRepository.registerDevice(authToken: storedAuthToken);
      }
    });
  });

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
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final notificationService =
            Provider.of<NotificationService>(context, listen: false);

        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return MaterialApp(
              navigatorKey: notificationService.navigatorKey,
              title: 'BankID App',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              locale: languageProvider.currentLocale,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF37C293),
                  primary: const Color(0xFF37C293),
                ),
                primaryColor: const Color(0xFF37C293),
                scaffoldBackgroundColor: Colors.white,
                fontFamily: 'Rubik',
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
      },
    );
  }
}
