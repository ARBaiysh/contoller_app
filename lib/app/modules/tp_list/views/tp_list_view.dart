import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tp_list_controller.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/tp_list_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class TpListView extends GetView<TpListController> {
  const TpListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Список ТП',
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
            tooltip: 'Сортировка',
          ),
        ],
      ),
      body: SafeArea(
        top: false,    // AppBar уже учитывает верхнюю область
        bottom: true,  // Защищаем от виртуальных кнопок внизу
        left: true,    // Защищаем от вырезов по бокам
        right: true,
        child: Column(
          children: [
            // Search field
            _buildSearchField(context),
        
            // Summary cards
            _buildSummaryCards(context),
        
            // TP List
            Expanded(
              child: Obx(() => _buildTpList(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        onChanged: controller.searchTps,
        decoration: InputDecoration(
          hintText: 'Поиск по номеру, названию или адресу',
          prefixIcon: const Icon(Icons.search),
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

  Widget _buildSummaryCards(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildClickableSummaryCard(
              context: context,
              title: 'Всего ТП',
              value: '${controller.totalTps}',
              color: AppColors.info,
              icon: Icons.electrical_services,
              filterValue: 'all',
              isActive: controller.selectedFilter == 'all',
            ),
          ),
          const SizedBox(width: Constants.paddingS),
          Expanded(
            child: _buildClickableSummaryCard(
              context: context,
              title: 'В работе',
              value: '${controller.inProgressTps}',
              color: AppColors.warning,
              icon: Icons.pending,
              filterValue: 'in_progress',
              isActive: controller.selectedFilter == 'in_progress',
            ),
          ),
          const SizedBox(width: Constants.paddingS),
          Expanded(
            child: _buildClickableSummaryCard(
              context: context,
              title: 'Завершено',
              value: '${controller.completedTps}',
              color: AppColors.success,
              icon: Icons.check_circle,
              filterValue: 'completed',
              isActive: controller.selectedFilter == 'completed',
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildClickableSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required String filterValue,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => controller.setFilter(filterValue),
      borderRadius: BorderRadius.circular(Constants.borderRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8), // Уменьшено с 12 до 8
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.2)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: isActive
                ? color
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.transparent,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? color.withOpacity(0.3)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 18, // Уменьшено с 20 до 18
            ),
            const SizedBox(height: 2), // Уменьшено с 4 до 2
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : null,
                    fontSize: 16, // Явно указан размер
                  ),
                ),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive
                        ? color
                        : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 10, // Уменьшено с 11 до 10
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTpList(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.tpList.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshTpList,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: Constants.paddingS,
          bottom: Constants.paddingL,
        ),
        itemCount: controller.tpList.length,
        itemBuilder: (context, index) {
          final tp = controller.tpList[index];
          return TpListItem(
            tp: tp,
            onTap: () => controller.navigateToSubscribers(tp),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = controller.searchQuery.isNotEmpty;
    final isFiltered = controller.selectedFilter != 'all';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.electrical_services_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              isSearching
                  ? 'Ничего не найдено'
                  : 'Список ТП пуст',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              isSearching
                  ? 'Попробуйте изменить параметры поиска'
                  : isFiltered
                  ? 'Нет ТП с выбранным фильтром'
                  : 'Нет доступных трансформаторных пунктов',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearching || isFiltered) ...[
              const SizedBox(height: Constants.paddingL),
              TextButton(
                onPressed: () {
                  controller.searchTps('');
                  controller.setFilter('all');
                },
                child: const Text('Сбросить фильтры'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сортировка',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Constants.paddingL),
              Obx(() => Column(
                children: controller.sortOptions.map((option) {
                  return RadioListTile<String>(
                    title: Text(option.label),
                    value: option.value,
                    groupValue: controller.sortBy,
                    onChanged: (value) {
                      controller.setSorting(value!);
                      Get.back();
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              )),
              const SizedBox(height: Constants.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Закрыть'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}