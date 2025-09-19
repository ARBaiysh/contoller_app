// lib/app/modules/tp_list/widgets/tp_item_card.dart

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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with TP info and status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TP Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TP Number and Name
                          Text(
                            '${tp.number} ${tp.name}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Fider
                          Text(
                            tp.fider,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    _buildStatusBadge(context),
                  ],
                ),
                const SizedBox(height: Constants.paddingM),

                // Statistics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      context: context,
                      label: 'Абоненты',
                      value: '${tp.totalSubscribers}',
                    ),
                    _buildStatItem(
                      context: context,
                      label: 'Собрано',
                      value: '${tp.readingsCollected}',
                      color: AppColors.success,
                    ),
                    _buildStatItem(
                      context: context,
                      label: 'Доступно',
                      value: '${tp.readingsAvailable}',
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: Constants.paddingM),

                // Progress Bar
                _buildProgressBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    // Если нет абонентов
    if (tp.totalSubscribers == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Constants.paddingS,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Нет абонентов',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final isCompleted = tp.isCompleted;
    final color = isCompleted ? AppColors.success : AppColors.warning;
    final text = isCompleted ? 'Завершено' : 'В работе';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color ?? Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final progress = tp.progressPercentage / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Прогресс',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${tp.progressPercentage.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          valueColor: AlwaysStoppedAnimation<Color>(
            tp.isCompleted ? AppColors.success : AppColors.primary,
          ),
          minHeight: 6,
        ),
      ],
    );
  }
}