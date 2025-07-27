import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../data/repositories/tp_repository.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class ReportsController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();
  final TpRepository _tpRepository = Get.find<TpRepository>();
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();

  // Observable states
  final _isGenerating = false.obs;
  final _selectedReportType = 'disconnections'.obs;
  final _selectedTpId = ''.obs;

  // Getters
  bool get isGenerating => _isGenerating.value;
  String get selectedReportType => _selectedReportType.value;
  String get selectedTpId => _selectedTpId.value;

  // Report types
  List<ReportType> get reportTypes => [
    ReportType(
      id: 'disconnections',
      title: 'Список отключений',
      description: 'Абоненты для отключения',
      icon: Icons.power_off_outlined,
    ),
    ReportType(
      id: 'debtors',
      title: 'Список должников',
      description: 'Абоненты с задолженностью',
      icon: Icons.warning_amber_outlined,
    ),
    ReportType(
      id: 'payments',
      title: 'Отчет по оплатам',
      description: 'Список оплаченных абонентов',
      icon: Icons.payment_outlined,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _selectedReportType.value = reportTypes.first.id;
  }

  // Set selected report type
  void setReportType(String reportType) {
    _selectedReportType.value = reportType;
  }

  // Set selected TP
  void setSelectedTp(String tpId) {
    _selectedTpId.value = tpId;
  }

  // Generate report
  Future<void> generateReport() async {
    if (_isGenerating.value) return;

    _isGenerating.value = true;

    try {
      // Get report data based on type
      final reportData = await _getReportData();

      // Simulate report generation
      await Future.delayed(const Duration(seconds: 2));

      // Vibrate for feedback
      HapticFeedback.lightImpact();

      // Navigate to report viewer
      Get.toNamed(Routes.REPORT_VIEWER, arguments: reportData);

    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось сформировать отчет: $e',
        backgroundColor: Constants.error.withValues(alpha: 0.1),
        colorText: Constants.error,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isGenerating.value = false;
    }
  }

  // Get report data based on selected type
  Future<Map<String, dynamic>> _getReportData() async {
    switch (_selectedReportType.value) {
      case 'disconnections':
        return await _getDisconnectionsList();
      case 'debtors':
        return await _getDebtorsList();
      case 'payments':
        return await _getPaidSubscribersList();
      default:
        throw Exception('Неизвестный тип отчета');
    }
  }

  // Get disconnections list (debtors with high debt)
  Future<Map<String, dynamic>> _getDisconnectionsList() async {
    final debtors = await _subscriberRepository.getDebtors(
      tpId: _selectedTpId.value.isEmpty ? null : _selectedTpId.value,
    );

    // Filter for disconnection (debt > 1000 som)
    final forDisconnection = debtors.where((s) => s.debtAmount > 1000).toList();

    return {
      'type': 'disconnections',
      'title': 'Список абонентов для отключения',
      'data': forDisconnection,
      'count': forDisconnection.length,
      'total_debt': forDisconnection.fold<double>(0, (sum, s) => sum + s.debtAmount),
    };
  }

  // Get debtors list
  Future<Map<String, dynamic>> _getDebtorsList() async {
    final debtors = await _subscriberRepository.getDebtors(
      tpId: _selectedTpId.value.isEmpty ? null : _selectedTpId.value,
    );

    return {
      'type': 'debtors',
      'title': 'Список должников',
      'data': debtors,
      'count': debtors.length,
      'total_debt': debtors.fold<double>(0, (sum, s) => sum + s.debtAmount),
    };
  }

  // Get paid subscribers list
  Future<Map<String, dynamic>> _getPaidSubscribersList() async {
    List<dynamic> allSubscribers;

    if (_selectedTpId.value.isEmpty) {
      // Get all subscribers from all TPs
      final tps = await _tpRepository.getTpList();
      allSubscribers = [];
      for (final tp in tps) {
        final tpSubscribers = await _subscriberRepository.getSubscribersByTp(tp.id);
        allSubscribers.addAll(tpSubscribers);
      }
    } else {
      allSubscribers = await _subscriberRepository.getSubscribersByTp(_selectedTpId.value);
    }

    // Filter paid subscribers (balance >= 0)
    final paidSubscribers = allSubscribers.where((s) => !s.isDebtor).toList();

    return {
      'type': 'payments',
      'title': 'Список оплаченных абонентов',
      'data': paidSubscribers,
      'count': paidSubscribers.length,
      'total_balance': paidSubscribers.fold<double>(0, (sum, s) => sum + s.balance),
    };
  }

  // Get report statistics
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      final stats = await _statisticsRepository.getStatistics();
      return {
        'total_reports_generated': 45,
        'last_report_date': DateTime.now().subtract(const Duration(days: 2)),
        'readings_collected': stats.readingsCollected,
        'total_subscribers': stats.totalSubscribers,
      };
    } catch (e) {
      return {};
    }
  }
}

// Model for report types
class ReportType {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  ReportType({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}