import 'package:get/get.dart';
import '../controllers/abonent_list_controller.dart';

class AbonentListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AbonentListController>(
      () => AbonentListController(),
    );
  }
}
