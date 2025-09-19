import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../controllers/tp_list_controller.dart';
import '../widgets/tp_item_card.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class TpListView extends GetView<TpListController> {
  const TpListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final refreshController = RefreshController(initialRefresh: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Список ТП',
        actions: [
          // Кнопка синхронизации показывается только если список НЕ пуст
          Obx(() {
            // Если список пуст, не показываем иконку в AppBar
            if (controller.isEmpty && !controller.isLoading) {
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
              onPressed: controller.syncTpList,
              tooltip: 'Синхронизировать',
            );
          }),
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
          // Если идет синхронизация при пустом списке, показываем специальный экран
          if (controller.isSyncing && controller.isEmpty) {
            return _buildSyncingState(context);
          }

          return Column(
            children: [
              // Поиск показываем только если есть данные
              if (controller.hasData) _buildSearchField(context),

              // Кнопки фильтрации - показываем только если есть данные
              if (controller.hasData) _buildFilterButtons(context),

              // Статус синхронизации (улучшенный дизайн)
              _buildSyncStatus(context),

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
  // КНОПКИ ФИЛЬТРАЦИИ
  // ========================================

  Widget _buildFilterButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      child: Row(
        children: [
          // Кнопка "Все ТП"
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Фильтр все ТП
                },
                borderRadius: BorderRadius.circular(Constants.borderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Constants.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Всего ТП',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Constants.paddingS),

          // Кнопка "В работе"
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Фильтр в работе
                },
                borderRadius: BorderRadius.circular(Constants.borderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Constants.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '4',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'В работе',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Constants.paddingS),

          // Кнопка "Завершено"
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Фильтр завершено
                },
                borderRadius: BorderRadius.circular(Constants.borderRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: Constants.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '1',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Завершено',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // СТАТУС СИНХРОНИЗАЦИИ (УЛУЧШЕННЫЙ ДИЗАЙН)
  // ========================================

  Widget _buildSyncStatus(BuildContext context) {
    return Obx(() {
      if (!controller.isSyncing || controller.isEmpty) return const SizedBox.shrink();

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
                    'Синхронизация данных',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Get.theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.syncProgress.isNotEmpty
                        ? controller.syncProgress
                        : 'Обновление списка трансформаторных пунктов...',
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
                      Icons.electrical_services,
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
              'Синхронизация данных',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Constants.paddingS),

            // Прогресс текст
            Obx(() => Text(
              controller.syncProgress.isNotEmpty
                  ? controller.syncProgress
                  : 'Загрузка списка трансформаторных пунктов...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            )),
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
                  Obx(() => Text(
                    controller.syncElapsedFormatted,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Get.theme.colorScheme.primary,
                    ),
                  )),
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
              isSearching
                  ? 'Ничего не найдено'
                  : 'Список ТП пуст',
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

            // Показываем кнопку синхронизации только если не идет поиск
            if (!isSearching)
              Obx(() => ElevatedButton.icon(
                onPressed: controller.isSyncing ? null : controller.syncTpList,
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

            // Если идет поиск, показываем кнопку сброса
            if (isSearching)
              const SizedBox(height: Constants.paddingM),
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