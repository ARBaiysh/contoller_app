import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/dashboard_model.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../routes/app_pages.dart';

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
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${dashboard.completionPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingS),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: dashboard.completionPercentage / 100,
                  backgroundColor: theme.dividerColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: Constants.paddingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Собрано: ${dashboard.readingsCollected}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    'Осталось: ${dashboard.readingsRemaining}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: Constants.paddingM),

        // Компактная статистика (КЛИКАБЕЛЬНАЯ)
        Row(
          children: [
            // ТП - открывает список ТП
            Expanded(
              child: _buildCompactStat(
                context: context,
                icon: Icons.business,
                value: dashboard.totalTransformerPoints.toString(),
                label: 'ТП',
                onTap: () {
                  Get.toNamed(Routes.TP_LIST);
                },
              ),
            ),
            const SizedBox(width: Constants.paddingS),
            // Абонентов - открывает поиск
            Expanded(
              child: _buildCompactStat(
                context: context,
                icon: Icons.people,
                value: dashboard.totalAbonents.toString(),
                label: 'Абонентов',
                onTap: () {
                  Get.toNamed(Routes.SEARCH);
                },
              ),
            ),
            const SizedBox(width: Constants.paddingS),
            // Должников - открывает поиск
            Expanded(
              child: _buildCompactStat(
                context: context,
                icon: Icons.warning_amber,
                value: dashboard.debtorsCount.toString(),
                label: 'Должников',
                isWarning: true,
                onTap: () {
                  Get.toNamed(Routes.SEARCH);
                },
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
    required VoidCallback onTap,
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    final color = isWarning ? AppColors.error : theme.textTheme.bodyMedium?.color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(Constants.borderRadius),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.1),
              width: 1,
            ),
            // ✅ ДОБАВЛЕНА ТЕНЬ для кликабельного вида
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Column(
              children: [
                // Иконка
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (color ?? theme.primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color?.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: Constants.paddingXS),
                // Значение
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                // Метка
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }
}