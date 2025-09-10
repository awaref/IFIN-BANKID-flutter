import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bankid_app/screens/language_selection_screen.dart';

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
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              "Logo",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
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
    // Show custom permission dialog first
    await _showNotificationPermissionDialog();
    
    if (!mounted) return;
    
    // 👉 Navigate to language screen after user responds
    _navigateToLanguageScreen();
  }
  
  /// 🔹 Show custom notification permission dialog
  Future<void> _showNotificationPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 32,
                    color: Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                const Text(
                  'Allow app to send you notifications?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                const Text(
                  'Stay informed about your account activity and important security updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    // Don't allow button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          debugPrint("⚠️ Notifications denied");
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Don't allow",
                          style: TextStyle(color: Color(0xFF7F8C8D), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Allow button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final status = await Permission.notification.request();
                          
                          if (!mounted) return;
                          
                          if (status.isGranted) {
                            debugPrint("✅ Notifications allowed");
                          } else if (status.isPermanentlyDenied) {
                            debugPrint("❌ Permanently denied → opening settings");
                            await openAppSettings();
                          } else {
                            debugPrint("⚠️ Denied (temporary)");
                          }
                        },
                        child: const Text("Allow"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
