import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bankid_app/screens/id_app_identity_screen.dart';
import 'package:hugeicons/hugeicons.dart' show HugeIcons, HugeIcon;
import 'package:pinput/pinput.dart';
import 'package:bankid_app/l10n/app_localizations.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isTimerExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _isTimerExpired = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _isTimerExpired = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<bool> _verifyCode(String pin) async {
    // TODO: Replace with your API verification
    await Future.delayed(const Duration(milliseconds: 500));
    return pin == "123456"; // mock validation
  }

  void _resendCode() {
    // TODO: Implement backend resend SMS API
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.enterVerificationCode,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xFF212B36),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.verificationCodeSentTo,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                  ),
                  TextSpan(
                    text: '+9** *** *** 999',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: const Color(0xFF212B36),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 70),
            Text(
              AppLocalizations.of(context)!.verificationCode,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xFF212B36),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Pinput(
                length: 6,
                controller: _codeController,
                onCompleted: (pin) async {
                  final isValid = await _verifyCode(pin);
                  if (isValid && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const IdAppIdentityScreen(),
                      ),
                    );
                  } else {
                    setState(() {
                      _codeController.clear();
                    });
                  }
                },
                defaultPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  textStyle: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                focusedPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  textStyle: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                submittedPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  textStyle: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                errorPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                      width: 2,
                    ),
                  ),
                  textStyle: Theme.of(context).textTheme.headlineSmall!
                      .copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.resendSmsWithin,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedTime,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: const Color(0xFF212B36),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isTimerExpired ? _resendCode : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      _isTimerExpired ? const Color(0xFF37C293) : const Color(0xFF919EAB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.retryVerification,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
