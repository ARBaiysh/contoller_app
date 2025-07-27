import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/statistic_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Constants.appName,
        showBackButton: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Obx(() => _buildBody(context)),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.statistics == null) {
      return _buildErrorState(context);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(Constants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: Constants.paddingL),
            _buildStatisticsGrid(context),
            const SizedBox(height: Constants.paddingL),
            _buildQuickActions(context),
            const SizedBox(height: Constants.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Доброе утро';
    } else if (hour < 18) {
      greeting = 'Добрый день';
    } else {
      greeting = 'Добрый вечер';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Constants.paddingXS),
        Text(
          controller.userName,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    final stats = controller.statistics!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статистика',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Constants.paddingM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: Constants.paddingM,
          crossAxisSpacing: Constants.paddingM,
          childAspectRatio: 1.0,
          children: [
            StatisticCard(
              title: 'Собрано показаний',
              value: '${stats.readingsCollected}',
              subtitle: 'из ${stats.totalSubscribers}',
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
              showProgress: true,
              progressValue: stats.collectionPercentage,
              onTap: controller.navigateToTpList,
            ),
            StatisticCard(
              title: 'Оплатили',
              value: '${stats.paidSubscribers}',
              subtitle: '${stats.paymentPercentage.toStringAsFixed(1)}%',
              icon: Icons.payment,
              iconColor: AppColors.info,
            ),
            StatisticCard(
              title: 'Должников',
              value: '${stats.debtorCount}',
              subtitle: '${stats.debtorPercentage.toStringAsFixed(1)}%',
              icon: Icons.warning_amber_outlined,
              iconColor: AppColors.warning,
            ),
            StatisticCard(
              title: 'Сумма долга',
              value: '${(stats.totalDebtAmount / 1000).toStringAsFixed(1)}K',
              subtitle: '${stats.totalDebtAmount.toStringAsFixed(0)} сом',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрые действия',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: Constants.paddingM),
        _buildActionButton(
          context: context,
          icon: Icons.electrical_services,
          title: 'Список ТП',
          subtitle: 'Просмотр и управление',
          onTap: controller.navigateToTpList,
        ),
        const SizedBox(height: Constants.paddingS),
        _buildActionButton(
          context: context,
          icon: Icons.search,
          title: 'Поиск абонентов',
          subtitle: 'По ФИО, адресу или счету',
          onTap: controller.navigateToSearch,
        ),
        const SizedBox(height: Constants.paddingS),
        _buildActionButton(
          context: context,
          icon: Icons.description,
          title: 'Отчеты',
          subtitle: 'Формирование документов',
          onTap: controller.navigateToReports,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Constants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Constants.paddingS),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: Constants.iconSizeMedium,
              ),
            ),
            const SizedBox(width: Constants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: Constants.iconSizeSmall,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Obx(() => BottomNavigationBar(
      currentIndex: controller.currentIndex,
      onTap: controller.changeTabIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.electrical_services_outlined),
          activeIcon: Icon(Icons.electrical_services),
          label: 'ТП',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Поиск',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          activeIcon: Icon(Icons.description),
          label: 'Отчеты',
        ),
      ],
    ));
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: Constants.paddingM),
          Text(
            'Не удалось загрузить данные',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Constants.paddingM),
          ElevatedButton(
            onPressed: controller.loadStatistics,
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}