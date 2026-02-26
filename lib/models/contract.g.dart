// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contract _$ContractFromJson(Map<String, dynamic> json) => Contract(
  id: json['id'] as String,
  title: json['title'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$ContractToJson(Contract instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': instance.status,
};
