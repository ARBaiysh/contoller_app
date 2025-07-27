import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_item.dart';
import '../widgets/app_info_card.dart';
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
        
              // Security settings section
              SettingsSection(
                title: 'Безопасность',
                children: [
                  Obx(() => controller.biometricAvailable
                      ? SettingsItem(
                    icon: Icons.fingerprint,
                    title: 'Биометрическая аутентификация',
                    subtitle: controller.biometricEnabled
                        ? 'Быстрый вход с помощью биометрии'
                        : 'Включить для быстрого входа',
                    trailing: Switch(
                      value: controller.biometricEnabled,
                      onChanged: controller.toggleBiometric,
                      activeColor: AppColors.primary,
                    ),
                  )
                      : const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: Constants.paddingL),
        
              // App settings section
              SettingsSection(
                title: 'Настройки приложения',
                children: [
                  Obx(() => SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Уведомления',
                    subtitle: 'Получать уведомления о новых данных',
                    trailing: Switch(
                      value: controller.notificationsEnabled,
                      onChanged: controller.toggleNotifications,
                      activeColor: AppColors.primary,
                    ),
                  )),
                  Obx(() => SettingsItem(
                    icon: Icons.sync_outlined,
                    title: 'Автосинхронизация',
                    subtitle: 'Автоматическое обновление данных',
                    trailing: Switch(
                      value: controller.autoSyncEnabled,
                      onChanged: controller.toggleAutoSync,
                      activeColor: AppColors.primary,
                    ),
                  )),
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
        
              // Data and storage section
              SettingsSection(
                title: 'Данные и хранилище',
                children: [
                  Obx(() => SettingsItem(
                    icon: Icons.storage_outlined,
                    title: 'Размер кэша',
                    subtitle: controller.cacheFormattedSize,
                    trailing: SizedBox(
                      width: 80, // Fixed width for the button
                      child: TextButton(
                        onPressed: controller.isLoading ? null : controller.clearCache,
                        child: controller.isLoading
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Очистить'),
                      ),
                    ),
                  )),
                  SettingsItem(
                    icon: Icons.refresh_outlined,
                    title: 'Обновить данные',
                    subtitle: 'Принудительное обновление с сервера',
                    onTap: () => _refreshData(),
                  ),
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
                    onTap: controller.showAboutDialog,
                  ),
                  SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Помощь и поддержка',
                    subtitle: 'Инструкции по использованию',
                    onTap: () => _showHelp(),
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingL),
        
              // App info card
              AppInfoCard(controller: controller),
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

  void _refreshData() {
    Get.snackbar(
      'Обновление',
      'Данные обновляются...',
      backgroundColor: Constants.info.withValues(alpha: 0.1),
      colorText: Constants.info,
      snackPosition: SnackPosition.TOP,
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
              Text('• Поиск абонентов'),
              Text('• Формирование отчетов'),
              Text('• Биометрическая аутентификация'),
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
}