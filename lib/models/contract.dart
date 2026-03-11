import 'package:json_annotation/json_annotation.dart';

part 'contract.g.dart';

@JsonSerializable()
class ContractUser {
  final String id;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String email;

  ContractUser({required this.id, required this.fullName, required this.email});

  factory ContractUser.fromJson(Map<String, dynamic> json) =>
      _$ContractUserFromJson(json);
  Map<String, dynamic> toJson() => _$ContractUserToJson(this);
}

@JsonSerializable()
class Contract {
  final String id;
  final String title;
  final String? subtitle;
  final String? description;
  final String status;
  final String? type;
  final String? date;
  @JsonKey(name: 'pdf_url')
  final String? pdfUrl;
  @JsonKey(name: 'document_path')
  final String? documentPath;
  @JsonKey(name: 'signed_document_path')
  final String? signedDocumentPath;
  final String? content;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'created_by')
  final ContractUser? createdBy;
  final ContractUser? signer;

  Contract({
    required this.id,
    required this.title,
    this.subtitle,
    this.description,
    required this.status,
    this.type,
    this.date,
    this.pdfUrl,
    this.documentPath,
    this.signedDocumentPath,
    this.content,
    this.expiresAt,
    this.createdAt,
    this.createdBy,
    this.signer,
  });

  factory Contract.fromJson(Map<String, dynamic> json) =>
      _$ContractFromJson(json);
  Map<String, dynamic> toJson() => _$ContractToJson(this);
}
