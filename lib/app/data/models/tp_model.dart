// lib/app/data/models/tp_model.dart

class TpModel {
  final String id;
  final String number;
  final String name;
  final String fider;

  // Статистика от API
  final int totalSubscribers;
  final int readingsCollected;
  final int readingsAvailable;

  TpModel({
    required this.id,
    required this.number,
    required this.name,
    required this.fider,
    required this.totalSubscribers,
    required this.readingsCollected,
    required this.readingsAvailable,
  });

  // Calculate progress percentage
  double get progressPercentage {
    if (totalSubscribers == 0) return 0;
    return (readingsCollected / totalSubscribers) * 100;
  }

  // Check if all readings are collected
  bool get isCompleted => totalSubscribers > 0 && readingsCollected == totalSubscribers;

  // Get status based on progress
  String get status {
    if (totalSubscribers == 0) return 'not_started';
    if (isCompleted) return 'completed';
    if (readingsCollected > 0) return 'in_progress';
    return 'not_started';
  }

  // From JSON - парсим данные от API
  factory TpModel.fromJson(Map<String, dynamic> json) {
    return TpModel(
      id: json['id'] ?? '',
      number: json['number'] ?? '',
      name: json['name'] ?? '',
      fider: json['fider'] ?? '',
      totalSubscribers: json['total_subscribers'] ?? 0,
      readingsCollected: json['readings_collected'] ?? 0,
      readingsAvailable: json['readings_available'] ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'fider': fider,
      'total_subscribers': totalSubscribers,
      'readings_collected': readingsCollected,
      'readings_available': readingsAvailable,
    };
  }
}