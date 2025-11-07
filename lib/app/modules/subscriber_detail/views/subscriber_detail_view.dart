import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscriber_detail_controller.dart';
import '../widgets/consumption_card.dart';
import '../widgets/subscriber_info_card.dart';
import '../widgets/reading_form_card.dart';
import '../widgets/meter_info_card.dart';
import '../widgets/balance_info_card.dart';
import '../widgets/reading_history_card.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/values/constants.dart';
import '../../../core/theme/app_colors.dart';

class SubscriberDetailView extends GetView<SubscriberDetailController> {
  const SubscriberDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Данные абонента',
        actions: [
          // ✅ ДОБАВЛЕНО: Кнопка синхронизации в AppBar
          Obx(() {
            // Если идет синхронизация - показываем индикатор
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

            // Иначе показываем кнопку обновления
            return IconButton(
              icon: const Icon(Icons.sync),
              onPressed: controller.refreshSubscriberDetails,
              tooltip: 'Обновить данные',
            );
          }),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        left: true,
        right: true,
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.subscriber == null) {
            return _buildErrorState(context);
          }

          return RefreshIndicator(
            onRefresh: controller.isSyncing
                ? () async {} // Блокируем если идет синхронизация
                : controller.refreshSubscriberDetails,
            notificationPredicate: (notification) {
              return !controller.isSyncing && notification.depth == 0;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ ДОБАВЛЕНО: Баннер статуса синхронизации
                  _buildSyncStatusBanner(context),

                  // New reading form (moved up)
                  Obx(() => controller.canSubmitReading
                      ? ReadingFormCard(controller: controller)
                      : const SizedBox.shrink()),

                  // Reading history card - показываем только если есть показания за текущий месяц
                  Obx(() {
                    final subscriber = controller.subscriber;
                    if (subscriber == null) return const SizedBox.shrink();

                    // Проверяем, есть ли показания за текущий месяц
                    final hasCurrentMonthReading = subscriber.currentMonthConsumption > 0;

                    return hasCurrentMonthReading
                        ? const ReadingHistoryCard()
                        : const SizedBox.shrink();
                  }),

                  // Subscriber info card (moved down)
                  const SubscriberInfoCard(),

                  // Consumption card
                  const ConsumptionCard(),

                  // Balance info card
                  const BalanceInfoCard(),

                  // Meter info card
                  const MeterInfoCard(),

                  const SizedBox(height: Constants.paddingXL),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ✅ НОВЫЙ ВИДЖЕТ: Баннер статуса синхронизации
  Widget _buildSyncStatusBanner(BuildContext context) {
    return Obx(() {
      // Показываем только если идет синхронизация
      if (!controller.isSyncing) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.all(Constants.paddingM),
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.info.withOpacity(0.1),
              AppColors.info.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: AppColors.info.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Анимированная иконка
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
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
                    'Обновление данных абонента',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (controller.syncMessage.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      controller.syncMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              'Данные абонента не найдены',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Constants.paddingM),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}