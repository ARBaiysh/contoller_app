import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../routes/app_pages.dart';
import '../controllers/subscriber_detail_controller.dart';

class MeterInfoCard extends StatelessWidget {
  const MeterInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberDetailController>();

    return Obx(() {
      final subscriber = controller.subscriber;
      if (subscriber == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: () => _openMeterDetail(subscriber.accountNumber, subscriber.meterSerialNumber),
        child: Container(
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
                  Expanded(
                    child: Text(
                      'Данные счётчика',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingM),

              _InfoRow(label: 'Тип ПУ', value: subscriber.meterType ?? 'Не указан'),
              _InfoRow(label: 'Серийный номер', value: subscriber.meterSerialNumber),
              _InfoRow(label: 'Тариф', value: subscriber.tariffName ?? '${subscriber.tariff.toStringAsFixed(2)} сом/кВт·ч'),

              const SizedBox(height: Constants.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.paddingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Нажмите для подробной информации',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openMeterDetail(String accountNumber, String meterNumber) {
    Get.toNamed(
      Routes.METER_DETAIL,
      arguments: {
        'accountNumber': accountNumber,
        'meterNumber': meterNumber,
      },
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
