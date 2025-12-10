import 'package:bankid_app/screens/verification_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/setup_passcode_screen.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/services/malaa_api_client.dart';

class NationalIdScreen extends StatefulWidget {
  final MalaaApiClient? malaaClient;
  const NationalIdScreen({super.key, this.malaaClient});

  @override
  State<NationalIdScreen> createState() => _NationalIdScreenState();
}

class _NationalIdScreenState extends State<NationalIdScreen> {
  final TextEditingController _idController = TextEditingController();
  String? _selectedPhoneNumber;
  bool _loading = false;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nationalIdScreenTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 62),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nationalIdNumberLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: l10n.nationalIdNumberHint,
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
                onPressed: _loading
                    ? null
                    : () async {
                        final civil = _idController.text.trim();
                        if (!_isValidCivil(civil)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid national ID')),
                          );
                          return;
                        }
                        setState(() => _loading = true);
                        final client = widget.malaaClient ?? MalaaApiClient();
                        final res = await client.fetchPhoneNumbers(civilNumber: civil);
                        setState(() => _loading = false);
                        if (res.error != null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res.error!)),
                          );
                          return;
                        }
                        if (!mounted) return;
                        await _showPhoneNumberBottomSheet(context, res.numbers);
                        if (_selectedPhoneNumber != null) {
                          if (!mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  VerificationCodeScreen(phoneNumber: _selectedPhoneNumber!),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF37C293),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.continueButton,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            if (_loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Future<void> _showPhoneNumberBottomSheet(BuildContext context, List<String> numbers) async {
    final l10n = AppLocalizations.of(context)!;
    final String? selectedNumberFromModal = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (BuildContext context) {
        String? modalSelectedPhoneNumber = _selectedPhoneNumber; // Local state for the modal
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
                              Text(
                                l10n.yourPhoneNumbersTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.6
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.yourPhoneNumbersDescription,
                                style: TextStyle(fontSize: 14, color: Color(0xFF919EAB), fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 24),
                              RadioGroup<String>(
                                groupValue: modalSelectedPhoneNumber,
                                onChanged: (value) {
                                  setModalState(() {
                                    modalSelectedPhoneNumber = value;
                                  });
                                },
                                child: Column(
                                  children: [
                                    for (final n in numbers) ...[
                                      _buildPhoneNumberOption(setModalState, n),
                                      const SizedBox(height: 8),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 60),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: modalSelectedPhoneNumber != null ? () {
                                    Navigator.of(context).pop(modalSelectedPhoneNumber); // Pop with the selected number
                                  } : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF37C293),
                                    disabledBackgroundColor: Colors.grey[300],
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.pickNumberButton,
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

    if (selectedNumberFromModal != null) {
      setState(() {
        _selectedPhoneNumber = selectedNumberFromModal;
      });
    }
  }

  Widget _buildPhoneNumberOption(
    StateSetter setModalState,
    String phoneNumber,
  ) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: phoneNumber,
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

  bool _isValidCivil(String civil) {
    final d = civil.replaceAll(RegExp(r'\D'), '');
    return d.length >= 6;
  }
}
