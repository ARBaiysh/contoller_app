import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/dashboard_model.dart';

class CoordinatesStatsCard extends StatelessWidget {
  final DashboardModel dashboard;

  const CoordinatesStatsCard({
    Key? key,
    required this.dashboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: Constants.paddingM),
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
          // Заголовок
          Padding(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'ГЕОКООРДИНАТЫ',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),

          Padding(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Column(
              children: [
                // Всего отсканировано — на всю ширину
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.pin_drop_outlined,
                        label: 'Всего отсканировано',
                        value: '${dashboard.coordinatesTotal}',
                        iconColor: AppColors.success,
                        iconBgColor: AppColors.success.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingS),

                // За месяц и за сегодня — в ряд
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.calendar_month_outlined,
                        label: 'За месяц',
                        value: '${dashboard.coordinatesThisMonth}',
                        iconColor: Colors.deepPurple,
                        iconBgColor: Colors.deepPurple.withOpacity(0.15),
                      ),
                    ),
                    const SizedBox(width: Constants.paddingS),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.today_outlined,
                        label: 'За сегодня',
                        value: '${dashboard.coordinatesToday}',
                        iconColor: Colors.amber,
                        iconBgColor: Colors.amber.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius - 2),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: Constants.paddingS),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingS),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
