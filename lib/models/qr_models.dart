import 'package:json_annotation/json_annotation.dart';

part 'qr_models.g.dart';

@JsonSerializable()
class PartnerWebsite {
  final String id;
  final String name;
  final String domain;

  PartnerWebsite({
    required this.id,
    required this.name,
    required this.domain,
  });

  factory PartnerWebsite.fromJson(Map<String, dynamic> json) => _$PartnerWebsiteFromJson(json);
  Map<String, dynamic> toJson() => _$PartnerWebsiteToJson(this);
}

@JsonSerializable()
class QrScanResponse {
  @JsonKey(name: 'session_token')
  final String sessionToken;
  @JsonKey(name: 'partner_website')
  final PartnerWebsite partnerWebsite;
  @JsonKey(name: 'requires_approval')
  final bool requiresApproval;

  QrScanResponse({
    required this.sessionToken,
    required this.partnerWebsite,
    required this.requiresApproval,
  });

  factory QrScanResponse.fromJson(Map<String, dynamic> json) => _$QrScanResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrScanResponseToJson(this);
}

@JsonSerializable()
class QrApproveResponse {
  final String message;
  final Map<String, dynamic> session;

  QrApproveResponse({
    required this.message,
    required this.session,
  });

  factory QrApproveResponse.fromJson(Map<String, dynamic> json) => _$QrApproveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrApproveResponseToJson(this);
}

@JsonSerializable()
class QrRejectResponse {
  final String message;

  QrRejectResponse({
    required this.message,
  });

  factory QrRejectResponse.fromJson(Map<String, dynamic> json) => _$QrRejectResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrRejectResponseToJson(this);
}
