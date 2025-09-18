import 'package:get/get.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';
import 'tp_repository.dart';

class SubscriberRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final TpRepository _tpRepository = Get.find<TpRepository>();

  // Get subscribers by TP
  Future<List<SubscriberModel>> getSubscribersByTp(String tpCode, {bool forceRefresh = false}) async {
    try {
      // Всегда загружаем с сервера
      final response = await _apiProvider.getAbonentsByTp(tpCode);
      final subscribers = response.data;

      // Обновляем статистику ТП
      _updateTpStatistics(tpCode, subscribers);

      // Проверяем статус синхронизации
      if (response.syncing && response.syncMessageId != null) {
        print('[SUBSCRIBER REPO] Abonents are syncing, messageId: ${response.syncMessageId}');
        // TODO: Обработать синхронизацию когда будет готов механизм
      }

      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching subscribers: $e');
      throw Exception('Не удалось загрузить список абонентов');
    }
  }

  // Search subscribers - теперь нужно загружать все ТП для поиска
  Future<List<SubscriberModel>> searchSubscribers(String query) async {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final List<SubscriberModel> results = [];

    // Получаем список всех ТП
    final tpList = await _tpRepository.getTpList();

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
      }
    }

    return results;
  }

  // Get subscriber by account number
  Future<SubscriberModel?> getSubscriberByAccountNumber(String accountNumber) async {
    // Определяем TP по номеру счета
    // Формат: TPXXXX_XXXXXX
    final parts = accountNumber.split('_');
    if (parts.length == 2) {
      final tpCode = parts[0];
      try {
        final subscribers = await getSubscribersByTp(tpCode);
        return subscribers.firstWhereOrNull(
              (s) => s.accountNumber == accountNumber,
        );
      } catch (e) {
        print('[SUBSCRIBER REPO] Error getting subscriber: $e');
        return null;
      }
    }

    return null;
  }

  // Submit meter reading
  Future<bool> submitMeterReading({
    required String accountNumber,
    required int currentReading,
  }) async {
    try {
      final response = await _apiProvider.submitMeterReading(
        accountNumber: accountNumber,
        currentReading: currentReading,
      );

      // После отправки обновляем список абонентов
      final parts = accountNumber.split('_');
      if (parts.length == 2) {
        final tpCode = parts[0];
        await getSubscribersByTp(tpCode);
      }

      return true;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error submitting reading: $e');
      throw Exception('Не удалось отправить показание');
    }
  }

  // Обновить статистику ТП
  void _updateTpStatistics(String tpCode, List<SubscriberModel> subscribers) {
    // Рассчитываем статистику
    final statistics = <String, dynamic>{
      'total_subscribers': subscribers.length,
      'readings_collected': 0,
      'readings_available': 0,
      'readings_processing': 0,
      'readings_completed': 0,
    };

    for (final subscriber in subscribers) {
      if (subscriber.canTakeReading) {
        statistics['readings_available']++;
      } else {
        statistics['readings_completed']++;
        statistics['readings_collected']++;
      }

      // Если есть текущее показание в процессе
      if (subscriber.readingStatus == ReadingStatus.processing) {
        statistics['readings_processing']++;
        statistics['readings_collected']++;
      }
    }

    // Обновляем в TpRepository
    _tpRepository.updateTpStatistics(tpCode, subscribers);
    print('[SUBSCRIBER REPO] Updated TP $tpCode statistics: $statistics');
  }

  // Обновить список абонентов (для совместимости)
  Future<List<SubscriberModel>> refreshSubscribers(String tpCode) async {
    return getSubscribersByTp(tpCode);
  }
}