import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/add_new_signature_screen.dart';
import 'package:bankid_app/screens/signature_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';

class DigitalSignaturesListScreen extends StatefulWidget {
  const DigitalSignaturesListScreen({super.key});

  @override
  State<DigitalSignaturesListScreen> createState() => _DigitalSignaturesListScreenState();
}

class _DigitalSignaturesListScreenState extends State<DigitalSignaturesListScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          AppLocalizations.of(context)?.digitalSignatures ?? 'Digital Signatures',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: languageProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              _buildSignatureCard(context, 'Digital Signature Number 1', 'March 25, 2025', 'assets/images/signature_placeholder.svg', 1),
              const SizedBox(height: 16),
              _buildSignatureCard(context, 'Digital Signature Number 2', 'March 25, 2025', 'assets/images/signature_placeholder.svg', 2),
              const SizedBox(height: 16),
              _buildSignatureCard(context, 'Digital Signature Number 3', 'March 25, 2025', 'assets/images/signature_placeholder.svg', 3),
              const SizedBox(height: 16),
              _buildSignatureCard(context, 'Digital Signature Number 4', 'March 25, 2025', 'assets/images/signature_placeholder.svg', 4),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddNewSignatureScreen()),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)?.addNewSignature ?? 'Add New Signature',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28A745), // Green background
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureCard(BuildContext context, String title, String date, String imagePath, int signatureNumber) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SignatureDetailScreen(signatureNumber: signatureNumber)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              imagePath,
              height: 50,
              width: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)?.fileAddedOn ?? 'File added on ' + date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}