import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bankid_app/screens/language_selection_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

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
      if (mounted) {
        _requestNotificationPermission();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Ensure proper text direction based on locale
          textDirection: Localizations.localeOf(context).languageCode == 'ar' 
              ? TextDirection.rtl 
              : TextDirection.ltr,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 100,
              width: 100,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.splashScreenLogo ?? "Logo",
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                 fontSize: 40.49,
                 fontWeight: FontWeight.w700,
                 color: Colors.white,
                 height: 1.6,
                 letterSpacing: 0.0,
               ),
            ),
          ],
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

  /// 🔹 Request system notification permission
  Future<void> _requestNotificationPermission() async {
    // Request notification permission using system dialog
    final status = await Permission.notification.request();
    
    if (!mounted) return;
    
    // Log permission status
    if (status.isGranted) {
      debugPrint("✅ Notifications allowed");
    } else if (status.isPermanentlyDenied) {
      debugPrint("❌ Permanently denied → opening settings");
      await openAppSettings();
    } else {
      debugPrint("⚠️ Denied (temporary)");
    }
    
    // 👉 Navigate to language screen after permission request
    _navigateToLanguageScreen();
  }
  

}
