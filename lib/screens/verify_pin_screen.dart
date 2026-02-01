import 'package:bankid_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const VerifyPinScreen(),
    );
  }
}

class VerifyPinScreen extends StatefulWidget {
  final bool fromPinBiometrics;

  const VerifyPinScreen({
    super.key,
    this.fromPinBiometrics = false,
  });

  @override
  State<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isError = false;
  bool _isSubmitting = false;
  bool _autoLoginTriggered = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus to show keyboard immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _controller.addListener(() {
      setState(() {
        isError = false;
      });

      if (widget.fromPinBiometrics &&
          _controller.text.length == 6 &&
          !_autoLoginTriggered &&
          !_isSubmitting) {
        _autoLoginTriggered = true;
        _submitPin(auto: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          // Refocus when tapping anywhere on the screen
          _focusNode.requestFocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.enterPinCode,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.pinCodeDescription,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(6, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index < 5 ? 12 : 0),
                    child: _buildPinBox(index),
                  );
                }),
              ),
              if (isError) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.incorrectPin,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
              // Hidden TextField for native keyboard input
              Opacity(
                opacity: 0.0,
                child: SizedBox(
                  height: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          _submitPin(auto: false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37C293),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.verify,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinBox(int index) {
    bool hasDigit = index < _controller.text.length;
    bool isSelected = index == _controller.text.length;
    
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? Colors.red
              : isSelected
                  ? const Color(0xFF4CD964)
                  : const Color(0xFFE5E5E5),
          width: isSelected || isError ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        hasDigit ? _controller.text[index] : '',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _submitPin({required bool auto}) async {
    final pin = _controller.text;

    if (pin.length != 6) {
      setState(() {
        isError = true;
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isSubmitting = true;
      isError = false;
    });

    debugPrint(
      'VerifyPinScreen: ${auto ? 'Automatic' : 'Manual'} login '
      '${widget.fromPinBiometrics ? 'from PinBiometricsScreen' : 'standard flow'}.',
    );

    try {
      final bool success;
      if (widget.fromPinBiometrics && authProvider.nationalId != null) {
        success = await authProvider.loginWithNationalId(authProvider.nationalId!, pin);
      } else {
        success = await authProvider.loginWithPassword(pin);
      }

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
          (route) => false,
        );
      } else {
        setState(() {
          isError = true;
        });
        debugPrint(
          'VerifyPinScreen: login failed. Status: ${authProvider.status}, '
          'Error: ${authProvider.errorMessage}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
        });
      }
      debugPrint('VerifyPinScreen: unexpected login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
