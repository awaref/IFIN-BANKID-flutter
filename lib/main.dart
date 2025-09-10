import 'package:flutter/material.dart';
import 'package:bankid_app/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BankID App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2ECC71),
          primary: const Color(0xFF2ECC71),
        ),
        primaryColor: const Color(0xFF2ECC71),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
