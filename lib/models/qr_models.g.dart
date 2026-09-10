// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelyingParty _$RelyingPartyFromJson(Map<String, dynamic> json) => RelyingParty(
      id: json['id'] as String,
      name: json['name'] as String,
      domain: json['domain'] as String,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$RelyingPartyToJson(RelyingParty instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'domain': instance.domain,
      'logo_url': instance.logoUrl,
    };

QrScanResponse _$QrScanResponseFromJson(Map<String, dynamic> json) =>
    QrScanResponse(
      approvalRef: json['approval_ref'] as String,
      intent: json['intent'] as String,
      userVisibleData: json['user_visible_data'] as String?,
      expiresAt: json['expires_at'] as String?,
      relyingParty:
          RelyingParty.fromJson(json['relying_party'] as Map<String, dynamic>),
      requiresApproval: json['requires_approval'] as bool? ?? true,
    );

Map<String, dynamic> _$QrScanResponseToJson(QrScanResponse instance) =>
    <String, dynamic>{
      'approval_ref': instance.approvalRef,
      'intent': instance.intent,
      'user_visible_data': instance.userVisibleData,
      'expires_at': instance.expiresAt,
      'relying_party': instance.relyingParty,
      'requires_approval': instance.requiresApproval,
    };

QrApproveResponse _$QrApproveResponseFromJson(Map<String, dynamic> json) =>
    QrApproveResponse(
      message: json['message'] as String,
      order: json['order'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$QrApproveResponseToJson(QrApproveResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'order': instance.order,
    };

QrRejectResponse _$QrRejectResponseFromJson(Map<String, dynamic> json) =>
    QrRejectResponse(
      message: json['message'] as String,
    );

Map<String, dynamic> _$QrRejectResponseToJson(QrRejectResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
