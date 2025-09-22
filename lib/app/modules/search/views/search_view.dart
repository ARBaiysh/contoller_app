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
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with search field
            _buildSearchHeader(context),

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
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button and title
          const SizedBox(width: Constants.paddingM),
          Text(
            'Поиск абонентов',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: Constants.paddingM),

          // Search field
          Obx(() => TextField(
            controller: controller.searchTextController,
            onChanged: controller.search,
            decoration: InputDecoration(
              hintText: 'Поиск по ФИО, Адресу, ЛС, № счётчика (минимум 3 символа)',
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
                vertical: Constants.paddingM,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Constants.paddingM,
        Constants.paddingS,
        Constants.paddingM,
        Constants.paddingS,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Debtor filter
          Obx(() => CheckboxListTile(
            title: const Text('Только должники'),
            subtitle: controller.filterByDebtor
                ? Text(
              'Найдено: ${controller.debtorResults}',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            )
                : null,
            value: controller.filterByDebtor,
            onChanged: (_) => controller.toggleDebtorFilter(),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.error,
            visualDensity: VisualDensity.compact,
          )),

          const SizedBox(height: Constants.paddingXS),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: 'Все',
                  value: 'all',
                  isSelected: controller.filterByStatus == 'all',
                ),
                const SizedBox(width: Constants.paddingS),
                _buildFilterChip(
                  context: context,
                  label: 'Можно снимать',
                  value: 'available',
                  isSelected: controller.filterByStatus == 'available',
                  color: AppColors.success,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(width: Constants.paddingS),
                _buildFilterChip(
                  context: context,
                  label: 'Показания сняты',
                  value: 'completed',
                  isSelected: controller.filterByStatus == 'completed',
                  color: Colors.grey,
                  icon: Icons.check_circle,
                ),
              ],
            )),
          ),

          const SizedBox(height: Constants.paddingXS),

          // НОВЫЙ ФИЛЬТР ПО ТАРИФУ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: [
                _buildTariffFilterChip(
                  context: context,
                  label: 'Все',
                  value: 'all',
                  isSelected: controller.filterByTariff == 'all',
                ),
                const SizedBox(width: Constants.paddingS),
                _buildTariffFilterChip(
                  context: context,
                  label: 'Быт',
                  value: 'household',
                  isSelected: controller.filterByTariff == 'household',
                  color: Colors.green,
                  icon: Icons.home_outlined,
                ),
                const SizedBox(width: Constants.paddingS),
                _buildTariffFilterChip(
                  context: context,
                  label: 'НеБыт',
                  value: 'non_household',
                  isSelected: controller.filterByTariff == 'non_household',
                  color: Colors.orange,
                  icon: Icons.business_outlined,
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildTariffFilterChip({
    required BuildContext context,
    required String label,
    required String value,
    required bool isSelected,
    Color? color,
    IconData? icon,
  }) {
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => controller.setTariffFilter(value),
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: chipColor.withValues(alpha: 0.3),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact, // Компактность
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required String value,
    required bool isSelected,
    Color? color,
    IconData? icon,
  }) {
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => controller.setStatusFilter(value),
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: chipColor.withValues(alpha: 0.3),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    if (controller.recentSearches.isEmpty) {
      return Center(
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
                Icons.search,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              'Начните поиск',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              'Введите ФИО, адрес или лицевой счет абонента',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
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
              SizedBox(
                width: 120,
                child: TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: const Text('Очистить'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),
          Wrap(
            spacing: Constants.paddingS,
            runSpacing: Constants.paddingS,
            children: controller.recentSearches.map((search) {
              return GestureDetector(
                onTap: () => controller.search(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.paddingM,
                    vertical: Constants.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: Constants.paddingS),
                      Text(search),
                      const SizedBox(width: Constants.paddingS),
                      GestureDetector(
                        onTap: () => controller.removeFromRecent(search),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (controller.searchQuery.isNotEmpty && controller.searchQuery.length < 3) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: Constants.paddingL),
              Text(
                'Введите минимум 3 символа',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        // Results count
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.paddingM,
            vertical: Constants.paddingS,
          ),
          child: Row(
            children: [
              Text(
                'Найдено: ${controller.totalResults}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (controller.filterByDebtor) ...[
                const Spacer(),
                Text(
                  'Должники: ${controller.debtorResults}',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
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
                  // TP header (if different from previous)
                  if (index == 0 ||
                      controller.searchResults[index - 1].transformerPointCode != subscriber.transformerPointCode)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.paddingM,
                        vertical: Constants.paddingS,
                      ),
                      margin: const EdgeInsets.only(top: Constants.paddingS),
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        subscriber.transformerPointName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
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
            Container(
              padding: const EdgeInsets.all(Constants.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              'Ничего не найдено',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              'Попробуйте изменить параметры поиска',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.paddingL),
            if (controller.filterByDebtor || controller.filterByStatus != 'all')
              ElevatedButton.icon(
                onPressed: () {
                  controller.setStatusFilter('all');
                  if (controller.filterByDebtor) {
                    controller.toggleDebtorFilter();
                  }
                },
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Сбросить фильтры'),
              ),
          ],
        ),
      ),
    );
  }
}