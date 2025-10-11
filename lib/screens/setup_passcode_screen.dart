import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/screens/national_id_screen.dart';
import 'package:hugeicons/hugeicons.dart' show HugeIcon, HugeIcons;
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
          children: [
            Text(
              l10n.setupPasscode,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold , height: 1.6 ,color: Color(0xFF172A47) ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createPinDescription,
              style: TextStyle(fontSize: 16, color: Color(0xFF919EAB)),
            ),
            const SizedBox(height: 48),
            Text(
              l10n.passcode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
                    border: Border.all(color: Color(0xFFE2E8F0)),
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
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
                    border: Border.all(color: const Color(0xFF37C293), width: 1),
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
                  backgroundColor: const  Color(0xFF37C293), // Green color from image
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.setPasscode,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox( height: 64,)
          ],
        ),
      ),
    );
  }

}