import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscribers_controller.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/subscriber_list_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class SubscribersView extends GetView<SubscribersController> {
  const SubscribersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: controller.tpName,
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

            // Status filter chips
            _buildStatusChips(context),

            // Subscribers list
            Expanded(
              child: Obx(() => _buildSubscribersList(context)),
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
        onChanged: controller.searchSubscribers,
        decoration: InputDecoration(
          hintText: 'Поиск по ФИО, адресу или лицевому счету',
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

  Widget _buildStatusChips(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: Constants.paddingS),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
        itemCount: controller.statusFilterOptions.length,
        itemBuilder: (context, index) {
          final option = controller.statusFilterOptions[index];
          final isSelected = controller.selectedStatus == option.value;

          return Padding(
            padding: const EdgeInsets.only(right: Constants.paddingS),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option.icon,
                    size: 16,
                    color: isSelected ? Colors.white : option.color,
                  ),
                  const SizedBox(width: 4),
                  Text('${option.label} (${option.count})'),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => controller.setStatusFilter(option.value),
              backgroundColor: option.color.withValues(alpha: 0.1),
              selectedColor: option.color,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : option.color,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: option.color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          );
        },
      )),
    );
  }

  Widget _buildSubscribersList(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.subscribers.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshSubscribers,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: Constants.paddingS,
          bottom: Constants.paddingL,
        ),
        itemCount: controller.subscribers.length,
        itemBuilder: (context, index) {
          final subscriber = controller.subscribers[index];
          return SubscriberListItem(
            subscriber: subscriber,
            onTap: () => controller.navigateToSubscriberDetail(subscriber),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = controller.searchQuery.isNotEmpty;
    final isFiltered = controller.selectedStatus != 'all';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              isSearching
                  ? 'Абоненты не найдены'
                  : 'Список пуст',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              isSearching
                  ? 'Попробуйте изменить параметры поиска'
                  : isFiltered
                  ? 'Нет абонентов с выбранным статусом'
                  : 'В данном ТП нет абонентов',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (isSearching || isFiltered) ...[
              const SizedBox(height: Constants.paddingL),
              TextButton(
                onPressed: () {
                  controller.searchSubscribers('');
                  controller.setStatusFilter('all');
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