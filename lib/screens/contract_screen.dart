import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/verify_pin_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ContractScreen(),
    );
  }
}

class ContractScreen extends StatelessWidget {
  const ContractScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          l10n.contractScreenTitle,
          style: const TextStyle(
            color: Color(0xFF1A1D3D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.contractScreenPartyOneTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(l10n.contractScreenNameLabel, l10n.contractScreenPartyOneNameValue),
                  const SizedBox(height: 8),
                  _buildInfoRow(l10n.contractScreenIdPassportNumberLabel, l10n.contractScreenPartyOneIdPassportNumberValue),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    l10n.contractScreenAddressLabel,
                    l10n.contractScreenPartyOneAddressValue,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(l10n.contractScreenPhoneLabel, l10n.contractScreenPartyOnePhoneValue),
                  const SizedBox(height: 8),
                  _buildInfoRowWithLink(
                    l10n.contractScreenEmailLabel,
                    l10n.contractScreenPartyOneEmailValue,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.contractScreenPartyTwoTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    l10n.contractScreenNameLabel,
                    l10n.contractScreenPartyTwoNameValue,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    l10n.contractScreenCommercialRegistrationLabel,
                    l10n.contractScreenPartyTwoCommercialRegistrationValue,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    l10n.contractScreenAddressLabel,
                    l10n.contractScreenPartyTwoAddressValue,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(l10n.contractScreenPhoneLabel, l10n.contractScreenPartyTwoPhoneValue),
                  const SizedBox(height: 8),
                  _buildInfoRowWithLink(l10n.contractScreenEmailLabel, l10n.contractScreenPartyTwoEmailValue),
                  const SizedBox(height: 24),
                  Text(
                    l10n.contractScreenIntroductionTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contractScreenIntroductionDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contractScreenArticleOneTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contractScreenArticleOneDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contractScreenArticleTwoTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contractScreenArticleTwoDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contractScreenArticleThreeTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contractScreenArticleThreeDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contractScreenArticleFourTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contractScreenArticleFourDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contractScreenArticleFiveTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contractScreenArticleFiveDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.contractScreenArticleSixTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contractScreenArticleSixDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.contractScreenSignaturesTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D3D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(l10n.contractScreenPartyOneTitle, l10n.contractScreenPartyOneNameValue),
                  const SizedBox(height: 8),
                  _buildInfoRow(l10n.contractScreenSignatureLabel, l10n.contractScreenSignatureValue),
                  const SizedBox(height: 8),
                  _buildInfoRow(l10n.contractScreenDateLabel, l10n.contractScreenDateValue),
                  const SizedBox(height: 16),
                  _buildInfoRow(l10n.contractScreenPartyTwoTitle, l10n.contractScreenPartyTwoSignatureValue),
                  const SizedBox(height: 8),
                  _buildInfoRow(l10n.contractScreenSignatureLabel, l10n.contractScreenSignatureValue),
                  const SizedBox(height: 8),
                  _buildInfoRow(l10n.contractScreenDateLabel, l10n.contractScreenDateValue),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerifyPinScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF37C293),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.contractScreenSignContractButton,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ); }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D3D),
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithLink(String label, String email) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D3D),
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3B82F6),
              height: 1.5,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}