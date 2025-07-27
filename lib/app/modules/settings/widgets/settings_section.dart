import 'package:flutter/material.dart';
import '../../../core/values/constants.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(
            left: Constants.paddingS,
            bottom: Constants.paddingM,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
        ),

        // Section content
        Container(
          decoration: Constants.getCardDecoration(context),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    indent: Constants.paddingL + Constants.iconSizeMedium,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}