import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/values/constants.dart';

class ReportsController extends GetxController {
  final StatisticsRepository _statisticsRepository = Get.find<StatisticsRepository>();

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
    ReportType(
      id: 'consumption',
      title: 'Расход электроэнергии',
      description: 'Отчёт по потреблению',
      icon: Icons.electric_bolt_outlined,
    ),
    ReportType(
      id: 'charges',
      title: 'Начисления',
      description: 'Отчёт по начислениям',
      icon: Icons.receipt_long_outlined,
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
    // Используем реальное API для формирования отчета
    return await _statisticsRepository.generateReport(
      reportType: _selectedReportType.value,
      tpId: _selectedTpId.value.isNotEmpty ? _selectedTpId.value : null,
    );
  }

  // Get report statistics
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      // Используем реальное API для получения статистики отчетов
      return await _statisticsRepository.getReportsStatistics();
    } catch (e) {
      print('[REPORTS CONTROLLER] Error getting report stats: $e');
      // Возвращаем пустую статистику при ошибке
      return {
        'total_reports_generated': 0,
        'last_report_date': null,
        'readings_collected': 0,
        'total_subscribers': 0,
      };
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