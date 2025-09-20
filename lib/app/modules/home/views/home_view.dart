import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../controllers/home_controller.dart';
import '../widgets/corporate_summary_card.dart';
import '../widgets/corporate_metric_card.dart';
import '../../../widgets/app_drawer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RefreshController refreshController = RefreshController();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0D1117)
          : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'КОНТРОЛЬНАЯ ПАНЕЛЬ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            Obx(() {
              if (controller.dashboard != null) {
                return Text(
                  'Обновлено ${controller.dashboard!.lastUpdateTime}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashboard = controller.dashboard;
        if (dashboard == null) {
          return _buildErrorState(context, refreshController);
        }

        return SmartRefresher(
          controller: refreshController,
          enablePullDown: true,
          header: const ClassicHeader(),
          onRefresh: () async {
            await controller.refreshDashboard();
            refreshController.refreshCompleted();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Constants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Секция: Общий прогресс
                _buildSectionTitle(context, 'ОБЩИЙ ПРОГРЕСС'),
                const SizedBox(height: Constants.paddingM),
                CorporateSummaryCard(
                  title: 'Выполнение плана показаний',
                  value: '${dashboard.readingsCollected}/${dashboard.totalReadingsNeeded}',
                  subtitle: 'Снято показаний из необходимых',
                  percentage: dashboard.completionPercentage,
                  isPositive: dashboard.completionPercentage > 30,
                ),

                const SizedBox(height: Constants.paddingL),

                // Секция: Ключевые показатели
                _buildSectionTitle(context, 'КЛЮЧЕВЫЕ ПОКАЗАТЕЛИ'),
                const SizedBox(height: Constants.paddingM),

                // Сетка метрик 2x2
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: Constants.paddingM,
                  crossAxisSpacing: Constants.paddingM,
                  childAspectRatio: 1.1,
                  children: [
                    CorporateMetricCard(
                      icon: Icons.speed,
                      title: 'Показания',
                      value: dashboard.readingsCollected.toString(),
                      subtitle: 'снято сегодня: ${dashboard.readingsToday}',
                      iconColor: AppColors.info,
                      items: [
                        MetricItem(
                          label: 'Выполнено',
                          value: dashboard.readingsCollected.toString(),
                          icon: Icons.check_circle_outline,
                          valueColor: AppColors.success,
                        ),
                        MetricItem(
                          label: 'Осталось',
                          value: dashboard.readingsRemaining.toString(),
                          icon: Icons.pending_outlined,
                          valueColor: AppColors.warning,
                        ),
                        MetricItem(
                          label: 'Сегодня',
                          value: '+${dashboard.readingsToday}',
                          icon: Icons.today,
                          valueColor: AppColors.info,
                        ),
                      ],
                    ),

                    CorporateMetricCard(
                      icon: Icons.people_outline,
                      title: 'Абоненты',
                      value: dashboard.totalAbonents.toString(),
                      subtitle: 'кол-ов ${dashboard.totalTransformerPoints} ТП',
                      iconColor: AppColors.primary,
                      items: [
                        MetricItem(
                          label: 'Всего',
                          value: dashboard.totalAbonents.toString(),
                          icon: Icons.person_outline,
                        ),
                        MetricItem(
                          label: 'Должники',
                          value: '${dashboard.debtorsCount}',
                          icon: Icons.warning_amber_outlined,
                          valueColor: AppColors.error,
                        ),
                        MetricItem(
                          label: 'Процент',
                          value: '${dashboard.debtorsPercentage.toStringAsFixed(0)}%',
                          icon: Icons.pie_chart_outline,
                          valueColor: AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: Constants.paddingM),

                // Финансовые показатели в ряд
                Container(
                  height: 100, // Фиксированная высота
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFinanceCard(
                          context: context,
                          title: 'ЗАДОЛЖЕННОСТЬ',
                          value: dashboard.formattedDebtAmount,
                          icon: Icons.trending_down,
                          color: AppColors.error,
                          isNegative: true,
                        ),
                      ),
                      const SizedBox(width: Constants.paddingS), // Уменьшили отступ между карточками
                      Expanded(
                        child: _buildFinanceCard(
                          context: context,
                          title: 'ПЕРЕПЛАТЫ',
                          value: dashboard.formattedOverpaymentAmount,
                          icon: Icons.trending_up,
                          color: AppColors.success,
                          isNegative: false,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Constants.paddingL),

                // Секция: Платежи
                _buildSectionTitle(context, 'ПЛАТЕЖИ'),
                const SizedBox(height: Constants.paddingM),

                _buildPaymentsSummary(context, dashboard),

                const SizedBox(height: Constants.paddingL),

                // Секция: Быстрые действия
                _buildSectionTitle(context, 'БЫСТРЫЕ ДЕЙСТВИЯ'),
                const SizedBox(height: Constants.paddingM),

                _buildQuickActions(context),

                const SizedBox(height: Constants.paddingXL),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildFinanceCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isNegative,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Constants.paddingS), // Уменьшили padding с paddingM
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18), // Уменьшили размер иконки
              const SizedBox(width: 4), // Уменьшили отступ
              Expanded( // Добавили Expanded для текста
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8, // Уменьшили letter spacing
                    fontSize: 10, // Уменьшили размер
                  ),
                  overflow: TextOverflow.ellipsis, // Добавили обрезку текста
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingS), // Уменьшили отступ
          FittedBox( // Добавили FittedBox для автоматического масштабирования
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith( // Изменили с titleLarge
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSummary(BuildContext context, dynamic dashboard) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildPaymentRow(
            context: context,
            label: 'Сегодня',
            count: dashboard.paidToday,
            amount: dashboard.formattedPaymentsToday,
            icon: Icons.today,
          ),
          const Divider(height: Constants.paddingL),
          _buildPaymentRow(
            context: context,
            label: 'За месяц',
            count: dashboard.paidThisMonth,
            amount: dashboard.formattedPaymentsThisMonth,
            icon: Icons.calendar_month,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required BuildContext context,
    required String label,
    required int count,
    required String amount,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.success,
          size: 20,
        ),
        const SizedBox(width: Constants.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
              Text(
                '$count абонентов',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.electrical_services,
            label: 'СПИСОК ТП',
            onTap: controller.navigateToTpList,
          ),
        ),
        const SizedBox(width: Constants.paddingS),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.search,
            label: 'ПОИСК',
            onTap: controller.navigateToSearch,
          ),
        ),
        const SizedBox(width: Constants.paddingS),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.description,
            label: 'ОТЧЕТЫ',
            onTap: controller.navigateToReports,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Constants.paddingM),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, RefreshController refreshController) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: Constants.paddingM),
            Text(
              'НЕ УДАЛОСЬ ЗАГРУЗИТЬ ДАННЫЕ',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 1.2,
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: Constants.paddingS),
            Text(
              controller.lastError,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.paddingL),
            ElevatedButton.icon(
              onPressed: () => controller.loadDashboard(),
              icon: const Icon(Icons.refresh),
              label: const Text('ПОВТОРИТЬ'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.paddingL,
                  vertical: Constants.paddingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}