import 'package:get/get.dart';
import '../models/tp_model.dart';
import '../providers/api_provider.dart';
import 'auth_repository.dart';

class TpRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // In-memory cache для статистики ТП
  final Map<String, TpModel> _tpCache = {};

  // Get all TPs
  Future<List<TpModel>> getTpList({bool forceRefresh = false}) async {
    try {
      final response = await _apiProvider.getTransformerPoints();

      // Преобразуем данные в модели
      final tpList = response.data.map((json) => TpModel.fromJson(json)).toList();

      // Обновляем кеш с сохранением статистики
      for (var tp in tpList) {
        if (_tpCache.containsKey(tp.id) && !forceRefresh) {
          // Сохраняем существующую статистику
          final cachedTp = _tpCache[tp.id]!;
          tp.totalSubscribers = cachedTp.totalSubscribers;
          tp.readingsCollected = cachedTp.readingsCollected;
          tp.readingsAvailable = cachedTp.readingsAvailable;
          tp.readingsProcessing = cachedTp.readingsProcessing;
          tp.readingsCompleted = cachedTp.readingsCompleted;
          tp.lastUpdated = cachedTp.lastUpdated;
        }
        _tpCache[tp.id] = tp;
      }

      // Проверяем статус синхронизации
      if (response.syncing && response.syncMessageId != null) {
        // TODO: Обработать синхронизацию когда будет готов механизм
        print('[TP REPO] TP list is syncing, messageId: ${response.syncMessageId}');
      }

      return tpList;
    } catch (e) {
      print('[TP REPO] Error fetching TP list: $e');
      throw Exception('Не удалось загрузить список ТП');
    }
  }

  // Get TP by ID
  TpModel? getTpById(String tpId) {
    return _tpCache[tpId];
  }

  // Sync TP abonents
  Future<Map<String, dynamic>> syncTpAbonents(String tpCode) async {
    try {
      final result = await _apiProvider.syncTpAbonents(tpCode);

      // После синхронизации нужно обновить список абонентов
      // Это будет реализовано позже вместе с загрузкой абонентов

      return result;
    } catch (e) {
      print('[TP REPO] Error syncing TP abonents: $e');
      throw Exception('Не удалось синхронизировать абонентов');
    }
  }

  // Update TP statistics (вызывается из SubscriberRepository)
  void updateTpStatistics(String tpId, List<dynamic> subscribers) {
    final tp = _tpCache[tpId];
    if (tp != null) {
      tp.updateStatistics(subscribers);
      _tpCache[tpId] = tp;
      print('[TP REPO] Updated statistics for TP $tpId: ${tp.totalSubscribers} subscribers');
    }
  }

  // Recalculate all statistics (если понадобится)
  Future<void> recalculateAllStatistics() async {
    // TODO: Реализовать когда будет готов SubscriberRepository
    print('[TP REPO] Recalculating all TP statistics...');
  }

  // Clear cache
  void clearCache() {
    _tpCache.clear();
  }

  // Search TPs
  List<TpModel> searchTps(String query) {
    if (query.isEmpty) return _tpCache.values.toList();

    final lowerQuery = query.toLowerCase();
    return _tpCache.values.where((tp) {
      return tp.number.toLowerCase().contains(lowerQuery) ||
          tp.name.toLowerCase().contains(lowerQuery) ||
          tp.fider.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}