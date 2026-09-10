import 'package:json_annotation/json_annotation.dart';

part 'qr_models.g.dart';

@JsonSerializable()
class RelyingParty {
  final String id;
  final String name;
  final String domain;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  RelyingParty({
    required this.id,
    required this.name,
    required this.domain,
    this.logoUrl,
  });

  factory RelyingParty.fromJson(Map<String, dynamic> json) =>
      _$RelyingPartyFromJson(json);
  Map<String, dynamic> toJson() => _$RelyingPartyToJson(this);
}

@JsonSerializable()
class QrScanResponse {
  @JsonKey(name: 'approval_ref')
  final String approvalRef;
  final String intent;
  @JsonKey(name: 'user_visible_data')
  final String? userVisibleData;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  @JsonKey(name: 'relying_party')
  final RelyingParty relyingParty;
  @JsonKey(name: 'requires_approval')
  final bool requiresApproval;

  QrScanResponse({
    required this.approvalRef,
    required this.intent,
    this.userVisibleData,
    this.expiresAt,
    required this.relyingParty,
    this.requiresApproval = true,
  });

  bool get isSignIntent => intent.toLowerCase() == 'sign';

  DateTime? get expiresAtDateTime {
    if (expiresAt == null || expiresAt!.isEmpty) return null;
    return DateTime.tryParse(expiresAt!);
  }

  bool get isExpired {
    final exp = expiresAtDateTime;
    if (exp == null) return false;
    return DateTime.now().toUtc().isAfter(exp.toUtc());
  }

  factory QrScanResponse.fromJson(Map<String, dynamic> json) =>
      _$QrScanResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrScanResponseToJson(this);
}

@JsonSerializable()
class QrApproveResponse {
  final String message;
  final Map<String, dynamic>? order;

  QrApproveResponse({
    required this.message,
    this.order,
  });

  factory QrApproveResponse.fromJson(Map<String, dynamic> json) =>
      _$QrApproveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrApproveResponseToJson(this);
}

@JsonSerializable()
class QrRejectResponse {
  final String message;

  QrRejectResponse({
    required this.message,
  });

  factory QrRejectResponse.fromJson(Map<String, dynamic> json) =>
      _$QrRejectResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrRejectResponseToJson(this);
}
