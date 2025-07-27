import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../core/values/constants.dart';

class SubscriberDetailController extends GetxController {
  final SubscriberRepository _subscriberRepository = Get.find<SubscriberRepository>();

  // Form key for reading input
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controller for new reading
  final TextEditingController readingController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  // Subscriber data from arguments
  late final String subscriberId;
  late final String tpName;

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
    // Get arguments
    final args = Get.arguments;
    if (args != null) {
      subscriberId = args['subscriberId'] ?? '';
      tpName = args['tpName'] ?? 'ТП';
    } else {
      subscriberId = '';
      tpName = 'ТП';
    }
    loadSubscriberDetails();
  }

  @override
  void onClose() {
    readingController.dispose();
    commentController.dispose();
    super.onClose();
  }

  // Load subscriber details
  Future<void> loadSubscriberDetails() async {
    _isLoading.value = true;
    try {
      final sub = await _subscriberRepository.getSubscriberById(subscriberId);
      _subscriber.value = sub;
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить данные абонента',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withOpacity(0.1),
        colorText: Constants.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh subscriber details
  Future<void> refreshSubscriberDetails() async {
    await loadSubscriberDetails();
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

    if (reading < Constants.minReadingValue || reading > Constants.maxReadingValue) {
      return 'Показание должно быть от ${Constants.minReadingValue} до ${Constants.maxReadingValue}';
    }

    if (subscriber?.lastReading != null && reading <= subscriber!.lastReading!) {
      return 'Новое показание должно быть больше предыдущего (${subscriber!.lastReading})';
    }

    return null;
  }

  // Submit reading
  Future<void> submitReading() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!canSubmitReading) {
      Get.snackbar(
        'Ошибка',
        'Невозможно внести показание для данного абонента',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withOpacity(0.1),
        colorText: Constants.error,
      );
      return;
    }

    _isSubmitting.value = true;

    try {
      final reading = int.parse(readingController.text);
      final comment = commentController.text.trim();

      final updatedSubscriber = await _subscriberRepository.submitReading(
        subscriberId: subscriberId,
        reading: reading,
        comment: comment.isNotEmpty ? comment : null,
      );

      _subscriber.value = updatedSubscriber;

      // Clear form
      readingController.clear();
      commentController.clear();

      // Show success message
      Get.snackbar(
        'Успех',
        Constants.readingSubmitted,
        backgroundColor: Constants.success.withOpacity(0.1),
        colorText: Constants.success,
        snackPosition: SnackPosition.TOP,
      );

      // Update previous screen
      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Constants.error.withOpacity(0.1),
        colorText: Constants.error,
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

  // Calculate approximate amount
  String calculateAmount(int newReading) {
    if (subscriber?.lastReading == null) return '0';
    final consumption = newReading - subscriber!.lastReading!;
    // Mock calculation: 1.5 som per kWh
    final amount = consumption * 1.5;
    return amount.toStringAsFixed(2);
  }
}