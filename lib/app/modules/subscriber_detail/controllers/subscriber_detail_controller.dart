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

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  SubscriberModel? get subscriber => _subscriber.value;
  bool get isSyncing => _isSyncing.value;
  String get syncMessage => _syncMessage.value;
  String get submissionMessage => _submissionMessage.value;
  bool get canSubmitReading => _canSubmitReading.value;

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

  // ИСПРАВЛЕНО: Refresh subscriber details
  Future<void> refreshSubscriberDetails() async {
    // ✅ ЗАЩИТА: Проверяем флаги
    if (_subscriber.value == null || _isSyncing.value) {
      print('[SUBSCRIBER DETAIL] ⚠️ Sync already in progress or no subscriber data');
      return;
    }

    final accountNumber = _subscriber.value!.accountNumber;

    // ✅ СРАЗУ блокируем повторные нажатия
    _isSyncing.value = true;
    _syncMessage.value = 'Инициализация...';

    print('[SUBSCRIBER DETAIL] Starting sync for: $accountNumber');

    try {
      await _subscriberRepository.syncSingleSubscriber(
        accountNumber,
        onSyncStarted: () {
          // Флаг уже установлен выше
          _syncMessage.value = 'Синхронизация...';
          print('[SUBSCRIBER DETAIL] Sync confirmed by server');
        },
        onProgress: (message) {
          _syncMessage.value = message.toLowerCase();
        },
        onSuccess: (updatedSubscriber) async {
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
        },
        onError: (error) {
          _isSyncing.value = false;
          _syncMessage.value = '';

          Get.snackbar(
            'Ошибка синхронизации',
            error,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            duration: const Duration(seconds: 3),
          );
        },
      );
    } catch (e) {
      // ✅ Если ошибка ДО вызова колбэков - сбрасываем флаг
      print('[SUBSCRIBER DETAIL] ❌ Error before sync started: $e');
      _isSyncing.value = false;
      _syncMessage.value = '';

      Get.snackbar(
        'Ошибка',
        'Не удалось запустить синхронизацию: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
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
    return null;
  }

  // Submit meter reading
  // Submit meter reading
  Future<void> submitReading() async {
    if (!formKey.currentState!.validate() || _subscriber.value == null) return;

    final reading = int.parse(readingController.text);
    final accountNumber = _subscriber.value!.accountNumber;
    final meterSerialNumber = _subscriber.value!.meterSerialNumber;

    _isSubmitting.value = true;

    await _subscriberRepository.submitMeterReading(
      accountNumber: accountNumber,
      meterSerialNumber: meterSerialNumber,
      currentReading: reading,
      onSubmitStarted: () {
        _submissionMessage.value = 'Отправка показания...';
        if (_subscriber.value != null) {
          _subscriber.value = _subscriber.value!.copyWith(canTakeReading: false);
          _updateCanSubmitReading();
        }
      },
      onProgress: (message) {
        _submissionMessage.value = message;
      },
      onSuccess: () async {
        _isSubmitting.value = false;
        _submissionMessage.value = '';

        Get.snackbar(
          'Успешно',
          'Показание принято и обработано',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 3),
        );

        // Очищаем форму
        readingController.clear();

        // Автоматически синхронизируем данные абонента
        await refreshSubscriberDetails();
      },
      onError: (error) {
        _isSubmitting.value = false;
        _submissionMessage.value = '';

        // ИСПРАВЛЕНО: Правильное обновление Rxn при ошибке
        if (_subscriber.value != null) {
          _subscriber.value = _subscriber.value!.copyWith(canTakeReading: true);
          _updateCanSubmitReading();
        }

        Get.snackbar(
          'Ошибка отправки',
          error,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 4),
        );
      },
    );
  }

  // НОВОЕ: Получение информации для UI
  String get subscriberName => subscriber?.fullName ?? 'Неизвестно';

  String get subscriberAccount => subscriber?.accountNumber ?? '';
}
