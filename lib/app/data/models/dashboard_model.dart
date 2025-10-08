class DashboardModel {
  final DateTime generatedAt;
  final int totalTransformerPoints;
  final int totalAbonents;
  final int totalReadingsNeeded;
  final int readingsCollected;
  final int readingsRemaining;
  final double completionPercentage;
  final int readingsToday;
  final int totalConsumptionThisMonth;
  final double totalChargeThisMonth;
  final int debtorsCount;
  final double totalDebtAmount;
  final double totalOverpaymentAmount;
  final int paidThisMonth;
  final double totalPaymentsThisMonth;
  final int paidToday;
  final double totalPaymentsToday;
  final bool fullSyncInProgress;
  final DateTime? fullSyncStartedAt;
  final DateTime? lastFullSyncCompleted;

  DashboardModel({
    required this.generatedAt,
    required this.totalTransformerPoints,
    required this.totalAbonents,
    required this.totalReadingsNeeded,
    required this.readingsCollected,
    required this.readingsRemaining,
    required this.completionPercentage,
    required this.readingsToday,
    required this.totalConsumptionThisMonth,
    required this.totalChargeThisMonth,
    required this.debtorsCount,
    required this.totalDebtAmount,
    required this.totalOverpaymentAmount,
    required this.paidThisMonth,
    required this.totalPaymentsThisMonth,
    required this.paidToday,
    required this.totalPaymentsToday,
    required this.fullSyncInProgress,
    this.fullSyncStartedAt,
    this.lastFullSyncCompleted,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // ✅ ИСПРАВЛЕННАЯ функция для безопасного парсинга дат
    DateTime? parseDateTime(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;

      try {
        print('[DashboardModel] Parsing date string: "$dateString"');

        final parsed = DateTime.parse(dateString);
        print('[DashboardModel] Parsed result: $parsed (isUtc: ${parsed.isUtc})');

        // ✅ ПРАВИЛЬНАЯ проверка timezone
        final hasTimezone = dateString.endsWith('Z') ||
            RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(dateString);

        if (hasTimezone) {
          print('[DashboardModel] ✅ Date has timezone (UTC)');
          return parsed;
        } else {
          print('[DashboardModel] ⚠️  Date has NO timezone (LOCAL)');
          // Явно создаем локальное время
          return DateTime(
            parsed.year, parsed.month, parsed.day,
            parsed.hour, parsed.minute, parsed.second,
            parsed.millisecond, parsed.microsecond,
          );
        }
      } catch (e) {
        print('[DashboardModel] ❌ Error: $e');
        return null;
      }
    }

    return DashboardModel(
      generatedAt: parseDateTime(json['generatedAt']) ?? DateTime.now(),
      totalTransformerPoints: json['totalTransformerPoints'] ?? 0,
      totalAbonents: json['totalAbonents'] ?? 0,
      totalReadingsNeeded: json['totalReadingsNeeded'] ?? 0,
      readingsCollected: json['readingsCollected'] ?? 0,
      readingsRemaining: json['readingsRemaining'] ?? 0,
      completionPercentage: (json['completionPercentage'] ?? 0).toDouble(),
      readingsToday: json['readingsToday'] ?? 0,

      // НОВЫЕ ПОЛЯ
      totalConsumptionThisMonth: json['totalConsumptionThisMonth'] ?? 0,
      totalChargeThisMonth: (json['totalChargeThisMonth'] ?? 0).toDouble(),

      debtorsCount: json['debtorsCount'] ?? 0,
      totalDebtAmount: (json['totalDebtAmount'] ?? 0).toDouble(),
      totalOverpaymentAmount: (json['totalOverpaymentAmount'] ?? 0).toDouble(),
      paidThisMonth: json['paidThisMonth'] ?? 0,
      totalPaymentsThisMonth: (json['totalPaymentsThisMonth'] ?? 0).toDouble(),
      paidToday: json['paidToday'] ?? 0,
      totalPaymentsToday: (json['totalPaymentsToday'] ?? 0).toDouble(),
      fullSyncInProgress: json['fullSyncInProgress'] ?? false,
      fullSyncStartedAt: parseDateTime(json['fullSyncStartedAt']),
      lastFullSyncCompleted: parseDateTime(json['lastFullSyncCompleted']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'totalTransformerPoints': totalTransformerPoints,
      'totalAbonents': totalAbonents,
      'totalReadingsNeeded': totalReadingsNeeded,
      'readingsCollected': readingsCollected,
      'readingsRemaining': readingsRemaining,
      'completionPercentage': completionPercentage,
      'readingsToday': readingsToday,
      'totalConsumptionThisMonth': totalConsumptionThisMonth,
      'totalChargeThisMonth': totalChargeThisMonth,
      'debtorsCount': debtorsCount,
      'totalDebtAmount': totalDebtAmount,
      'totalOverpaymentAmount': totalOverpaymentAmount,
      'paidThisMonth': paidThisMonth,
      'totalPaymentsThisMonth': totalPaymentsThisMonth,
      'paidToday': paidToday,
      'totalPaymentsToday': totalPaymentsToday,
      'fullSyncInProgress': fullSyncInProgress,
      'fullSyncStartedAt': fullSyncStartedAt?.toIso8601String(),
      'lastFullSyncCompleted': lastFullSyncCompleted?.toIso8601String(),
    };
  }

  static DashboardModel empty() {
    return DashboardModel(
      generatedAt: DateTime.now(),
      totalTransformerPoints: 0,
      totalAbonents: 0,
      totalReadingsNeeded: 0,
      readingsCollected: 0,
      readingsRemaining: 0,
      completionPercentage: 0,
      readingsToday: 0,
      totalConsumptionThisMonth: 0,
      totalChargeThisMonth: 0,
      debtorsCount: 0,
      totalDebtAmount: 0,
      totalOverpaymentAmount: 0,
      paidThisMonth: 0,
      totalPaymentsThisMonth: 0,
      paidToday: 0,
      totalPaymentsToday: 0,
      fullSyncInProgress: false,
      fullSyncStartedAt: null,
      lastFullSyncCompleted: null,
    );
  }
}