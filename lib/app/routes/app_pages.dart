import 'package:get/get.dart';

import '../modules/abonent_list/bindings/abonent_list_binding.dart';
import '../modules/abonent_list/views/abonent_list_view.dart';
import '../modules/askue_history/controllers/askue_history_controller.dart';
import '../modules/askue_history/views/askue_history_view.dart';
import '../modules/meter_detail/controllers/meter_detail_controller.dart';
import '../modules/meter_detail/views/meter_detail_view.dart';
import '../modules/about/views/about_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/navbar/main_nav_view.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/subscriber_detail/views/subscriber_detail_view.dart';
import '../modules/subscribers/views/subscribers_view.dart';
import '../modules/tp_list/views/tp_list_view.dart';
import '../modules/update_required/update_required_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.NAVBAR,
      page: () => const MainNavView(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.TP_LIST,
      page: () => const TpListView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SUBSCRIBERS,
      page: () => const SubscribersView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SUBSCRIBER_DETAIL,
      page: () => const SubscriberDetailView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),

    GetPage(name: Routes.ABOUT, page: () => const AboutView()),

    GetPage(
      name: _Paths.UPDATE_REQUIRED,
      page: () => const UpdateRequiredView(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: Routes.ABONENT_LIST,
      page: () => const AbonentListView(),
      binding: AbonentListBinding(),
      transition: Transition.cupertino,
    ),

    GetPage(
      name: Routes.METER_DETAIL,
      page: () => const MeterDetailView(),
      binding: BindingsBuilder(() {
        Get.put(MeterDetailController());
      }),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: Routes.ASKUE_HISTORY,
      page: () => const AskueHistoryView(),
      binding: BindingsBuilder(() {
        Get.put(AskueHistoryController());
      }),
      transition: Transition.rightToLeft,
    ),
  ];
}
