import 'package:flutter/material.dart';
import '../../../data/models/tp_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class TpItemCard extends StatelessWidget {
  final TpModel tp;
  final VoidCallback onTap;

  const TpItemCard({
    super.key,
    required this.tp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Временные данные пока нет из бэкенда
    final totalCount = 10;
    final collectedCount = 8;
    final remainingCount = 2;
    final progressPercent = (collectedCount / totalCount * 100).round();

    // Определяем цвет статуса
    final statusColor = progressPercent == 100 ? Colors.green : Colors.orange;
    final statusText = progressPercent == 100 ? 'Завершено' : 'В работе';

    return Container(
      margin: const EdgeInsets.only(bottom: Constants.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок с иконкой и кнопкой
                Row(
                  children: [
                    // Иконка ТП
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.electrical_services,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Constants.paddingM),

                    // Название ТП
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tp.number} ${tp.name}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            tp.fider,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Статус "В работе"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.paddingS,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingM),

                // Статистика
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      context: context,
                      label: 'Абоненты',
                      value: totalCount.toString(),
                      color: null,
                    ),
                    _buildStatItem(
                      context: context,
                      label: 'Собрано',
                      value: collectedCount.toString(),
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      context: context,
                      label: 'Осталось',
                      value: remainingCount.toString(),
                      color: Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingM),

                // Прогресс бар
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Прогресс сбора',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '${progressPercent.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Constants.paddingXS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent / 100,
                        minHeight: 8,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}