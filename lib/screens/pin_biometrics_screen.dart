import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
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
  bool _isDeviceSupported = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    bool isDeviceSupported;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      isDeviceSupported = await auth.isDeviceSupported();
    } catch (e) {
      canCheckBiometrics = false;
      isDeviceSupported = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      _isDeviceSupported = isDeviceSupported;
    });

    // Auto-trigger authentication if possible
    if (_canCheckBiometrics || _isDeviceSupported) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      
      String localizedReason = l10n.appProtectionScanFingerprint;
      if (availableBiometrics.contains(BiometricType.face)) {
        localizedReason = l10n.appProtectionScanFace;
      }

      final bool authenticated = await auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: const [
          AndroidAuthMessages(),
          IOSAuthMessages(),
        ],
      );

      if (authenticated && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled') {
        _showErrorSnackBar(l10n.biometricsNotEnrolled);
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        _showErrorSnackBar(l10n.biometricsLockedOut);
      } else if (e.code == 'NotAvailable') {
        _showErrorSnackBar(l10n.biometricsNotSupported);
      } else {
        _showErrorSnackBar('${l10n.authenticationError} ${e.message}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC3545),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
              onTap: (_canCheckBiometrics || _isDeviceSupported) ? _authenticate : null,
            ),
            const SizedBox(height: 16),
            _buildProtectionOption(
              context,
              icon: HugeIcons.strokeRoundedCirclePassword,
              title: l10n.usePinInstead,
              subtitle: l10n.appProtectionCreatePin,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VerifyPinScreen(fromPinBiometrics: true),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRecommended ? const Color(0xFF37C293) : const Color(0xFFE0E0E0),
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: icon,
              color: isRecommended ? const Color(0xFF37C293) : Colors.black,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRecommended)
                    Text(
                      AppLocalizations.of(context)!.appProtectionRecommended,
                      style: const TextStyle(
                        color: Color(0xFF37C293),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF637381),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF637381)),
          ],
        ),
      ),
    );
  }
}
