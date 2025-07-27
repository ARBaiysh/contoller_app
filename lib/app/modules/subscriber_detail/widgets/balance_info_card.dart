import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/subscriber_model.dart';


class BalanceInfoCard extends StatelessWidget {
  final SubscriberModel subscriber;

  const BalanceInfoCard({
    Key? key,
    required this.subscriber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDebtor = subscriber.isDebtor;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.paddingM,
        vertical: Constants.paddingS,
      ),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context).copyWith(
        color: isDebtor
            ? AppColors.error.withOpacity(0.05)
            : AppColors.success.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: isDebtor ? AppColors.error : AppColors.success,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'Баланс',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Текущий баланс:',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '${subscriber.balance.toStringAsFixed(2)} сом',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDebtor ? AppColors.error : AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (subscriber.lastPaymentDate != null) ...[
            const SizedBox(height: Constants.paddingM),
            _InfoRow(
              label: 'Последняя оплата',
              value: '${subscriber.lastPaymentAmount.toStringAsFixed(2)} сом',
            ),
            _InfoRow(
              label: 'Дата оплаты',
              value: DateFormat(Constants.dateFormat).format(subscriber.lastPaymentDate!),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}