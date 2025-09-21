import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class RecentActivityCard extends StatelessWidget {
  final DashboardModel dashboard;

  const RecentActivityCard({
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
            'Сводка за сегодня',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Карточка активности
        Container(
          padding: const EdgeInsets.all(Constants.paddingL),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Constants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Показания сегодня
              _buildActivityItem(
                context: context,
                icon: Icons.electrical_services,
                iconColor: AppColors.info,
                title: 'Показания снято',
                value: dashboard.readingsToday.toString(),
                subtitle: 'счетчиков',
              ),

              const Divider(height: Constants.paddingL * 2),

              // Оплаты сегодня
              _buildActivityItem(
                context: context,
                icon: Icons.payment,
                iconColor: AppColors.success,
                title: 'Оплат поступило',
                value: dashboard.paidToday.toString(),
                subtitle: dashboard.formattedPaymentsToday,
              ),

              const Divider(height: Constants.paddingL * 2),

              // Прогресс относительно плана
              _buildProgressItem(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Row(
      children: [
        // Иконка
        Container(
          padding: const EdgeInsets.all(Constants.paddingM),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Constants.borderRadius),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),

        const SizedBox(width: Constants.paddingM),

        // Описание
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: Constants.paddingXS),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        // Значение
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: iconColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(BuildContext context) {
    final progress = dashboard.completionPercentage;
    final progressColor = progress >= 80
        ? AppColors.success
        : progress >= 50
        ? AppColors.warning
        : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Иконка прогресса
            Container(
              padding: const EdgeInsets.all(Constants.paddingM),
              decoration: BoxDecoration(
                color: progressColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Constants.borderRadius),
              ),
              child: Icon(
                Icons.trending_up,
                color: progressColor,
                size: 24,
              ),
            ),

            const SizedBox(width: Constants.paddingM),

            // Описание прогресса
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выполнение плана',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: Constants.paddingXS),
                  Text(
                    '${dashboard.readingsCollected} из ${dashboard.totalReadingsNeeded}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Процент
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: progressColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: Constants.paddingM),

        // Прогресс бар
        ClipRRect(
          borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}