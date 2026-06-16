// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      totalAbonents: (json['totalAbonents'] as num?)?.toInt() ?? 0,
      totalTransformerPoints:
          (json['totalTransformerPoints'] as num?)?.toInt() ?? 0,
      readingsThisMonth: (json['readingsThisMonth'] as num?)?.toInt() ?? 0,
      totalCharge: (json['totalCharge'] as num?)?.toDouble() ?? 0,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0,
      totalPrepayment: (json['totalPrepayment'] as num?)?.toDouble() ?? 0,
      totalConsumption: (json['totalConsumption'] as num?)?.toDouble() ?? 0,
      paymentCountThisMonth:
          (json['paymentCountThisMonth'] as num?)?.toInt() ?? 0,
      totalPaymentAmount: (json['totalPaymentAmount'] as num?)?.toDouble() ?? 0,
      coordinatesTotal: (json['coordinatesTotal'] as num?)?.toInt() ?? 0,
      coordinatesThisMonth:
          (json['coordinatesThisMonth'] as num?)?.toInt() ?? 0,
      coordinatesToday: (json['coordinatesToday'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'totalAbonents': instance.totalAbonents,
      'totalTransformerPoints': instance.totalTransformerPoints,
      'readingsThisMonth': instance.readingsThisMonth,
      'totalCharge': instance.totalCharge,
      'totalDebt': instance.totalDebt,
      'totalPrepayment': instance.totalPrepayment,
      'totalConsumption': instance.totalConsumption,
      'paymentCountThisMonth': instance.paymentCountThisMonth,
      'totalPaymentAmount': instance.totalPaymentAmount,
      'coordinatesTotal': instance.coordinatesTotal,
      'coordinatesThisMonth': instance.coordinatesThisMonth,
      'coordinatesToday': instance.coordinatesToday,
    };
