import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // Проверяем вложенную навигацию
      final current = navKeys[controller.currentIndex.value].currentState!;
      if (current.canPop()) {
        current.pop();
        return false;
      }

      // Используем метод контроллера
      final shouldExit = controller.handleBack();

      if (shouldExit) {
        // Показываем диалог выхода
        final exitConfirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Выход из приложения'),
            content: const Text('Вы действительно хотите выйти?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Выйти'),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        if (exitConfirmed == true) {
          SystemNavigator.pop();
          return true;
        }
        return false;
      }

      return false;
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
      buildTabNavigator(navKeys[0], const HomeView()),
      buildTabNavigator(navKeys[1], const TpListView()),
      buildTabNavigator(navKeys[2], const SearchView()),
      buildTabNavigator(navKeys[3], const ReportsView()),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await onWillPop();
        // PopScope обработает выход автоматически, если shouldExit = true
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