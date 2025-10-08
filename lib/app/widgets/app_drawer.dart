import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/controllers/theme_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/values/constants.dart';
import '../modules/home/controllers/home_controller.dart';
import '../routes/app_pages.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
                    Get.toNamed(Routes.SETTINGS);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.newspaper,
                  title: 'Новости',
                  subtitle: 'Последние новости',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.NEWS);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Уведомления',
                  subtitle: 'Задания и статусы',
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.NOTIFICATIONS);
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
          // ✅ ИСПРАВЛЕНО: Используем Obx для реактивного обновления имени
          Obx(() => Text(
            controller.userName.value.isEmpty
                ? 'Загрузка...'
                : controller.userName.value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          )),
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
          // Theme switcher с динамическим текстом
          Obx(() => SwitchListTile(
            title: Text(
              'Тема оформления',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              themeController.isDarkMode ? 'Темная тема' : 'Светлая тема',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            value: themeController.isDarkMode,
            onChanged: (value) {
              themeController.setTheme(value);

              Get.snackbar(
                'Тема изменена',
                value ? 'Включена темная тема' : 'Включена светлая тема',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(milliseconds: 1500),
                margin: const EdgeInsets.all(Constants.paddingM),
                backgroundColor: Theme.of(context).cardColor,
                colorText: Theme.of(context).textTheme.bodyLarge?.color,
              );
            },
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          )),


          // Help & Support button
          // ListTile(
          //   leading: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Colors.blue.withOpacity(0.1),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: const Icon(
          //       Icons.help_outline,
          //       color: Colors.blue,
          //       size: 20,
          //     ),
          //   ),
          //   title: Text(
          //     'Помощь и поддержка',
          //     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          //   subtitle: Text(
          //     'FAQ и контакты',
          //     style: Theme.of(context).textTheme.bodySmall?.copyWith(
          //       color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          //     ),
          //   ),
          //   onTap: () {
          //     Get.back();
          //     Get.toNamed(Routes.HELP_SUPPORT);
          //   },
          //   contentPadding: EdgeInsets.zero,
          // ),
          //
          // const SizedBox(height: Constants.paddingS),

          // Logout button
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: AppColors.error,
                size: 20,
              ),
            ),
            title: Text(
              'Удалить аккаунт',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Завершить текущую сессию',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error.withOpacity(0.7),
              ),
            ),
            onTap: () {
              Get.back(); // Закрываем drawer
              homeController.logout();
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}