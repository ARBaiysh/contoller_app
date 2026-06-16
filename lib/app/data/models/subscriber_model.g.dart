// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriber_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriberModel _$SubscriberModelFromJson(Map<String, dynamic> json) =>
    SubscriberModel(
      accountNumber: json['accountNumber'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: _phoneFromJson(json['phone']),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      meterSerialNumber: json['meterSerialNumber'] as String? ?? '',
      meterType: json['meterType'] as String?,
      askueUuid: json['askueUuid'] as String?,
      currentReading: (json['lastReading'] as num?)?.toInt() ?? 0,
      previousReading: (json['previousReading'] as num?)?.toInt() ?? 0,
      lastReadingDate: dateTimeOrNull(json['lastReadingDate']),
      currentMonthConsumption:
          (json['currentMonthConsumption'] as num?)?.toDouble() ?? 0.0,
      currentMonthCharge:
          (json['currentMonthCharge'] as num?)?.toDouble() ?? 0.0,
      lastPaymentDate: dateTimeOrNull(json['lastPaymentDate']),
      lastPaymentAmount: (json['lastPaymentAmount'] as num?)?.toDouble() ?? 0.0,
      tariff: (json['tariff'] as num?)?.toDouble() ?? 0.0,
      tariffName: json['tariffName'] as String?,
      transformerPointCode: json['transformerPointCode'] as String? ?? '',
      transformerPointName: json['transformerPointName'] as String? ?? '',
      contractDate: json['contractDate'] as String?,
      notes: json['notes'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SubscriberModelToJson(SubscriberModel instance) =>
    <String, dynamic>{
      'accountNumber': instance.accountNumber,
      'fullName': instance.fullName,
      'address': instance.address,
      'phone': instance.phone,
      'balance': instance.balance,
      'meterSerialNumber': instance.meterSerialNumber,
      'meterType': instance.meterType,
      'askueUuid': instance.askueUuid,
      'lastReading': instance.currentReading,
      'previousReading': instance.previousReading,
      'lastReadingDate': instance.lastReadingDate?.toIso8601String(),
      'currentMonthConsumption': instance.currentMonthConsumption,
      'currentMonthCharge': instance.currentMonthCharge,
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'lastPaymentAmount': instance.lastPaymentAmount,
      'tariff': instance.tariff,
      'tariffName': instance.tariffName,
      'transformerPointCode': instance.transformerPointCode,
      'transformerPointName': instance.transformerPointName,
      'contractDate': instance.contractDate,
      'notes': instance.notes,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
    };
