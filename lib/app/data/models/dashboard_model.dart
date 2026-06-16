import 'package:json_annotation/json_annotation.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardModel {
  @JsonKey(defaultValue: 0)
  final int totalAbonents;
  @JsonKey(defaultValue: 0)
  final int totalTransformerPoints;
  @JsonKey(defaultValue: 0)
  final int readingsThisMonth;
  @JsonKey(defaultValue: 0)
  final double totalCharge;
  @JsonKey(defaultValue: 0)
  final double totalDebt;
  @JsonKey(defaultValue: 0)
  final double totalPrepayment;
  @JsonKey(defaultValue: 0)
  final double totalConsumption;
  @JsonKey(defaultValue: 0)
  final int paymentCountThisMonth;
  @JsonKey(defaultValue: 0)
  final double totalPaymentAmount;
  @JsonKey(defaultValue: 0)
  final int coordinatesTotal;
  @JsonKey(defaultValue: 0)
  final int coordinatesThisMonth;
  @JsonKey(defaultValue: 0)
  final int coordinatesToday;

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
    this.coordinatesTotal = 0,
    this.coordinatesThisMonth = 0,
    this.coordinatesToday = 0,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);

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
