import 'dart:async';

import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/models/qr_models.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/services/biometric_service.dart';
import 'package:bankid_app/services/qr_auth_error_mapper.dart';

class QrAuthScreen extends StatefulWidget {
  final QrScanResponse scanResponse;

  const QrAuthScreen({
    super.key,
    required this.scanResponse,
  });

  @override
  State<QrAuthScreen> createState() => _QrAuthScreenState();
}

class _QrAuthScreenState extends State<QrAuthScreen> {
  bool _isLoading = false;
  bool _isExpired = false;
  Timer? _expiryTimer;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _isExpired = widget.scanResponse.isExpired;
    final exp = widget.scanResponse.expiresAtDateTime;
    if (exp != null && !_isExpired) {
      final delay = exp.toUtc().difference(DateTime.now().toUtc());
      if (delay.isNegative) {
        _isExpired = true;
      } else {
        _expiryTimer = Timer(delay, () {
          if (mounted) setState(() => _isExpired = true);
        });
      }
    }
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  void _handleError(Object e) {
    if (!mounted) return;
    final message = QrAuthErrorMapper.messageFor(context, e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    QrAuthErrorMapper.navigateToKycIfNeeded(context, e);
  }

  Future<bool> _verifyLocalAuth() async {
    final l10n = AppLocalizations.of(context)!;
    final available = await _biometricService.isBiometricAvailable();
    // Prefer biometrics; device credential (PIN/pattern) is allowed as fallback
    final authenticated = await _biometricService.authenticate(
      reason: l10n.authenticateReason,
      biometricOnly: false,
    );
    if (authenticated) return true;

    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.qrLocalAuthRequired)),
      );
    }
    return false;
  }

  Future<void> _approve() async {
    if (_isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.qrRequestExpired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final ok = await _verifyLocalAuth();
      if (!ok) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      await authProvider.authRepository
          .approveQrAuth(widget.scanResponse.approvalRef);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.qrAuthSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reject({bool popAfter = true}) async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.authRepository
          .rejectQrAuth(widget.scanResponse.approvalRef);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.qrAuthRejected),
            backgroundColor: Colors.orange,
          ),
        );
        if (popAfter) Navigator.pop(context);
      }
    } catch (e) {
      _handleError(e);
      if (popAfter && mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onCancel() async {
    if (_isLoading) return;
    await _reject(popAfter: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rp = widget.scanResponse.relyingParty;
    final isSign = widget.scanResponse.isSignIntent;
    final headline = isSign
        ? l10n.qrSignFor(rp.name)
        : l10n.qrLogInTo(rp.name);
    final logoUrl = rp.logoUrl;
    final visibleData = widget.scanResponse.userVisibleData;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onCancel();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(l10n.qrAuthTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              color: Colors.black,
              size: 24,
            ),
            onPressed: _isLoading ? null : _onCancel,
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4FA),
                  shape: BoxShape.circle,
                ),
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => HugeIcon(
                            icon: HugeIcons.strokeRoundedGlobe,
                            size: 50.sp,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      )
                    : HugeIcon(
                        icon: HugeIcons.strokeRoundedGlobe,
                        size: 50.sp,
                        color: const Color(0xFF2C3E50),
                      ),
              ),
              SizedBox(height: 24.h),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              if (rp.domain.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  rp.domain,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF637381),
                  ),
                ),
              ],
              if (isSign &&
                  visibleData != null &&
                  visibleData.isNotEmpty) ...[
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4FA),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    visibleData,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ),
              ],
              if (_isExpired) ...[
                SizedBox(height: 16.h),
                Text(
                  l10n.qrRequestExpired,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ],
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isExpired ? null : _approve,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF37c293),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          l10n.qrAuthApprove,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF637381),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          l10n.qrAuthReject,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
