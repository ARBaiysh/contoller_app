import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class ReportTypeCard extends StatelessWidget {
  final ReportType reportType;
  final ReportsController controller;

  const ReportTypeCard({
    Key? key,
    required this.reportType,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedReportType == reportType.id;

      return InkWell(
        onTap: () => controller.setReportType(reportType.id),
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: AnimatedContainer(
          duration: Constants.animationFast,
          padding: const EdgeInsets.all(Constants.paddingM),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Constants.borderRadius),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Flexible(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(Constants.paddingS),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        reportType.icon,
                        size: 24,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: Constants.paddingS),

                  // Title
                  Flexible(
                    flex: 2,
                    child: Text(
                      reportType.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).textTheme.titleSmall?.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: Constants.paddingXS),

                  // Description
                  Flexible(
                    flex: 2,
                    child: Text(
                      reportType.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Selection indicator
                  if (isSelected) ...[
                    const SizedBox(height: Constants.paddingXS),
                    Flexible(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.paddingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Выбрано',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 4), // Placeholder for consistent height
                ],
              );
            },
          ),
        ),
      );
    });
  }
}