import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/screens/onboarding_screens.dart';
import 'package:bankid_app/screens/pin_biometrics_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    
    // Always store ID in Provider first
    authProvider.setNationalId(nationalId);
    
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
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                l10n?.nationalIdScreenTitle ?? 'Start with your National ID number.',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 62.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        l10n?.nationalIdNumberLabel ?? 'National ID Number',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _idController,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: InputDecoration(
                          hintText: l10n?.nationalIdNumberHint ?? 'Enter your ID',
                          hintStyle: TextStyle(fontSize: 16.sp),
                          border: const OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: authProvider.status != AuthStatus.loading,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.status == AuthStatus.loading
                      ? null
                      : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: authProvider.status == AuthStatus.loading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Verify',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
