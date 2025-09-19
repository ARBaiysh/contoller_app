import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/sync_status_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Универсальный сервис синхронизации для любых типов операций
class SyncService extends GetxService {
  AuthRepository get _authRepository => Get.find<AuthRepository>();

  // Активные синхронизации (для предотвращения дублирования)
  final Map<int, Timer> _activeSync = {};

  @override
  void onClose() {
    // Останавливаем все активные синхронизации при закрытии сервиса
    for (var timer in _activeSync.values) {
      timer.cancel();
    }
    _activeSync.clear();
    super.onClose();
  }

  /// Мониторинг синхронизации с настраиваемыми параметрами
  ///
  /// [messageId] - ID сообщения для мониторинга
  /// [timeout] - Максимальное время ожидания
  /// [checkInterval] - Частота проверки статуса
  /// [onSuccess] - Колбэк при успешном завершении
  /// [onError] - Колбэк при ошибке
  /// [onProgress] - Колбэк для обновления прогресса (опционально)
  Future<void> monitorSync({
    required int messageId,
    required Duration timeout,
    required Duration checkInterval,
    required Function(SyncStatusModel) onSuccess,
    required Function(String error) onError,
    Function(String message, Duration elapsed)? onProgress,
  }) async {
    // Проверяем, не мониторится ли уже эта синхронизация
    if (_activeSync.containsKey(messageId)) {
      print('[SYNC SERVICE] Sync $messageId already being monitored');
      return;
    }

    print('[SYNC SERVICE] Starting monitoring sync $messageId');
    print('[SYNC SERVICE] Timeout: ${timeout.inMinutes}m, Check interval: ${checkInterval.inSeconds}s');

    final startTime = DateTime.now();
    late Timer syncTimer;
    late Timer timeoutTimer;

    // Функция очистки
    void cleanup() {
      syncTimer.cancel();
      timeoutTimer.cancel();
      _activeSync.remove(messageId);
      print('[SYNC SERVICE] Cleanup completed for sync $messageId');
    }

    // Таймер таймаута
    timeoutTimer = Timer(timeout, () {
      print('[SYNC SERVICE] Sync $messageId timed out after ${timeout.inMinutes} minutes');
      cleanup();
      onError('Время ожидания синхронизации истекло (${timeout.inMinutes} мин)');
    });

    // Функция проверки статуса
    Future<void> checkStatus() async {
      try {
        final elapsed = DateTime.now().difference(startTime);
        print('[SYNC SERVICE] Checking status for sync $messageId (elapsed: ${elapsed.inSeconds}s)');

        final syncStatus = await _authRepository.checkSyncStatus(messageId);
        print('[SYNC SERVICE] Status: ${syncStatus.status}');

        if (syncStatus.isSuccess) {
          print('[SYNC SERVICE] Sync $messageId completed successfully');
          cleanup();
          onSuccess(syncStatus);

        } else if (syncStatus.isError) {
          final errorMessage = syncStatus.errorDetails ?? 'Ошибка синхронизации';
          print('[SYNC SERVICE] Sync $messageId failed: $errorMessage');
          cleanup();
          onError(errorMessage);

        } else if (syncStatus.isSyncing) {
          // Синхронизация продолжается - обновляем прогресс
          onProgress?.call(syncStatus.displayMessage, elapsed);
          print('[SYNC SERVICE] Sync $messageId still in progress: ${syncStatus.status}');

        } else {
          // Неизвестный статус
          print('[SYNC SERVICE] Unknown status for sync $messageId: ${syncStatus.status}');
          cleanup();
          onError('Неизвестный статус синхронизации: ${syncStatus.status}');
        }

      } catch (e) {
        print('[SYNC SERVICE] Error checking sync status: $e');
        cleanup();
        onError('Ошибка при проверке статуса синхронизации');
      }
    }

    // Запускаем периодическую проверку
    syncTimer = Timer.periodic(checkInterval, (_) => checkStatus());
    _activeSync[messageId] = syncTimer;

    // Делаем первую проверку сразу
    await checkStatus();
  }

  /// Остановить мониторинг конкретной синхронизации
  void cancelSync(int messageId) {
    final timer = _activeSync[messageId];
    if (timer != null) {
      timer.cancel();
      _activeSync.remove(messageId);
      print('[SYNC SERVICE] Cancelled monitoring for sync $messageId');
    }
  }

  /// Проверить, мониторится ли синхронизация
  bool isSyncActive(int messageId) {
    return _activeSync.containsKey(messageId);
  }

  /// Получить количество активных синхронизаций
  int get activeSyncCount => _activeSync.length;

  /// Остановить все активные синхронизации
  void cancelAllSync() {
    for (var entry in _activeSync.entries) {
      entry.value.cancel();
      print('[SYNC SERVICE] Cancelled sync ${entry.key}');
    }
    _activeSync.clear();
  }
}