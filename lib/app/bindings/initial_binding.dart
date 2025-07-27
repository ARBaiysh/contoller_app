import 'package:get/get.dart';

import '../core/controllers/theme_controller.dart';
import '../data/providers/api_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/statistics_repository.dart';
import '../data/repositories/subscriber_repository.dart';
import '../data/repositories/tp_repository.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/tp_list/controllers/tp_list_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services - Permanent
    Get.put(ThemeController(), permanent: true);
    Get.put(ApiProvider(), permanent: true);

    // Repositories - Lazy loaded but kept in memory
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<SubscriberRepository>(() => SubscriberRepository(), fenix: true);
    Get.lazyPut<TpRepository>(() => TpRepository(), fenix: true);
    Get.lazyPut<StatisticsRepository>(() => StatisticsRepository(), fenix: true);

    // Controllers - Lazy loaded
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<TpListController>(() => TpListController(), fenix: true);
    // Get.lazyPut<SubscribersController>(() => SubscribersController());
    // Get.lazyPut<SubscriberDetailController>(() => SubscriberDetailController());
  }
}
