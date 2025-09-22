import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bankid_app/screens/id_app_identity_screen.dart';
import 'package:hugeicons/hugeicons.dart' show HugeIcons, HugeIcon;
import 'package:pinput/pinput.dart';

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
    _secondsRemaining = 60;
    _isTimerExpired = false;
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Verification code.',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Color(0xFF212B36),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Verification code has been sent to',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6), // spacing between texts
                Text(
                  '+9** *** *** 999',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: const Color(0xFF212B36),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),
            Text(
              'Verification code',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Color(0xFF212B36),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Pinput(
                length: 6,
                controller: _codeController,
                onChanged: (value) {
                  // No explicit action needed here as _codeController is updated automatically
                },
                onCompleted: (pin) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const IdAppIdentityScreen(),
                    ),
                  );
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'You can resend the SMS within',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6), // spacing between texts
                Text(
                  '00:00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Color(0xFF212B36),
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
                onPressed: _isTimerExpired
                    ? () {
                        _startTimer();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isTimerExpired
                      ? Color(0xFF37C293)
                      : Color(0xFF919EAB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Retry Verification',
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
