import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/dashboard_model.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class DashboardHeader extends StatelessWidget {

  const DashboardHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    DashboardModel dashboard = controller.dashboard.value;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Время обновления
        Row(
          mainAxisAlignment: MainAxisAlignment.end  ,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.paddingS,
                vertical: Constants.paddingXS,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
              ),
              child: Text(
                'Обновлено: ${_formatDateTime(dashboard.generatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: Constants.paddingL),

        // Основная карточка сбора показаний
        Container(
          padding: const EdgeInsets.all(Constants.paddingL),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(Constants.borderRadius),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'СБОР ПОКАЗАНИЙ',
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.paddingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
                    ),
                    child: Text(
                      '${dashboard.completionPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Constants.paddingM),

              // Показания сегодня
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Сегодня',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dashboard.readingsToday.toString(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 40,
                    color: theme.dividerColor.withOpacity(0.2),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Собрано',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dashboard.readingsCollected} / ${dashboard.totalReadingsNeeded}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Constants.paddingM),

              // Прогресс бар
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dashboard.completionPercentage / 100,
                  minHeight: 8,
                  backgroundColor: theme.dividerColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),

              const SizedBox(height: Constants.paddingS),

              Text(
                'Осталось: ${dashboard.readingsRemaining}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: Constants.paddingM),

        // Компактная статистика
        Row(
          children: [
            Expanded(
              child: _buildCompactStat(
                context: context,
                icon: Icons.business,
                value: dashboard.totalTransformerPoints.toString(),
                label: 'ТП',
              ),
            ),
            const SizedBox(width: Constants.paddingS),
            Expanded(
              child: _buildCompactStat(
                context: context,
                icon: Icons.people,
                value: dashboard.totalAbonents.toString(),
                label: 'Абонентов',
              ),
            ),
            const SizedBox(width: Constants.paddingS),
            Expanded(
              child: _buildCompactStat(
                context: context,
                icon: Icons.warning_amber,
                value: dashboard.debtorsCount.toString(),
                label: 'Должников',
                isWarning: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStat({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    final color = isWarning ? AppColors.error : theme.textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color?.withOpacity(0.6),
          ),
          const SizedBox(height: Constants.paddingXS),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }
}