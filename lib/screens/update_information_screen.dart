import 'package:flutter/material.dart';
import 'package:bankid_app/screens/home_screen.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/core/utils/country_utils.dart';

class UpdateInformationScreen extends StatelessWidget {
  const UpdateInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final locale = Localizations.localeOf(context).languageCode;

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.updateInformationTitle,
                style: const TextStyle(
                  color: Color(0xFF172a47),
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildImagePlaceholder()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildImagePlaceholder()),
                ],
              ),
              const SizedBox(height: 16),

              _buildInfoRow(l10n.firstNameLabel, authProvider.firstName ?? '-'),
              _buildDivider(),
              _buildInfoRow(l10n.lastNameLabel, authProvider.lastName ?? '-'),
              _buildDivider(),
              _buildInfoRow(l10n.genderLabel, authProvider.gender ?? '-'),
              _buildDivider(),
              _buildInfoRow(
                l10n.dateOfBirthLabel,
                authProvider.dateOfBirth ?? '-',
              ),
              _buildDivider(),
              _buildInfoRow(
                l10n.nationalityLabel,
                CountryUtils.getCountryName(
                  authProvider.nationality ?? '-',
                  locale: locale,
                ),
              ),
              _buildDivider(),
              _buildInfoRow(
                l10n.nationalIdNumberLabel,
                authProvider.nationalId ?? '-',
              ),
              _buildDivider(),
              _buildInfoRow(
                l10n.dateOfIssueLabel,
                authProvider.dateOfIssue ?? '-',
              ),
              _buildDivider(),
              _buildInfoRow(
                l10n.dateOfExpiryLabel,
                authProvider.dateOfExpiry ?? '-',
              ),

              const SizedBox(height: 32),

              /// Confirm Button
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
                    l10n.updateInformationButton,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
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

  Widget _buildImagePlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9, // ✅ keeps images proportional
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/selfie_placeholder.png'),
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

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        color: const Color(0xFF919EAB).withAlpha((0.2 * 255).round()),
        thickness: 1.0,
        height: 0.0,
      ),
    );
  }
}
