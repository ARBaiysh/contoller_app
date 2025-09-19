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
  final TextEditingController commentController = TextEditingController();

  // ИСПРАВЛЕНО: Данные из аргументов
  late final String tpName;
  late final String tpCode;

  // Observable states
  final _isLoading = false.obs;
  final _isSubmitting = false.obs;
  final _subscriber = Rxn<SubscriberModel>();

  // Getters
  bool get isLoading => _isLoading.value;

  bool get isSubmitting => _isSubmitting.value;

  SubscriberModel? get subscriber => _subscriber.value;

  bool get canSubmitReading => subscriber?.canTakeReading ?? false;

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
  }

  @override
  void onClose() {
    readingController.dispose();
    commentController.dispose();
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

  // ИСПРАВЛЕНО: Refresh subscriber details
  Future<void> refreshSubscriberDetails() async {
    if (_subscriber.value == null) return;

    _isLoading.value = true;
    try {
      // Перезагружаем данные абонента через repository
      final accountNumber = _subscriber.value!.accountNumber;
      final updatedSubscriber = await _subscriberRepository.getSubscriberByAccountNumber(accountNumber);

      if (updatedSubscriber != null) {
        _subscriber.value = updatedSubscriber;
        print('[SUBSCRIBER DETAIL] Subscriber data refreshed');
      }
    } catch (e) {
      print('[SUBSCRIBER DETAIL] Error refreshing subscriber: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось обновить данные абонента',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
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

    // ИСПРАВЛЕНО: Добавим проверку минимального и максимального значения
    final minValue = 0;
    final maxValue = 999999;

    if (reading < minValue || reading > maxValue) {
      return 'Показание должно быть от $minValue до $maxValue';
    }

    if (subscriber?.lastReading != null && reading <= subscriber!.lastReading!) {
      return 'Новое показание должно быть больше предыдущего (${subscriber!.lastReading})';
    }

    return null;
  }

  // Submit reading
  Future<void> submitReading({
    required int reading,
    String comment = '',
  }) async {
    if (_subscriber.value == null) return;

    _isSubmitting.value = true;

    try {
      print('[SUBSCRIBER DETAIL] Submitting reading: $reading for ${_subscriber.value!.accountNumber}');

      // Отправляем показание через repository
      final success = await _subscriberRepository.submitMeterReading(
        accountNumber: _subscriber.value!.accountNumber,
        currentReading: reading,
      );

      if (success) {
        Get.snackbar(
          'Успешно',
          'Показание отправлено',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          snackPosition: SnackPosition.TOP,
        );

        // Очищаем форму
        readingController.clear();
        commentController.clear();

        // Обновляем данные абонента
        await refreshSubscriberDetails();

        // Возвращаемся назад
        Get.back();
      }
    } catch (e) {
      print('[SUBSCRIBER DETAIL] Error submitting reading: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось отправить показание: ${e.toString().replaceAll('Exception: ', '')}',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  // Calculate consumption
  String calculateConsumption(int newReading) {
    if (subscriber?.lastReading == null) return '0';
    final consumption = newReading - subscriber!.lastReading!;
    return consumption.toString();
  }

  // Calculate approximate amount (примерный расчет)
  String calculateAmount(int newReading) {
    if (subscriber?.lastReading == null) return '0.00';
    final consumption = newReading - subscriber!.lastReading!;
    // Примерный расчет: 1.5 руб за кВт·ч
    final amount = consumption * 1.5;
    return amount.toStringAsFixed(2);
  }

  // НОВОЕ: Получение информации для UI
  String get subscriberName => subscriber?.fullName ?? 'Неизвестно';

  String get subscriberAccount => subscriber?.accountNumber ?? '';
}
