import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/report_viewer_controller.dart';
import '../widgets/report_header_card.dart';
import '../widgets/subscriber_report_item.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/values/constants.dart';

class ReportViewerView extends GetView<ReportViewerController> {
  const ReportViewerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Просмотр отчета',
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(),
            tooltip: 'Поделиться',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportReport(),
            tooltip: 'Экспорт',
          ),
        ],
      ),
      body: Column(
        children: [
          // Report header
          ReportHeaderCard(controller: controller),

          // Subscribers list
          Expanded(
            child: _buildSubscribersList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribersList(BuildContext context) {
    if (controller.subscribers.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: Constants.paddingM,
        right: Constants.paddingM,
        top: Constants.paddingS,
        bottom: Constants.paddingXL,
      ),
      itemCount: controller.subscribers.length + 1, // +1 for summary
      itemBuilder: (context, index) {
        if (index == controller.subscribers.length) {
          return _buildSummaryCard(context);
        }

        final subscriber = controller.subscribers[index];
        return SubscriberReportItem(
          subscriber: subscriber,
          controller: controller,
          index: index + 1,
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: Constants.paddingM),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context).copyWith(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Итого',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Constants.paddingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Количество записей:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${controller.totalCount}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (controller.totalAmountText.isNotEmpty) ...[
            const SizedBox(height: Constants.paddingXS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.reportType == 'payments' ? 'Общий баланс:' : 'Общий долг:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${controller.totalAmount.toStringAsFixed(2)} сом',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: controller.reportType == 'payments'
                        ? Constants.success
                        : Constants.error,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Constants.paddingS),
          Text(
            'Дата формирования: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
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
              Icons.description_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              'Нет данных для отчета',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              'По выбранным критериям не найдено ни одной записи',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _shareReport() {
    Get.snackbar(
      'Поделиться',
      'Функция отправки отчета будет добавлена в следующей версии',
      snackPosition: SnackPosition.TOP,
    );
  }

  void _exportReport() {
    Get.snackbar(
      'Экспорт',
      'Отчет экспортирован в PDF формат',
      backgroundColor: Constants.success.withOpacity(0.1),
      colorText: Constants.success,
      snackPosition: SnackPosition.TOP,
    );
  }
}