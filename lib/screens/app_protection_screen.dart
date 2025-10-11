import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:bankid_app/screens/setup_passcode_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class AppProtectionScreen extends StatefulWidget {
  const AppProtectionScreen({super.key});

  @override
  State<AppProtectionScreen> createState() => _AppProtectionScreenState();
}

class _AppProtectionScreenState extends State<AppProtectionScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool _isBiometricSupported = false;
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
      print("Error checking biometrics: $e");
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
      print("Error authenticating: $e");
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });

    if (authenticated) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SetupPasscodeScreen()),
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
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appProtectionActivateProtection,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appProtectionChooseOption,
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
              title: l10n.appProtectionSetUpPasscode,
              subtitle: l10n.appProtectionCreatePin,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SetupPasscodeScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 64),
              child: ElevatedButton(
                onPressed: () {
                  // Handle continue button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37C293),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.appProtectionContinue,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
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
                color: const Color(0xFF37C293).withOpacity(0.1),
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
                        color: const Color(0xFFD01F39).withOpacity(0.12),
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
