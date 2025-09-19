import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/subscriber_model.dart';

class ReadingHistoryCard extends StatelessWidget {
  final SubscriberModel subscriber;

  const ReadingHistoryCard({
    Key? key,
    required this.subscriber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.paddingM,
        vertical: Constants.paddingS,
      ),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: AppColors.primary,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'История показаний',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          if (subscriber.lastReading != null) ...[
            _InfoRow(
              label: 'Последнее показание',
              value: '${subscriber.lastReading} кВт·ч',
              valueStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subscriber.lastReadingDate != null)
              _InfoRow(
                label: 'Дата снятия',
                value: DateFormat('dd.MM.yyyy HH:mm').format(subscriber.lastReadingDate!),
              ),

            // ИСПРАВЛЕНО: Убрали consumption и amountDue (их нет в новой модели)
            // Показываем информацию о платежах вместо этого
            if (subscriber.lastPaymentAmount > 0) ...[
              const SizedBox(height: Constants.paddingS),
              const Divider(),
              const SizedBox(height: Constants.paddingS),
              _InfoRow(
                label: 'Последний платеж',
                value: '${subscriber.lastPaymentAmount.toStringAsFixed(2)} сом.',
                valueStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subscriber.lastPaymentDate != null)
                _InfoRow(
                  label: 'Дата платежа',
                  value: DateFormat('dd.MM.yyyy').format(subscriber.lastPaymentDate!),
                ),
            ],

            // Показываем текущий баланс
            const SizedBox(height: Constants.paddingS),
            const Divider(),
            const SizedBox(height: Constants.paddingS),
            _InfoRow(
              label: 'Текущий баланс',
              value: subscriber.formattedBalance,
              valueStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: subscriber.isDebtor ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else
            Text(
              'Нет данных о предыдущих показаниях',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.valueStyle,
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
              style: valueStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}