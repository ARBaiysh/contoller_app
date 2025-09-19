// lib/app/data/repositories/subscriber_repository.dart

import 'dart:async';
import 'package:get/get.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';
import '../../core/services/sync_service.dart';
import '../../core/values/constants.dart';

class SubscriberRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final SyncService _syncService = Get.find<SyncService>();

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

      print('[SUBSCRIBER REPO] Loaded ${subscribers.length} subscribers for TP: $tpCode');
      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching subscribers: $e');
      throw Exception('Не удалось загрузить список абонентов');
    }
  }

  /// Получение абонента по номеру лицевого счета
  Future<SubscriberModel?> getSubscriberByAccountNumber(String accountNumber) async {
    try {
      print('[SUBSCRIBER REPO] Getting subscriber by account: $accountNumber');

      // Поиск по всем ТП
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

      // Запускаем синхронизацию - используем правильный метод
      final syncResponse = await _apiProvider.syncAbonentsByTp(tpCode);

      if (syncResponse.isAlreadyRunning) {
        print('[SUBSCRIBER REPO] Sync already running');
        onError(syncResponse.displayMessage);
        return;
      }

      if (syncResponse.isError) {
        print('[SUBSCRIBER REPO] Sync initiation failed: ${syncResponse.displayMessage}');
        onError(syncResponse.displayMessage);
        return;
      }

      if (syncResponse.isInitiated && syncResponse.syncMessageId != null) {
        print('[SUBSCRIBER REPO] Sync initiated with messageId: ${syncResponse.syncMessageId}');
        onSyncStarted();

        await _syncService.monitorSync(
          messageId: syncResponse.syncMessageId!,
          timeout: Constants.abonentsSyncTimeout,
          checkInterval: Constants.abonentsSyncCheckInterval,
          onSuccess: (syncStatus) {
            print('[SUBSCRIBER REPO] Sync completed successfully');
            onSuccess();
          },
          onError: (error) {
            print('[SUBSCRIBER REPO] Sync failed: $error');
            onError(error);
          },
          onProgress: (message, elapsed) {
            print('[SUBSCRIBER REPO] Sync progress: $message (${elapsed.inSeconds}s)');
            onProgress(message, elapsed);
          },
        );
      } else {
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
  Future<List<SubscriberModel>> searchSubscribers(String query) async {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final List<SubscriberModel> results = [];

    try {
      // Получаем список всех ТП через ApiProvider
      final tpList = await _apiProvider.getTransformerPoints();
      print('[SUBSCRIBER REPO] Searching across ${tpList.length} transformer points');

      // Загружаем абонентов по каждому ТП и ищем
      for (final tpData in tpList) {
        try {
          final tpId = tpData['id'] ?? '';
          if (tpId.isEmpty) continue;

          final subscribers = await getSubscribersByTp(tpId);
          final filtered = subscribers.where((s) {
            return s.accountNumber.toLowerCase().contains(lowerQuery) ||
                s.fullName.toLowerCase().contains(lowerQuery) ||
                s.address.toLowerCase().contains(lowerQuery);
          });
          results.addAll(filtered);
        } catch (e) {
          print('[SUBSCRIBER REPO] Error searching in TP: $e');
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

      await _apiProvider.submitMeterReading(
        accountNumber: accountNumber,
        currentReading: currentReading,
      );

      print('[SUBSCRIBER REPO] Reading submitted successfully');
      return true;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error submitting reading: $e');
      throw Exception('Не удалось отправить показание счетчика');
    }
  }

  /// Отправка показания счетчика (алиас для совместимости)
  Future<bool> submitReading({
    required String accountNumber,
    required int newReading,
    String? comment,
  }) async {
    return submitMeterReading(
      accountNumber: accountNumber,
      currentReading: newReading,
    );
  }

  /// Принудительное обновление списка абонентов (для совместимости)
  Future<List<SubscriberModel>> refreshSubscribers(String tpCode) async {
    return getSubscribersByTp(tpCode, forceRefresh: true);
  }

  /// Получение статистики абонентов для ТП (локальный расчет для UI)
  Map<String, int> getSubscriberStatistics(List<SubscriberModel> subscribers) {
    return {
      'total': subscribers.length,
      'available': subscribers.where((s) => s.canTakeReading).length,
      'completed': subscribers.where((s) => !s.canTakeReading).length,
      'debtors': subscribers.where((s) => s.isDebtor).length,
    };
  }
}