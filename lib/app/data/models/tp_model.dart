// lib/app/data/models/tp_model.dart

import 'package:json_annotation/json_annotation.dart';

import 'json_converters.dart';

part 'tp_model.g.dart';

@JsonSerializable()
class TpModel {
  @JsonKey(defaultValue: '')
  final String code;
  @JsonKey(defaultValue: '')
  final String name;
  // Бэкенд не присылает 'active' — по умолчанию true (как было в ручном fromJson)
  @JsonKey(defaultValue: true)
  final bool active;
  // Бэкенд присылает количество абонентов в поле 'totalAbonents'
  @JsonKey(name: 'totalAbonents', defaultValue: 0)
  final int abonentCount;
  @JsonKey(fromJson: dateTimeOrNull)
  final DateTime? lastSync;
  @JsonKey(defaultValue: '')
  final String fider;
  @JsonKey(name: 'readings_collected', defaultValue: 0)
  final int readingsCollected;
  @JsonKey(name: 'readings_available', defaultValue: 0)
  final int readingsAvailable;

  TpModel({
    required this.code,
    required this.name,
    required this.active,
    required this.abonentCount,
    this.lastSync,
    required this.fider,
    required this.readingsCollected,
    required this.readingsAvailable,
  });

  // Для обратной совместимости с кодом, использующим id
  String get id => code;
  int get totalSubscribers => abonentCount;
  String get number => code; // Для обратной совместимости

  // Прогресс сбора показаний
  double get progressPercentage {
    if (totalSubscribers == 0) return 0.0;
    return (readingsCollected / totalSubscribers) * 100.0;
  }

  // Проверка завершенности сбора показаний
  bool get isCompleted => readingsCollected >= totalSubscribers;

  factory TpModel.fromJson(Map<String, dynamic> json) => _$TpModelFromJson(json);

  Map<String, dynamic> toJson() => _$TpModelToJson(this);

  static TpModel empty() {
    return TpModel(
      code: '',
      name: '',
      active: false,
      abonentCount: 0,
      lastSync: null,
      fider: '',
      readingsCollected: 0,
      readingsAvailable: 0,
    );
  }
}
