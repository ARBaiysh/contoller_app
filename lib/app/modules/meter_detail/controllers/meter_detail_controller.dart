import 'package:get/get.dart';
import '../../../data/models/meter_detail_model.dart';
import '../../../data/providers/api_provider.dart';

class MeterDetailController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();

  final _isLoading = true.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  final Rxn<MeterDetailModel> _meterData = Rxn<MeterDetailModel>();

  late String accountNumber;
  late String meterNumber;

  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  MeterDetailModel? get meterData => _meterData.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    accountNumber = args['accountNumber'] ?? '';
    meterNumber = args['meterNumber'] ?? '';
    loadMeterData();
  }

  Future<void> loadMeterData() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final data = await _apiProvider.getMeterData(
        accountNumber: accountNumber,
        meterNumber: meterNumber,
      );
      _meterData.value = data;
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadMeterData();
  }
}
