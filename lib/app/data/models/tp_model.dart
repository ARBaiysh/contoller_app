class TpModel {
  final String id;
  final String number;
  final String name;
  final String fider; // Заменили address на fider

  // Статистика - рассчитывается локально
  int totalSubscribers;
  int readingsCollected;
  int readingsAvailable;
  int readingsProcessing;
  int readingsCompleted;
  DateTime? lastUpdated;

  TpModel({
    required this.id,
    required this.number,
    required this.name,
    required this.fider,
    this.totalSubscribers = 0,
    this.readingsCollected = 0,
    this.readingsAvailable = 0,
    this.readingsProcessing = 0,
    this.readingsCompleted = 0,
    this.lastUpdated,
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

  // From JSON - только базовые поля от API
  factory TpModel.fromJson(Map<String, dynamic> json) {
    return TpModel(
      id: json['id'] ?? '',
      number: json['number'] ?? '',
      name: json['name'] ?? '',
      fider: json['fider'] ?? '',
    );
  }

  // To JSON - включаем все поля для локального использования
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'fider': fider,
      'total_subscribers': totalSubscribers,
      'readings_collected': readingsCollected,
      'readings_available': readingsAvailable,
      'readings_processing': readingsProcessing,
      'readings_completed': readingsCompleted,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  // Copy with - для обновления статистики
  TpModel copyWith({
    String? id,
    String? number,
    String? name,
    String? fider,
    int? totalSubscribers,
    int? readingsCollected,
    int? readingsAvailable,
    int? readingsProcessing,
    int? readingsCompleted,
    DateTime? lastUpdated,
  }) {
    return TpModel(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      fider: fider ?? this.fider,
      totalSubscribers: totalSubscribers ?? this.totalSubscribers,
      readingsCollected: readingsCollected ?? this.readingsCollected,
      readingsAvailable: readingsAvailable ?? this.readingsAvailable,
      readingsProcessing: readingsProcessing ?? this.readingsProcessing,
      readingsCompleted: readingsCompleted ?? this.readingsCompleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Обновить статистику на основе списка абонентов
  void updateStatistics(List<dynamic> subscribers) {
    totalSubscribers = subscribers.length;
    readingsCollected = 0;
    readingsAvailable = 0;
    readingsProcessing = 0;
    readingsCompleted = 0;

    for (var subscriber in subscribers) {
      final status = subscriber['readingStatus'] ?? 'available';
      switch (status) {
        case 'completed':
          readingsCompleted++;
          readingsCollected++;
          break;
        case 'processing':
          readingsProcessing++;
          readingsCollected++;
          break;
        case 'available':
          readingsAvailable++;
          break;
      }
    }

    lastUpdated = DateTime.now();
  }
}