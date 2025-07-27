import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/report_viewer_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class ReportHeaderCard extends StatelessWidget {
  final ReportViewerController controller;

  const ReportHeaderCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Constants.paddingM),
      padding: const EdgeInsets.all(Constants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Constants.paddingS),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getReportIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: Constants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.reportTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getReportSubtitle(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingL),

          // Statistics row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  label: 'Записей',
                  value: '${controller.totalCount}',
                ),
              ),
              if (controller.totalAmountText.isNotEmpty) ...[
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    context: context,
                    label: controller.reportType == 'payments' ? 'Баланс' : 'Долг',
                    value: '${controller.totalAmount.toStringAsFixed(0)} сом',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          // Date and time
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.paddingM,
              vertical: Constants.paddingS,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'Сформирован: ${DateFormat('dd.MM.yyyy в HH:mm').format(DateTime.now())}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.paddingXS),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  IconData _getReportIcon() {
    switch (controller.reportType) {
      case 'disconnections':
        return Icons.power_off;
      case 'debtors':
        return Icons.warning_amber;
      case 'payments':
        return Icons.payment;
      default:
        return Icons.description;
    }
  }

  String _getReportSubtitle() {
    switch (controller.reportType) {
      case 'disconnections':
        return 'Абоненты для отключения электроэнергии';
      case 'debtors':
        return 'Абоненты с задолженностью по оплате';
      case 'payments':
        return 'Абоненты с положительным балансом';
      default:
        return 'Детальный отчет по абонентам';
    }
  }
}