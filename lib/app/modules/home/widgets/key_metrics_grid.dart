import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class KeyMetricsGrid extends StatelessWidget {
  final DashboardModel dashboard;

  const KeyMetricsGrid({
    Key? key,
    required this.dashboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Padding(
          padding: const EdgeInsets.only(bottom: Constants.paddingM),
          child: Text(
            'Ключевые показатели',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Сетка метрик 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Constants.paddingM,
          crossAxisSpacing: Constants.paddingM,
          childAspectRatio: 0.9, // Уменьшили с 1.2 до 0.9
          children: [
            _buildMetricCard(
              context: context,
              title: 'Показания',
              mainValue: dashboard.readingsCollected.toString(),
              subtitle: 'из ${dashboard.totalReadingsNeeded}',
              icon: Icons.electrical_services,
              color: AppColors.info,
              trend: dashboard.readingsToday > 0 ? '+${dashboard.readingsToday} сегодня' : null,
            ),
            _buildMetricCard(
              context: context,
              title: 'Должники',
              mainValue: dashboard.debtorsCount.toString(),
              subtitle: dashboard.formattedDebtAmount,
              icon: Icons.warning_amber,
              color: AppColors.warning,
            ),
            _buildMetricCard(
              context: context,
              title: 'Оплаты',
              mainValue: dashboard.paidToday.toString(),
              subtitle: dashboard.formattedPaymentsToday,
              icon: Icons.payment,
              color: AppColors.success,
              trend: '${dashboard.paidThisMonth} за месяц',
            ),
            _buildMetricCard(
              context: context,
              title: 'Остаток',
              mainValue: dashboard.readingsRemaining.toString(),
              subtitle: 'показаний',
              icon: Icons.pending_actions,
              color: dashboard.readingsRemaining > 50 ? AppColors.error : AppColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String mainValue,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM), // Уменьшили отступы
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка и заголовок
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: Constants.paddingS),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: Constants.paddingS), // Уменьшили отступ

          // Основное значение
          Text(
            mainValue,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Изменили с headlineMedium на headlineSmall
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),

          const SizedBox(height: 2), // Минимальный отступ

          // Подзаголовок
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),

          // Тренд (если есть)
          if (trend != null) ...[
            const SizedBox(height: Constants.paddingS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.paddingS,
                vertical: Constants.paddingXS,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
              ),
              child: Text(
                trend,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}