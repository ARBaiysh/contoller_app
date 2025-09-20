
import 'dart:async';

import 'package:get/get.dart';

import '../../core/services/sync_service.dart';
import '../../core/values/constants.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';

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
  Future<void> syncAbonentsList(
    String tpCode, {
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

  /// Отправка показаний счетчика с мониторингом через SyncService
  Future<void> submitMeterReading({
    required String accountNumber,
    required String meterSerialNumber,
    required int currentReading,
    required Function() onSubmitStarted,
    required Function(String message) onProgress,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      print('[SUBSCRIBER REPO] Submitting meter reading for: $accountNumber');

      // Отправляем показание
      final response = await _apiProvider.submitMeterReading(
        accountNumber: accountNumber,
        meterSerialNumber: meterSerialNumber,
        currentReading: currentReading,
      );

      final status = response['status'] ?? 'ERROR';
      final syncMessageId = response['syncMessageId'];

      if (status == 'INITIATED' && syncMessageId != null) {
        print('[SUBSCRIBER REPO] Reading submission initiated with messageId: $syncMessageId');
        onSubmitStarted();

        // Мониторим обработку показания
        await _syncService.monitorSync(
          messageId: syncMessageId,
          timeout: const Duration(minutes: 3),
          checkInterval: const Duration(seconds: 3),
          onSuccess: (syncStatus) {
            print('[SUBSCRIBER REPO] Reading processed successfully');
            onSuccess();
          },
          onError: (error) {
            print('[SUBSCRIBER REPO] Reading processing failed: $error');
            onError(error);
          },
          onProgress: (message, elapsed) {
            onProgress('Обработка показания...');
          },
        );
      } else {
        onError(response['message'] ?? 'Ошибка отправки показания');
      }
    } catch (e) {
      print('[SUBSCRIBER REPO] Error submitting reading: $e');
      onError('Не удалось отправить показание');
    }
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
  /// Синхронизация одного абонента с колбэками для UI
  Future<void> syncSingleSubscriber(
      String accountNumber, {
        required Function() onSyncStarted,
        required Function(String message) onProgress,
        required Function(SubscriberModel subscriber) onSuccess,
        required Function(String error) onError,
      }) async {
    try {
      print('[SUBSCRIBER REPO] Starting single subscriber sync: $accountNumber');

      // Запускаем синхронизацию
      final syncResponse = await _apiProvider.syncSingleAbonent(accountNumber);

      // Проверяем статус
      final status = syncResponse['status'] ?? 'ERROR';

      if (status == 'ALREADY_RUNNING') {
        print('[SUBSCRIBER REPO] Single sync already running');
        onError('Синхронизация уже выполняется');
        return;
      }

      if (status == 'ERROR') {
        print('[SUBSCRIBER REPO] Single sync initiation failed');
        onError(syncResponse['message'] ?? 'Ошибка запуска синхронизации');
        return;
      }

      if (status == 'INITIATED' && syncResponse['syncMessageId'] != null) {
        final messageId = syncResponse['syncMessageId'];
        print('[SUBSCRIBER REPO] Single sync initiated with messageId: $messageId');
        onSyncStarted();

        // Мониторим синхронизацию
        await _syncService.monitorSync(
          messageId: messageId,
          timeout: const Duration(minutes: 2),
          checkInterval: const Duration(seconds: 3),
          onSuccess: (syncStatus) async {
            // После успешной синхронизации получаем обновленные данные
            print('[SUBSCRIBER REPO] Single sync completed, fetching updated data...');
            try {
              final updatedSubscriber = await fetchSubscriberByAccount(accountNumber);
              if (updatedSubscriber != null) {
                onSuccess(updatedSubscriber);
              } else {
                onError('Не удалось получить обновленные данные');
              }
            } catch (e) {
              onError('Ошибка получения обновленных данных');
            }
          },
          onError: (error) {
            print('[SUBSCRIBER REPO] Single sync failed: $error');
            onError(error);
          },
          onProgress: (message, elapsed) {
            onProgress('Синхронизация абонента...');
          },
        );
      } else {
        onError('Неожиданный ответ сервера');
      }

    } catch (e) {
      print('[SUBSCRIBER REPO] Error in single subscriber sync: $e');
      onError('Не удалось запустить синхронизацию');
    }
  }

  /// Получение обновленных данных абонента
  Future<SubscriberModel?> fetchSubscriberByAccount(String accountNumber) async {
    try {
      print('[SUBSCRIBER REPO] Fetching subscriber data: $accountNumber');

      final responseData = await _apiProvider.getAbonentByAccount(accountNumber);

      // Преобразуем в модель
      final subscriber = SubscriberModel.fromJson(responseData);

      print('[SUBSCRIBER REPO] Successfully fetched subscriber: ${subscriber.fullName}');
      return subscriber;

    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching subscriber by account: $e');
      throw Exception('Не удалось получить данные абонента');
    }
  }

}
