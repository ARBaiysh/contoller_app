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
                                child: const Text(
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Address
                        Text(
                          subscriber.address,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Meter serial number if available
                        if (subscriber.meterInfo != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.speed,
                                size: 14,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Счетчик: ${subscriber.meterInfo}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  // Balance
                  _buildInfoItem(
                    context: context,
                    icon: Icons.account_balance_wallet,
                    label: 'Баланс',
                    value: _formatBalance(subscriber.balance),
                    valueColor: subscriber.balance >= 0 ? AppColors.success : AppColors.error,
                  ),

                  // Last reading
                  if (subscriber.lastReading != null)
                    _buildInfoItem(
                      context: context,
                      icon: Icons.electric_meter,
                      label: 'Последнее',
                      value: '${subscriber.lastReading}',
                    ),

                  // Status
                  _buildReadingStatus(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color:
                Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReadingStatus(BuildContext context) {
    final status = subscriber.canTakeReading ? 'available' : 'completed';
    final color = subscriber.canTakeReading ? AppColors.warning : AppColors.success;
    final text = subscriber.canTakeReading ? 'Можно брать' : 'Обработан';
    final icon = subscriber.canTakeReading ? Icons.edit : Icons.check;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBalance(double balance) {
    if (balance >= 0) {
      return '${balance.toStringAsFixed(2)} сом';
    } else {
      return '-${balance.abs().toStringAsFixed(2)} сом';
    }
  }
}