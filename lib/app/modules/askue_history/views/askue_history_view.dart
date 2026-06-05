import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../controllers/askue_history_controller.dart';

class AskueHistoryView extends GetView<AskueHistoryController> {
  const AskueHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Показания АСКУЭ'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value.isNotEmpty) {
            return _buildError(context);
          }
          if (controller.readings.isEmpty) {
            return _buildEmpty(context);
          }
          return _buildList(context);
        }),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(Constants.paddingM),
      itemCount: controller.readings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(context);
        final i = index - 1;
        final r = controller.readings[i];
        final consumption = controller.consumptionAt(i);
        return _buildRow(context, r.date, r.reading, consumption);
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.paddingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.fullName.isNotEmpty)
            Text(
              controller.fullName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          Text(
            'Ежедневные показания и расход из системы АСКУЭ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: Constants.paddingS),
        ],
      ),
    );
  }

  Widget _buildRow(
      BuildContext context, DateTime date, double reading, double? consumption) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: Constants.paddingS),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Row(
        children: [
          // Дата + показание
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 13,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd.MM.yyyy').format(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  NumberFormat('#,##0.##', 'ru').format(reading),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // Ежедневный расход
          _buildConsumptionBadge(context, consumption),
        ],
      ),
    );
  }

  Widget _buildConsumptionBadge(BuildContext context, double? consumption) {
    final theme = Theme.of(context);
    if (consumption == null) {
      return Text(
        '—',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
        ),
      );
    }
    // Расход обычно ≥ 0; отрицательное (сброс/замена счётчика) показываем серым
    final positive = consumption >= 0;
    final color = positive ? AppColors.info : Colors.grey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Расход',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: Constants.paddingS, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${positive ? '+' : ''}${NumberFormat('#,##0.##', 'ru').format(consumption)} кВт·ч',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.error),
            const SizedBox(height: Constants.paddingM),
            Text(
              controller.error.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: Constants.paddingM),
            ElevatedButton.icon(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined,
                size: 56,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.4)),
            const SizedBox(height: Constants.paddingM),
            Text(
              'Нет показаний АСКУЭ за период',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
