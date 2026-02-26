import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/add_new_signature_screen.dart';
import 'package:bankid_app/screens/signature_detail_screen.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:bankid_app/providers/signature_provider.dart';
import 'package:bankid_app/models/signature.dart';

class DigitalSignaturesListScreen extends StatefulWidget {
  const DigitalSignaturesListScreen({super.key});

  @override
  State<DigitalSignaturesListScreen> createState() =>
      _DigitalSignaturesListScreenState();
}

class _DigitalSignaturesListScreenState
    extends State<DigitalSignaturesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<SignatureProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();
    final signatureProvider = context.watch<SignatureProvider>();

    final signatures = signatureProvider.signatures;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.digitalSignaturesListTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: signatureProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : signatures.isEmpty
            ? Center(child: Text(l10n.noSignaturesFound))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: signatures.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final sig = signatures[index];
                  return _SignatureCard(
                    signature: sig,
                    isRTL: languageProvider.isRTL,
                  );
                },
              ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedAdd01,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                l10n.addNewSignatureButton,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37C293),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddNewSignatureScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SignatureCard extends StatelessWidget {
  final SignatureItem signature;
  final bool isRTL;

  const _SignatureCard({required this.signature, required this.isRTL});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignatureDetailScreen(signature: signature),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isRTL
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Preview Container
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: _SignaturePreview(signature: signature)),
            ),
            const SizedBox(height: 10),

            // Title Row
            Row(
              mainAxisAlignment: isRTL
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedSignature,
                  size: 20,
                  color: Colors.black,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    signature.name,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Align(
              alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                '${l10n.fileAddedOnLabel} ${_formatDate(signature.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
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
      'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _SignaturePreview extends StatelessWidget {
  final SignatureItem signature;

  const _SignaturePreview({required this.signature});

  @override
  Widget build(BuildContext context) {
    // TEXT SIGNATURE
    if (signature.type == SignatureType.text && signature.textValue != null) {
      return Text(
        signature.textValue!,
        style: GoogleFonts.allura(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      );
    }

    // IMAGE & HANDWRITING & SVG
    return FutureBuilder<Uint8List>(
      future: context.read<SignatureProvider>().getSignatureImageBytes(
        signature.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        }

        if (snapshot.hasData) {
          if (signature.type == SignatureType.svg) {
            return SvgPicture.memory(snapshot.data!, fit: BoxFit.contain);
          }

          return Image.memory(snapshot.data!, fit: BoxFit.contain);
        }

        return const Icon(Icons.image_not_supported, color: Colors.grey);
      },
    );
  }
}
