import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/subscriber_model.dart';
import '../controllers/subscriber_detail_controller.dart';

class SubscriberInfoCard extends StatelessWidget {
  final SubscriberModel subscriber;
  final String tpName;

  const SubscriberInfoCard({
    Key? key,
    required this.subscriber,
    required this.tpName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Constants.paddingM),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.primary,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'Информация об абоненте',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          _InfoRow(label: 'ФИО', value: subscriber.fullName),
          _InfoRow(label: 'Лицевой счет', value: subscriber.accountNumber),
          _InfoRow(label: 'Адрес', value: subscriber.address),
          if (subscriber.phone != null && subscriber.phone!.isNotEmpty)
            _InfoRow(label: 'Телефон', value: subscriber.phone!),
          _InfoRow(label: 'ТП', value: tpName),

          const SizedBox(height: Constants.paddingM),

          // Status badge с поддержкой синхронизации
          GetBuilder<SubscriberDetailController>(
            builder: (controller) {
              return Obx(() {
                if (controller.isSyncing) {
                  // Показываем статус синхронизации
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Constants.paddingM,
                      vertical: Constants.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Constants.borderRadius),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        const SizedBox(width: Constants.paddingS),
                        Text(
                          'Статус: ${controller.syncMessage}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Показываем обычный статус
                  return _StatusBadge(status: subscriber.status);
                }
              });
            },
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
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
  });

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
              style: valueStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// ИСПРАВЛЕНО: StatusBadge использует новый SubscriberStatus
class _StatusBadge extends StatelessWidget {
  final SubscriberStatus status;

  const _StatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingM,
        vertical: Constants.paddingS,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 20,
          ),
          const SizedBox(width: Constants.paddingS),
          Text(
            'Статус: ${status.displayName}',
            style: TextStyle(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case SubscriberStatus.normal:
        return AppColors.success;
      case SubscriberStatus.debtor:
        return AppColors.error;
      case SubscriberStatus.disabled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case SubscriberStatus.normal:
        return Icons.check_circle_outline;
      case SubscriberStatus.debtor:
        return Icons.warning;
      case SubscriberStatus.disabled:
        return Icons.block;
    }
  }
}
