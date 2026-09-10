import 'package:otp_auth/otp_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/totp_account.dart';

class OtpUriParseException implements Exception {
  OtpUriParseException(this.message);
  final String message;

  @override
  String toString() => message;
}

class OtpUriParser {
  OtpUriParser({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  TotpAccount parse(String uri) {
    final trimmed = uri.trim();
    if (!trimmed.toLowerCase().startsWith('otpauth://')) {
      throw OtpUriParseException('Invalid QR code for authenticator setup');
    }
    if (trimmed.toLowerCase().startsWith('otpauth://hotp/')) {
      throw OtpUriParseException('Unsupported OTP type. Only TOTP is supported.');
    }
    if (!trimmed.toLowerCase().startsWith('otpauth://totp/')) {
      throw OtpUriParseException('Unsupported OTP type. Only TOTP is supported.');
    }

    OTPUri otpUri;
    try {
      otpUri = OTPUri.parse(trimmed);
    } catch (_) {
      throw OtpUriParseException('Could not read account from QR code');
    }

    if (otpUri.secret.isEmpty) {
      throw OtpUriParseException('Missing secret in authenticator URI');
    }

    final normalizedSecret = TotpAccount.normalizeSecret(otpUri.secret);
    try {
      Base32.decode(normalizedSecret);
    } catch (_) {
      throw OtpUriParseException('Secret key is not valid Base32');
    }

    final algorithm = _mapAlgorithm(otpUri.algorithm);
    final digits = otpUri.digits;
    final period = otpUri.period;

    if (digits != 6 && digits != 8) {
      throw OtpUriParseException('Digits must be 6 or 8');
    }
    if (period <= 0) {
      throw OtpUriParseException('Period must be a positive number');
    }

    final issuer = _resolveIssuer(otpUri);
    final accountName = _resolveAccountName(otpUri);

    TotpAccount.validateFields(
      issuer: issuer,
      accountName: accountName,
      secret: normalizedSecret,
      algorithm: algorithm,
      digits: digits,
      period: period,
    );

    return TotpAccount(
      id: _uuid.v4(),
      issuer: issuer,
      accountName: accountName,
      secret: normalizedSecret,
      algorithm: algorithm,
      digits: digits,
      period: period,
    );
  }

  TotpAlgorithm _mapAlgorithm(OTPAlgorithm algorithm) {
    switch (algorithm) {
      case OTPAlgorithm.sha256:
        return TotpAlgorithm.sha256;
      case OTPAlgorithm.sha512:
        return TotpAlgorithm.sha512;
      case OTPAlgorithm.sha1:
        return TotpAlgorithm.sha1;
    }
  }

  String _resolveIssuer(OTPUri otpUri) {
    if (otpUri.issuer != null && otpUri.issuer!.trim().isNotEmpty) {
      return otpUri.issuer!.trim();
    }
    return 'Unknown';
  }

  String _resolveAccountName(OTPUri otpUri) {
    final account = otpUri.account?.trim() ?? '';
    if (account.isNotEmpty) {
      return account;
    }
    return 'Account';
  }
}
