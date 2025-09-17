import 'package:flutter/material.dart';
import 'package:bankid_app/screens/national_id_screen.dart';
import 'package:pinput/pinput.dart'; // Import pinput package

class SetupPasscodeScreen extends StatefulWidget {
  const SetupPasscodeScreen({super.key});

  @override
  State<SetupPasscodeScreen> createState() => _SetupPasscodeScreenState();
}

class _SetupPasscodeScreenState extends State<SetupPasscodeScreen> {
  String _passcode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(''), // Empty title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
          children: [
            const Text(
              'Setup the passcode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your 6-digit PIN to protect your personal data',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'Passcode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Replace TextField with a custom passcode input display and a hidden TextField for input
            // Stack(
            //   children: [
            //     _buildPasscodeInput(),
            //     Positioned.fill(
            //       child: TextField(
            //         controller: TextEditingController(text: _passcode),
            //         obscureText: true,
            //         keyboardType: TextInputType.number,
            //         maxLength: 6,
            //         textAlign: TextAlign.center,
            //         style: const TextStyle(color: Colors.transparent), // Hide the text
            //         decoration: const InputDecoration(
            //           counterText: "", // Hide the character counter
            //           border: InputBorder.none, // Hide the border
            //         ),
            //         onChanged: (value) {
            //           setState(() {
            //             _passcode = value;
            //           });
            //         },
            //         // Removed showCursor: false and readOnly: true to allow keyboard input
            //       ),
            //     ),
            //   ],
            // ),
            Center(
              child: Pinput(
                length: 6,
                onChanged: (value) {
                  setState(() {
                    _passcode = value;
                  });
                },
                onCompleted: (pin) {
                  // Optionally handle completion here, though the button handles navigation
                },
                defaultPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF28B446), width: 2),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                submittedPinTheme: PinTheme(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF28B446), width: 2),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // Consider adding a controller if you need to clear or pre-fill the pin
                // controller: pinController,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _passcode.length == 6
                    ? () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const NationalIdScreen()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF28B446), // Green color from image
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Set passcode',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasscodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        bool isActive = index < _passcode.length;
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? const Color(0xFF28B446) : Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              isActive ? _passcode[index] : '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),
    );
  }
}