import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/models/qr_models.dart'; // Import the new model
import 'package:bankid_app/providers/auth_provider.dart';

class QrAuthScreen extends StatefulWidget {
  final String sessionToken;
  final PartnerWebsite partnerWebsite; // Changed type to PartnerWebsite
  final bool requiresApproval;

  const QrAuthScreen({
    super.key,
    required this.sessionToken,
    required this.partnerWebsite,
    required this.requiresApproval,
  });

  @override
  State<QrAuthScreen> createState() => _QrAuthScreenState();
}

class _QrAuthScreenState extends State<QrAuthScreen> {
  bool _isLoading = false;

  void _handleError(dynamic e, {StackTrace? stackTrace}) {
    if (!mounted) return;

    String message = AppLocalizations.of(context)!.qrAuthError;
    
    if (e is NetworkException) {
      message = AppLocalizations.of(context)!.noInternetConnectionTitle;
    } else if (e is UnauthorizedException) {
      message = AppLocalizations.of(context)!.qrSessionExpired;
    } else if (e is ServerException) {
      message = '${AppLocalizations.of(context)!.authenticationError} (500)';
    } else if (e is ApiException) {
      if (e.statusCode == 400 || e.statusCode == 404) {
        message = AppLocalizations.of(context)!.qrSessionExpired;
      } else {
        message = e.message;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _approve() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.authRepository.approveQrAuth(widget.sessionToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.qrAuthSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.authRepository.rejectQrAuth(widget.sessionToken);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.qrAuthRejected),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace: stackTrace);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final partnerName = widget.partnerWebsite.name;
    final String? partnerLogo = null; // Reverted to null as PartnerWebsite model does not have a logoUrl field yet.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.qrAuthTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4FA),
                shape: BoxShape.circle,
              ),
              child: partnerLogo != null
                  ? ClipOval(child: Image.network(partnerLogo, fit: BoxFit.cover))
                  : HugeIcon(icon: HugeIcons.strokeRoundedGlobe, size: 50.sp, color: const Color(0xFF2C3E50)),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.qrAuthRequestFrom,
              style: TextStyle(fontSize: 16.sp, color: const Color(0xFF637381)),
            ),
            SizedBox(height: 8.h),
            Text(
              partnerName,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
            ),
            SizedBox(height: 48.h),
            if (widget.requiresApproval)
              Text(
                l10n.qrAuthRequiresApproval,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: const Color(0xFF2C3E50)),
              ),
            const Spacer(),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _approve,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37c293),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(l10n.qrAuthApprove, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _reject,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF637381),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(l10n.qrAuthReject, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
