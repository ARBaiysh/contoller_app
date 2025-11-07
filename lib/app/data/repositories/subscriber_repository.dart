import 'package:get/get.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';

class SubscriberRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  // ========================================
  // ОСНОВНЫЕ МЕТОДЫ ЗАГРУЗКИ
  // ========================================

  /// Получение всех абонентов инспектора
  /// forceRefresh - принудительное обновление из 1С
  Future<List<SubscriberModel>> getAllSubscribers({bool forceRefresh = false}) async {
    try {
      print('[SUBSCRIBER REPO] Getting all subscribers (forceRefresh: $forceRefresh)');

      final responseData = await _apiProvider.getAllAbonents(
        forceRefresh: forceRefresh,
      );

      final subscribers = responseData
          .map((json) => SubscriberModel.fromJson(json))
          .toList();

      print('[SUBSCRIBER REPO] Loaded ${subscribers.length} subscribers');
      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching all subscribers: $e');
      throw Exception('Не удалось загрузить список абонентов');
    }
  }

  /// Получение списка абонентов по ТП
  /// forceRefresh - принудительное обновление из 1С
  Future<List<SubscriberModel>> getSubscribersByTp(
    String tpCode, {
    bool forceRefresh = false,
  }) async {
    try {
      print('[SUBSCRIBER REPO] Getting subscribers for TP: $tpCode (forceRefresh: $forceRefresh)');

      final responseData = await _apiProvider.getAbonentsByTp(
        tpCode,
        forceRefresh: forceRefresh,
      );

      final subscribers = responseData
          .map((json) => SubscriberModel.fromJson(json))
          .toList();

      print('[SUBSCRIBER REPO] Loaded ${subscribers.length} subscribers for TP: $tpCode');
      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching subscribers: $e');
      throw Exception('Не удалось загрузить список абонентов');
    }
  }

  /// Получение детальной информации об абоненте
  /// forceRefresh - принудительное обновление из 1С
  Future<SubscriberModel> getSubscriberByAccountNumber(
    String accountNumber, {
    bool forceRefresh = false,
  }) async {
    try {
      print('[SUBSCRIBER REPO] Getting subscriber: $accountNumber (forceRefresh: $forceRefresh)');

      final responseData = await _apiProvider.getAbonentByAccount(
        accountNumber,
        forceRefresh: forceRefresh,
      );

      final subscriber = SubscriberModel.fromJson(responseData);

      print('[SUBSCRIBER REPO] Successfully fetched subscriber: ${subscriber.fullName}');
      return subscriber;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error getting subscriber by account: $e');
      throw Exception('Не удалось получить данные абонента');
    }
  }

  // ========================================
  // ПОИСК
  // ========================================

  /// Живой поиск абонентов (на сервере)
  /// Возвращает максимум 30 результатов
  Future<List<SubscriberModel>> searchSubscribers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      print('[SUBSCRIBER REPO] Searching subscribers with query: $query');

      final results = await _apiProvider.searchAbonents(query);

      final subscribers = results
          .map((json) => SubscriberModel.fromJson(json))
          .toList();

      print('[SUBSCRIBER REPO] Search completed: found ${subscribers.length} results');
      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Search error: $e');
      throw Exception('Ошибка при поиске абонентов');
    }
  }

  // ========================================
  // ПОКАЗАНИЯ СЧЕТЧИКОВ
  // ========================================

  /// Отправка показания счетчика
  /// Возвращает readingId для отслеживания статуса
  Future<Map<String, dynamic>> submitMeterReading({
    required String accountNumber,
    required int currentReading,
    String? meterSerialNumber,
  }) async {
    try {
      print('[SUBSCRIBER REPO] Submitting meter reading for: $accountNumber');

      final response = await _apiProvider.submitMeterReading(
        accountNumber: accountNumber,
        currentReading: currentReading,
        meterSerialNumber: meterSerialNumber,
      );

      print('[SUBSCRIBER REPO] Reading submitted successfully');
      return response;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error submitting reading: $e');
      throw Exception('Не удалось отправить показание');
    }
  }

  /// Проверить статус показания
  Future<Map<String, dynamic>> checkReadingStatus(int readingId) async {
    try {
      print('[SUBSCRIBER REPO] Checking reading status: $readingId');

      final response = await _apiProvider.checkReadingStatus(readingId);

      return response;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error checking reading status: $e');
      throw Exception('Не удалось проверить статус показания');
    }
  }

  /// Получить историю показаний по лицевому счету
  Future<List<Map<String, dynamic>>> getReadingHistory(String accountNumber) async {
    try {
      print('[SUBSCRIBER REPO] Getting reading history for: $accountNumber');

      final response = await _apiProvider.getReadingHistory(accountNumber);

      // Преобразуем в список Map
      final history = response.map((item) => Map<String, dynamic>.from(item)).toList();

      print('[SUBSCRIBER REPO] Reading history loaded: ${history.length} items');
      return history;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error getting reading history: $e');
      throw Exception('Не удалось получить историю показаний');
    }
  }

  // ========================================
  // УПРАВЛЕНИЕ ТЕЛЕФОНАМИ
  // ========================================

  /// Обновить номер телефона абонента
  Future<void> updatePhone({
    required String accountNumber,
    required String phoneNumber,
  }) async {
    try {
      print('[SUBSCRIBER REPO] Updating phone for account: $accountNumber');

      await _apiProvider.updatePhone(
        accountNumber: accountNumber,
        phoneNumber: phoneNumber,
      );

      print('[SUBSCRIBER REPO] Phone updated successfully');
    } catch (e) {
      print('[SUBSCRIBER REPO] Error updating phone: $e');
      rethrow;
    }
  }

  // ========================================
  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ
  // ========================================

  /// Принудительное обновление списка абонентов для ТП
  Future<List<SubscriberModel>> refreshSubscribers(String tpCode) async {
    return getSubscribersByTp(tpCode, forceRefresh: true);
  }

  /// Получение статистики абонентов (локальный расчет)
  Map<String, int> getSubscriberStatistics(List<SubscriberModel> subscribers) {
    return {
      'total': subscribers.length,
      'debtors': subscribers.where((s) => s.isDebtor).length,
    };
  }

  // Для обратной совместимости - заглушка для синхронизации одного абонента
  Future<void> syncSingleSubscriber(
    String accountNumber, {
    required Function() onSyncStarted,
    required Function(String message) onProgress,
    required Function(SubscriberModel subscriber) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      // В новом API просто обновляем данные через forceRefresh
      onSyncStarted();
      onProgress('Обновление данных...');

      final subscriber = await getSubscriberByAccountNumber(
        accountNumber,
        forceRefresh: true,
      );

      onSuccess(subscriber);
    } catch (e) {
      onError(e.toString());
    }
  }

  // ========================================
  // СПЕЦИАЛЬНЫЕ СПИСКИ
  // ========================================

  /// Получить список абонентов с показаниями за текущий месяц
  Future<List<SubscriberModel>> getAbonentsWithConsumption() async {
    try {
      print('[SUBSCRIBER REPO] Fetching abonents with consumption');

      final data = await _apiProvider.getAbonentsWithConsumption();
      final subscribers = data.map((json) => SubscriberModel.fromJson(json)).toList();

      print('[SUBSCRIBER REPO] Loaded ${subscribers.length} abonents with consumption');
      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching consumption list: $e');
      throw Exception('Не удалось загрузить список абонентов с показаниями');
    }
  }

  /// Получить список абонентов которые оплатили в текущем месяце
  Future<List<SubscriberModel>> getAbonentsWithPayments() async {
    try {
      print('[SUBSCRIBER REPO] Fetching abonents with payments');

      final data = await _apiProvider.getAbonentsWithPayments();
      final subscribers = data.map((json) => SubscriberModel.fromJson(json)).toList();

      print('[SUBSCRIBER REPO] Loaded ${subscribers.length} abonents with payments');
      return subscribers;
    } catch (e) {
      print('[SUBSCRIBER REPO] Error fetching payments list: $e');
      throw Exception('Не удалось загрузить список оплативших абонентов');
    }
  }
}
