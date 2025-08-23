import 'package:get/get.dart';
import '../models/tp_model.dart';
import '../providers/api_provider.dart';
import 'auth_repository.dart';

class TpRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Cache for TP list
  List<TpModel>? _tpListCache;
  DateTime? _lastFetchTime;

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Get all TPs assigned to current user
  Future<List<TpModel>> getTpList({bool forceRefresh = false}) async {
    try {
      // Check if cache is valid
      if (!forceRefresh &&
          _tpListCache != null &&
          _lastFetchTime != null &&
          DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
        return _tpListCache!;
      }

      // Fetch from API
      final allTps = await _apiProvider.getTpList();

      // ИСПРАВЛЕНИЕ: Проверяем, есть ли пользователь и assigned_tps
      final assignedTpIds = _authRepository.assignedTps;

      List<TpModel> userTps;

      // Если у пользователя нет assigned_tps или список пустой, показываем все ТП
      if (assignedTpIds.isEmpty) {
        print('Warning: No assigned TPs found, showing all TPs');
        userTps = allTps;
      } else {
        // Фильтруем только если есть assigned_tps
        userTps = allTps.where((tp) => assignedTpIds.contains(tp.id)).toList();
        print('Filtered TPs: ${userTps.length} out of ${allTps.length}');
      }

      // Update cache
      _tpListCache = userTps;
      _lastFetchTime = DateTime.now();

      return userTps;
    } catch (e) {
      print('Error fetching TP list: $e');
      throw Exception('Не удалось загрузить список ТП');
    }
  }

  // Get TP by ID
  Future<TpModel> getTpById(String tpId) async {
    try {
      // Check cache first
      if (_tpListCache != null) {
        final cachedTp = _tpListCache!.firstWhereOrNull((tp) => tp.id == tpId);
        if (cachedTp != null) {
          return cachedTp;
        }
      }

      // Fetch from API
      final tp = await _apiProvider.getTpById(tpId);

      // ИСПРАВЛЕНИЕ: Убираем строгую проверку доступа, если assignedTps пустой
      final assignedTpIds = _authRepository.assignedTps;
      if (assignedTpIds.isNotEmpty && !assignedTpIds.contains(tp.id)) {
        throw Exception('У вас нет доступа к данному ТП');
      }

      return tp;
    } catch (e) {
      print('Error fetching TP details: $e');
      throw Exception('Не удалось загрузить данные ТП');
    }
  }

  // Get TPs by status
  Future<List<TpModel>> getTpsByStatus(String status) async {
    try {
      final allTps = await getTpList();
      return allTps.where((tp) => tp.status == status).toList();
    } catch (e) {
      print('Error filtering TPs by status: $e');
      throw Exception('Ошибка фильтрации');
    }
  }

  // Get TP statistics
  Future<Map<String, dynamic>> getTpStatistics(String tpId) async {
    try {
      final tp = await getTpById(tpId);

      return {
        'total_subscribers': tp.totalSubscribers,
        'readings_collected': tp.readingsCollected,
        'progress_percentage': tp.progressPercentage,
        'is_completed': tp.isCompleted,
        'readings_by_status': {
          'available': tp.readingsAvailable,
          'processing': tp.readingsProcessing,
          'completed': tp.readingsCompleted,
        },
      };
    } catch (e) {
      print('Error getting TP statistics: $e');
      throw Exception('Не удалось получить статистику ТП');
    }
  }

  // Search TPs
  Future<List<TpModel>> searchTps(String query) async {
    try {
      if (query.isEmpty) return [];

      final allTps = await getTpList();
      final lowerQuery = query.toLowerCase();

      return allTps.where((tp) {
        final number = tp.number.toLowerCase();
        final name = tp.name.toLowerCase();
        final address = tp.address.toLowerCase();

        return number.contains(lowerQuery) ||
            name.contains(lowerQuery) ||
            address.contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching TPs: $e');
      throw Exception('Ошибка поиска');
    }
  }

  // Get TPs with uncollected readings
  Future<List<TpModel>> getTpsWithUncollectedReadings() async {
    try {
      final allTps = await getTpList();
      return allTps.where((tp) => !tp.isCompleted).toList()
        ..sort((a, b) => a.progressPercentage.compareTo(b.progressPercentage));
    } catch (e) {
      print('Error getting TPs with uncollected readings: $e');
      throw Exception('Ошибка получения данных');
    }
  }

  // Clear cache
  void clearCache() {
    _tpListCache = null;
    _lastFetchTime = null;
  }

  // Refresh TP list
  Future<List<TpModel>> refreshTpList() async {
    return getTpList(forceRefresh: true);
  }
}