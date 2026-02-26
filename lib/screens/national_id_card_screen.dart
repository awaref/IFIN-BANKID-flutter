import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bankid_app/screens/check_information_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/config.dart';
import 'dart:io';

class NationalIdCardScreen extends StatefulWidget {
  final String selfiePath;
  final String? kycRequestId;

  const NationalIdCardScreen({
    super.key,
    required this.selfiePath,
    this.kycRequestId,
  });

  @override
  State<NationalIdCardScreen> createState() =>
      _NationalIdCardScreenState();
}

class _NationalIdCardScreenState
    extends State<NationalIdCardScreen> {
  String _idDocumentType = 'id_card';
  String? _idDocumentPath;
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final auth =
        Provider.of<AuthProvider>(context, listen: false);
    final nationalId = auth.nationalId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final imageHeight = screenWidth * 0.38;

          return Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!
                          .takeAPictureOfYourNationalIdCard,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 16),

                    if (nationalId != null) ...[
                      Container(
                        padding:
                            const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF4F7FB),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          'National ID: $nationalId',
                          style:
                              const TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w600,
                            color:
                                Color(0xFF172A47),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    /// Document Type Selector
                    Wrap(
                      spacing: 12,
                      children: [
                        ChoiceChip(
                          label:
                              const Text('ID Card'),
                          selected:
                              _idDocumentType ==
                                  'id_card',
                          onSelected: (_) =>
                              setState(() =>
                                  _idDocumentType =
                                      'id_card'),
                        ),
                        ChoiceChip(
                          label:
                              const Text('Passport'),
                          selected:
                              _idDocumentType ==
                                  'passport',
                          onSelected: (_) =>
                              setState(() =>
                                  _idDocumentType =
                                      'passport'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// Image Preview
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(12),
                      child: _idDocumentPath ==
                              null
                          ? Image.asset(
                              'assets/images/selfie_placeholder.png',
                              height:
                                  imageHeight,
                              width:
                                  double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(
                                  _idDocumentPath!),
                              height:
                                  imageHeight,
                              width:
                                  double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      AppLocalizations.of(context)!
                          .pleaseEnsure,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildInstructionPoint(
                        AppLocalizations.of(
                                context)!
                            .usingCorrectNationalIdCard),
                    _buildInstructionPoint(
                        AppLocalizations.of(
                                context)!
                            .nationalIdCardWithinScanningFrame),
                    _buildInstructionPoint(
                        AppLocalizations.of(
                                context)!
                            .fingersDontCoverNationalId),
                    _buildInstructionPoint(
                        AppLocalizations.of(
                                context)!
                            .imageClearWithoutGlare),

                    const SizedBox(height: 32),

                    /// Button (Logic unchanged)
                    SizedBox(
                      width:
                          double.infinity,
                      child: ElevatedButton(
                        onPressed: _uploading
                            ? null
                            : _onTakeAndUpload,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF37C293),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      vertical:
                                          14),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        10),
                          ),
                        ),
                        child: Text(
                          _uploading
                              ? 'Uploading...'
                              : AppLocalizations.of(
                                      context)!
                                  .takeAPicture,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionPoint(String text) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Padding(
            padding:
                EdgeInsets.only(top: 6),
            child: Icon(Icons.circle,
                size: 5,
                color:
                    Color(0xFF37C293)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                      fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔒 Logic untouched
  Future<void> _onTakeAndUpload() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(
            source: ImageSource.camera);

    if (image == null) return;

    setState(() {
      _idDocumentPath = image.path;
      _uploading = true;
    });

    try {
      final api =
          ApiService(baseUrl: AppConfig.baseUrl);

      await api.postMultipart(
        '/kyc/requests/${widget.kycRequestId}/documents',
        fields: {
          'id_document_type':
              _idDocumentType,
        },
        files: [
          await http.MultipartFile
              .fromPath(
                  'selfie',
                  widget.selfiePath),
          await http.MultipartFile
              .fromPath(
                  'id_document',
                  _idDocumentPath!),
        ],
      );

      if (!mounted) return;

      Navigator.of(context)
          .pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              CheckInformationScreen(
            selfiePath:
                widget.selfiePath,
            idDocumentPath:
                _idDocumentPath,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
            content:
                Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }
}