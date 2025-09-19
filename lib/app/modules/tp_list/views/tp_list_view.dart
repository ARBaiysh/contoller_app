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
        title: 'Трансформаторные подстанции',
        actions: [
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

            // Статус синхронизации
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

            // Кнопка синхронизации внизу
            _buildSyncButton(context),
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
  // СТАТУС СИНХРОНИЗАЦИИ
  // ========================================

  Widget _buildSyncStatus(BuildContext context) {
    return Obx(() {
      if (!controller.isSyncing) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Constants.paddingM),
        margin: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: AppColors.info.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
              ),
            ),
            const SizedBox(width: Constants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.syncProgress,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: Constants.paddingXS),
                  Text(
                    'Время: ${controller.syncElapsedFormatted} / 05:00',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.info.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ========================================
  // СОСТОЯНИЯ
  // ========================================

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: Constants.paddingM),
          Text('Загрузка списка ТП...'),
        ],
      ),
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
              'Нажмите кнопку "Синхронизировать" внизу экрана для загрузки данных с сервера',
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
          bottom: Constants.paddingXL, // Отступ для кнопки синхронизации
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

  // ========================================
  // КНОПКА СИНХРОНИЗАЦИИ
  // ========================================

  Widget _buildSyncButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final isEnabled = !controller.isSyncing && !controller.isLoading;

        return ElevatedButton.icon(
          onPressed: isEnabled ? controller.syncTpList : null,
          icon: controller.isSyncing
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Icon(Icons.sync),
          label: Text(
            controller.isSyncing ? 'Синхронизация...' : 'Синхронизировать',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? AppColors.primary : Colors.grey,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
            disabledForegroundColor: Colors.grey.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(vertical: Constants.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
          ),
        );
      }),
    );
  }
}