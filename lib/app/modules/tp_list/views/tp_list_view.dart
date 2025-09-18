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
          // Индикатор синхронизации
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
              : const SizedBox.shrink()),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
            tooltip: 'Сортировка',
          ),
        ],
      ),
      body: SafeArea(
        top: false, // AppBar уже учитывает верхнюю область
        bottom: true, // Защищаем от виртуальных кнопок внизу
        left: true, // Защищаем от вырезов по бокам
        right: true,
        child: Column(
          children: [
            // Search field
            _buildSearchField(context),

            // Summary info (упрощенная версия)
            _buildSummaryInfo(context),

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
          hintText: 'Поиск по номеру, названию или фидеру',
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

  Widget _buildSummaryInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      child: Obx(() => Row(
        children: [
          Icon(
            Icons.electrical_services,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: Constants.paddingS),
          Text(
            'Всего ТП: ${controller.totalTps}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (controller.searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: () => controller.searchTps(''),
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Очистить'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
        ],
      )),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.electrical_services_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              isSearching ? 'Ничего не найдено' : 'Список ТП пуст',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              isSearching
                  ? 'Попробуйте изменить параметры поиска'
                  : 'Потяните вниз для обновления',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Сортировка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: controller.sortOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option.label),
                value: option.value,
                groupValue: controller.sortBy,
                onChanged: (value) {
                  if (value != null) {
                    controller.setSorting(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
}