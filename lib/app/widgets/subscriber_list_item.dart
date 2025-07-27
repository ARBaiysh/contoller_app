import 'package:flutter/material.dart';
import '../data/models/subscriber_model.dart';
import '../core/theme/app_colors.dart';
import '../core/values/constants.dart';

class SubscriberListItem extends StatelessWidget {
  final SubscriberModel subscriber;
  final VoidCallback onTap;

  const SubscriberListItem({
    Key? key,
    required this.subscriber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Constants.paddingM,
          vertical: Constants.paddingXS,
        ),
        decoration: Constants.getCardDecoration(context),
        child: Column(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(Constants.paddingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator
                  _buildStatusIndicator(context),
                  const SizedBox(width: Constants.paddingM),

                  // Subscriber info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account number and name
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subscriber.fullName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (subscriber.isDebtor)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Долг',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Account number
                        Text(
                          'Л/С: ${subscriber.accountNumber}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Address
                        Text(
                          subscriber.address,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),

            // Bottom info bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.paddingM,
                vertical: Constants.paddingS,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(Constants.borderRadius),
                  bottomRight: Radius.circular(Constants.borderRadius),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Meter info
                  Row(
                    children: [
                      Icon(
                        Icons.electric_meter,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subscriber.meterInfo.type,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      if (subscriber.lastReading != null) ...[
                        const SizedBox(width: Constants.paddingM),
                        Icon(
                          Icons.speed,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${subscriber.lastReading}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Balance or status
                  _buildBalanceInfo(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    Color color;
    IconData icon;

    switch (subscriber.readingStatus) {
      case ReadingStatus.available:
        color = AppColors.success;
        icon = Icons.radio_button_unchecked;
        break;
      case ReadingStatus.processing:
        color = AppColors.warning;
        icon = Icons.pending;
        break;
      case ReadingStatus.completed:
        color = Colors.grey;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildBalanceInfo(BuildContext context) {
    if (subscriber.isDebtor) {
      return Row(
        children: [
          Icon(
            Icons.warning_amber,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            '${subscriber.debtAmount.toStringAsFixed(0)} сом',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (subscriber.balance > 0) {
      return Row(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 14,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            '+${subscriber.balance.toStringAsFixed(0)} сом',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Text(
        subscriber.readingStatus.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: _getStatusColor(),
        ),
      );
    }
  }

  Color _getStatusColor() {
    switch (subscriber.readingStatus) {
      case ReadingStatus.available:
        return AppColors.success;
      case ReadingStatus.processing:
        return AppColors.warning;
      case ReadingStatus.completed:
        return Colors.grey;
    }
  }
}