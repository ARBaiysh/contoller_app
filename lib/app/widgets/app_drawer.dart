import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/values/constants.dart';
import '../core/controllers/theme_controller.dart';
import '../modules/home/controllers/home_controller.dart';
import '../routes/app_pages.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final themeController = ThemeController.to;

    return Drawer(
      child: Column(
        children: [
          // Header
          _buildHeader(context, homeController),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Профиль',
                  subtitle: 'Информация о пользователе',
                  onTap: () {
                    Get.back();
                    // В будущем можно добавить отдельный экран профиля
                    Get.snackbar(
                      'Профиль',
                      'Функция в разработке',
                      snackPosition: SnackPosition.TOP,
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'Настройки',
                  subtitle: 'Конфигурация приложения',
                  onTap: () {
                    Get.back();
                    homeController.navigateToSettings();
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Помощь и поддержка',
                  subtitle: 'Инструкции и FAQ',
                  onTap: () {
                    Get.back();
                    _showHelp();
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'О приложении',
                  subtitle: 'Версия и информация',
                  onTap: () {
                    Get.back();
                    _showAbout();
                  },
                ),
                const Divider(),
              ],
            ),
          ),

          // Bottom section
          _buildBottomSection(context, homeController, themeController),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + Constants.paddingL,
        left: Constants.paddingL,
        right: Constants.paddingL,
        bottom: Constants.paddingL,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                controller.userName.isNotEmpty
                    ? controller.userName[0].toUpperCase()
                    : 'К',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: Constants.paddingM),

          // User name
          Text(
            controller.userName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Constants.paddingXS),

          // Role
          Text(
            'Контролер',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingL,
        vertical: Constants.paddingXS,
      ),
    );
  }

  Widget _buildBottomSection(
      BuildContext context,
      HomeController homeController,
      ThemeController themeController,
      ) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Theme switcher
          Obx(() => SwitchListTile(
            title: Text(
              'Темная тема',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            value: themeController.isDarkMode,
            onChanged: (value) => themeController.toggleTheme(),
            secondary: Icon(
              themeController.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            contentPadding: EdgeInsets.zero,
          )),

          // Logout button
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppColors.error,
            ),
            title: Text(
              'Выход',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
              ),
            ),
            onTap: homeController.logout,
            contentPadding: EdgeInsets.zero,
          ),

          // Version info
          const SizedBox(height: Constants.paddingS),
          Text(
            'Версия ${Constants.appVersion}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    Get.dialog(
      AlertDialog(
        title: const Text('Помощь'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Основные функции приложения:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('• Просмотр списка ТП и абонентов'),
              Text('• Ввод показаний счетчиков'),
              Text('• Поиск абонентов по различным критериям'),
              Text('• Формирование отчетов'),
              SizedBox(height: 16),
              Text(
                'Навигация:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('• Используйте нижнюю панель для быстрого перехода'),
              Text('• Боковое меню содержит настройки и профиль'),
              SizedBox(height: 16),
              Text(
                'Для получения дополнительной помощи обратитесь к администратору системы.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text('О приложении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${Constants.appName}'),
            const SizedBox(height: 8),
            Text('Версия: ${Constants.appVersion}'),
            const SizedBox(height: 8),
            Text('${Constants.companyName}'),
            const SizedBox(height: 16),
            const Text(
              'Мобильное приложение для контролеров электросетевой компании для сбора показаний электросчетчиков.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}