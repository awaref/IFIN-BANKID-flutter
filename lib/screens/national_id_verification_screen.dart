import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/screens/onboarding_screens.dart';
import 'package:bankid_app/screens/pin_biometrics_screen.dart';

class NationalIdVerificationScreen extends StatefulWidget {
  const NationalIdVerificationScreen({super.key});

  @override
  State<NationalIdVerificationScreen> createState() => _NationalIdVerificationScreenState();
}

class _NationalIdVerificationScreenState extends State<NationalIdVerificationScreen> {
  final TextEditingController _idController = TextEditingController();
  
  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final nationalId = _idController.text.trim();
    if (nationalId.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter your National ID')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final exists = await authProvider.checkNationalId(nationalId);

    if (!mounted) return;

    if (exists) {
      navigator.push(
        MaterialPageRoute(builder: (_) => const PinBiometricsScreen()),
      );
    } else {
      if (authProvider.status == AuthStatus.error) {
        messenger.showSnackBar(
           SnackBar(content: Text(authProvider.errorMessage ?? 'An error occurred')),
        );
      } else {
        // ID not found -> Navigate to existing onboarding flow
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingFlow()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              l10n?.nationalIdScreenTitle ?? 'Start with your National ID number.',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 62),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    l10n?.nationalIdNumberLabel ?? 'National ID Number',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _idController,
                    decoration:  InputDecoration(
                      hintText: l10n?.nationalIdNumberHint ?? 'Enter your ID',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: authProvider.status != AuthStatus.loading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.status == AuthStatus.loading
                    ? null
                    : () => _submit(context),
                child: authProvider.status == AuthStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
