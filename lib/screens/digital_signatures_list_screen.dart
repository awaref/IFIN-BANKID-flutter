import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/add_new_signature_screen.dart';
import 'package:bankid_app/screens/signature_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:bankid_app/providers/signature_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class DigitalSignaturesListScreen extends StatefulWidget {
  const DigitalSignaturesListScreen({super.key});

  @override
  State<DigitalSignaturesListScreen> createState() =>
      _DigitalSignaturesListScreenState();
}

class _DigitalSignaturesListScreenState
    extends State<DigitalSignaturesListScreen> {

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final signatures = Provider.of<SignatureProvider>(context).items;

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
          l10n.digitalSignaturesListTitle,
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
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final sig = signatures[index];
            return _buildSignatureCard(
              context,
              sig.title,
              sig.createdAt,
              sig.filePath,
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
                l10n.addNewSignatureButton,
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
    DateTime date,
    String path,
    bool isRTL,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SignatureDetailScreen(
              signatureNumber: 0,
              signatureImagePath: path,
            ),
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
              color: const Color(0xFF000000).withValues(alpha: 0.05),
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
                child: _SignaturePreview(path: path),
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
                '${AppLocalizations.of(context)?.fileAddedOnLabel ?? 'File added on'} ${_formatDate(date)}',
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

  String _formatDate(DateTime d) {
    return '${_monthName(d.month)} ${d.day}, ${d.year}';
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[m - 1];
  }

}

class _SignaturePreview extends StatelessWidget {
  final String path;
  const _SignaturePreview({required this.path});

  @override
  Widget build(BuildContext context) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.svg')) {
      return SvgPicture.file(File(path), fit: BoxFit.contain);
    }
    return Image.file(File(path), fit: BoxFit.contain);
  }
}
