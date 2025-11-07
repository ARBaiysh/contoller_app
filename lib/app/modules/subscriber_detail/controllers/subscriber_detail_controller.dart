import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';

class SubscriberDetailController extends GetxController {
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();

  // Form key for reading input
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controller for new reading
  final TextEditingController readingController = TextEditingController();

  // ИСПРАВЛЕНО: Данные из аргументов
  late final String tpName;
  late final String tpCode;

  // Observable states
  final _isLoading = false.obs;
  final _isSubmitting = false.obs;
  final Rxn<SubscriberModel> _subscriber = Rxn<SubscriberModel>(SubscriberModel.empty());
  final _isSyncing = false.obs;
  final _syncMessage = ''.obs;
  final _submissionMessage = ''.obs;

  final _canSubmitReading = false.obs;

  // История показаний
  final _readingHistory = <Map<String, dynamic>>[].obs;
  final _isLoadingHistory = false.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  SubscriberModel? get subscriber => _subscriber.value;
  bool get isSyncing => _isSyncing.value;
  String get syncMessage => _syncMessage.value;
  String get submissionMessage => _submissionMessage.value;
  bool get canSubmitReading => _canSubmitReading.value;
  List<Map<String, dynamic>> get readingHistory => _readingHistory;
  bool get isLoadingHistory => _isLoadingHistory.value;

  @override
  void onInit() {
    super.onInit();
    // ИСПРАВЛЕНО: Получаем subscriber напрямую из аргументов
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    // Проверяем, передан ли объект subscriber
    if (args.containsKey('subscriber')) {
      _subscriber.value = args['subscriber'] as SubscriberModel;
      print('[SUBSCRIBER DETAIL] Received subscriber: ${_subscriber.value?.accountNumber}');
    }

    tpName = args['tpName'] ?? _subscriber.value?.transformerPointName ?? 'ТП';
    tpCode = args['tpCode'] ?? _subscriber.value?.transformerPointCode ?? '';

    // Если данные не переданы, показываем ошибку
    if (_subscriber.value == null) {
      print('[SUBSCRIBER DETAIL] ERROR: No subscriber data received');
      _isLoading.value = false;
    } else {
      _isLoading.value = false;
      print('[SUBSCRIBER DETAIL] Subscriber loaded successfully: ${_subscriber.value!.fullName}');
    }

    _isSyncing.listen((_) => _updateCanSubmitReading());
    _subscriber.listen((_) => _updateCanSubmitReading());

    _updateCanSubmitReading();

    // Загружаем историю показаний
    if (_subscriber.value != null) {
      loadReadingHistory();
    }
  }

  void _updateCanSubmitReading() {
    if (_isSyncing.value) {
      _canSubmitReading.value = false;
      return;
    }

    if (_subscriber.value == null) {
      _canSubmitReading.value = false;
      return;
    }

    if (!_subscriber.value!.canTakeReading) {
      _canSubmitReading.value = false;
      return;
    }

    if (_subscriber.value!.lastReadingDate != null) {
      final now = DateTime.now();
      final lastReading = _subscriber.value!.lastReadingDate!;
      if (lastReading.year == now.year && lastReading.month == now.month) {
        _canSubmitReading.value = false;
        return;
      }
    }

    _canSubmitReading.value = true;
  }

  @override
  void onClose() {
    readingController.dispose();
    super.onClose();
  }

