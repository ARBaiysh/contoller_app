import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class FinancialSummaryCard extends StatefulWidget {
  final DashboardModel dashboard;

  const FinancialSummaryCard({
    Key? key,
    required this.dashboard,
  }) : super(key: key);

  @override
  State<FinancialSummaryCard> createState() => _FinancialSummaryCardState();
}

class _FinancialSummaryCardState extends State<FinancialSummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboard = widget.dashboard;

    // Вычисляем общий баланс
    final totalBalance = dashboard.totalPaymentsThisMonth - dashboard.totalDebtAmount;
    final isPositiveBalance = totalBalance >= 0;

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
          // Заголовок (всегда видимый)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Constants.borderRadius),
              bottom: Radius.circular(_isExpanded ? 0 : Constants.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Constants.paddingM),
              child: Row(
                children: [
                  // Иконка
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: Constants.paddingM),

                  // Заголовок и краткая информация
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ФИНАНСОВЫЕ ПОКАЗАТЕЛИ',
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Платежи сегодня: ${dashboard.formattedPaymentsToday}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Иконка разворота
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more,
                      color: theme.iconTheme.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Развернутое содержимое
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Constants.paddingM),
                child: Column(
                  children: [
                    // Платежи
                    _buildSection(
                      context: context,
                      title: 'Платежи',
                      icon: Icons.trending_up,
                      iconColor: AppColors.success,
                      items: [
                        _FinancialItem(
                          label: 'Сегодня',
                          count: '${dashboard.paidToday} абонентов',
                          amount: dashboard.formattedPaymentsToday,
                        ),
                        _FinancialItem(
                          label: 'За месяц',
                          count: '${dashboard.paidThisMonth} абонентов',
                          amount: dashboard.formattedPaymentsThisMonth,
                        ),
                      ],
                    ),

                    const SizedBox(height: Constants.paddingM),

                    // Задолженности
                    _buildSection(
                      context: context,
                      title: 'Задолженности',
                      icon: Icons.warning_amber,
                      iconColor: AppColors.error,
                      items: [
                        _FinancialItem(
                          label: 'Должники',
                          count: '${dashboard.debtorsCount} абонентов',
                          amount: dashboard.formattedDebtAmount,
                          isNegative: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: Constants.paddingM),

                    // Переплаты
                    if (dashboard.totalOverpaymentAmount > 0) ...[
                      _buildSection(
                        context: context,
                        title: 'Переплаты',
                        icon: Icons.add_circle_outline,
                        iconColor: AppColors.info,
                        items: [
                          _FinancialItem(
                            label: 'Общая сумма',
                            count: null,
                            amount: dashboard.formattedOverpaymentAmount,
                          ),
                        ],
                      ),
                      const SizedBox(height: Constants.paddingM),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_FinancialItem> items,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: Constants.paddingS),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: Constants.paddingS),

        // Элементы
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 26, bottom: Constants.paddingS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  if (item.count != null)
                    Text(
                      item.count!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
              Text(
                item.amount,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: item.isNegative ? AppColors.error : null,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _FinancialItem {
  final String label;
  final String? count;
  final String amount;
  final bool isNegative;

  _FinancialItem({
    required this.label,
    this.count,
    required this.amount,
    this.isNegative = false,
  });
}