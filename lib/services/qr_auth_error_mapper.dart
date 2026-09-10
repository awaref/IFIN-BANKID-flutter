import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:bankid_app/screens/id_app_identity_screen.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:flutter/material.dart';

/// Shared QR auth error mapping for scan / autostart / approve / reject.
class QrAuthErrorMapper {
  QrAuthErrorMapper._();

  static bool isDeviceNotTrusted(ApiException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('not trusted') ||
        msg.contains('untrusted') ||
        msg.contains('device not trusted') ||
        msg.contains('device_not_trusted');
  }

  static bool isAccountInvalid(ApiException e) {
    final msg = e.message.toLowerCase();
    return e.statusCode == 403 &&
        (msg.contains('account.valid') ||
            msg.contains('account invalid') ||
            msg.contains('kyc') ||
            msg.contains('verification') ||
            msg.contains('valid'));
  }

  /// Returns a localized message. Caller may also navigate on 403.
  static String messageFor(
    BuildContext context,
    Object e, {
    bool Function(ApiException)? onDeviceNotTrusted,
    bool Function(ApiException)? onAccountInvalid,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (e is NetworkException) {
      return l10n.qrNetworkRetry;
    }
    if (e is UnauthorizedException) {
      return l10n.qrSessionExpired;
    }
    if (e is ServerException) {
      return l10n.qrNetworkRetry;
    }
    if (e is ApiException) {
      if (e.statusCode == 403 || isAccountInvalid(e)) {
        onAccountInvalid?.call(e);
        return l10n.qrAccountNeedsVerification;
      }
      if (e.statusCode == 404 && isDeviceNotTrusted(e)) {
        onDeviceNotTrusted?.call(e);
        return l10n.qrDeviceNotTrusted;
      }
      if (e.statusCode == 404 || e.statusCode == 400) {
        return l10n.qrExpiredOrUsed;
      }
      return e.message.isNotEmpty ? e.message : l10n.qrAuthError;
    }
    return l10n.qrAuthError;
  }

  static void navigateToKycIfNeeded(BuildContext context, Object e) {
    if (e is ApiException &&
        (e.statusCode == 403 || isAccountInvalid(e))) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const IdAppIdentityScreen()),
      );
    }
  }
}
