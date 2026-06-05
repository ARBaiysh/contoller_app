import 'package:get/get.dart';
import '../models/dashboard_model.dart';
import '../models/statistics_model.dart';
import '../providers/api_provider.dart';

class StatisticsRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // Кеш для предотвращения дублирующихся запросов
  DashboardModel? _cachedDashboard;
  DateTime? _cacheTime;
  Future<DashboardModel>? _ongoingRequest;
  static const _cacheDuration = Duration(seconds: 2);

  /// Получение статистики для главного экрана (дашборд)
  /// GET /api/mobile/dashboard/stats
  Future<DashboardModel> getDashboardStatistics() async {
    // Если есть активный запрос - возвращаем его
    if (_ongoingRequest != null) {
      print('[STATS REPO] Returning ongoing dashboard request...');
      return _ongoingRequest!;
    }

    // Если данные в кеше и они свежие - возвращаем из кеша
    if (_cachedDashboard != null && _cacheTime != null) {
      final age = DateTime.now().difference(_cacheTime!);
      if (age < _cacheDuration) {
        print('[STATS REPO] Returning cached dashboard (age: ${age.inMilliseconds}ms)');
        return _cachedDashboard!;
      }
    }

    // Создаем новый запрос
    print('[STATS REPO] Fetching dashboard statistics...');
    _ongoingRequest = _fetchDashboard();

    try {
      final result = await _ongoingRequest!;
      _cachedDashboard = result;
      _cacheTime = DateTime.now();
      return result;
    } finally {
      _ongoingRequest = null;
    }
  }

  Future<DashboardModel> _fetchDashboard() async {
    try {
      final response = await _apiProvider.getDashboardStatistics();
      return DashboardModel.fromJson(response);
    } catch (e) {
      print('[STATS REPO] Error getting dashboard statistics: $e');
      throw Exception('Не удалось загрузить статистику');
    }
  }

  // Оставляем старый метод для совместимости (если используется)
  Future<StatisticsModel> getStatistics() async {
    try {
      final dashboard = await getDashboardStatistics();

      // Преобразуем DashboardModel в StatisticsModel для совместимости
      return StatisticsModel(
        totalSubscribers: dashboard.totalAbonents,
        readingsCollected: dashboard.readingsThisMonth,
        readingsRemaining: dashboard.totalAbonents - dashboard.readingsThisMonth,
        paidSubscribers: dashboard.paymentCountThisMonth,
        debtorCount: 0, // Нет в новом API
        totalDebtAmount: dashboard.totalDebt,
        totalCollectedAmount: dashboard.totalPaymentAmount,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return StatisticsModel.empty();
    }
  }
}