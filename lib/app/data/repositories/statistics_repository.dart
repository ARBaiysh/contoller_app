import 'package:get/get.dart';
import '../models/statistics_model.dart';
import '../models/tp_model.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';
import 'tp_repository.dart';
import 'subscriber_repository.dart';

class StatisticsRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final TpRepository _tpRepository = Get.find<TpRepository>();
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();

  // Cache for statistics
  StatisticsModel? _statisticsCache;
  DateTime? _lastFetchTime;

  // Cache duration (1 minute for statistics)
  static const Duration _cacheDuration = Duration(minutes: 1);

  // Get overall statistics
  Future<StatisticsModel> getStatistics({bool forceRefresh = false}) async {
    try {
      // Check if cache is valid
      if (!forceRefresh &&
          _statisticsCache != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _statisticsCache!;
      }

      // Fetch from API
      final statistics = await _apiProvider.getStatistics();

      // Update cache
      _statisticsCache = statistics;
      _lastFetchTime = DateTime.now();

      return statistics;
    } catch (e) {
      print('Error fetching statistics: $e');
      throw Exception('Не удалось загрузить статистику');
    }
  }

  // Get statistics for specific TP
  Future<Map<String, dynamic>> getTpStatistics(String tpId) async {
    try {
      final tp = await _tpRepository.getTpById(tpId);
      final subscribers = await _subscriberRepository.getSubscribersByTp(tpId);

      // Calculate statistics
      final debtors = subscribers.where((s) => s.isDebtor).toList();
      final totalDebt = debtors.fold<double>(0, (sum, s) => sum + s.debtAmount);

      final paidSubscribers = subscribers.where((s) => !s.isDebtor).length;

      return {
        'tp_info': {
          'number': tp.number,
          'name': tp.name,
          'address': tp.address,
        },
        'subscribers': {
          'total': tp.totalSubscribers,
          'with_readings': tp.readingsCollected,
          'without_readings': tp.totalSubscribers - tp.readingsCollected,
        },
        'readings': {
          'available': tp.readingsAvailable,
          'processing': tp.readingsProcessing,
          'completed': tp.readingsCompleted,
          'progress': tp.progressPercentage,
        },
        'payments': {
          'paid_count': paidSubscribers,
          'debtor_count': debtors.length,
          'total_debt': totalDebt,
        },
      };
    } catch (e) {
      print('Error getting TP statistics: $e');
      throw Exception('Не удалось получить статистику ТП');
    }
  }

  // Get daily statistics
  Future<Map<String, dynamic>> getDailyStatistics() async {
    try {
      final statistics = await getStatistics();
      final tps = await _tpRepository.getTpList();

      // Calculate daily progress
      final todayReadings = statistics.readingsCollected; // In real app, would filter by date
      final todayPayments = statistics.paidSubscribers; // In real app, would filter by date

      return {
        'date': DateTime.now(),
        'readings': {
          'collected_today': todayReadings,
          'total_collected': statistics.readingsCollected,
          'remaining': statistics.readingsRemaining,
        },
        'payments': {
          'paid_today': todayPayments,
          'total_paid': statistics.paidSubscribers,
        },
        'tps': {
          'total': tps.length,
          'completed': tps.where((tp) => tp.isCompleted).length,
          'in_progress': tps.where((tp) => !tp.isCompleted).length,
        },
      };
    } catch (e) {
      print('Error getting daily statistics: $e');
      throw Exception('Не удалось получить дневную статистику');
    }
  }

  // Get chart data for dashboard
  Future<Map<String, dynamic>> getChartData() async {
    try {
      // In real app, would fetch historical data
      // For now, return mock data for last 7 days
      final Map<String, dynamic> chartData = {
        'readings': [45.0, 52.0, 48.0, 65.0, 58.0, 72.0, 85.0],
        'payments': [65.0, 70.0, 68.0, 75.0, 72.0, 78.0, 82.0],
        'labels': ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'],
      };
      return chartData;
    } catch (e) {
      print('Error getting chart data: $e');
      throw Exception('Не удалось получить данные для графика');
    }
  }

  // Get debtors summary
  Future<Map<String, dynamic>> getDebtorsSummary() async {
    try {
      final statistics = await getStatistics();
      final allSubscribers = await _apiProvider.getAllSubscribers();

      // Group debtors by debt amount ranges
      final debtors = allSubscribers.where((s) => s.isDebtor).toList();

      final debtRanges = {
        'below_1000': debtors.where((s) => s.debtAmount < 1000).length,
        '1000_5000': debtors.where((s) => s.debtAmount >= 1000 && s.debtAmount < 5000).length,
        '5000_10000': debtors.where((s) => s.debtAmount >= 5000 && s.debtAmount < 10000).length,
        'above_10000': debtors.where((s) => s.debtAmount >= 10000).length,
      };

      // Get top debtors
      final topDebtors = debtors
        ..sort((a, b) => b.debtAmount.compareTo(a.debtAmount));

      return {
        'total_debtors': statistics.debtorCount,
        'total_debt': statistics.totalDebtAmount,
        'average_debt': statistics.debtorCount > 0
            ? statistics.totalDebtAmount / statistics.debtorCount
            : 0,
        'debt_ranges': debtRanges,
        'top_debtors': topDebtors.take(10).map((s) => {
          'account_number': s.accountNumber,
          'full_name': s.fullName,
          'address': s.address,
          'debt_amount': s.debtAmount,
        }).toList(),
      };
    } catch (e) {
      print('Error getting debtors summary: $e');
      throw Exception('Не удалось получить сводку по должникам');
    }
  }

  // Clear cache
  void clearCache() {
    _statisticsCache = null;
    _lastFetchTime = null;
  }

  // Refresh statistics
  Future<StatisticsModel> refreshStatistics() async {
    return getStatistics(forceRefresh: true);
  }
}