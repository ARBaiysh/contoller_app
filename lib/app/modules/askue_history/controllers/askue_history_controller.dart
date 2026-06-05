import 'package:get/get.dart';

import '../../../data/models/askue_model.dart';
import '../../../data/repositories/subscriber_repository.dart';

class AskueHistoryController extends GetxController {
  final SubscriberRepository _repository = Get.find<SubscriberRepository>();

  late final String accountNumber;
  late final String fullName;

  final isLoading = true.obs;
  final error = ''.obs;
  final readings = <AskueReading>[].obs; // новые сверху (как отдаёт minimdm)

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    accountNumber = args['accountNumber'] ?? '';
    fullName = args['fullName'] ?? '';
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';
    try {
      final list = await _repository.getAskueReadings(accountNumber);
      readings.value = list;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Ежедневный расход для записи i (список новые-сверху):
  /// показание[i] − показание[i+1] (предыдущий день). null для самой старой.
  double? consumptionAt(int i) {
    if (i + 1 >= readings.length) return null;
    final diff = readings[i].reading - readings[i + 1].reading;
    return diff;
  }
}
