// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InspectorData _$InspectorDataFromJson(Map<String, dynamic> json) =>
    InspectorData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      externalId: json['externalId'] as String? ?? '',
      regionCode: json['regionCode'] as String? ?? '',
      regionName: json['regionName'] as String? ?? '',
    );

Map<String, dynamic> _$InspectorDataToJson(InspectorData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'fullName': instance.fullName,
      'externalId': instance.externalId,
      'regionCode': instance.regionCode,
      'regionName': instance.regionName,
    };
