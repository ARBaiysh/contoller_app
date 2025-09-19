import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../controllers/tp_list_controller.dart';
import '../widgets/tp_item_card.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class TpListView extends GetView<TpListController> {
  const TpListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Список ТП',
        actions: [
          // НОВОЕ: Кнопка синхронизации (аналогично абонентам)
          Obx(() => controller.isSyncing
              ? Container(
            margin: const EdgeInsets.only(right: 12),
            width: 20,
            height: 20,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.sync),
            onPressed: controller.syncTpList,
            tooltip: 'Синхронизировать',
          )),
          // Кнопка сортировки
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: controller.showSortDialog,
            tooltip: 'Сортировка',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        left: true,
        right: true,
        child: Column(
          children: [
            // Поиск
            _buildSearchField(context),

            // НОВОЕ: Статус синхронизации (аналогично абонентам)
            _buildSyncStatus(context),

            // Список ТП
            Expanded(
              child: Obx(() {
                if (controller.isLoading && controller.tpList.isEmpty) {
                  return _buildLoadingState(context);
                }

                if (controller.isEmpty && !controller.isLoading) {
                  return _buildEmptyState(context);
                }

                return _buildTpList(context, refreshController);
              }),
            ),
            // УБРАЛИ: Кнопку синхронизации внизу
          ],
        ),
      ),
    );
  }

  // ========================================
  // ПОИСК
  // ========================================

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        onChanged: controller.searchTps,
        decoration: InputDecoration(
          hintText: 'Поиск по номеру, названию или фидеру',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => controller.searchTps(''),
          )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constants.borderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Constants.paddingM,
            vertical: Constants.paddingM,
          ),
        ),
      ),
    );
  }

  // ========================================
  // НОВОЕ: СТАТУС СИНХРОНИЗАЦИИ
  // ========================================

  Widget _buildSyncStatus(BuildContext context) {
    return Obx(() {
      if (!controller.isSyncing) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Constants.paddingM,
          vertical: Constants.paddingS,
        ),
        color: Get.theme.colorScheme.primary.withOpacity(0.1),
        child: Row(
          children: [
            // Анимированная иконка синхронизации
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Get.theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: Constants.paddingS),

            // Текст прогресса
            Expanded(
              child: Text(
                controller.syncProgress.isNotEmpty
                    ? controller.syncProgress
                    : 'Синхронизация ТП...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Таймер
            Text(
              controller.syncElapsedFormatted,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Get.theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ========================================
  // СОСТОЯНИЯ ЗАГРУЗКИ
  // ========================================

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.electrical_services_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              'Список ТП пуст',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              'Нажмите иконку синхронизации в верхней части экрана для загрузки данных с сервера',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // СПИСОК ТП
  // ========================================

  Widget _buildTpList(BuildContext context, RefreshController refreshController) {
    return SmartRefresher(
      controller: refreshController,
      enablePullDown: true,
      enablePullUp: false,
      header: WaterDropHeader(
        complete: Text(
          'Обновлено',
          style: TextStyle(color: AppColors.primary),
        ),
        waterDropColor: AppColors.primary,
      ),
      onRefresh: () async {
        await controller.refreshTpList();
        refreshController.refreshCompleted();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: Constants.paddingM,
          right: Constants.paddingM,
          top: Constants.paddingS,
          bottom: Constants.paddingXL, // Убрали отступ для кнопки
        ),
        itemCount: controller.tpList.length,
        itemBuilder: (context, index) {
          final tp = controller.tpList[index];
          return TpItemCard(
            tp: tp,
            onTap: () => controller.navigateToSubscribers(tp),
          );
        },
      ),
    );
  }
}