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

            // Если идет синхронизация
            if (controller.isSyncing) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            // Показываем иконку синхронизации
            return IconButton(
              icon: const Icon(Icons.sync),
              onPressed: controller.syncSubscribers,
              tooltip: 'Синхронизировать',
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
          // Если идет синхронизация при пустом списке, показываем специальный экран
          if (controller.isSyncing && controller.subscribers.isEmpty) {
            return _buildSyncingState(context);
          }

          return Column(
            children: [
              // Search field - показываем только если есть данные
              if (controller.hasData) _buildSearchField(context),

              // Индикатор прогресса синхронизации - показываем только если есть данные
              if (controller.hasData) _buildSyncProgress(context),

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

  Widget _buildSyncProgress(BuildContext context) {
    return Obx(() {
      if (!controller.isSyncing) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Constants.paddingM,
          vertical: Constants.paddingS,
        ),
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Get.theme.colorScheme.primary.withOpacity(0.1),
              Get.theme.colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: Get.theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Анимированная иконка
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Get.theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: Constants.paddingM),

            // Текст прогресса
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Синхронизация абонентов',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.syncProgress.isNotEmpty
                        ? controller.syncProgress
                        : 'Обновление списка абонентов ${controller.tpName}...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Get.theme.colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Таймер с иконкой
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.paddingS,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Get.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.syncElapsedFormatted,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
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

          const SizedBox(height: Constants.paddingXS),

          // НОВЫЙ РЯД ФИЛЬТРОВ ПО ТАРИФУ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: [
                const SizedBox(width: Constants.paddingS),
                _buildTariffChip(
                  context: context,
                  label: 'Все',
                  value: 'all',
                  count: controller.totalSubscribers,
                  isSelected: controller.filterByTariff == 'all',
                ),
                const SizedBox(width: Constants.paddingS),
                _buildTariffChip(
                  context: context,
                  label: 'Быт',
                  value: 'household',
                  count: controller.householdCount,
                  isSelected: controller.filterByTariff == 'household',
                  color: Colors.green,
                  icon: Icons.home_outlined,
                ),
                const SizedBox(width: Constants.paddingS),
                _buildTariffChip(
                  context: context,
                  label: 'НеБыт',
                  value: 'non_household',
                  count: controller.nonHouseholdCount,
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

  Widget _buildTariffChip({
    required BuildContext context,
    required String label,
    required String value,
    required int count,
    required bool isSelected,
    Color? color,
    IconData? icon,
  }) {
    final chipColor = color ?? Theme.of(context).primaryColor;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? chipColor : chipColor.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
          ],
          Text('$label ($count)'),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => controller.setTariffFilter(value),
      selectedColor: chipColor.withOpacity(0.2),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? chipColor : Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? chipColor : Theme.of(context).dividerColor,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      visualDensity: VisualDensity.compact,
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

            // Показываем кнопку синхронизации только если не идет поиск и нет фильтров
            if (!isSearching && !isFiltered)
              Obx(() => ElevatedButton.icon(
                onPressed: controller.isSyncing ? null : controller.syncSubscribers,
                icon: controller.isSyncing
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
                    : const Icon(Icons.sync),
                label: Text(
                  controller.isSyncing ? 'Синхронизация...' : 'Синхронизировать',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Constants.paddingL,
                    vertical: Constants.paddingM,
                  ),
                ),
              )),

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
  // СОСТОЯНИЕ СИНХРОНИЗАЦИИ ПРИ ПУСТОМ СПИСКЕ
  // ========================================

  Widget _buildSyncingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Большая анимированная иконка
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.people,
                      size: 48,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.paddingXL),

            // Заголовок
            Text(
              'Синхронизация абонентов',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Constants.paddingS),

            // Прогресс текст
            Text(
              controller.syncProgress.isNotEmpty
                  ? controller.syncProgress
                  : 'Загрузка списка абонентов для ${controller.tpName}...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.paddingL),

            // Таймер
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.paddingL,
                vertical: Constants.paddingM,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Constants.borderRadius),
                border: Border.all(
                  color: Get.theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: Get.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: Constants.paddingS),
                  Text(
                    controller.syncElapsedFormatted,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Constants.paddingXL),

            // Подсказка
            Text(
              'Пожалуйста, подождите...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
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