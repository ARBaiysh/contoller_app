// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tp_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TpModel _$TpModelFromJson(Map<String, dynamic> json) => TpModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      abonentCount: (json['totalAbonents'] as num?)?.toInt() ?? 0,
      lastSync: dateTimeOrNull(json['lastSync']),
      fider: json['fider'] as String? ?? '',
      readingsCollected: (json['readings_collected'] as num?)?.toInt() ?? 0,
      readingsAvailable: (json['readings_available'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TpModelToJson(TpModel instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'active': instance.active,
      'totalAbonents': instance.abonentCount,
      'lastSync': instance.lastSync?.toIso8601String(),
      'fider': instance.fider,
      'readings_collected': instance.readingsCollected,
      'readings_available': instance.readingsAvailable,
    };
