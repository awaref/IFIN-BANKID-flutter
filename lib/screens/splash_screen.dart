import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/screens/national_id_verification_screen.dart';
import 'package:bankid_app/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bankid_app/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _navigated = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // --- Animation ---
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // --- Start flow ---
    _requestNotificationPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;

    return Directionality(
      textDirection: localeCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/bankid_logo.png",
                  width: 140.w,
                  height: 140.w,
                ),
                SizedBox(height: 40.h),
                const CircularProgressIndicator(color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Navigation ---
  void _navigateToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _navigateToVerification() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NationalIdVerificationScreen()),
    );
  }

  // --- Permissions ---
  Future<void> _requestNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.request();
      if (!mounted) return;
      if (status.isPermanentlyDenied) await openAppSettings();
    }
    await _determineStartScreen();
  }

  // --- Language + auth check ---
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
    await _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // --- Step 1: biometric fast-path ---
      final canUseBiometric = await authProvider.canLoginWithBiometric();
      if (canUseBiometric) {
        final biometricSuccess = await authProvider.loginWithBiometric();
        if (biometricSuccess) {
          _navigateToHome();
          return;
        }
      }

      // --- Step 2: normal session/token ---
      final isAuthenticated = await authProvider.loadCurrentUser();
      if (isAuthenticated) {
        _navigateToHome();
      } else {
        _navigateToVerification();
      }
    } catch (_) {
      _navigateToVerification();
    }
  }
}