class TpModel {
  final String id;
  final String number;
  final String name;
  final String address;
  final int totalSubscribers;
  final int readingsCollected;
  final int readingsAvailable;
  final int readingsProcessing;
  final int readingsCompleted;
  final DateTime? lastUpdated;

  TpModel({
    required this.id,
    required this.number,
    required this.name,
    required this.address,
    required this.totalSubscribers,
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
  bool get isCompleted => readingsCollected == totalSubscribers;

  // Get status color based on progress
  String get status {
    if (isCompleted) return 'completed';
    if (readingsCollected > 0) return 'in_progress';
    return 'not_started';
  }

  // From JSON
  factory TpModel.fromJson(Map<String, dynamic> json) {
    return TpModel(
      id: json['id']?.toString() ?? '',
      number: json['number'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      totalSubscribers: json['total_subscribers'] ?? 0,
      readingsCollected: json['readings_collected'] ?? 0,
      readingsAvailable: json['readings_available'] ?? 0,
      readingsProcessing: json['readings_processing'] ?? 0,
      readingsCompleted: json['readings_completed'] ?? 0,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'name': name,
      'address': address,
      'total_subscribers': totalSubscribers,
      'readings_collected': readingsCollected,
      'readings_available': readingsAvailable,
      'readings_processing': readingsProcessing,
      'readings_completed': readingsCompleted,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  // Copy with
  TpModel copyWith({
    String? id,
    String? number,
    String? name,
    String? address,
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
      address: address ?? this.address,
      totalSubscribers: totalSubscribers ?? this.totalSubscribers,
      readingsCollected: readingsCollected ?? this.readingsCollected,
      readingsAvailable: readingsAvailable ?? this.readingsAvailable,
      readingsProcessing: readingsProcessing ?? this.readingsProcessing,
      readingsCompleted: readingsCompleted ?? this.readingsCompleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}