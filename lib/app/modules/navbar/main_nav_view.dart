import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/views/home_view.dart';
import '../reports/views/reports_view.dart';
import '../search/views/search_view.dart';
import '../tp_list/views/tp_list_view.dart';
import 'main_nav_controller.dart';

class MainNavView extends StatelessWidget {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainNavController());

    final navKeys = [
      GlobalKey<NavigatorState>(),
      GlobalKey<NavigatorState>(),
      GlobalKey<NavigatorState>(),
      GlobalKey<NavigatorState>(),
    ];

    Future<bool> onWillPop() async {
      final current = navKeys[controller.currentIndex.value].currentState!;
      if (current.canPop()) {
        current.pop();
        return false;
      }
      if (controller.currentIndex.value != 0) {
        controller.switchTo(0);
        return false;
      }
      return true;
    }

    Widget buildTabNavigator(GlobalKey<NavigatorState> key, Widget root) {
      return Navigator(
        key: key,
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => root,
          settings: const RouteSettings(name: 'root'),
        ),
      );
    }

    final tabs = [
      buildTabNavigator(navKeys[0], const HomeView()), // Главная
      buildTabNavigator(navKeys[1], const TpListView()),    // ТП
      buildTabNavigator(navKeys[2], const SearchView()),    // Поиск
      buildTabNavigator(navKeys[3], const ReportsView()),   // Отчёты
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onWillPop();
      },
      child: Obx(() {
        return Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: tabs,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.switchTo,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'ТП'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Отчёты'),
            ],
          ),
        );
      }),
    );
  }
}
