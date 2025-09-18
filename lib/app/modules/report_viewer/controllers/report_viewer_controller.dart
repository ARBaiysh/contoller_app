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
    subscribers = List<SubscriberModel>.from(args['data'] ?? []);
    totalCount = args['count'] ?? 0;
    totalAmount = (args['total_debt'] ?? args['total_balance'] ?? 0.0).toDouble();
  }

  // Get formatted total amount text
  String get totalAmountText {
    switch (reportType) {
      case 'disconnections':
      case 'debtors':
        return 'Общий долг: ${totalAmount.toStringAsFixed(2)} сом';
      case 'payments':
        return 'Общий баланс: ${totalAmount.toStringAsFixed(2)} сом';
      default:
        return '';
    }
  }

  // Get amount for subscriber
  double getSubscriberAmount(SubscriberModel subscriber) {
    switch (reportType) {
      case 'disconnections':
      case 'debtors':
        return subscriber.balance;
      case 'payments':
        return subscriber.balance;
      default:
        return 0.0;
    }
  }

  // Get amount text for subscriber
  String getSubscriberAmountText(SubscriberModel subscriber) {
    final amount = getSubscriberAmount(subscriber);
    switch (reportType) {
      case 'disconnections':
      case 'debtors':
        return '${amount.toStringAsFixed(2)} сом долг';
      case 'payments':
        return '${amount.toStringAsFixed(2)} сом баланс';
      default:
        return '';
    }
  }
}