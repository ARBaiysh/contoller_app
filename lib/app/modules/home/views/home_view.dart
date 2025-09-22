import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../core/values/constants.dart';
import '../../../widgets/app_drawer.dart';
import '../controllers/home_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/sync_status_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController refreshController = RefreshController();
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final dashboard = controller.dashboard.value;
        if (dashboard == null) {
          return _buildErrorState(context, refreshController, controller);
        }

        return SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          header: WaterDropMaterialHeader(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onRefresh: () async {
            await controller.refreshDashboard();
            refreshController.refreshCompleted();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Новый минималистичный заголовок
                DashboardHeader(),

                // Финансовые показатели (свернутая карточка)
                FinancialSummaryCard(dashboard: dashboard),

                // Статус синхронизации
                const SyncStatusCard(),

                // Отступ снизу
                const SizedBox(height: Constants.paddingXL),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Панель управления'),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  Widget _buildErrorState(BuildContext context, RefreshController refreshController, HomeController controllerHome) {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      header: WaterDropMaterialHeader(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      onRefresh: () async {
        await controllerHome.loadDashboard();
        refreshController.refreshCompleted();
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
              const SizedBox(height: Constants.paddingM),
              Text(
                'Не удалось загрузить данные',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.paddingL),

              Text(
                controllerHome.lastError.value != ''
                    ? controllerHome.lastError.value
                    : 'Потяните вниз для обновления',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              ElevatedButton.icon(
                onPressed: () => controllerHome.loadDashboard(),
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
