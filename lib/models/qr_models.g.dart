// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartnerWebsite _$PartnerWebsiteFromJson(Map<String, dynamic> json) =>
    PartnerWebsite(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: json['domain'] as String,
    );

Map<String, dynamic> _$PartnerWebsiteToJson(PartnerWebsite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'domain': instance.domain,
    };

QrScanResponse _$QrScanResponseFromJson(Map<String, dynamic> json) =>
    QrScanResponse(
      sessionToken: json['session_token'] as String,
      partnerWebsite: PartnerWebsite.fromJson(
        json['partner_website'] as Map<String, dynamic>,
      ),
      requiresApproval: json['requires_approval'] as bool,
    );

Map<String, dynamic> _$QrScanResponseToJson(QrScanResponse instance) =>
    <String, dynamic>{
      'session_token': instance.sessionToken,
      'partner_website': instance.partnerWebsite,
      'requires_approval': instance.requiresApproval,
    };

QrApproveResponse _$QrApproveResponseFromJson(Map<String, dynamic> json) =>
    QrApproveResponse(
      message: json['message'] as String,
      session: json['session'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QrApproveResponseToJson(QrApproveResponse instance) =>
    <String, dynamic>{'message': instance.message, 'session': instance.session};

QrRejectResponse _$QrRejectResponseFromJson(Map<String, dynamic> json) =>
    QrRejectResponse(message: json['message'] as String);

Map<String, dynamic> _$QrRejectResponseToJson(QrRejectResponse instance) =>
    <String, dynamic>{'message': instance.message};
