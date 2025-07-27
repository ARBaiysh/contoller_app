import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/values/constants.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progressValue;

  const StatisticCard({
    Key? key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.showProgress = false,
    this.progressValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultIconColor = iconColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Constants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: backgroundColor != null
            ? Constants.getCardDecoration(context).copyWith(
          color: backgroundColor,
        )
            : Constants.getCardDecoration(context),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: defaultIconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: defaultIconColor,
                          size: 20,
                        ),
                      ),
                      if (onTap != null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Value
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 22,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),

                // Subtitle or Progress
                if (subtitle != null || showProgress) ...[
                  const SizedBox(height: 4),
                  if (showProgress && progressValue != null)
                    _buildProgressBar(context)
                  else if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ],
            );
          },
        ),
      ),
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
              subtitle ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${progressValue!.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: Constants.paddingXS),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue! / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              iconColor ?? AppColors.primary,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}