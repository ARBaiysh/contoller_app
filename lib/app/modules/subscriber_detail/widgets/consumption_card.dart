import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../controllers/subscriber_detail_controller.dart';

class ConsumptionCard extends StatelessWidget {
  const ConsumptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberDetailController>();

    return Obx(() {
      final subscriber = controller.subscriber;
      if (subscriber == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(Constants.paddingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: Constants.paddingS),
                  Text(
                    'Показатели за месяц',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingM),

              // Две карточки с данными
              Row(
                children: [
                  // Потребление
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      icon: Icons.electric_bolt,
                      iconColor: Colors.amber,
                      iconBgColor: Colors.amber.withOpacity(0.15),
                      label: 'Потребление',
                      value: NumberFormat('#,###', 'ru').format(subscriber.currentMonthConsumption),
                      unit: 'кВт·ч',
                    ),
                  ),
                  const SizedBox(width: Constants.paddingS),
                  // Начисления
                  Expanded(
                    child: _buildMetricCard(
                      context: context,
                      icon: Icons.receipt_long,
                      iconColor: Colors.deepPurple,
                      iconBgColor: Colors.deepPurple.withOpacity(0.15),
                      label: 'Начислено',
                      value: NumberFormat('#,###.##', 'ru').format(subscriber.currentMonthCharge),
                      unit: 'сом',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required String unit,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius - 2),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(height: Constants.paddingS),
          // Метка
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          // Значение
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}