import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bankid_app/models/signature.dart';
import 'package:bankid_app/providers/signature_provider.dart';

class SignatureDetailScreen extends StatefulWidget {
  final SignatureItem signature;

  const SignatureDetailScreen({super.key, required this.signature});

  @override
  State<SignatureDetailScreen> createState() => _SignatureDetailScreenState();
}

class _SignatureDetailScreenState extends State<SignatureDetailScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final loc = AppLocalizations.of(context);
    final signature = widget.signature;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          signature.name,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: languageProvider.isRTL
                ? TextDirection.rtl
                : TextDirection.ltr,
            children: [
              /// Signature container
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(signature),
                ),
              ),
              const SizedBox(height: 12),

              /// Details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signature.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${loc?.fileAddedOn ?? 'File added on'} ${signature.createdAt.day}/${signature.createdAt.month}/${signature.createdAt.year}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      /// Bottom buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _isDeleting
                    ? null
                    : () => _showDeleteDialog(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFF9E4E7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isDeleting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFDC3545),
                        ),
                      )
                    : Text(
                        loc?.delete ?? 'Delete',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC3545),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Decide image source or fallback
  Widget _buildImageWidget(SignatureItem signature) {
    if (signature.type == SignatureType.text && signature.textValue != null) {
      return Container(
        height: 250,
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          signature.textValue!,
          style: GoogleFonts.allura(
            fontSize: 48,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      );
    }

    final signatureImagePath = signature.imageUrl;
    if (signatureImagePath == null) {
      return Container(
        height: 250,
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            const SizedBox(height: 8),
            Text(signature.name, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Handle Data URI (Base64)
    if (signatureImagePath.startsWith('data:image') ||
        (!signatureImagePath.startsWith('http') && signatureImagePath.length > 100)) {
      try {
        final base64Data = signatureImagePath.contains(',')
            ? signatureImagePath.split(',').last
            : signatureImagePath;
        return Image.memory(
          base64Decode(base64Data),
          height: 250,
          width: double.infinity,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 64, color: Colors.grey),
        );
      } catch (e) {
        return const Icon(Icons.broken_image, size: 64, color: Colors.grey);
      }
    }

    return FutureBuilder<Uint8List>(
      future: Provider.of<SignatureProvider>(context, listen: false)
          .getImageBytes(widget.signature),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 250,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
          );
        }

        if (snapshot.hasData) {
          final bytes = snapshot.data!;
          final lower = signatureImagePath.toLowerCase();
          if (lower.endsWith('.svg')) {
            return SvgPicture.memory(
              bytes,
              height: 250,
              width: double.infinity,
              fit: BoxFit.contain,
            );
          }
          return Image.memory(
            bytes,
            height: 250,
            width: double.infinity,
            fit: BoxFit.contain,
          );
        }

        return Container(
          height: 250,
          width: double.infinity,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
        );
      },
    );
  }

  /// Updated delete dialog (matches design)
  void _showDeleteDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title row with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc?.deleteSignature ?? 'Delete Signature',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Message
                Text(
                  loc?.areYouSureYouWantToDeleteSignature(
                        0, // ID or index not critical here for UI string
                        widget.signature.name,
                      ) ??
                      'Are you sure you want to delete ${widget.signature.name}?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 24),

                /// Buttons row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          loc?.cancel ?? 'Cancel',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop(); // close dialog
                          setState(() {
                            _isDeleting = true;
                          });
                          try {
                            await Provider.of<SignatureProvider>(
                              context,
                              listen: false,
                            ).deleteSignature(widget.signature.id);
                            
                            if (!context.mounted) return;
                            Navigator.of(context).pop(); // go back
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting signature: $e'),
                                backgroundColor: const Color(0xFFDC3545),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isDeleting = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          loc?.delete ?? 'Delete',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
