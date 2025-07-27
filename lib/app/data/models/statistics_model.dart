class StatisticsModel {
  final int totalSubscribers;
  final int readingsCollected;
  final int readingsRemaining;
  final int paidSubscribers;
  final int debtorCount;
  final double totalDebtAmount;
  final double totalCollectedAmount;
  final DateTime lastUpdated;

  StatisticsModel({
    required this.totalSubscribers,
    required this.readingsCollected,
    required this.readingsRemaining,
    required this.paidSubscribers,
    required this.debtorCount,
    required this.totalDebtAmount,
    required this.totalCollectedAmount,
    required this.lastUpdated,
  });

  // Calculate collection percentage
  double get collectionPercentage {
    if (totalSubscribers == 0) return 0;
    return (readingsCollected / totalSubscribers) * 100;
  }

  // Calculate payment percentage
  double get paymentPercentage {
    if (totalSubscribers == 0) return 0;
    return (paidSubscribers / totalSubscribers) * 100;
  }

  // Calculate debtor percentage
  double get debtorPercentage {
    if (totalSubscribers == 0) return 0;
    return (debtorCount / totalSubscribers) * 100;
  }

  // Check if collection is completed
  bool get isCollectionCompleted => readingsRemaining == 0;

  // From JSON
  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalSubscribers: json['total_subscribers'] ?? 0,
      readingsCollected: json['readings_collected'] ?? 0,
      readingsRemaining: json['readings_remaining'] ?? 0,
      paidSubscribers: json['paid_subscribers'] ?? 0,
      debtorCount: json['debtor_count'] ?? 0,
      totalDebtAmount: (json['total_debt_amount'] ?? 0).toDouble(),
      totalCollectedAmount: (json['total_collected_amount'] ?? 0).toDouble(),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'total_subscribers': totalSubscribers,
      'readings_collected': readingsCollected,
      'readings_remaining': readingsRemaining,
      'paid_subscribers': paidSubscribers,
      'debtor_count': debtorCount,
      'total_debt_amount': totalDebtAmount,
      'total_collected_amount': totalCollectedAmount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Copy with
  StatisticsModel copyWith({
    int? totalSubscribers,
    int? readingsCollected,
    int? readingsRemaining,
    int? paidSubscribers,
    int? debtorCount,
    double? totalDebtAmount,
    double? totalCollectedAmount,
    DateTime? lastUpdated,
  }) {
    return StatisticsModel(
      totalSubscribers: totalSubscribers ?? this.totalSubscribers,
      readingsCollected: readingsCollected ?? this.readingsCollected,
      readingsRemaining: readingsRemaining ?? this.readingsRemaining,
      paidSubscribers: paidSubscribers ?? this.paidSubscribers,
      debtorCount: debtorCount ?? this.debtorCount,
      totalDebtAmount: totalDebtAmount ?? this.totalDebtAmount,
      totalCollectedAmount: totalCollectedAmount ?? this.totalCollectedAmount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Empty statistics
  factory StatisticsModel.empty() {
    return StatisticsModel(
      totalSubscribers: 0,
      readingsCollected: 0,
      readingsRemaining: 0,
      paidSubscribers: 0,
      debtorCount: 0,
      totalDebtAmount: 0.0,
      totalCollectedAmount: 0.0,
      lastUpdated: DateTime.now(),
    );
  }
}