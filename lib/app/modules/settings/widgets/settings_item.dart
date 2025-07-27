import 'package:flutter/material.dart';
import '../../../core/values/constants.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingM),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(Constants.paddingS),
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: Constants.iconSizeMedium,
                color: iconColor ?? Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: Constants.paddingM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing widget
            if (trailing != null) ...[
              const SizedBox(width: Constants.paddingM),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: Constants.paddingM),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}