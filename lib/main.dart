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
import 'package:bankid_app/repositories/device_repository.dart';
import 'package:bankid_app/services/notification_service.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔥 BACKGROUND PUSH RECEIVED");
  debugPrint("Message ID: ${message.messageId}");
  debugPrint("Title: ${message.notification?.title}");
  debugPrint("Body: ${message.notification?.body}");
  debugPrint("Data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize API & Repositories
  final apiService = ApiService(baseUrl: AppConfig.baseUrl);
  final authRepository = AuthRepository(apiService: apiService);
  final signatureService = SignatureService(apiService: apiService);

  // Callback for unauthorized responses
  void onUnauthorizedCallback() {
    authRepository.deleteToken();
  }

  final deviceApi = DeviceApi(onUnauthorized: onUnauthorizedCallback);
  final deviceRepository = DeviceRepository(deviceApi: deviceApi);

  // Setup Firebase background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // Register device automatically once user is logged in
  final storedAuthToken = await authRepository.getToken();
  if (storedAuthToken != null) {
    await deviceRepository.registerDevice(authToken: storedAuthToken);
  }

  // Listen for token refresh and re-register in Firebase
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint("🔄 FCM Token refreshed: $newToken");
    final storedAuthToken = await authRepository.getToken();
    if (storedAuthToken != null) {
      await deviceRepository.registerDevice(authToken: storedAuthToken);
    }
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    final notificationService = Provider.of<NotificationService>(context);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
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
          builder: (context, child) {
            return Directionality(
              textDirection: Localizations.localeOf(context).languageCode == 'ar'
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