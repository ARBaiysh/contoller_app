import 'package:get/get.dart';
import '../../../data/models/subscriber_model.dart';

class ReportViewerController extends GetxController {
  // Report data from arguments
  late final Map<String, dynamic> reportData;
  late final String reportTitle;
  late final String reportType;
  late final List<SubscriberModel> subscribers;
  late final int totalCount;
  late final double totalAmount;

  @override
  void onInit() {
    super.onInit();
    // Get report data from arguments
    final args = Get.arguments as Map<String, dynamic>;
    reportData = args;
    reportTitle = args['title'] ?? 'Отчет';
    reportType = args['type'] ?? '';

    // Parse subscribers from JSON
    final subscribersData = args['subscribers'] ?? args['data'] ?? [];
    if (subscribersData is List) {
      subscribers = subscribersData
          .map((json) => SubscriberModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      subscribers = [];
    }

    totalCount = args['count'] ?? 0;
    totalAmount = (args['total_debt'] ?? args['total_balance'] ?? 0.0).toDouble();

    print('[REPORT VIEWER] Loaded report:');
    print('[REPORT VIEWER] - Type: $reportType');
    print('[REPORT VIEWER] - Title: $reportTitle');
    print('[REPORT VIEWER] - Subscribers count: ${subscribers.length}');
    print('[REPORT VIEWER] - Total count: $totalCount');
    print('[REPORT VIEWER] - Total amount: $totalAmount');
  }

  // Get formatted total amount text
  String get totalAmountText {
    switch (reportType) {
      case 'disconnections':
      case 'debtors':
        return 'Общий долг: ${totalAmount.toStringAsFixed(2)} сом';
      case 'payments':
        return 'Общий баланс: ${totalAmount.toStringAsFixed(2)} сом';
      case 'consumption':
        return 'Общий расход: ${totalConsumption.toStringAsFixed(0)} кВт·ч';
      case 'charges':
        return 'Общее начисление: ${totalCharge.toStringAsFixed(2)} сом';
      default:
        return '';
    }
  }

  // Get total consumption (for consumption report)
  double get totalConsumption {
    if (reportType == 'consumption') {
      return (reportData['total_consumption'] ?? 0).toDouble();
    }
    return 0.0;
  }

  // Get total charge (for charges report)
  double get totalCharge {
    if (reportType == 'charges') {
      return (reportData['total_charge'] ?? 0).toDouble();
    }
    return 0.0;
  }

  // Get amount for subscriber
  double getSubscriberAmount(SubscriberModel subscriber) {
    switch (reportType) {
      case 'disconnections':
      case 'debtors':
      case 'payments':
        return subscriber.balance;
      case 'consumption':
        return subscriber.currentMonthConsumption.toDouble();
      case 'charges':
        return subscriber.currentMonthCharge;
      default:
        return 0.0;
    }
  }

  // Get amount text for subscriber
  String getSubscriberAmountText(SubscriberModel subscriber) {
    switch (reportType) {
      case 'disconnections':
      case 'debtors':
        return '${subscriber.balance.toStringAsFixed(2)} сом долг';
      case 'payments':
        return '${subscriber.balance.toStringAsFixed(2)} сом баланс';
      case 'consumption':
        return '${subscriber.currentMonthConsumption} кВт·ч расход';
      case 'charges':
        return '${subscriber.currentMonthCharge.toStringAsFixed(2)} сом начисление';
      default:
        return '';
    }
  }
}