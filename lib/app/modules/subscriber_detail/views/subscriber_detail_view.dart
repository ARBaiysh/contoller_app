import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscriber_detail_controller.dart';
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
            onRefresh: controller.refreshSubscriberDetails,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subscriber info card
                  SubscriberInfoCard(
                    subscriber: controller.subscriber!,
                    tpName: controller.tpName,
                  ),

                  // New reading form - PRIORITY FOR CONTROLLER
                  if (controller.canSubmitReading)
                    ReadingFormCard(controller: controller),

                  // Meter info card
                  MeterInfoCard(meter: controller.subscriber!.meterInfo),

                  // Balance info card
                  BalanceInfoCard(subscriber: controller.subscriber!),

                  // Reading history card
                  ReadingHistoryCard(subscriber: controller.subscriber!),

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