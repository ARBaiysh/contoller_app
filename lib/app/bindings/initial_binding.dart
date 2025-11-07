import 'package:contoller_app/app/modules/navbar/main_nav_controller.dart';
import 'package:get/get.dart';

import '../core/controllers/theme_controller.dart';
import '../core/services/app_update_service.dart';
import '../core/services/biometric_service.dart';
import '../data/providers/api_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/statistics_repository.dart';
import '../data/repositories/subscriber_repository.dart';
import '../data/repositories/tp_repository.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/help_support/controllers/help_support_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../modules/report_viewer/controllers/report_viewer_controller.dart';
import '../modules/reports/controllers/reports_controller.dart';
import '../modules/search/controllers/search_controller.dart';
import '../modules/settings/controllers/settings_controller.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/subscriber_detail/controllers/subscriber_detail_controller.dart';
import '../modules/subscribers/controllers/subscribers_controller.dart';
import '../modules/tp_list/controllers/tp_list_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services - Permanent
    Get.put(ThemeController(), permanent: true);
    Get.put(ApiProvider(), permanent: true);
    Get.put(AppUpdateService(), permanent: true);
    Get.put(BiometricService(), permanent: true);

    // Repositories - Lazy loaded but kept in memory
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<SubscriberRepository>(() => SubscriberRepository(), fenix: true);
    Get.lazyPut<TpRepository>(() => TpRepository(), fenix: true);
    Get.lazyPut<StatisticsRepository>(() => StatisticsRepository(), fenix: true);


    // Controllers - Lazy loaded with fenix for auto-recreation
    Get.lazyPut<SplashController>(() => SplashController(), fenix: true);
    Get.lazyPut<MainNavController>(() => MainNavController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<TpListController>(() => TpListController(), fenix: true);
    Get.lazyPut<SubscribersController>(() => SubscribersController(), fenix: true);
    Get.lazyPut<SubscriberDetailController>(() => SubscriberDetailController(), fenix: true);
    Get.lazyPut<GlobalSearchController>(() => GlobalSearchController(), fenix: true);
    Get.lazyPut<ReportsController>(() => ReportsController(), fenix: true);
    Get.lazyPut<ReportViewerController>(() => ReportViewerController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<HelpSupportController>(() => HelpSupportController(), fenix: true);
  }
}
