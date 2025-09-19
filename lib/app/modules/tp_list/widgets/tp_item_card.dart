import 'package:flutter/material.dart';
import '../../../data/models/tp_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class TpItemCard extends StatelessWidget {
  final TpModel tp;
  final VoidCallback onTap;

  const TpItemCard({
    Key? key,
    required this.tp,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Constants.paddingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with number and name
              Row(
                children: [
                  // TP Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.electrical_services,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: Constants.paddingM),

                  // TP Info
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
                        const SizedBox(height: Constants.paddingXS),
                        Text(
                          tp.fider,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}