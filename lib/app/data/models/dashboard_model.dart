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
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      generatedAt: DateTime.parse(json['generatedAt']),
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
    );
  }

  // Вспомогательные методы для форматирования
  String get formattedDebtAmount => '${totalDebtAmount.toStringAsFixed(0)} сом';
  String get formattedOverpaymentAmount => '${totalOverpaymentAmount.toStringAsFixed(0)} сом';
  String get formattedPaymentsToday => '${totalPaymentsToday.toStringAsFixed(0)} сом';
  String get formattedPaymentsThisMonth => '${totalPaymentsThisMonth.toStringAsFixed(0)} сом';

  // Процент должников
  double get debtorsPercentage {
    if (totalAbonents == 0) return 0;
    return (debtorsCount / totalAbonents) * 100;
  }

  // Чистый баланс (переплаты - долги)
  double get netBalance => totalOverpaymentAmount - totalDebtAmount;
  String get formattedNetBalance => '${netBalance.toStringAsFixed(0)} сом';

  // Для удобного отображения времени последнего обновления
  String get lastUpdateTime {
    final now = DateTime.now();
    final difference = now.difference(generatedAt);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else {
      return '${difference.inDays} д назад';
    }
  }
}