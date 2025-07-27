import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0D1117) : Colors.white,
      body: SafeArea(
        child: Center(
          child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Компактный логотип
              _buildCompactLogo(isDarkMode),
              const SizedBox(height: Constants.paddingXL),

              // Название приложения
              _buildAppTitle(context, isDarkMode),
              const SizedBox(height: Constants.paddingS),

              // Компания
              _buildCompanyInfo(context, isDarkMode),

              const Spacer(flex: 2),

              // Индикатор загрузки
              if (controller.isLoading) ...[
                _buildSimpleLoader(isDarkMode),
                const SizedBox(height: Constants.paddingL),
                _buildLoadingText(context, isDarkMode),
              ],

              const Spacer(flex: 2),

              // Версия внизу
              _buildVersionInfo(context, isDarkMode),
              const SizedBox(height: Constants.paddingL),
            ],
          )),
        ),
      ),
    );
  }

  // Компактный профессиональный логотип
  Widget _buildCompactLogo(bool isDarkMode) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.electrical_services,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  // Название приложения
  Widget _buildAppTitle(BuildContext context, bool isDarkMode) {
    return Text(
      'ОшПЭС Контролер',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Информация о компании
  Widget _buildCompanyInfo(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingM,
        vertical: Constants.paddingS,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Система учета электроэнергии',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.grey[600],
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Простой индикатор загрузки
  Widget _buildSimpleLoader(bool isDarkMode) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        backgroundColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }

  // Текст загрузки
  Widget _buildLoadingText(BuildContext context, bool isDarkMode) {
    return Text(
      controller.loadingText,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  // Информация о версии
  Widget _buildVersionInfo(BuildContext context, bool isDarkMode) {
    return Text(
      'Версия ${Constants.appVersion}',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.4)
            : Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }
}