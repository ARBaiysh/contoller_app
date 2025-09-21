import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class DashboardHeader extends StatelessWidget {
  final HomeController controller;

  const DashboardHeader({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboard = controller.dashboard;
    if (dashboard == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(Constants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с временем
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Сводка по участку',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.paddingS,
                  vertical: Constants.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
                ),
                child: Text(
                  dashboard.lastUpdateTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: Constants.paddingL),

          // Основные показатели в строке
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  'Абонентов',
                  dashboard.totalAbonents.toString(),
                  'на ${dashboard.totalTransformerPoints} ТП',
                  Icons.people,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
              ),
              Expanded(
                child: _buildHeaderStat(
                  'Показания',
                  '${dashboard.completionPercentage.toStringAsFixed(0)}%',
                  '${dashboard.readingsCollected}/${dashboard.totalReadingsNeeded}',
                  Icons.electrical_services,
                ),
              ),
            ],
          ),

          const SizedBox(height: Constants.paddingM),

          // Финансовые показатели
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  'Должники',
                  dashboard.debtorsCount.toString(),
                  dashboard.formattedDebtAmount,
                  Icons.warning_amber,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: Constants.paddingS),
              Expanded(
                child: _buildFinancialCard(
                  'Оплаты',
                  dashboard.paidToday.toString(),
                  dashboard.formattedPaymentsToday,
                  Icons.payments,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: Constants.paddingS),
              Expanded(
                child: _buildFinancialCard(
                  'За месяц',
                  dashboard.paidThisMonth.toString(),
                  dashboard.formattedPaymentsThisMonth,
                  Icons.calendar_month,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 20,
        ),
        const SizedBox(width: Constants.paddingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialCard(
      String title,
      String count,
      String amount,
      IconData icon,
      Color accentColor
      ) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingS),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              color: accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Доброе утро!';
    } else if (hour < 17) {
      return 'Добрый день!';
    } else {
      return 'Добрый вечер!';
    }
  }
}