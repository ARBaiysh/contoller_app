import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/reports_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class ReportStatsCard extends StatelessWidget {
  final ReportsController controller;

  const ReportStatsCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getReportStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingCard(context);
        }

        final stats = snapshot.data!;
        return Container(
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
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: Constants.paddingM),
                  const Expanded(
                    child: Text(
                      'Статистика отчетов',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingL),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context: context,
                      title: 'Сформировано',
                      value: '${stats['total_reports_generated'] ?? 0}',
                      subtitle: 'отчетов',
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      context: context,
                      title: 'Показания',
                      value: '${stats['readings_collected'] ?? 0}',
                      subtitle: 'из ${stats['total_subscribers'] ?? 0}',
                    ),
                  ),
                ],
              ),

              if (stats['last_report_date'] != null) ...[
                const SizedBox(height: Constants.paddingM),
                const Divider(color: Colors.white24),
                const SizedBox(height: Constants.paddingM),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: Constants.paddingS),
                    Text(
                      'Последний отчет: ${DateFormat('dd.MM.yyyy').format(stats['last_report_date'])}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.paddingXS),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.paddingXS),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(Constants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}