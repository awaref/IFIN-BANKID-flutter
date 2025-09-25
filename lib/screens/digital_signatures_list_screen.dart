import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/add_new_signature_screen.dart';
import 'package:bankid_app/screens/signature_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class DigitalSignaturesListScreen extends StatefulWidget {
  const DigitalSignaturesListScreen({super.key});

  @override
  State<DigitalSignaturesListScreen> createState() =>
      _DigitalSignaturesListScreenState();
}

class _DigitalSignaturesListScreenState
    extends State<DigitalSignaturesListScreen> {
  final List<Map<String, dynamic>> signatures = [
    {"title": "Digital Signature Number 1", "date": "March 25, 2025", "svg": _signature1SVG()},
    {"title": "Digital Signature Number 2", "date": "March 25, 2025", "svg": _signature2SVG()},
    {"title": "Digital Signature Number 3", "date": "March 25, 2025", "svg": _signature3SVG()},
    {"title": "Digital Signature Number 4", "date": "March 25, 2025", "svg": _signature1SVG()},
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)?.digitalSignatures ??
              'Digital Signatures',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: signatures.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final sig = signatures[index];
            return _buildSignatureCard(
              context,
              sig["title"],
              sig["date"],
              sig["svg"],
              index + 1,
              languageProvider.isRTL,
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AddNewSignatureScreen()),
                );
              },
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedAdd01,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                AppLocalizations.of(context)?.addNewSignature ??
                    'Add New Signature',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37C293),
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureCard(
    BuildContext context,
    String title,
    String date,
    String svgString,
    int signatureNumber,
    bool isRTL,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                SignatureDetailScreen(signatureNumber: signatureNumber),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Signature preview
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.string(
                  svgString,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Icon + Title
            Row(
              mainAxisAlignment:
                  isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedSignature,
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Date
            Align(
              alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                '${AppLocalizations.of(context)?.fileAddedOn ?? 'File added on'} $date',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                ),
                textAlign: isRTL ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SVG Signatures
  static String _signature1SVG() => '''
    <svg viewBox="0 0 200 80" xmlns="http://www.w3.org/2000/svg">
      <path d="M15 45 C25 25, 45 35, 75 30 C95 27, 115 40, 135 35 C155 30, 175 45, 185 40" 
            stroke="#000" stroke-width="2.5" fill="none" stroke-linecap="round"/>
    </svg>
  ''';

  static String _signature2SVG() => '''
    <svg viewBox="0 0 200 80" xmlns="http://www.w3.org/2000/svg">
      <path d="M25 55 C35 35, 55 45, 85 40 C105 35, 125 50, 145 45" 
            stroke="#000" stroke-width="2.5" fill="none" stroke-linecap="round"/>
    </svg>
  ''';

  static String _signature3SVG() => '''
    <svg viewBox="0 0 200 80" xmlns="http://www.w3.org/2000/svg">
      <path d="M35 65 C45 50, 55 60, 65 55 C70 53, 75 57, 80 55" 
            stroke="#000" stroke-width="2.5" fill="none" stroke-linecap="round"/>
    </svg>
  ''';
}
