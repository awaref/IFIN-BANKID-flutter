import 'package:json_annotation/json_annotation.dart';

part 'contract.g.dart';

@JsonSerializable()
class Contract {
  final String id;
  final String title;
  final String? subtitle;
  final String status;
  final String? type;
  final String? date;

  Contract({
    required this.id,
    required this.title,
    this.subtitle,
    required this.status,
    this.type,
    this.date,
  });

  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);
  Map<String, dynamic> toJson() => _$ContractToJson(this);
}
