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
                  icon: Icons.home_outlined,
                  title: 'Главная',
                  onTap: () {
                    Get.back();
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.electrical_services_outlined,
                  title: 'Список ТП',
                  onTap: () {
                    Get.back();
                    homeController.navigateToTpList();
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.search_outlined,
                  title: 'Поиск абонентов',
                  onTap: () {
                    Get.back();
                    homeController.navigateToSearch();
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'Отчеты',
                  onTap: () {
                    Get.back();
                    homeController.navigateToReports();
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'Настройки',
                  onTap: () {
                    Get.back();
                    homeController.navigateToSettings();
                  },
                ),
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
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                controller.userName.isNotEmpty
                    ? controller.userName[0].toUpperCase()
                    : 'К',
                style: const TextStyle(
                  color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: Constants.fontSizeL,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Constants.paddingXS),

          // Role
          Text(
            'Контролер',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: Constants.fontSizeS,
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
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      onTap: onTap,
      horizontalTitleGap: 0,
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
}