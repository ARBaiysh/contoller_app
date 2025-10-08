import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../core/values/constants.dart';

class FinancialSummaryCard extends StatelessWidget {
  final DashboardModel dashboard;

  const FinancialSummaryCard({
    Key? key,
    required this.dashboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: Constants.paddingM),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 20,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'ПОКАЗАТЕЛИ',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),

          // Показатели (всегда видны)
          Padding(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Column(
              children: [
                // ===== Потребление и начисления =====

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.electric_bolt_outlined,
                        label: 'Начислено за месяц (кВт·ч)',
                        value: '${NumberFormat('#,###', 'ru').format(dashboard.totalConsumptionThisMonth)} кВт·ч',
                        iconColor: Colors.amber,
                        iconBgColor: Colors.amber.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.receipt_long_outlined,
                        label: 'Начислено за месяц (сом)',
                        value: '${NumberFormat('#,###.##', 'ru').format(dashboard.totalChargeThisMonth)} сом',
                        iconColor: Colors.deepPurple,
                        iconBgColor: Colors.deepPurple.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingS),

                // Оплаты за месяц
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.payments_outlined,
                        label: 'Оплачено за месяц',
                        value: '${NumberFormat('#,###.##', 'ru').format(dashboard.totalPaymentsThisMonth)} сом',
                        subtitle: '${dashboard.paidThisMonth} абонентов',
                        iconColor: Colors.green,
                        iconBgColor: Colors.green.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingS),

                // Должники и переплаты
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.warning_amber_outlined,
                        label: 'Задолженность',
                        value: '${NumberFormat('#,###.##', 'ru').format(dashboard.totalDebtAmount)} сом',
                        subtitle: '${dashboard.debtorsCount} должников',
                        iconColor: Colors.red,
                        iconBgColor: Colors.red.withOpacity(0.15),
                      ),
                    ),
                    const SizedBox(width: Constants.paddingS),
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.trending_up_outlined,
                        label: 'Переплата',
                        value: '${NumberFormat('#,###.##', 'ru').format(dashboard.totalOverpaymentAmount)} сом',
                        subtitle: '',
                        iconColor: Colors.blue,
                        iconBgColor: Colors.blue.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingS),

                // Сегодня
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context: context,
                        icon: Icons.today_outlined,
                        label: 'Оплачено (сегодня)',
                        value: '${NumberFormat('#,###.##', 'ru').format(dashboard.totalPaymentsToday)} сом',
                        subtitle: '${dashboard.paidToday} абонентов',
                        iconColor: Colors.teal,
                        iconBgColor: Colors.teal.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : theme.cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius - 2),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: Constants.paddingS),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingS),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}