// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContractUser _$ContractUserFromJson(Map<String, dynamic> json) => ContractUser(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$ContractUserToJson(ContractUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'email': instance.email,
    };

Contract _$ContractFromJson(Map<String, dynamic> json) => Contract(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String,
  type: json['type'] as String?,
  date: json['date'] as String?,
  pdfUrl: json['pdf_url'] as String?,
  documentPath: json['document_path'] as String?,
  signedDocumentPath: json['signed_document_path'] as String?,
  content: json['content'] as String?,
  expiresAt: json['expires_at'] as String?,
  createdAt: json['created_at'] as String?,
  createdBy: json['created_by'] == null
      ? null
      : ContractUser.fromJson(json['created_by'] as Map<String, dynamic>),
  signer: json['signer'] == null
      ? null
      : ContractUser.fromJson(json['signer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ContractToJson(Contract instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'description': instance.description,
  'status': instance.status,
  'type': instance.type,
  'date': instance.date,
  'pdf_url': instance.pdfUrl,
  'document_path': instance.documentPath,
  'signed_document_path': instance.signedDocumentPath,
  'content': instance.content,
  'expires_at': instance.expiresAt,
  'created_at': instance.createdAt,
  'created_by': instance.createdBy,
  'signer': instance.signer,
};
