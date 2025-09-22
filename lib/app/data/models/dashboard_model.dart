class DashboardModel {
  final DateTime generatedAt;
  final int totalTransformerPoints;
  final int totalAbonents;
  final int totalReadingsNeeded;
  final int readingsCollected;
  final int readingsRemaining;
  final double completionPercentage;
  final int readingsToday;
  final int debtorsCount;
  final double totalDebtAmount;
  final double totalOverpaymentAmount;
  final int paidThisMonth;
  final double totalPaymentsThisMonth;
  final int paidToday;
  final double totalPaymentsToday;

  // Новые поля для полной синхронизации
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
    required this.debtorsCount,
    required this.totalDebtAmount,
    required this.totalOverpaymentAmount,
    required this.paidThisMonth,
    required this.totalPaymentsThisMonth,
    required this.paidToday,
    required this.totalPaymentsToday,
    // Новые поля
    required this.fullSyncInProgress,
    this.fullSyncStartedAt,
    this.lastFullSyncCompleted,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // Функция для безопасного парсинга дат
    DateTime? parseDateTime(String? dateString) {
      if (dateString == null) return null;
      try {
        print('[DashboardModel] Parsing date string: $dateString');

        // Парсим дату
        final parsed = DateTime.parse(dateString);
        print('[DashboardModel] Parsed as: $parsed (isUtc: ${parsed.isUtc})');

        // Если строка содержит 'Z' или явный часовой пояс, доверяем парсеру
        if (dateString.endsWith('Z') || dateString.contains('+') || dateString.contains('-')) {
          print('[DashboardModel] Date has timezone info, using as-is');
          return parsed;
        } else {
          // Если нет информации о часовом поясе, считаем что это локальное время
          print('[DashboardModel] No timezone info, treating as local time');
          return parsed;
        }
      } catch (e) {
        print('[DashboardModel] Error parsing date: $dateString - $e');
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
      debtorsCount: json['debtorsCount'] ?? 0,
      totalDebtAmount: (json['totalDebtAmount'] ?? 0).toDouble(),
      totalOverpaymentAmount: (json['totalOverpaymentAmount'] ?? 0).toDouble(),
      paidThisMonth: json['paidThisMonth'] ?? 0,
      totalPaymentsThisMonth: (json['totalPaymentsThisMonth'] ?? 0).toDouble(),
      paidToday: json['paidToday'] ?? 0,
      totalPaymentsToday: (json['totalPaymentsToday'] ?? 0).toDouble(),
      // Новые поля с правильным парсингом
      fullSyncInProgress: json['fullSyncInProgress'] ?? false,
      fullSyncStartedAt: parseDateTime(json['fullSyncStartedAt']),
      lastFullSyncCompleted: parseDateTime(json['lastFullSyncCompleted']),
    );
  }

  // Вспомогательные методы для UI
  String get lastUpdateTime {
    final now = DateTime.now();
    final diff = now.difference(generatedAt.toLocal());

    if (diff.inMinutes < 1) {
      return 'только что';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} мин назад';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} ч назад';
    } else {
      return '${diff.inDays} дн назад';
    }
  }

  String get formattedPaymentsToday {
    return '${totalPaymentsToday.toStringAsFixed(0)} сом';
  }

  String get formattedPaymentsThisMonth {
    return '${totalPaymentsThisMonth.toStringAsFixed(0)} сом';
  }

  String get formattedDebtAmount {
    return '${totalDebtAmount.toStringAsFixed(0)} сом';
  }

  String get formattedOverpaymentAmount {
    return '${totalOverpaymentAmount.toStringAsFixed(0)} сом';
  }

  // Методы для статуса полной синхронизации
  String get fullSyncStatusText {
    if (fullSyncInProgress) {
      return 'Синхронизация выполняется...';
    } else if (lastFullSyncCompleted != null) {
      return 'Данные актуальны';
    } else {
      return 'Требуется синхронизация';
    }
  }

  String get fullSyncTimeText {
    if (fullSyncInProgress && fullSyncStartedAt != null) {
      return 'Начата ${_formatDateTime(fullSyncStartedAt!)}';
    } else if (lastFullSyncCompleted != null) {
      return 'Обновлено ${_formatDateTime(lastFullSyncCompleted!)}';
    } else {
      return 'Никогда';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final diff = now.difference(localDateTime);

    if (diff.inMinutes < 1) {
      return 'только что';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} мин назад';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ч назад';
    } else if (diff.inDays == 1) {
      return 'вчера в ${localDateTime.hour.toString().padLeft(2, '0')}:${localDateTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} дн назад';
    } else {
      return '${localDateTime.day}.${localDateTime.month}.${localDateTime.year}';
    }
  }

  // Иконка статуса синхронизации
  String get fullSyncStatusIcon {
    if (fullSyncInProgress) {
      return '🔄';
    } else if (lastFullSyncCompleted != null) {
      return '✅';
    } else {
      return '❌';
    }
  }

  static DashboardModel empty() {
    return DashboardModel(
      generatedAt: DateTime.now(),
      totalTransformerPoints: 0,
      totalAbonents: 0,
      totalReadingsNeeded: 0,
      readingsCollected: 0,
      readingsRemaining: 0,
      completionPercentage: 0.0,
      readingsToday: 0,
      debtorsCount: 0,
      totalDebtAmount: 0.0,
      totalOverpaymentAmount: 0.0,
      paidThisMonth: 0,
      totalPaymentsThisMonth: 0.0,
      paidToday: 0,
      totalPaymentsToday: 0.0,
      fullSyncInProgress: false,
      fullSyncStartedAt: null,
      lastFullSyncCompleted: null,
    );
  }
}