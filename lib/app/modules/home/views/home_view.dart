import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../controllers/home_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/sync_status_card.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/key_metrics_grid.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/recent_activity_card.dart';
import '../../../widgets/app_drawer.dart';
import '../../../core/values/constants.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final dashboard = controller.dashboard;
        if (dashboard == null) {
          return _buildErrorState(context, refreshController);
        }

        return SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          header: const WaterDropMaterialHeader(
            backgroundColor: Constants.primary,
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
                // Заголовок с приветствием
                DashboardHeader(controller: controller),
                const SizedBox(height: Constants.paddingL),

                // Общий прогресс
                ProgressOverviewCard(dashboard: dashboard),
                const SizedBox(height: Constants.paddingL),

                // Ключевые метрики
                KeyMetricsGrid(dashboard: dashboard),
                const SizedBox(height: Constants.paddingL),

                // Быстрые действия
                QuickActionsCard(controller: controller),
                const SizedBox(height: Constants.paddingL),

                // Недавняя активность
                RecentActivityCard(dashboard: dashboard),

                // Статус синхронизации (новый блок)
                SyncStatusCard(controller: controller),
                const SizedBox(height: Constants.paddingL),

                // Отступ снизу для удобства
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
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Панель управления',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Obx(() {
            if (controller.dashboard != null) {
              return Text(
                'Обновлено ${controller.dashboard!.lastUpdateTime}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  Widget _buildErrorState(BuildContext context, RefreshController refreshController) {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      header: const WaterDropMaterialHeader(
        backgroundColor: Constants.primary,
      ),
      onRefresh: () async {
        await controller.loadDashboard();
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
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(height: Constants.paddingM),
              Text(
                'Не удалось загрузить данные',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.paddingS),
              Text(
                controller.lastError.isNotEmpty
                    ? controller.lastError
                    : 'Потяните вниз для обновления',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.paddingL),
              OutlinedButton.icon(
                onPressed: () => controller.loadDashboard(),
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