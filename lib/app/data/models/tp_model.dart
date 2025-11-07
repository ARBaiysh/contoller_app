// lib/app/data/models/tp_model.dart

class TpModel {
  final String code;
  final String name;
  final bool active;
  final int abonentCount;
  final DateTime? lastSync;
  final String fider;
  final int readingsCollected;
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

  factory TpModel.fromJson(Map<String, dynamic> json) {
    return TpModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      active: json['active'] ?? true,
      abonentCount: json['abonentCount'] ?? json['totalAbonents'] ?? 0,
      lastSync: json['lastSync'] != null
        ? DateTime.tryParse(json['lastSync'])
        : null,
      fider: json['fider'] ?? '',
      readingsCollected: json['readings_collected'] ?? 0,
      readingsAvailable: json['readings_available'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'active': active,
      'abonentCount': abonentCount,
      'lastSync': lastSync?.toIso8601String(),
      'fider': fider,
      'readings_collected': readingsCollected,
      'readings_available': readingsAvailable,
    };
  }

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