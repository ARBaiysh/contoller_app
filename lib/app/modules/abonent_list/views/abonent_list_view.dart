import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/subscriber_list_item.dart';
import '../controllers/abonent_list_controller.dart'
    show AbonentListController, DateFilter, AbonentListType;

class AbonentListView extends GetView<AbonentListController> {
  const AbonentListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: controller.title,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Статистика
            _buildStatistics(context),

            // Фильтр по дате
            _buildDateFilter(context),

            // Поиск
            _buildSearchField(context),

            // Список
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.abonents.isEmpty) {
                  return _buildEmptyState(context);
                }

                return SmartRefresher(
                  controller: refreshController,
                  enablePullDown: true,
                  header: WaterDropMaterialHeader(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onRefresh: () async {
                    await controller.loadAbonents();
                    refreshController.refreshCompleted();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: Constants.paddingS,
                      bottom: Constants.paddingL,
                    ),
                    itemCount: controller.abonents.length,
                    itemBuilder: (context, index) {
                      final subscriber = controller.abonents[index];
                      return SubscriberListItem(
                        subscriber: subscriber,
                        onTap: () => controller.navigateToSubscriberDetail(subscriber),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // СТАТИСТИКА
  // ========================================

  Widget _buildStatistics(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Constants.paddingM,
        Constants.paddingS,
        Constants.paddingM,
        Constants.paddingXS,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingS,
        vertical: Constants.paddingS,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Obx(() {
        final isConsumption = controller.listType == AbonentListType.consumption;

        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context: context,
                label: 'Всего',
                value: controller.totalCount.toString(),
                color: AppColors.primary,
              ),
            ),
            if (!isConsumption) ...[
              Container(
                width: 1,
                height: 30,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'Должники',
                  value: controller.debtorsCount.toString(),
                  color: AppColors.error,
                ),
              ),
            ],
            if (isConsumption) ...[
              Container(
                width: 1,
                height: 30,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'кВт·ч',
                  value: controller.totalConsumption.toStringAsFixed(0),
                  color: AppColors.info,
                ),
              ),
            ],
            Container(
              width: 1,
              height: 30,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: _buildStatItem(
                context: context,
                label: 'Сумма',
                value: controller.totalAmount.toStringAsFixed(0),
                color: AppColors.success,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  // ========================================
  // ФИЛЬТР ПО ДАТЕ
  // ========================================

  Widget _buildDateFilter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Constants.paddingM,
        Constants.paddingXS,
        Constants.paddingM,
        Constants.paddingXS,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  context: context,
                  label: 'Все',
                  isSelected: controller.dateFilter == DateFilter.all,
                  onTap: () => controller.setDateFilter(DateFilter.all),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildFilterButton(
                  context: context,
                  label: 'За сегодня',
                  isSelected: controller.dateFilter == DateFilter.today,
                  onTap: () => controller.setDateFilter(DateFilter.today),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
          ),
        ),
      ),
    );
  }

  // ========================================
  // ПОИСК
  // ========================================

  Widget _buildSearchField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
      padding: const EdgeInsets.only(bottom: Constants.paddingS),
      child: Obx(() => TextField(
            controller: controller.searchTextController,
            onChanged: controller.search,
            decoration: InputDecoration(
              hintText: 'Поиск по ФИО, адресу, ЛС',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Constants.borderRadius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Constants.paddingM,
                vertical: Constants.paddingS,
              ),
            ),
          )),
    );
  }

  // ========================================
  // ПУСТОЕ СОСТОЯНИЕ
  // ========================================

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Constants.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              controller.emptyMessage,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              'Потяните вниз для обновления',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
