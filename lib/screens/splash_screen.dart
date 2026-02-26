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
import 'package:bankid_app/screens/home_screen.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;
  bool _isLoading = true; // Added for loading indicator

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;

    return Directionality(
      textDirection: localeCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white, // 🔹 Brand/splash color
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator() // Show loading indicator
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.splashScreenLogo ?? "BankID",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 40.sp,
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
  
  void _navigateToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
  
  Future<void> _determineStartScreen() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code');
    const supported = ['en', 'ar'];
    
    if (savedCode != null && supported.contains(savedCode)) {
      await languageProvider.changeLanguage(Locale(savedCode));
    } else {
      await languageProvider.changeLanguage(const Locale('en'));
    }
    await _checkAuthentication(); // Always check authentication after language is set
  }

  /// 🔹 Request system notification permission (Android 13+, iOS 12+)
  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.request();

      if (!mounted) return;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }

    // 👉 Determine start based on stored language after permission request
    await _determineStartScreen();
  }

  Future<void> _checkAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });
      final isAuthenticated = await authProvider.loadCurrentUser();
      if (isAuthenticated) {
        _navigateToHome();
      } else {
        _navigateToVerification();
      }
    } catch (e) {
      _navigateToVerification();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
