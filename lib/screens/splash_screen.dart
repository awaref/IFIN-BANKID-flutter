import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/screens/national_id_verification_screen.dart';
import 'package:bankid_app/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

    // Notification permission is requested by NotificationService in main.dart.
    // Requesting it here races with FirebaseMessaging.requestPermission and can
    // hang forever ("Can request only one set of permissions at a time").
    _determineStartScreen();
  }

  @override
  void dispose() {
    // Ensure the flag is reset if we leave the splash screen unexpectedly
    try {
      Provider.of<ApiService>(context, listen: false).ignoreSessionExpired = false;
    } catch (_) {}
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
                  cacheWidth: (140.w * 3).toInt(), // 3x for density
                  cacheHeight: (140.w * 3).toInt(),
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

  // --- Language + auth check ---
  Future<void> _determineStartScreen() async {
    try {
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('language_code');
      const supported = ['en', 'ar'];

      if (savedCode != null && supported.contains(savedCode)) {
        await languageProvider.changeLanguage(Locale(savedCode));
      } else {
        await languageProvider.changeLanguage(const Locale('en'));
      }
      await _checkAuthentication().timeout(const Duration(seconds: 20));
    } catch (_) {
      _navigateToVerification();
    }
  }

  Future<void> _checkAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      // Set to true so that failing to refresh token here doesn't
      // trigger the app-wide pushAndRemoveUntil(SplashScreen).
      apiService.ignoreSessionExpired = true;

      // --- Step 1: biometric fast-path ---
      final canUseBiometric = await authProvider.canLoginWithBiometric();
      if (canUseBiometric) {
        final biometricSuccess = await authProvider
            .loginWithBiometric()
            .timeout(const Duration(seconds: 15), onTimeout: () => false);
        if (biometricSuccess) {
          apiService.ignoreSessionExpired = false;
          _navigateToHome();
          return;
        }
      }

      // --- Step 2: normal session/token ---
      final isAuthenticated = await authProvider.loadCurrentUser();
      apiService.ignoreSessionExpired = false;
      if (isAuthenticated) {
        _navigateToHome();
      } else {
        _navigateToVerification();
      }
    } catch (_) {
      apiService.ignoreSessionExpired = false;
      _navigateToVerification();
    }
  }
}
