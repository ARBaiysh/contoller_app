import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart';
import '../../../widgets/subscriber_list_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class SearchView extends GetView<GlobalSearchController> {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: controller.searchTextController,
          onChanged: controller.search,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Поиск по ФИО, адресу или лицевому счету',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.clearSearch,
            tooltip: 'Очистить',
          )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(context),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.showRecent) {
                return _buildRecentSearches(context);
              }

              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.searchQuery.isNotEmpty && controller.searchResults.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildSearchResults(context);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingM,
        vertical: Constants.paddingS,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Debtor filter
          Obx(() => CheckboxListTile(
            title: const Text('Только должники'),
            subtitle: controller.filterByDebtor && controller.debtorResults > 0
                ? Text('Найдено: ${controller.debtorResults}')
                : null,
            value: controller.filterByDebtor,
            onChanged: (_) => controller.toggleDebtorFilter(),
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          )),

          // Status filter
          Obx(() => Row(
            children: [
              const Text('Статус: '),
              const SizedBox(width: Constants.paddingS),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip(
                        context: context,
                        label: 'Все',
                        value: 'all',
                      ),
                      const SizedBox(width: Constants.paddingS),
                      _buildStatusChip(
                        context: context,
                        label: 'Можно брать',
                        value: 'available',
                        color: AppColors.success,
                      ),
                      const SizedBox(width: Constants.paddingS),
                      _buildStatusChip(
                        context: context,
                        label: 'Обрабатывается',
                        value: 'processing',
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: Constants.paddingS),
                      _buildStatusChip(
                        context: context,
                        label: 'Обработан',
                        value: 'completed',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required BuildContext context,
    required String label,
    required String value,
    Color? color,
  }) {
    final isSelected = controller.filterByStatus == value;
    final chipColor = color ?? AppColors.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.setStatusFilter(value),
      selectedColor: chipColor.withOpacity(0.2),
      backgroundColor: chipColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: chipColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    if (controller.recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              'Начните поиск',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              'Введите ФИО, адрес или лицевой счет',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Constants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Недавние поиски',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: const Text('Очистить'),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),
          ...controller.recentSearches.map((query) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => controller.removeFromRecent(query),
            ),
            onTap: () => controller.search(query),
            contentPadding: EdgeInsets.zero,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Column(
      children: [
        // Results count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Constants.paddingM),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Text(
            'Найдено: ${controller.totalResults}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: Constants.paddingS,
              bottom: Constants.paddingL,
            ),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final subscriber = controller.searchResults[index];
              return Column(
                children: [
                  // TP name header
                  if (index == 0 ||
                      subscriber.tpId != controller.searchResults[index - 1].tpId)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.paddingM,
                        vertical: Constants.paddingS,
                      ),
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      child: Text(
                        controller.getTpName(subscriber.tpId),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Subscriber item
                  SubscriberListItem(
                    subscriber: subscriber,
                    onTap: () => controller.navigateToSubscriberDetail(subscriber),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
              Icons.search_off,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              'Ничего не найдено',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              'Попробуйте изменить параметры поиска',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.paddingL),
            if (controller.filterByDebtor || controller.filterByStatus != 'all')
              TextButton(
                onPressed: () {
                  controller.setStatusFilter('all');
                  if (controller.filterByDebtor) {
                    controller.toggleDebtorFilter();
                  }
                },
                child: const Text('Сбросить фильтры'),
              ),
          ],
        ),
      ),
    );
  }
}