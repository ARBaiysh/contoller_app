import 'package:flutter/material.dart';
import '../data/models/tp_model.dart';
import '../core/theme/app_colors.dart';
import '../core/values/constants.dart';

class TpListItem extends StatelessWidget {
  final TpModel tp;
  final VoidCallback onTap;

  const TpListItem({
    Key? key,
    required this.tp,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Constants.borderRadius),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Constants.paddingM,
          vertical: Constants.paddingS,
        ),
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TP Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.electrical_services,
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: Constants.paddingM),

                // TP Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Number and Name
                      Text(
                        '${tp.number} ${tp.name}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Address
                      Text(
                        tp.address,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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
                  label: 'Осталось',
                  value: '${tp.totalSubscribers - tp.readingsCollected}',
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
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isCompleted = tp.isCompleted;
    final color = isCompleted ? AppColors.success : AppColors.warning;
    final text = isCompleted ? 'Завершен' : 'В работе';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Прогресс сбора',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${tp.progressPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: Constants.paddingS),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: tp.progressPercentage / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (tp.isCompleted) return AppColors.success;
    if (tp.progressPercentage > 0) return AppColors.warning;
    return AppColors.info;
  }
}