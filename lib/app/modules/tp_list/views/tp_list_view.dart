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
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Фильтр',
          ),
        ],
      ),
      body: Column(
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
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context: context,
              title: 'Всего ТП',
              value: '${controller.totalTps}',
              color: AppColors.info,
              icon: Icons.electrical_services,
            ),
          ),
          const SizedBox(width: Constants.paddingS),
          Expanded(
            child: _buildSummaryCard(
              context: context,
              title: 'В работе',
              value: '${controller.inProgressTps}',
              color: AppColors.warning,
              icon: Icons.pending,
            ),
          ),
          const SizedBox(width: Constants.paddingS),
          Expanded(
            child: _buildSummaryCard(
              context: context,
              title: 'Завершено',
              value: '${controller.completedTps}',
              color: AppColors.success,
              icon: Icons.check_circle,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
            size: 20,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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

  void _showFilterDialog(BuildContext context) {
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
                'Фильтр',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Constants.paddingL),
              Obx(() => Column(
                children: controller.filterOptions.map((option) {
                  final isSelected = controller.selectedFilter == option.value;
                  return RadioListTile<String>(
                    title: Text(option.label),
                    subtitle: Text('${option.count} ТП'),
                    value: option.value,
                    groupValue: controller.selectedFilter,
                    onChanged: (value) {
                      controller.setFilter(value!);
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
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Закрыть'),
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