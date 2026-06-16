import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'meter_detail_model.g.dart';

/// Модель детальных данных счётчика.
/// Бэкенд (MeterDataDto) отдаёт поля в snake_case — отсюда fieldRename.snake.
@JsonSerializable(fieldRename: FieldRename.snake)
class MeterDetailModel {
  @JsonKey(defaultValue: '')
  final String meterType;
  @JsonKey(defaultValue: '')
  final String meterNumber;
  @JsonKey(fromJson: dateTimeOrNull)
  final DateTime? meterDate;
  @JsonKey(defaultValue: 1)
  final int coefficient;
  @JsonKey(defaultValue: 1)
  final int phase;
  @JsonKey(defaultValue: '')
  final String amperage;
  @JsonKey(defaultValue: 5)
  final int digitCapacity;
  @JsonKey(defaultValue: '')
  final String stateSeal;
  @JsonKey(defaultValue: '')
  final String oneTimeSeal;
  @JsonKey(defaultValue: '')
  final String coverSeal;
  @JsonKey(defaultValue: '')
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

  factory MeterDetailModel.fromJson(Map<String, dynamic> json) =>
      _$MeterDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeterDetailModelToJson(this);

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
