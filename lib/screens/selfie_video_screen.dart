import 'package:flutter/material.dart';
import 'package:bankid_app/screens/national_id_card_screen.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/l10n/app_localizations.dart';

class SelfieVideoScreen extends StatelessWidget {
  const SelfieVideoScreen({super.key});

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
              AppLocalizations.of(context)!.takeASelfieVideo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
           Text(
              AppLocalizations.of(context)!.onTheNextScreenFollowInstructions,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
              child: Image.asset(
                'assets/images/selfie_placeholder.png',
                height: 124,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            _buildInstructionPoint(
              AppLocalizations.of(context)!.pleaseNoteSurroundingsVisible,
            ),
            const SizedBox(height: 16),
            _buildInstructionPoint(
              AppLocalizations.of(context)!.tryMovingToBetterLighting,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const NationalIdCardScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF37C293),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.takeASelfie,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 64,)
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, color: Color(0xFF37C293), size: 4),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6))),
        ],
      ),
    );
  }
}
