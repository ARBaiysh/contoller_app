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
          // Кнопка синхронизации показывается только если список НЕ пуст
          Obx(() {
            // Если список пуст, не показываем иконку в AppBar
            if (controller.subscribers.isEmpty && !controller.isLoading) {
              return const SizedBox.shrink();
            }

            // Показываем иконку обновления
            return IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refreshSubscribers,
              tooltip: 'Обновить',
            );
          }),
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
        child: Obx(() {
          return Column(
            children: [
              // Search field - показываем только если есть данные
              if (controller.hasData) _buildSearchField(context),

              // Индикатор прогресса синхронизации убран (синхронизации больше нет в новом API)
              // if (controller.hasData) _buildSyncProgress(context),

              // Status filter chips - показываем только если есть данные
              if (controller.hasData) _buildStatusChips(context),

              // Subscribers list
              Expanded(
                child: _buildSubscribersList(context),
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
        onChanged: controller.searchSubscribers,
        decoration: InputDecoration(
          hintText: 'Поиск по ФИО, Адресу, ЛС, № счётчика',
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

  // ========================================
  // ПРОГРЕСС СИНХРОНИЗАЦИИ (УЛУЧШЕННЫЙ ДИЗАЙН)
  // ========================================

  // ========================================
  // ФИЛЬТР ЧИПЫ (СТИЛЬ КАК НА СКРИНШОТЕ)
  // ========================================

  Widget _buildStatusChips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
      child: Column(
        children: [
          // Существующие фильтры по статусу
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: controller.statusFilterOptions.map((option) {
                final isSelected = controller.selectedStatus == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: Constants.paddingS),
                  child: FilterChip(
                    label: Text('${option['label']} (${option['count']})'),
                    selected: isSelected,
                    onSelected: (_) => controller.setStatusFilter(option['value']),
                    selectedColor: (option['color'] as Color).withOpacity(0.2),
                    checkmarkColor: option['color'] as Color,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? option['color'] as Color
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? option['color'] as Color
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                );
              }).toList(),
            )),
          ),
        ],
      ),
    );
  }

  // ========================================
  // СПИСОК АБОНЕНТОВ
  // ========================================

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

  // ========================================
  // ПУСТОЕ СОСТОЯНИЕ С КНОПКОЙ СИНХРОНИЗАЦИИ
  // ========================================

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
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              isSearching
                  ? 'Ничего не найдено'
                  : 'Список абонентов пуст',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              isSearching
                  ? 'Попробуйте изменить параметры поиска'
                  : 'Нажмите кнопку ниже для загрузки абонентов',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.paddingL),

            // Показываем кнопку обновления только если не идет поиск и нет фильтров
            if (!isSearching && !isFiltered)
              ElevatedButton.icon(
                onPressed: controller.refreshSubscribers,
                icon: const Icon(Icons.refresh),
                label: const Text('Обновить данные'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.paddingL,
                    vertical: Constants.paddingM,
                  ),
                ),
              ),

            // Если есть фильтры, показываем кнопку сброса
            if (isFiltered || isSearching)
              const SizedBox(height: Constants.paddingM),
            if (isFiltered)
              TextButton(
                onPressed: () => controller.setStatusFilter('all'),
                child: const Text('Показать всех абонентов'),
              ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // ДИАЛОГ СОРТИРОВКИ
  // ========================================

  void _showSortDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.borderRadius),
        ),
        child: Container(
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
              const SizedBox(height: Constants.paddingM),
              // Определяем sortOptions локально
              ...[
                {'value': 'default', 'label': 'По умолчанию'},
                {'value': 'name', 'label': 'По имени'},
                {'value': 'address', 'label': 'По адресу'},
                {'value': 'account', 'label': 'По лицевому счету'},
                {'value': 'debt', 'label': 'По задолженности'},
              ].map((option) {
                return RadioListTile<String>(
                  title: Text(option['label']!),
                  value: option['value']!,
                  groupValue: controller.sortBy,
                  onChanged: (value) {
                    controller.setSorting(value!);
                    Get.back();
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
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