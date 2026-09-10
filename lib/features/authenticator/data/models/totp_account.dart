import 'package:otp_auth/otp_auth.dart';

enum TotpAlgorithm { sha1, sha256, sha512 }

extension TotpAlgorithmX on TotpAlgorithm {
  OTPAlgorithm get toOtpAuth {
    switch (this) {
      case TotpAlgorithm.sha1:
        return OTPAlgorithm.sha1;
      case TotpAlgorithm.sha256:
        return OTPAlgorithm.sha256;
      case TotpAlgorithm.sha512:
        return OTPAlgorithm.sha512;
    }
  }

  static TotpAlgorithm fromString(String value) {
    switch (value.toUpperCase()) {
      case 'SHA256':
        return TotpAlgorithm.sha256;
      case 'SHA512':
        return TotpAlgorithm.sha512;
      case 'SHA1':
      default:
        return TotpAlgorithm.sha1;
    }
  }

  String get label {
    switch (this) {
      case TotpAlgorithm.sha1:
        return 'SHA1';
      case TotpAlgorithm.sha256:
        return 'SHA256';
      case TotpAlgorithm.sha512:
        return 'SHA512';
    }
  }
}

class TotpAccount {
  TotpAccount({
    required this.id,
    required this.issuer,
    required this.accountName,
    required this.secret,
    this.algorithm = TotpAlgorithm.sha1,
    this.digits = 6,
    this.period = 30,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toUtc(),
        updatedAt = updatedAt ?? DateTime.now().toUtc();

  final String id;
  final String issuer;
  final String accountName;
  final String secret;
  final TotpAlgorithm algorithm;
  final int digits;
  final int period;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  static String normalizeSecret(String raw) {
    return raw.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  static void validateSecret(String secret) {
    final normalized = normalizeSecret(secret);
    if (normalized.isEmpty) {
      throw TotpValidationException('Secret key is required');
    }
    try {
      Base32.decode(normalized);
    } catch (_) {
      throw TotpValidationException('Secret key is not valid Base32');
    }
  }

  static void validateFields({
    required String issuer,
    required String accountName,
    required String secret,
    required TotpAlgorithm algorithm,
    required int digits,
    required int period,
  }) {
    if (issuer.trim().isEmpty) {
      throw TotpValidationException('Issuer is required');
    }
    if (accountName.trim().isEmpty) {
      throw TotpValidationException('Account name is required');
    }
    if (issuer.length > 255 || accountName.length > 255) {
      throw TotpValidationException('Issuer and account name must be 255 characters or fewer');
    }
    validateSecret(secret);
    if (digits != 6 && digits != 8) {
      throw TotpValidationException('Digits must be 6 or 8');
    }
    if (period <= 0) {
      throw TotpValidationException('Period must be a positive number');
    }
  }

  TotpAccount copyWith({
    String? id,
    String? issuer,
    String? accountName,
    String? secret,
    TotpAlgorithm? algorithm,
    int? digits,
    int? period,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TotpAccount(
      id: id ?? this.id,
      issuer: issuer ?? this.issuer,
      accountName: accountName ?? this.accountName,
      secret: secret ?? this.secret,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'issuer': issuer,
        'accountName': accountName,
        'secret': secret,
        'algorithm': algorithm.label,
        'digits': digits,
        'period': period,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TotpAccount.fromJson(Map<String, dynamic> json) {
    return TotpAccount(
      id: json['id'] as String,
      issuer: json['issuer'] as String,
      accountName: json['accountName'] as String,
      secret: json['secret'] as String,
      algorithm: TotpAlgorithmX.fromString(json['algorithm'] as String? ?? 'SHA1'),
      digits: json['digits'] as int? ?? 6,
      period: json['period'] as int? ?? 30,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class TotpValidationException implements Exception {
  TotpValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DuplicateSecretException implements Exception {
  DuplicateSecretException();

  @override
  String toString() => 'An account with this secret already exists';
}
