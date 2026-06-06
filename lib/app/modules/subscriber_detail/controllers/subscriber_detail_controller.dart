import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/askue_model.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../routes/app_pages.dart';
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

  // АСКУЭ
  final Rxn<AskueStatus> _askueStatus = Rxn<AskueStatus>();
  AskueStatus? get askueStatus => _askueStatus.value;

  /// Идёт проверка показания в АСКУЭ (показываем индикатор вместо поля ввода)
  final _isAskueChecking = false.obs;
  bool get isAskueChecking => _isAskueChecking.value;

  /// Свежее показание из АСКУЭ есть → поле ввода залочено и предзаполнено
  bool get isAskueLocked => _askueStatus.value?.fresh == true;

  /// У абонента привязан АСКУЭ-ПУ (для кнопки «История АСКУЭ»)
  bool get hasAskue => _subscriber.value?.hasAskue == true;

  AskueReading? get askueLatest => _askueStatus.value?.latest;

  /// Дата последнего АСКУЭ-показания в формате dd.MM.yyyy
  String? get askueLatestDate {
    final d = _askueStatus.value?.latest?.date;
    if (d == null) return null;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

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
      _loadAskueStatus();
    }
  }

  /// Загрузить статус АСКУЭ и, если показание свежее, предзаполнить поле
  /// ввода целой частью (1С принимает целое показание).
  Future<void> _loadAskueStatus() async {
    final sub = _subscriber.value;
    if (sub == null || !sub.hasAskue) return;

    _isAskueChecking.value = true;
    try {
      final status = await _subscriberRepository.getAskueStatus(sub.accountNumber);
      _askueStatus.value = status;

      if (status.fresh && status.latest != null) {
        readingController.text = status.latest!.reading.toInt().toString();
      }
    } finally {
      _isAskueChecking.value = false;
    }
  }

  /// Открыть экран истории АСКУЭ-показаний
  void openAskueHistory() {
    final sub = _subscriber.value;
    if (sub == null || !sub.hasAskue) return;
    Get.toNamed(Routes.ASKUE_HISTORY, arguments: {
      'accountNumber': sub.accountNumber,
      'fullName': sub.fullName,
    });
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
      AppSnackbar.error('Ошибка', 'Данные абонента не переданы');
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

      AppSnackbar.success('Успешно', 'Данные абонента обновлены',
          duration: const Duration(seconds: 2));
    } catch (e) {
      print('[SUBSCRIBER DETAIL] Error refreshing: $e');
      _isSyncing.value = false;
      _syncMessage.value = '';

      AppSnackbar.error('Ошибка',
          'Не удалось обновить данные: ${e.toString().replaceAll('Exception: ', '')}');
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
        AppSnackbar.success(
          'Успешно',
          documentNumber != null
              ? 'Показание зарегистрировано\nДокумент: $documentNumber'
              : message.isNotEmpty ? message : 'Показание успешно отправлено',
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
        AppSnackbar.error(
          'Ошибка обработки',
          message.isNotEmpty ? message : 'Произошла ошибка при обработке показания',
          duration: const Duration(seconds: 5),
        );
      } else {
        // PROCESSING - еще обрабатывается
        AppSnackbar.warning('В обработке', 'Показание принято и обрабатывается');

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

      AppSnackbar.error('Ошибка отправки', e.toString().replaceAll('Exception: ', ''));
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

      AppSnackbar.success('Успешно', 'Номер телефона обновлен',
          duration: const Duration(seconds: 2));
    } catch (e) {
      _isPhoneUpdating.value = false;

      print('[SUBSCRIBER DETAIL] Error updating phone: $e');

      AppSnackbar.error('Ошибка', e.toString().replaceAll('Exception: ', ''));

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
      AppSnackbar.error('Ошибка GPS', e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Выполнить 3 замера GPS с диалогом прогресса. Возвращает [lat, lng, accuracy] или null.
  Future<List<double>?> _performGpsScan() async {
    final currentAttempt = 1.obs;
    final bestAccuracyRx = Rxn<double>();
    final positions = <Position>[];

    final overlayContext = Get.overlayContext ?? Get.context;
    if (overlayContext == null) {
      throw Exception('Нет контекста навигатора');
    }
    final navigator = Navigator.of(overlayContext, rootNavigator: true);

    final scanRoute = DialogRoute<void>(
      context: overlayContext,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => Obx(() => GpsScanningDialog(
            currentAttempt: currentAttempt.value,
            maxAttempts: 3,
            bestAccuracy: bestAccuracyRx.value,
          )),
    );

    bool routeClosed = false;
    void closeScanRoute() {
      if (routeClosed) return;
      routeClosed = true;
      try {
        if (scanRoute.isActive) {
          navigator.removeRoute(scanRoute);
        }
      } catch (e) {
        print('[SUBSCRIBER DETAIL] closeScanRoute error: $e');
      }
    }

    try {
      navigator.push(scanRoute);

      for (int i = 0; i < 3; i++) {
        currentAttempt.value = i + 1;

        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 25),
          );
          positions.add(position);

          if (bestAccuracyRx.value == null || position.accuracy < bestAccuracyRx.value!) {
            bestAccuracyRx.value = position.accuracy;
          }
        } catch (e) {
          print('[SUBSCRIBER DETAIL] GPS attempt ${i + 1} failed: $e');
        }

        if (i < 2) await Future.delayed(const Duration(seconds: 2));
      }
    } finally {
      closeScanRoute();
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (positions.isEmpty) {
      throw Exception('Не удалось получить координаты. Проверьте сигнал GPS и попробуйте на открытом месте.');
    }

    final byLat = [...positions]..sort((a, b) => a.latitude.compareTo(b.latitude));
    final medianLat = byLat[byLat.length ~/ 2].latitude;

    final byLng = [...positions]..sort((a, b) => a.longitude.compareTo(b.longitude));
    final medianLng = byLng[byLng.length ~/ 2].longitude;

    final avgAccuracy = positions.map((p) => p.accuracy).reduce((a, b) => a + b) / positions.length;

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
