import 'package:bankid_app/screens/verification_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/setup_passcode_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class NationalIdScreen extends StatefulWidget {
  const NationalIdScreen({super.key});

  @override
  State<NationalIdScreen> createState() => _NationalIdScreenState();
}

class _NationalIdScreenState extends State<NationalIdScreen> {
  final TextEditingController _idController = TextEditingController();
  String? _selectedPhoneNumber;

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
            const Text(
              'Start with your National ID number.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 62),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'National ID number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      hintText: 'Enter 9-digits number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showPhoneNumberBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF37C293),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  void _showPhoneNumberBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 80,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Phone numbers',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.6
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'We found these numbers on your National ID. Pick one to start with it.',
                                style: TextStyle(fontSize: 14, color: Color(0xFF919EAB), fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 24),
                              _buildPhoneNumberOption(setModalState, '+9** *** *** 999'),
                              const SizedBox(height: 8),
                              _buildPhoneNumberOption(setModalState, '+9** *** *** 888'),
                              const SizedBox(height: 8),
                              _buildPhoneNumberOption(setModalState, '+9** *** *** 777'),
                              const SizedBox(height: 8),
                              _buildPhoneNumberOption(setModalState, '+9** *** *** 666'),
                              const SizedBox(height: 60),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _selectedPhoneNumber != null ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const VerificationCodeScreen(),
                                      ),
                                    );
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF37C293),
                                    disabledBackgroundColor: Colors.grey[300],
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Pick number',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                              // Add extra padding at bottom for safe area
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPhoneNumberOption(
    StateSetter setModalState,
    String phoneNumber,
  ) {
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedPhoneNumber = phoneNumber;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: phoneNumber,
              groupValue: _selectedPhoneNumber,
              onChanged: (String? value) {
                setModalState(() {
                  _selectedPhoneNumber = value;
                });
              },
              activeColor: Color(0xFF37C293),
            ),
            Text(
              phoneNumber,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}