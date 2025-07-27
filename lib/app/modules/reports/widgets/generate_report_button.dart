import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class GenerateReportButton extends StatelessWidget {
  final ReportsController controller;

  const GenerateReportButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isGenerating = controller.isGenerating;
      final selectedReport = controller.reportTypes
          .firstWhere((r) => r.id == controller.selectedReportType);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected report info
          Container(
            padding: const EdgeInsets.all(Constants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Constants.borderRadius),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedReport.icon,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: Constants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Готов к формированию:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedReport.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (controller.selectedTpId.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Для выбранного ТП',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 2),
                        Text(
                          'Для всех ТП',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Constants.paddingL),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: Constants.buttonHeight,
            child: ElevatedButton(
              onPressed: isGenerating ? null : controller.generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
                elevation: isGenerating ? 0 : 2,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ),
              child: isGenerating
                  ? _buildLoadingContent()
                  : _buildButtonContent(context),
            ),
          ),

          // Button description
          const SizedBox(height: Constants.paddingM),
          Text(
            isGenerating
                ? 'Формирование отчета может занять несколько секунд...'
                : 'Отчет будет сформирован в формате PDF и сохранен в память устройства',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    });
  }

  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(width: Constants.paddingM),
        const Text(
          'Формируется отчет...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.file_download_outlined,
          size: 24,
        ),
        const SizedBox(width: Constants.paddingM),
        const Text(
          'Сформировать отчет',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}