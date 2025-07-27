import 'package:get/get.dart';

import '../modules/auth/views/auth_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/tp_list/views/tp_list_view.dart';
import '../modules/subscribers/views/subscribers_view.dart';
import '../modules/subscriber_detail/views/subscriber_detail_view.dart';
import '../modules/search/views/search_view.dart';
import '../modules/reports/views/reports_view.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.AUTH;

  static final routes = [
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
      name: _Paths.REPORTS,
      page: () => const ReportsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),
  ];
}