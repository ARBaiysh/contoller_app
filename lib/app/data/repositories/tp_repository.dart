// lib/app/data/repositories/tp_repository.dart

import 'dart:async';
import 'package:get/get.dart';
import '../models/tp_model.dart';
import '../providers/api_provider.dart';
import '../../core/services/sync_service.dart';
import '../../core/values/constants.dart';

class TpRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final SyncService _syncService = Get.find<SyncService>();

  // ========================================
  // ОСНОВНЫЕ МЕТОДЫ
  // ========================================

  /// Получение списка ТП с сервера
  Future<List<TpModel>> getTpList({bool forceRefresh = false}) async {
    try {
      print('[TP REPO] Fetching TP list...');

      // Получаем данные с сервера
      final responseData = await _apiProvider.getTransformerPoints();

      // Преобразуем в модели
      final tpList = responseData.map((json) => TpModel.fromJson(json)).toList();

      print('[TP REPO] Loaded ${tpList.length} TPs');
      return tpList;
    } catch (e) {
      print('[TP REPO] Error fetching TP list: $e');
      throw Exception('Не удалось загрузить список ТП');
    }
  }

  // ========================================
  // СИНХРОНИЗАЦИЯ
  // ========================================

  /// Синхронизация списка ТП с колбэками для UI
  Future<void> syncTpList({
    required Function() onSyncStarted,
    required Function(String message, Duration elapsed) onProgress,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      onSyncStarted();

      final stopwatch = Stopwatch()..start();
      Timer? progressTimer;

      // Обновляем прогресс каждые 3 секунды
      progressTimer = Timer.periodic(Constants.tpSyncCheckInterval, (timer) {
        final elapsed = stopwatch.elapsed;
        onProgress('Синхронизация ТП...', elapsed);
      });

      // Загружаем данные
      final tpList = await getTpList(forceRefresh: true);

      progressTimer?.cancel();
      stopwatch.stop();

      onProgress('Загружено ${tpList.length} ТП', stopwatch.elapsed);
      onSuccess();

    } catch (e) {
      print('[TP REPO] Sync error: $e');
      onError(e.toString());
      throw e;
    }
  }

  /// Принудительное обновление списка ТП
  Future<List<TpModel>> refreshTpList() async {
    return getTpList(forceRefresh: true);
  }

  /// Поиск ТП по запросу
  Future<List<TpModel>> searchTp(String query) async {
    if (query.isEmpty) return [];

    try {
      final tpList = await getTpList();
      final lowerQuery = query.toLowerCase();

      return tpList.where((tp) {
        return tp.number.toLowerCase().contains(lowerQuery) ||
            tp.name.toLowerCase().contains(lowerQuery) ||
            tp.fider.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('[TP REPO] Error searching TP: $e');
      return [];
    }
  }

  /// Получить ТП по ID
  Future<TpModel?> getTpById(String id) async {
    try {
      final tpList = await getTpList();
      return tpList.firstWhereOrNull((tp) => tp.id == id);
    } catch (e) {
      print('[TP REPO] Error getting TP by ID: $e');
      return null;
    }
  }
}