import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:bankid_app/screens/home_screen.dart';
import 'package:bankid_app/screens/verify_pin_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class PinBiometricsScreen extends StatefulWidget {
  const PinBiometricsScreen({super.key});

  @override
  State<PinBiometricsScreen> createState() => _PinBiometricsScreenState();
}

class _PinBiometricsScreenState extends State<PinBiometricsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.appProtectionScanFingerprint,
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      // Handle error
    }
    
    if (authenticated && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // No leading/back button as this is usually a root screen or after splash
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.verifyIdentityTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.verifyIdentitySubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _buildProtectionOption(
              context,
              icon: HugeIcons.strokeRoundedFingerPrint,
              title: l10n.appProtectionUseBiometrics,
              subtitle: l10n.appProtectionUseSecureWay,
              isRecommended: true,
              onTap: _canCheckBiometrics ? _authenticate : null,
            ),
            const SizedBox(height: 8),
            _buildProtectionOption(
              context,
              icon: HugeIcons.strokeRoundedLock,
              title: l10n.passcode,
              subtitle: l10n.sixDigitPin,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VerifyPinScreen(
                      fromPinBiometrics: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionOption(
    BuildContext context, {
    required dynamic icon,
    required String title,
    required String subtitle,
    bool isRecommended = false,
    VoidCallback? onTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF37C293).withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(24),
              ),
              child: HugeIcon(
                icon: icon,
                size: 24,
                color: const Color(0xFF37C293),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  if (isRecommended) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD01F39).withAlpha((0.12 * 255).round()),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Text(
                        l10n.appProtectionRecommended,
                        style: const TextStyle(
                          color: Color(0xFFD01F39),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF637381),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