  // ИСПРАВЛЕНО: Load subscriber details (теперь данные уже есть)
  Future<void> loadSubscriberDetails() async {
    if (_subscriber.value != null) {
      // Данные уже есть, просто обновляем
      return;
    }

    _isLoading.value = true;
    try {
      // Если нет данных, показываем ошибку
      Get.snackbar(
        'Ошибка',
        'Данные абонента не переданы',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } catch (e) {
      print('[SUBSCRIBER DETAIL] Error loading subscriber: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh subscriber details
  Future<void> refreshSubscriberDetails() async {
    if (_subscriber.value == null || _isSyncing.value) {
      print('[SUBSCRIBER DETAIL] ⚠️ Already refreshing or no subscriber data');
      return;
    }

    final accountNumber = _subscriber.value!.accountNumber;

    _isSyncing.value = true;
    _syncMessage.value = 'Обновление данных...';

    print('[SUBSCRIBER DETAIL] Refreshing data for: $accountNumber');

    try {
      final updatedSubscriber = await _subscriberRepository.getSubscriberByAccountNumber(
        accountNumber,
        forceRefresh: true,
      );

      _subscriber.value = null;
      await Future.delayed(const Duration(milliseconds: 10));
      _subscriber.value = updatedSubscriber;
      _updateCanSubmitReading();
      update();

      _isSyncing.value = false;
      _syncMessage.value = '';

      Get.snackbar(
        'Успешно',
        'Данные абонента обновлены',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('[SUBSCRIBER DETAIL] Error refreshing: $e');
      _isSyncing.value = false;
      _syncMessage.value = '';

      Get.snackbar(
        'Ошибка',
        'Не удалось обновить данные: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ========================================
  // ИСТОРИЯ ПОКАЗАНИЙ
  // ========================================

  /// Загрузить историю показаний
  Future<void> loadReadingHistory() async {
    if (_subscriber.value == null) {
      print('[SUBSCRIBER DETAIL] Cannot load reading history: no subscriber data');
      return;
    }

    final accountNumber = _subscriber.value!.accountNumber;

    _isLoadingHistory.value = true;

    try {
      print('[SUBSCRIBER DETAIL] Loading reading history for: $accountNumber');

      final history = await _subscriberRepository.getReadingHistory(accountNumber);

      _readingHistory.value = history;
      print('[SUBSCRIBER DETAIL] Reading history loaded: ${history.length} items');
    } catch (e) {
      print('[SUBSCRIBER DETAIL] Error loading reading history: $e');
      // Не показываем ошибку пользователю, просто оставляем историю пустой
      _readingHistory.value = [];
    } finally {
      _isLoadingHistory.value = false;
    }
  }

  // Validate reading
  String? validateReading(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите показание';
    }

    final reading = int.tryParse(value);
    if (reading == null) {
      return 'Введите корректное число';
    }

    // Проверка минимального и максимального значения
    final minValue = 0;
    final maxValue = 999999;

    if (reading < minValue || reading > maxValue) {
      return 'Показание должно быть от $minValue до $maxValue';
    }

    // Бэкенд сам проверит логику показаний (перемотка счетчика и т.д.)
    return null;
  }

  // Submit meter reading
  Future<void> submitReading() async {
    if (!formKey.currentState!.validate() || _subscriber.value == null) return;

    final reading = int.parse(readingController.text);
    final accountNumber = _subscriber.value!.accountNumber;
    final meterSerialNumber = _subscriber.value!.meterSerialNumber;

    _isSubmitting.value = true;
    _submissionMessage.value = 'Отправка показания...';

    try {
      // 1. Отправляем показание
      print('[SUBSCRIBER DETAIL] Submitting reading: $reading for $accountNumber');
      final response = await _subscriberRepository.submitMeterReading(
        accountNumber: accountNumber,
        currentReading: reading,
        meterSerialNumber: meterSerialNumber,
      );

      final readingId = response['readingId'];
      final status = response['status'];
      print('[SUBSCRIBER DETAIL] Reading submitted: readingId=$readingId, status=$status');

      // 2. Сразу получаем историю показаний
      _submissionMessage.value = 'Проверка статуса...';
      await Future.delayed(const Duration(milliseconds: 500)); // Небольшая задержка для обработки

      final history = await _subscriberRepository.getReadingHistory(accountNumber);
      print('[SUBSCRIBER DETAIL] Reading history loaded: ${history.length} items');

      // 3. Находим наше показание по readingId
      final ourReading = history.firstWhere(
        (item) => item['readingId'] == readingId,
        orElse: () => {'status': 'PROCESSING'},
      );

      final finalStatus = ourReading['status'] as String;
      final message = ourReading['message'] as String? ?? '';
      final documentNumber = ourReading['documentNumber'] as String?;

      print('[SUBSCRIBER DETAIL] Final status: $finalStatus, message: $message');

      _isSubmitting.value = false;
      _submissionMessage.value = '';

      // 4. Обрабатываем результат
      if (finalStatus == 'COMPLETED') {
        // Успех!
        Get.snackbar(
          'Успешно',
          documentNumber != null
            ? 'Показание зарегистрировано\nДокумент: $documentNumber'
            : message.isNotEmpty ? message : 'Показание успешно отправлено',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 3),
        );

        // Очищаем форму
        readingController.clear();

        // Автоматически обновляем данные абонента и историю показаний
        await Future.wait([
          refreshSubscriberDetails(),
          loadReadingHistory(),
        ]);
      } else if (finalStatus == 'ERROR') {
        // Ошибка обработки
        Get.snackbar(
          'Ошибка обработки',
          message.isNotEmpty ? message : 'Произошла ошибка при обработке показания',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 5),
          maxWidth: 500,
        );
      } else {
        // PROCESSING - еще обрабатывается
        Get.snackbar(
          'В обработке',
          'Показание принято и обрабатывается',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
          duration: const Duration(seconds: 3),
        );

        // Очищаем форму
        readingController.clear();

        // Обновляем данные абонента и историю показаний
        await Future.wait([
          refreshSubscriberDetails(),
          loadReadingHistory(),
        ]);
      }
    } catch (e) {
      _isSubmitting.value = false;
      _submissionMessage.value = '';

      print('[SUBSCRIBER DETAIL] Error submitting reading: $e');

      Get.snackbar(
        'Ошибка отправки',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // НОВОЕ: Получение информации для UI
  String get subscriberName => subscriber?.fullName ?? 'Неизвестно';

  String get subscriberAccount => subscriber?.accountNumber ?? '';

  // ========================================
  // PHONE MANAGEMENT METHODS
  // ========================================

  final _isPhoneUpdating = false.obs;
  bool get isPhoneUpdating => _isPhoneUpdating.value;

  /// Обновить телефон абонента
  Future<void> updatePhone(String phoneNumber) async {
    if (_subscriber.value == null || _isPhoneUpdating.value) {
      return;
    }

    final accountNumber = _subscriber.value!.accountNumber;

    _isPhoneUpdating.value = true;

    try {
      print('[SUBSCRIBER DETAIL] Updating phone for: $accountNumber to: $phoneNumber');

      await _subscriberRepository.updatePhone(
        accountNumber: accountNumber,
        phoneNumber: phoneNumber,
      );

      // Обновляем локальные данные абонента
      final updatedSubscriber = _subscriber.value!.copyWith(phone: phoneNumber);
      _subscriber.value = null;
      await Future.delayed(const Duration(milliseconds: 10));
      _subscriber.value = updatedSubscriber;

      _isPhoneUpdating.value = false;

      Get.snackbar(
        'Успешно',
        'Номер телефона обновлен',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _isPhoneUpdating.value = false;

      print('[SUBSCRIBER DETAIL] Error updating phone: $e');

      Get.snackbar(
        'Ошибка',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );

      rethrow; // Пробрасываем для обработки в диалоге
    }
  }
}
