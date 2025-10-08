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

class SubscriberDetailView extends GetView<SubscriberDetailController> {
  const SubscriberDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Данные абонента',
      ),
      body: SafeArea(
        top: false,    // AppBar уже учитывает верхнюю область
        bottom: true,  // Защищаем от виртуальных кнопок внизу
        left: true,    // Защищаем от вырезов по бокам
        right: true,   // Защищаем от вырезов по бокам
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
                ? () async {} // Пустая функция, если идет синхронизация
                : controller.refreshSubscriberDetails,
            notificationPredicate: (notification) {
              // Блокируем pull-to-refresh если идет синхронизация
              return !controller.isSyncing && notification.depth == 0;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subscriber info card - оборачиваем в Obx
                  const SubscriberInfoCard(),

                  // New reading form - оборачиваем в Obx
                  Obx(() => controller.canSubmitReading
                      ? ReadingFormCard(controller: controller)
                      : const SizedBox.shrink()),

                  // Meter info card
                  const MeterInfoCard(),

                  // Balance info card
                  const BalanceInfoCard(),

                  const ConsumptionCard(),

                  // Reading history card
                  const ReadingHistoryCard(),

                  const SizedBox(height: Constants.paddingXL),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: Constants.paddingM),
          Text(
            'Не удалось загрузить данные',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Constants.paddingM),
          ElevatedButton(
            onPressed: controller.loadSubscriberDetails,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}