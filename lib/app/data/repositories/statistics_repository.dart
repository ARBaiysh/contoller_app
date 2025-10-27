import 'package:get/get.dart';
import '../models/dashboard_model.dart';
import '../models/statistics_model.dart';
import '../providers/api_provider.dart';

class StatisticsRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  /// Получение статистики для главного экрана
  Future<DashboardModel> getDashboardStatistics({bool forceRefresh = false}) async {
    try {
      print('[STATS REPO] Fetching dashboard statistics...');
      final response = await _apiProvider.getDashboardStatistics();

      return DashboardModel.fromJson(response);
    } catch (e) {
      print('[STATS REPO] Error getting dashboard statistics: $e');
      throw Exception('Не удалось загрузить статистику');
    }
  }

  // Оставляем старый метод для совместимости
  Future<StatisticsModel> getStatistics() async {
    try {
      final dashboard = await getDashboardStatistics();

      // Преобразуем DashboardModel в StatisticsModel
      return StatisticsModel(
        totalSubscribers: dashboard.totalAbonents,
        readingsCollected: dashboard.readingsCollected,
        readingsRemaining: dashboard.readingsRemaining,
        paidSubscribers: dashboard.paidThisMonth,
        debtorCount: dashboard.debtorsCount,
        totalDebtAmount: dashboard.totalDebtAmount,
        totalCollectedAmount: dashboard.totalPaymentsThisMonth,
        lastUpdated: dashboard.generatedAt,
      );
    } catch (e) {
      // Возвращаем пустую статистику при ошибке
      return StatisticsModel.empty();
    }
  }

  // ========================================
  // REPORTS STATISTICS
  // ========================================

  /// Получить статистику отчетов
  Future<Map<String, dynamic>> getReportsStatistics() async {
    try {
      print('[STATS REPO] Fetching reports statistics...');
      final data = await _apiProvider.getReportsStatistics();
      return data;
    } catch (e) {
      print('[STATS REPO] Error getting reports statistics: $e');
      throw Exception('Не удалось загрузить статистику отчетов');
    }
  }

  /// Сформировать отчет
  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    String? tpId,
  }) async {
    try {
      print('[STATS REPO] Generating report - type: $reportType, tpId: $tpId');
      final data = await _apiProvider.generateReport(
        reportType: reportType,
        tpId: tpId,
      );
      return data;
    } catch (e) {
      print('[STATS REPO] Error generating report: $e');
      rethrow; // Пробрасываем исключение для обработки в контроллере
    }
  }
}