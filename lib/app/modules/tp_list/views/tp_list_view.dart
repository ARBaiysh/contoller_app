import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../controllers/tp_list_controller.dart';
import '../widgets/tp_item_card.dart';

class TpListView extends GetView<TpListController> {
  const TpListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Список ТП',
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
        child: Obx(() {
          return Column(
            children: [
              // Поиск показываем только если есть данные
              if (controller.hasData) _buildSearchField(context),

              // Список ТП или пустое состояние
              Expanded(
                child: controller.isLoading && controller.tpList.isEmpty
                    ? _buildLoadingState(context)
                    : controller.isEmpty && !controller.isLoading
                        ? _buildEmptyState(context)
                        : _buildTpList(context, refreshController),
              ),
            ],
          );
        }),
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
  // СОСТОЯНИЯ ЗАГРУЗКИ
  // ========================================

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = controller.searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.electrical_services_outlined,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              isSearching ? 'Ничего не найдено' : 'Список ТП пуст',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              isSearching
                  ? 'Попробуйте изменить параметры поиска'
                  : 'Нажмите кнопку ниже для загрузки данных с сервера',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.paddingL),

            // Показываем кнопку обновления только если не идет поиск
            if (!isSearching)
              ElevatedButton.icon(
                    onPressed: controller.refreshTpList,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Обновить данные'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.paddingL,
                        vertical: Constants.paddingM,
                      ),
                    ),
                  ),

            // Если идет поиск, показываем кнопку сброса
            if (isSearching) const SizedBox(height: Constants.paddingM),
            if (isSearching)
              TextButton(
                onPressed: () => controller.searchTps(''),
                child: const Text('Сбросить поиск'),
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
          bottom: Constants.paddingXL,
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
