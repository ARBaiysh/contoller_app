import 'package:get/get.dart';
import '../models/dashboard_model.dart';
import '../models/statistics_model.dart';
import '../providers/api_provider.dart';

class StatisticsRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // Кеш для статистики
  DashboardModel? _cachedDashboard;
  DateTime? _lastFetchTime;

  // Кеш действителен 5 минут
  static const Duration _cacheValidity = Duration(minutes: 5);

  /// Получение статистики для главного экрана
  Future<DashboardModel> getDashboardStatistics({bool forceRefresh = false}) async {
    try {
      // Проверяем кеш
      if (!forceRefresh && _cachedDashboard != null && _lastFetchTime != null) {
        final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
        if (timeSinceLastFetch < _cacheValidity) {
          print('[STATS REPO] Returning cached dashboard data');
          return _cachedDashboard!;
        }
      }

      print('[STATS REPO] Fetching fresh dashboard statistics...');
      final response = await _apiProvider.getDashboardStatistics();

      // Сохраняем в кеш
      _cachedDashboard = DashboardModel.fromJson(response);
      _lastFetchTime = DateTime.now();

      return _cachedDashboard!;
    } catch (e) {
      print('[STATS REPO] Error getting dashboard statistics: $e');

      // Если есть кеш, возвращаем его даже если устарел
      if (_cachedDashboard != null) {
        print('[STATS REPO] Returning stale cached data due to error');
        return _cachedDashboard!;
      }

      throw Exception('Не удалось загрузить статистику');
    }
  }

  /// Очистка кеша
  void clearCache() {
    _cachedDashboard = null;
    _lastFetchTime = null;
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
}