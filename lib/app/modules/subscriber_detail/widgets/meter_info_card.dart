import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/subscriber_model.dart';

// ИСПРАВЛЕНО: Убрали параметр MeterInfo, используем поля из SubscriberModel
class MeterInfoCard extends StatelessWidget {
  final SubscriberModel subscriber;

  const MeterInfoCard({
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
                Icons.electric_meter,
                color: AppColors.primary,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'Данные счетчика',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          // ИСПРАВЛЕНО: Используем поля из SubscriberModel
          _InfoRow(label: 'Тип', value: subscriber.meterType),
          _InfoRow(label: 'Серийный номер', value: subscriber.meterSerialNumber),
          if (subscriber.sealNumber.isNotEmpty)
            _InfoRow(label: 'Номер пломбы', value: subscriber.sealNumber),
          _InfoRow(label: 'Тариф', value: subscriber.tariffName),
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