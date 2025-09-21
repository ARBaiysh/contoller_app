import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class ProgressOverviewCard extends StatelessWidget {
  final DashboardModel dashboard;

  const ProgressOverviewCard({
    Key? key,
    required this.dashboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: Constants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выполнение плана',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Снятие показаний счетчиков',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Процент выполнения
              Text(
                '${dashboard.completionPercentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _getPercentageColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: Constants.paddingL),

          // Прогресс бар
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Выполнено: ${dashboard.readingsCollected}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Всего: ${dashboard.totalReadingsNeeded}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingS),
              ClipRRect(
                borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
                child: LinearProgressIndicator(
                  value: dashboard.completionPercentage / 100,
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(_getPercentageColor()),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: Constants.paddingL),

          // Статистика за сегодня
          Container(
            padding: const EdgeInsets.all(Constants.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.today,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'Сегодня снято: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${dashboard.readingsToday} показаний',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor() {
    if (dashboard.completionPercentage >= 80) return AppColors.success;
    if (dashboard.completionPercentage >= 50) return AppColors.warning;
    return AppColors.error;
  }
}