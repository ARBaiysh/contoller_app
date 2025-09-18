import 'package:flutter/material.dart';
import '../controllers/report_viewer_controller.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class SubscriberReportItem extends StatelessWidget {
  final SubscriberModel subscriber;
  final ReportViewerController controller;
  final int index;

  const SubscriberReportItem({
    Key? key,
    required this.subscriber,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = controller.getSubscriberAmount(subscriber);
    final isDebtor = controller.reportType != 'payments';

    return Container(
      margin: const EdgeInsets.only(bottom: Constants.paddingS),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with index and status
          Row(
            children: [
              // Index number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Constants.paddingM),

              // Subscriber name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscriber.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Л/С: ${subscriber.accountNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.paddingS,
                  vertical: Constants.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: isDebtor
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${amount.toStringAsFixed(0)} сом',
                  style: TextStyle(
                    color: isDebtor ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: Constants.paddingS),
              Expanded(
                child: Text(
                  subscriber.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingS),

          // TP info
          Row(
            children: [
              Icon(
                Icons.electrical_services,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                '${subscriber.tpNumber}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),

          // Additional info based on report type
          if (controller.reportType == 'disconnections') ...[
            const SizedBox(height: Constants.paddingS),
            Container(
              padding: const EdgeInsets.all(Constants.paddingS),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: Constants.paddingS),
                  Expanded(
                    child: Text(
                      'Рекомендуется к отключению (долг > 1000 сом)',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (controller.reportType == 'payments' && subscriber.lastPaymentDate != null) ...[
            const SizedBox(height: Constants.paddingS),
            Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'Последняя оплата: ${subscriber.lastPaymentAmount?.toStringAsFixed(0) ?? "0"} сом',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}