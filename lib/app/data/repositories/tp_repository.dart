import 'package:get/get.dart';
import '../models/tp_model.dart';
import '../models/tp_sync_response_model.dart';
import '../providers/api_provider.dart';
import '../../core/services/sync_service.dart';
import '../../core/values/constants.dart';

class TpRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final SyncService _syncService = Get.find<SyncService>();

  /// Получение списка ТП (простая загрузка, без кеширования)
  Future<List<TpModel>> getTpList({bool forceRefresh = false}) async {
    try {
      print('[TP REPO] Getting TP list...');
      final responseData = await _apiProvider.getTransformerPoints();

      // Преобразуем данные в модели
      final tpList = responseData.map((json) => TpModel.fromJson(json)).toList();

      print('[TP REPO] Loaded ${tpList.length} transformer points');
      return tpList;
    } catch (e) {
      print('[TP REPO] Error fetching TP list: $e');
      throw Exception('Не удалось загрузить список ТП');
    }
  }

  /// Синхронизация списка ТП с колбэками для UI
  Future<void> syncTpList({
    required Function() onSyncStarted,
    required Function(String message, Duration elapsed) onProgress,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      print('[TP REPO] Starting TP sync...');

      // Запускаем синхронизацию
      final syncResponse = await _apiProvider.syncTransformerPoints();

      if (syncResponse.isAlreadyRunning) {
        // 409 Conflict - синхронизация уже идет
        print('[TP REPO] Sync already running');
        onError(syncResponse.displayMessage);
        return;
      }

      if (syncResponse.isError) {
        // Ошибка запуска синхронизации
        print('[TP REPO] Sync initiation failed: ${syncResponse.displayMessage}');
        onError(syncResponse.displayMessage);
        return;
      }

      if (syncResponse.isInitiated && syncResponse.syncMessageId != null) {
        // Синхронизация успешно запущена - начинаем мониторинг
        print('[TP REPO] Sync initiated with messageId: ${syncResponse.syncMessageId}');
        onSyncStarted();

        await _syncService.monitorSync(
          messageId: syncResponse.syncMessageId!,
          timeout: Constants.tpSyncTimeout,           // 5 минут
          checkInterval: Constants.tpSyncCheckInterval, // 3 секунды
          onSuccess: (syncStatus) {
            print('[TP REPO] Sync completed successfully');
            onSuccess();
          },
          onError: (error) {
            print('[TP REPO] Sync failed: $error');
            onError(error);
          },
          onProgress: (message, elapsed) {
            print('[TP REPO] Sync progress: $message (${elapsed.inSeconds}s)');
            onProgress(message, elapsed);
          },
        );
      } else {
        // Неожиданный ответ
        print('[TP REPO] Unexpected sync response: ${syncResponse.status}');
        onError('Неожиданный ответ сервера при запуске синхронизации');
      }

    } catch (e) {
      print('[TP REPO] Error starting TP sync: $e');
      onError('Не удалось запустить синхронизацию ТП');
    }
  }

  /// Получить ТП по ID (простой поиск в списке)
  Future<TpModel?> getTpById(String id) async {
    try {
      final tpList = await getTpList();
      return tpList.firstWhereOrNull((tp) => tp.id == id);
    } catch (e) {
      print('[TP REPO] Error getting TP by ID: $e');
      return null;
    }
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

  /// Обновить статистику ТП на основе списка абонентов
  void updateTpStatistics(String tpId, List<dynamic> subscribers) {
    // Эта функция может быть использована другими репозиториями
    // для обновления статистики ТП после загрузки абонентов
    print('[TP REPO] Updating statistics for TP $tpId with ${subscribers.length} subscribers');

    // В новой архитектуре статистика не кешируется
    // Каждый раз загружается с сервера
  }
}