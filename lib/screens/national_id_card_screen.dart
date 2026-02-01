import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bankid_app/screens/check_information_screen.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bankid_app/services/api_service.dart';
import 'dart:io';

class NationalIdCardScreen extends StatefulWidget {
  final String selfiePath;
  final String? kycRequestId;
  const NationalIdCardScreen({super.key, required this.selfiePath, this.kycRequestId});

  @override
  State<NationalIdCardScreen> createState() => _NationalIdCardScreenState();
}

class _NationalIdCardScreenState extends State<NationalIdCardScreen> {
  String _idDocumentType = 'id_card';
  String? _idDocumentPath;
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
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
              AppLocalizations.of(context)!.takeAPictureOfYourNationalIdCard,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: 'id_card',
                    groupValue: _idDocumentType,
                    onChanged: (v) => setState(() => _idDocumentType = v!),
                    title: const Text('ID Card'),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: 'passport',
                    groupValue: _idDocumentType,
                    onChanged: (v) => setState(() => _idDocumentType = v!),
                    title: const Text('Passport'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: _idDocumentPath == null
                  ? Image.asset(
                      'assets/images/selfie_placeholder.png',
                      height: 124,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_idDocumentPath!),
                      height: 124,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.pleaseEnsure,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 16),
            _buildInstructionPoint(AppLocalizations.of(context)!.usingCorrectNationalIdCard),
            _buildInstructionPoint(AppLocalizations.of(context)!.nationalIdCardWithinScanningFrame),
            _buildInstructionPoint(AppLocalizations.of(context)!.fingersDontCoverNationalId),
            _buildInstructionPoint(AppLocalizations.of(context)!.imageClearWithoutGlare),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploading ? null : _onTakeAndUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37C293),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _uploading ? 'Uploading...' : AppLocalizations.of(context)!.takeAPicture,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, color: Color(0xFF37C293), size: 4),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Future<void> _onTakeAndUpload() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _idDocumentPath = image.path;
    });
    // if (widget.kycRequestId == null) {
    //   final messenger = ScaffoldMessenger.of(context);
    //   messenger.showSnackBar(const SnackBar(content: Text('Missing KYC Request ID')));
    //   return;
    // }
    setState(() {
      _uploading = true;
    });
    try {
      final api = ApiService(baseUrl: 'http://10.0.2.2/api/v1');
      await api.uploadKycDocuments(
        requestId: widget.kycRequestId!,
        selfiePath: widget.selfiePath,
        idDocumentPath: _idDocumentPath!,
        idDocumentType: _idDocumentType,
      );
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CheckInformationScreen(
            selfiePath: widget.selfiePath,
            idDocumentPath: _idDocumentPath,
          ),
        ),
      );
    } catch (e) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }
}
