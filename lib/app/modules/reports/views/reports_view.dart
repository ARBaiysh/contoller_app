import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../widgets/report_type_card.dart';
import '../widgets/report_stats_card.dart';
import '../widgets/tp_selector_card.dart';
import '../widgets/generate_report_button.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/values/constants.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Отчеты',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Constants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics card
              ReportStatsCard(controller: controller),
              const SizedBox(height: Constants.paddingL),

              // Report type selection
              Text(
                'Тип отчета',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Constants.paddingM),

              // Report types grid
              _buildReportTypesGrid(context),
              const SizedBox(height: Constants.paddingL),

              // TP selector
              TpSelectorCard(controller: controller),
              const SizedBox(height: Constants.paddingXL),

              // Generate button
              GenerateReportButton(controller: controller),
              const SizedBox(height: Constants.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Constants.paddingM,
        mainAxisSpacing: Constants.paddingM,
        childAspectRatio: 0.85, // Изменено с 1.1 на 0.85 для большей высоты
      ),
      itemCount: controller.reportTypes.length,
      itemBuilder: (context, index) {
        final reportType = controller.reportTypes[index];
        return ReportTypeCard(
          reportType: reportType,
          controller: controller,
        );
      },
    );
  }
}