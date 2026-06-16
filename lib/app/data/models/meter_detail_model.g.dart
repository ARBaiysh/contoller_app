// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeterDetailModel _$MeterDetailModelFromJson(Map<String, dynamic> json) =>
    MeterDetailModel(
      meterType: json['meter_type'] as String? ?? '',
      meterNumber: json['meter_number'] as String? ?? '',
      meterDate: dateTimeOrNull(json['meter_date']),
      coefficient: (json['coefficient'] as num?)?.toInt() ?? 1,
      phase: (json['phase'] as num?)?.toInt() ?? 1,
      amperage: json['amperage'] as String? ?? '',
      digitCapacity: (json['digit_capacity'] as num?)?.toInt() ?? 5,
      stateSeal: json['state_seal'] as String? ?? '',
      oneTimeSeal: json['one_time_seal'] as String? ?? '',
      coverSeal: json['cover_seal'] as String? ?? '',
      boxSeal: json['box_seal'] as String? ?? '',
    );

Map<String, dynamic> _$MeterDetailModelToJson(MeterDetailModel instance) =>
    <String, dynamic>{
      'meter_type': instance.meterType,
      'meter_number': instance.meterNumber,
      'meter_date': instance.meterDate?.toIso8601String(),
      'coefficient': instance.coefficient,
      'phase': instance.phase,
      'amperage': instance.amperage,
      'digit_capacity': instance.digitCapacity,
      'state_seal': instance.stateSeal,
      'one_time_seal': instance.oneTimeSeal,
      'cover_seal': instance.coverSeal,
      'box_seal': instance.boxSeal,
    };
