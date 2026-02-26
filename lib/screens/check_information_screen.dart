import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bankid_app/screens/home_screen.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/auth_provider.dart';

class CheckInformationScreen extends StatefulWidget {
  final String? selfiePath;
  final String? idDocumentPath;

  const CheckInformationScreen({
    super.key,
    this.selfiePath,
    this.idDocumentPath,
  });

  @override
  State<CheckInformationScreen> createState() => _CheckInformationScreenState();
}

class _CheckInformationScreenState extends State<CheckInformationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.kycRequestId != null) {
        auth.fetchKycRequest(auth.kycRequestId!);
      } else if (!auth.profileLoaded) {
        auth.loadCurrentUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // ✅ allows scrolling instead of overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.checkInformationTitle,
                style: const TextStyle(
                  color: Color(0xFF172a47),
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),

              /// ✅ Row with flexible images
              Row(
                children: [
                  Expanded(child: _buildImage(widget.selfiePath)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildImage(widget.idDocumentPath)),
                ],
              ),
              const SizedBox(height: 16),

              if (authProvider.status == AuthStatus.loading && !authProvider.profileLoaded)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else ...[
                _buildInfoRow(l10n.checkInformationFirstName, authProvider.firstName ?? '-'),
                _buildInfoRow(l10n.checkInformationLastName, authProvider.lastName ?? '-'),
                _buildInfoRow(l10n.checkInformationGender, authProvider.gender ?? '-'),
                _buildInfoRow(l10n.checkInformationDateOfBirth, authProvider.dateOfBirth ?? '-'),
                _buildInfoRow(l10n.checkInformationNationality, authProvider.nationality ?? '-'),
                _buildInfoRow(l10n.checkInformationNationalIdNumber, authProvider.nationalId ?? '-'),
                _buildInfoRow(l10n.checkInformationDateOfIssue, authProvider.dateOfIssue ?? '-'),
                _buildInfoRow(l10n.checkInformationDateOfExpiry, authProvider.dateOfExpiry ?? '-'),
              ],
              const SizedBox(height: 32),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF37C293),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.checkInformationConfirm,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16), // Added SizedBox for spacing

              /// Report a Problem Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(l10n.reportProblemTitle),
                          content: Text(l10n.supportPhoneNumber),
                          actions: <Widget>[
                            TextButton(
                              child: Text(l10n.closeButton),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(l10n.callButton),
                              onPressed: () async {
                                final Uri launchUri = Uri(
                                  scheme: 'tel',
                                  path: l10n.supportPhoneNumber,
                                );
                                if (await canLaunchUrl(launchUri)) {
                                  await launchUrl(launchUri);
                                } else {
                                  // Consider using a more robust logging solution or showing a user-friendly message
                                  // instead of print in production code.
                                  // For now, we'll keep it as is to avoid changing the original behavior too much.
                                }
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF37C293)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.reportProblemButton,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF37C293),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    return AspectRatio(
      aspectRatio: 16 / 9, // ✅ keeps images proportional
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: path != null
                ? FileImage(File(path)) as ImageProvider
                : const AssetImage('assets/images/selfie_placeholder.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF637381)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF212B36),
            ),
          ),
        ],
      ),
    );
  }
}
