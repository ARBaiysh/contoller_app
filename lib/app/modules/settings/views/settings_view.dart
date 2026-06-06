import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/settings_controller.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../core/controllers/theme_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Настройки',
      ),
      body: SafeArea(
        top: false,    // AppBar уже учитывает верхнюю область
        bottom: true,  // Защищаем от виртуальных кнопок внизу
        left: true,    // Защищаем от вырезов по бокам
        right: true,   // Защищаем от вырезов по бокам
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Constants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile card
              UserProfileCard(controller: controller),
              const SizedBox(height: Constants.paddingL),

              // App settings section
              SettingsSection(
                title: 'Настройки приложения',
                children: [
                  Obx(() => SettingsItem(
                    icon: Get.find<ThemeController>().isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    title: 'Тема оформления',
                    subtitle: Get.find<ThemeController>().isDarkMode
                        ? 'Темная тема'
                        : 'Светлая тема',
                    trailing: Switch(
                      value: Get.find<ThemeController>().isDarkMode,
                      onChanged: controller.toggleTheme,
                      activeColor: AppColors.primary,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: Constants.paddingL),

              // Sorting defaults section
              SettingsSection(
                title: 'Сортировка по умолчанию',
                children: [
                  Obx(() => SettingsItem(
                        icon: Icons.account_tree_outlined,
                        title: 'Список ТП',
                        subtitle: controller.tpSortLabel,
                        onTap: controller.chooseTpSort,
                      )),
                  Obx(() => SettingsItem(
                        icon: Icons.people_outline,
                        title: 'Список абонентов',
                        subtitle: controller.subscribersSortLabel,
                        onTap: controller.chooseSubscribersSort,
                      )),
                ],
              ),
              const SizedBox(height: Constants.paddingL),

              // About section
              SettingsSection(
                title: 'О приложении',
                children: [
                  SettingsItem(
                    icon: Icons.info_outline,
                    title: 'О приложении',
                    subtitle: 'Информация о версии и разработчике',
                    onTap: () => Get.toNamed(Routes.ABOUT),
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingL),

              // Logout button
              _buildLogoutButton(context),
              const SizedBox(height: Constants.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Constants.buttonHeight,
      child: ElevatedButton(
        onPressed: controller.showLogoutConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: Constants.paddingS),
            Text(
              'Выйти из системы',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}