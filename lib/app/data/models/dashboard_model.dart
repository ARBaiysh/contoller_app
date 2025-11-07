class DashboardModel {
  final int totalAbonents;
  final int totalTransformerPoints;
  final int readingsThisMonth;
  final double totalCharge;
  final double totalDebt;
  final double totalPrepayment;
  final double totalConsumption;
  final int paymentCountThisMonth;
  final double totalPaymentAmount;

  DashboardModel({
    required this.totalAbonents,
    required this.totalTransformerPoints,
    required this.readingsThisMonth,
    required this.totalCharge,
    required this.totalDebt,
    required this.totalPrepayment,
    required this.totalConsumption,
    required this.paymentCountThisMonth,
    required this.totalPaymentAmount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalAbonents: json['totalAbonents'] ?? 0,
      totalTransformerPoints: json['totalTransformerPoints'] ?? 0,
      readingsThisMonth: json['readingsThisMonth'] ?? 0,
      totalCharge: (json['totalCharge'] ?? 0).toDouble(),
      totalDebt: (json['totalDebt'] ?? 0).toDouble(),
      totalPrepayment: (json['totalPrepayment'] ?? 0).toDouble(),
      totalConsumption: (json['totalConsumption'] ?? 0).toDouble(),
      paymentCountThisMonth: json['paymentCountThisMonth'] ?? 0,
      totalPaymentAmount: (json['totalPaymentAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAbonents': totalAbonents,
      'totalTransformerPoints': totalTransformerPoints,
      'readingsThisMonth': readingsThisMonth,
      'totalCharge': totalCharge,
      'totalDebt': totalDebt,
      'totalPrepayment': totalPrepayment,
      'totalConsumption': totalConsumption,
      'paymentCountThisMonth': paymentCountThisMonth,
      'totalPaymentAmount': totalPaymentAmount,
    };
  }

  // Для обратной совместимости со старым кодом
  double get completionPercentage {
    if (totalAbonents == 0) return 0.0;
    return (readingsThisMonth / totalAbonents) * 100.0;
  }

  int get readingsCollected => readingsThisMonth;
  int get readingsRemaining => totalAbonents - readingsThisMonth;
  int get totalConsumptionThisMonth => totalConsumption.toInt();
  double get totalChargeThisMonth => totalCharge;
  double get totalPaymentsThisMonth => totalPaymentAmount;
  int get paidThisMonth => paymentCountThisMonth;
  double get totalDebtAmount => totalDebt;
  double get totalOverpaymentAmount => totalPrepayment;

  static DashboardModel empty() {
    return DashboardModel(
      totalAbonents: 0,
      totalTransformerPoints: 0,
      readingsThisMonth: 0,
      totalCharge: 0,
      totalDebt: 0,
      totalPrepayment: 0,
      totalConsumption: 0,
      paymentCountThisMonth: 0,
      totalPaymentAmount: 0,
    );
  }
}