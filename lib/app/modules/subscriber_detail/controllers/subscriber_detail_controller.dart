import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../widgets/gps_current_dialog.dart';
import '../widgets/gps_scanning_dialog.dart';
import '../widgets/gps_confirmation_dialog.dart';
import '../widgets/gps_success_dialog.dart';

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

  // ========================================
  // GPS COORDINATES METHODS
  // ========================================

  /// Запустить GPS-процесс: scanning → confirmation → save → success
  Future<void> captureCoordinates() async {
    if (_subscriber.value == null) return;

    final isUpdate = _subscriber.value!.hasCoordinates;

    try {
      // Проверяем что GPS включен
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final opened = await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange),
                SizedBox(width: 10),
                Text('GPS отключен', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ],
            ),
            content: const Text('Для записи координат необходимо включить службу геолокации (GPS).'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back(result: true);
                  await Geolocator.openLocationSettings();
                },
                child: const Text('Открыть настройки'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return; // Пользователь включит GPS и попробует снова
      }

      // Проверяем разрешения
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Доступ к геолокации запрещён');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        await Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.location_disabled, color: Colors.red),
                SizedBox(width: 10),
                Text('Нет доступа', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ],
            ),
            content: const Text('Доступ к геолокации запрещён. Разрешите в настройках приложения.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Get.back();
                  await Geolocator.openAppSettings();
                },
                child: const Text('Открыть настройки'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
        return;
      }

      // Показываем scanning dialog и делаем замеры
      final result = await _performGpsScan();
      if (result == null) return; // Отмена

      final lat = result[0];
      final lng = result[1];
      final accuracy = result[2];

      // Показываем confirmation dialog
      final confirmed = await Get.dialog<bool>(
        GpsConfirmationDialog(
          latitude: lat,
          longitude: lng,
          accuracy: accuracy,
          isUpdate: isUpdate,
          onRetry: () => captureCoordinates(), // Рекурсия для повтора
        ),
        barrierDismissible: false,
      );

      if (confirmed != true) return;

      // Сохраняем
      await _subscriberRepository.updateCoordinates(
        accountNumber: _subscriber.value!.accountNumber,
        latitude: lat,
        longitude: lng,
        accuracy: accuracy,
      );

      // Обновляем локальную модель через copyWith чтобы не потерять данные
      final updated = _subscriber.value!.copyWith(
        latitude: lat,
        longitude: lng,
        accuracy: accuracy,
      );
      _subscriber.value = null;
      await Future.delayed(const Duration(milliseconds: 10));
      _subscriber.value = updated;

      // Показываем success dialog
      await Get.dialog(
        GpsSuccessDialog(
          latitude: lat,
          longitude: lng,
          accuracy: accuracy,
          onShowOnMap: openInMaps,
        ),
      );
    } catch (e) {
      print('[SUBSCRIBER DETAIL] GPS error: $e');
      Get.snackbar(
        'Ошибка GPS',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Выполнить 3 замера GPS с диалогом прогресса. Возвращает [lat, lng, accuracy] или null.
  Future<List<double>?> _performGpsScan() async {
    double? bestAccuracy;
    final positions = <Position>[];

    // Показываем scanning dialog (реактивный через Obx не нужен — пересоздаём)
    for (int i = 0; i < 3; i++) {
      // Обновляем диалог
      if (i == 0) {
        Get.dialog(
          GpsScanningDialog(currentAttempt: 1, maxAttempts: 3, bestAccuracy: null),
          barrierDismissible: false,
        );
      } else {
        Get.back(); // Закрыть предыдущий
        Get.dialog(
          GpsScanningDialog(currentAttempt: i + 1, maxAttempts: 3, bestAccuracy: bestAccuracy),
          barrierDismissible: false,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      positions.add(position);

      if (bestAccuracy == null || position.accuracy < bestAccuracy) {
        bestAccuracy = position.accuracy;
      }

      if (i < 2) await Future.delayed(const Duration(seconds: 2));
    }

    // Закрыть scanning dialog
    Get.back();

    // Медиана
    positions.sort((a, b) => a.latitude.compareTo(b.latitude));
    final medianLat = positions[1].latitude;
    positions.sort((a, b) => a.longitude.compareTo(b.longitude));
    final medianLng = positions[1].longitude;
    final avgAccuracy = positions.map((p) => p.accuracy).reduce((a, b) => a + b) / 3;

    return [medianLat, medianLng, avgAccuracy];
  }

  /// Показать GPS диалог (вызывается из UI)
  void showGpsDialog() {
    if (_subscriber.value == null) return;

    if (_subscriber.value!.hasCoordinates) {
      // Есть координаты — показываем текущие данные
      Get.dialog(
        GpsCurrentDialog(
          latitude: _subscriber.value!.latitude!,
          longitude: _subscriber.value!.longitude!,
          accuracy: _subscriber.value!.accuracy,
          onShowOnMap: openInMaps,
          onUpdate: captureCoordinates,
        ),
      );
    } else {
      // Нет координат — сразу сканируем
      captureCoordinates();
    }
  }

  /// Открыть координаты на карте — системный выбор приложения
  Future<void> openInMaps() async {
    if (_subscriber.value == null || !_subscriber.value!.hasCoordinates) return;

    final lat = _subscriber.value!.latitude!;
    final lng = _subscriber.value!.longitude!;
    final url = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Фоллбэк на браузер
      final webUrl = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
