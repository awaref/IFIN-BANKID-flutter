import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bankid_app/screens/language_selection_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:bankid_app/screens/national_id_verification_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // ⏳ Show splash for 3 seconds, then check permission
    Timer(const Duration(seconds: 3), () {
      if (mounted) _requestNotificationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;

    return Directionality(
      textDirection: localeCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white, // 🔹 Brand/splash color
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)?.splashScreenLogo ?? "BankID",
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Navigate once (safe)
  void _navigateToLanguageScreen() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
    );
  }
  
  void _navigateToVerification() {
    if (_navigated || !mounted) return;
    _navigated = true;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NationalIdVerificationScreen()),
    );
  }
  
  Future<void> _determineStartScreen() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code');
    const supported = ['en', 'ar'];
    
    if (savedCode != null && supported.contains(savedCode)) {
      await languageProvider.changeLanguage(Locale(savedCode));
      _navigateToVerification();
    } else {
      await languageProvider.changeLanguage(const Locale('en'));
      _navigateToLanguageScreen();
    }
  }

  /// 🔹 Request system notification permission (Android 13+, iOS 12+)
  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.request();

      if (!mounted) return;

      if (status.isGranted) {
        debugPrint("✅ Notifications allowed");
      } else if (status.isPermanentlyDenied) {
        debugPrint("❌ Permanently denied → opening settings");
        await openAppSettings();
      } else {
        debugPrint("⚠️ Notifications denied temporarily");
      }
    }

    // 👉 Determine start based on stored language after permission request
    await _determineStartScreen();
  }
}
