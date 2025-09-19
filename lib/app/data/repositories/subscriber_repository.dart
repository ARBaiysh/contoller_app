import 'package:get/get.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';
import '../../core/services/sync_service.dart';
import '../../core/values/constants.dart';
import 'tp_repository.dart';

class SubscriberRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final SyncService _syncService = Get.find<SyncService>();
  final TpRepository _tpRepository = Get.find<TpRepository>();

  // ========================================
  // ОСНОВНЫЕ МЕТОДЫ ЗАГРУЗКИ
  // ========================================

  /// Получение списка абонентов по ТП (онлайн, без кеширования)
  /// Возвращает актуальные данные с сервера
  Future<List<SubscriberModel>> getSubscribersByTp(String tpCode, {bool forceRefresh = false}) async {
    try {
      print('[SUBSCRIBER REPO] Getting subscribers for TP: $tpCode');

      // Получаем данные с сервера
      final responseData = await _apiProvider.getAbonentsByTp(tpCode);

      // Преобразуем в модели
      final subscribers = responseData.map((json) => SubscriberModel.fromJson(json)).toList();

      // Обновляем статистику ТП (опционально)
      _updateTpStatistics(tpCode, subscribers);

      print('[SUBSCRIBER REPO] Loaded ${subscribers.length} subscribers for TP: $tpCode');
      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching subscribers: $e');
      throw Exception('Не удалось загрузить список абонентов');
    }
  }

  // ========================================
  // СИНХРОНИЗАЦИЯ С КОЛБЭКАМИ
  // ========================================

  /// Синхронизация абонентов по ТП с колбэками для UI
  /// Использует SyncService для мониторинга прогресса
  Future<void> syncAbonentsList(String tpCode, {
    required Function() onSyncStarted,
    required Function(String message, Duration elapsed) onProgress,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      print('[SUBSCRIBER REPO] Starting abonents sync for TP: $tpCode');

      // Запускаем синхронизацию абонентов
      final syncResponse = await _apiProvider.syncAbonentsByTp(tpCode);

      if (syncResponse.isAlreadyRunning) {
        // 409 Conflict - синхронизация уже идет
        print('[SUBSCRIBER REPO] Abonents sync already running for TP: $tpCode');
        onError(syncResponse.displayMessage);
        return;
      }

      if (syncResponse.isError) {
        // Ошибка запуска синхронизации
        print('[SUBSCRIBER REPO] Abonents sync initiation failed: ${syncResponse.displayMessage}');
        onError(syncResponse.displayMessage);
        return;
      }

      if (syncResponse.isInitiated && syncResponse.syncMessageId != null) {
        // Синхронизация успешно запущена - начинаем мониторинг
        print('[SUBSCRIBER REPO] Abonents sync initiated with messageId: ${syncResponse.syncMessageId}');
        onSyncStarted();

        await _syncService.monitorSync(
          messageId: syncResponse.syncMessageId!,
          timeout: Constants.abonentsSyncTimeout,           // 3 минуты
          checkInterval: Constants.abonentsSyncCheckInterval, // 3 секунды
          onSuccess: (syncStatus) {
            print('[SUBSCRIBER REPO] Abonents sync completed successfully for TP: $tpCode');
            onSuccess();
          },
          onError: (error) {
            print('[SUBSCRIBER REPO] Abonents sync failed for TP $tpCode: $error');
            onError(error);
          },
          onProgress: (message, elapsed) {
            print('[SUBSCRIBER REPO] Abonents sync progress for TP $tpCode: $message (${elapsed.inSeconds}s)');
            onProgress(message, elapsed);
          },
        );
      } else {
        // Неожиданный ответ
        print('[SUBSCRIBER REPO] Unexpected abonents sync response: ${syncResponse.status}');
        onError('Неожиданный ответ сервера при запуске синхронизации абонентов');
      }

    } catch (e) {
      print('[SUBSCRIBER REPO] Error starting abonents sync: $e');
      onError('Не удалось запустить синхронизацию абонентов');
    }
  }

  // ========================================
  // ПОИСК И ДОПОЛНИТЕЛЬНЫЕ МЕТОДЫ
  // ========================================

  /// Поиск абонентов по всем ТП
  /// Загружает список ТП и ищет абонентов в каждой
  Future<List<SubscriberModel>> searchSubscribers(String query) async {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final List<SubscriberModel> results = [];

    try {
      // Получаем список всех ТП
      final tpList = await _tpRepository.getTpList();
      print('[SUBSCRIBER REPO] Searching across ${tpList.length} transformer points');

      // Загружаем абонентов по каждому ТП и ищем
      for (final tp in tpList) {
        try {
          final subscribers = await getSubscribersByTp(tp.id);
          final filtered = subscribers.where((s) {
            return s.accountNumber.toLowerCase().contains(lowerQuery) ||
                s.fullName.toLowerCase().contains(lowerQuery) ||
                s.address.toLowerCase().contains(lowerQuery);
          });
          results.addAll(filtered);
        } catch (e) {
          print('[SUBSCRIBER REPO] Error searching in TP ${tp.id}: $e');
          // Продолжаем поиск в других ТП даже при ошибке
        }
      }

      print('[SUBSCRIBER REPO] Search completed: found ${results.length} results for "$query"');
      return results;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error in global search: $e');
      throw Exception('Ошибка при поиске абонентов');
    }
  }

  /// Получение абонента по номеру счета
  /// Пытается определить ТП по формату номера
  Future<SubscriberModel?> getSubscriberByAccountNumber(String accountNumber) async {
    try {
      // Определяем TP по номеру счета (если есть соглашение о формате)
      // Формат может быть: TPXXXX_XXXXXX или другой
      final parts = accountNumber.split('_');
      if (parts.length == 2) {
        final tpCode = parts[0];
        try {
          final subscribers = await getSubscribersByTp(tpCode);
          return subscribers.firstWhereOrNull(
                (s) => s.accountNumber == accountNumber,
          );
        } catch (e) {
          print('[SUBSCRIBER REPO] Error getting subscriber from TP $tpCode: $e');
        }
      }

      // Если не удалось определить ТП, ищем по всем
      final searchResults = await searchSubscribers(accountNumber);
      return searchResults.firstWhereOrNull(
            (s) => s.accountNumber == accountNumber,
      );
    } catch (e) {
      print('[SUBSCRIBER REPO] Error getting subscriber by account: $e');
      return null;
    }
  }

  // ========================================
  // СНЯТИЕ ПОКАЗАНИЙ
  // ========================================

  /// Отправка показаний счетчика
  Future<bool> submitMeterReading({
    required String accountNumber,
    required int currentReading,
  }) async {
    try {
      print('[SUBSCRIBER REPO] Submitting reading for $accountNumber: $currentReading');

      final response = await _apiProvider.submitMeterReading(
        accountNumber: accountNumber,
        currentReading: currentReading,
      );

      // После отправки можно обновить список абонентов для ТП (опционально)
      final parts = accountNumber.split('_');
      if (parts.length == 2) {
        final tpCode = parts[0];
        // Не делаем автообновление, пусть UI сам решает когда обновлять
        print('[SUBSCRIBER REPO] Reading submitted for TP: $tpCode');
      }

      return true;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error submitting reading: $e');
      throw Exception('Не удалось отправить показание счетчика');
    }
  }

  // ========================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ========================================

  /// Обновление статистики ТП на основе списка абонентов
  /// Используется для передачи данных в TpRepository
  void _updateTpStatistics(String tpCode, List<SubscriberModel> subscribers) {
    try {
      // Рассчитываем статистику
      final statistics = <String, dynamic>{
        'total_subscribers': subscribers.length,
        'readings_available': subscribers.where((s) => s.canTakeReading).length,
        'readings_completed': subscribers.where((s) => !s.canTakeReading).length,
        'debtors_count': subscribers.where((s) => s.isDebtor).length,
        'total_debt': subscribers.where((s) => s.isDebtor).fold(0.0, (sum, s) => sum + s.debtAmount),
      };

      // Передаем в TpRepository для возможного использования
      _tpRepository.updateTpStatistics(tpCode, subscribers);

      print('[SUBSCRIBER REPO] Updated TP $tpCode statistics: $statistics');
    } catch (e) {
      print('[SUBSCRIBER REPO] Error updating TP statistics: $e');
    }
  }

  /// Принудительное обновление списка абонентов (для совместимости)
  Future<List<SubscriberModel>> refreshSubscribers(String tpCode) async {
    return getSubscribersByTp(tpCode, forceRefresh: true);
  }

  /// Получение статистики абонентов для ТП (локальный расчет)
  Map<String, int> getSubscriberStatistics(List<SubscriberModel> subscribers) {
    return {
      'total': subscribers.length,
      'available': subscribers.where((s) => s.canTakeReading).length,
      'completed': subscribers.where((s) => !s.canTakeReading).length,
      'debtors': subscribers.where((s) => s.isDebtor).length,
    };
  }
}