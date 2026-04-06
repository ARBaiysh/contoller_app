import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../controllers/subscriber_detail_controller.dart';
import 'qr_payment_dialog.dart';

class BalanceInfoCard extends StatelessWidget {
  const BalanceInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberDetailController>();

    return Obx(() {
      final subscriber = controller.subscriber;
      if (subscriber == null) return const SizedBox.shrink();

      final isDebtor = subscriber.isDebtor;

      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: Constants.paddingM,
          vertical: Constants.paddingS,
        ),
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: Constants.getCardDecoration(context).copyWith(
          color: isDebtor
              ? AppColors.error.withValues(alpha: 0.05)
              : AppColors.success.withValues(alpha: 0.05),
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

            // Кнопка QR для оплаты
            const SizedBox(height: Constants.paddingM),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => QrPaymentPage(subscriber: subscriber));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Constants.borderRadius),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.qr_code_2, size: 20),
                label: const Text(
                  'QR для оплаты',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    });
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