import 'package:get/get.dart';

import '../data/providers/news_api_provider.dart';
import '../data/repositories/news_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../modules/abonent_list/bindings/abonent_list_binding.dart';
import '../modules/abonent_list/views/abonent_list_view.dart';
import '../modules/about/views/about_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/help_support/views/help_support_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/navbar/main_nav_view.dart';
import '../modules/news/controllers/news_controller.dart';
import '../modules/news/views/news_view.dart';
import '../modules/news/widgets/news_detail_view.dart';
import '../modules/notifications/controllers/notifications_controller.dart';
import '../modules/notifications/views/notification_detail_view.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/report_viewer/views/report_viewer_view.dart';
import '../modules/reports/views/reports_view.dart';
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
      name: _Paths.REPORTS,
      page: () => const ReportsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.REPORT_VIEWER,
      page: () => const ReportViewerView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.NEWS,
      page: () => const NewsView(),
      binding: BindingsBuilder(() {
        Get.put(NewsApiProvider());
        Get.put(NewsRepository());
        Get.put(NewsController());
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.NEWS_DETAIL,
      page: () => const NewsDetailView(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.put(NotificationRepository());
        Get.put(NotificationsController());
      }),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.NOTIFICATION_DETAIL,
      page: () => const NotificationDetailView(),
      transition: Transition.rightToLeftWithFade,
    ),

    GetPage(name: Routes.HELP_SUPPORT, page: () => const HelpSupportView()),
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
  ];
}
