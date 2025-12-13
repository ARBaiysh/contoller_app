import 'package:intl/intl.dart';

/// Модель детальных данных счётчика
class MeterDetailModel {
  final String meterType;
  final String meterNumber;
  final DateTime? meterDate;
  final int coefficient;
  final int phase;
  final String amperage;
  final int digitCapacity;
  final String stateSeal;
  final String oneTimeSeal;
  final String coverSeal;
  final String boxSeal;

  MeterDetailModel({
    required this.meterType,
    required this.meterNumber,
    this.meterDate,
    required this.coefficient,
    required this.phase,
    required this.amperage,
    required this.digitCapacity,
    required this.stateSeal,
    required this.oneTimeSeal,
    required this.coverSeal,
    required this.boxSeal,
  });

  factory MeterDetailModel.fromJson(Map<String, dynamic> json) {
    return MeterDetailModel(
      meterType: json['meter_type'] ?? '',
      meterNumber: json['meter_number'] ?? '',
      meterDate: json['meter_date'] != null
          ? DateTime.tryParse(json['meter_date'])
          : null,
      coefficient: json['coefficient'] ?? 1,
      phase: json['phase'] ?? 1,
      amperage: json['amperage'] ?? '',
      digitCapacity: json['digit_capacity'] ?? 5,
      stateSeal: json['state_seal'] ?? '',
      oneTimeSeal: json['one_time_seal'] ?? '',
      coverSeal: json['cover_seal'] ?? '',
      boxSeal: json['box_seal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meter_type': meterType,
      'meter_number': meterNumber,
      'meter_date': meterDate?.toIso8601String(),
      'coefficient': coefficient,
      'phase': phase,
      'amperage': amperage,
      'digit_capacity': digitCapacity,
      'state_seal': stateSeal,
      'one_time_seal': oneTimeSeal,
      'cover_seal': coverSeal,
      'box_seal': boxSeal,
    };
  }

  /// Форматированная дата установки
  String get formattedMeterDate {
    if (meterDate == null) return 'Не указана';
    return DateFormat('dd.MM.yyyy').format(meterDate!);
  }

  /// Текстовое описание фазности
  String get phaseDescription {
    switch (phase) {
      case 1:
        return 'Однофазный';
      case 3:
        return 'Трёхфазный';
      default:
        return '$phase-фазный';
    }
  }

  /// Проверка валидности пломбы
  bool isSealValid(String? seal) {
    if (seal == null || seal.isEmpty) return false;
    final invalidValues = ['неопределено', 'не указано', 'нет', '-', ''];
    return !invalidValues.contains(seal.toLowerCase().trim());
  }

  @override
  String toString() {
    return 'MeterDetailModel(meterType: $meterType, meterNumber: $meterNumber)';
  }
}
