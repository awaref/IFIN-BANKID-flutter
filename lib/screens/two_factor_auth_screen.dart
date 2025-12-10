import 'package:bankid_app/screens/enable_two_factor_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TwoFactorAuthScreen(),
    );
  }
}

class TwoFactorAuthScreen extends StatelessWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D1F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.twoFactorAuthTitle,
          style: const TextStyle(
            color: Color(0xFF1A1D1F),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFEAEAEA),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 134),
              // Asterisks box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11.64, vertical: 8.32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF212B36),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(6.65),
                ),
                child: const Text(
                  '✱✱✱✱✱✱',
                  style: TextStyle(
                    color: Color(0xFF37C293),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                l10n.twoFactorAuthTitle,
                style: const TextStyle(
                  color: Color(0xFF1A1D1F),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                l10n.twoFactorAuthDescription,
                style: const TextStyle(
                  color: Color(0xFF6F767E),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n.twoFactorAuthExplanation,
                  style: const TextStyle(
                    color: Color(0xFF6F767E),
                    fontSize: 13,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              // Enable button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EnableTwoFactorAuthScreen(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37C293),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.enableTwoFactorAuthButton,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
