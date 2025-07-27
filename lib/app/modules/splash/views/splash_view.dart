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
      body: Container(
        decoration: _buildBackgroundDecoration(isDarkMode),
        child: SafeArea(
          child: Center(
            child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Animated logo with glow effect
                _buildAnimatedLogo(isDarkMode),
                const SizedBox(height: Constants.paddingXL),

                // App name with fade in animation
                _buildAppName(context, isDarkMode),
                const SizedBox(height: Constants.paddingM),

                // Company name with slide animation
                _buildCompanyName(context, isDarkMode),
                const SizedBox(height: Constants.paddingXL * 2),

                // Loading section
                if (controller.isLoading) ...[
                  _buildLoadingIndicator(isDarkMode),
                  const SizedBox(height: Constants.paddingL),
                  _buildLoadingText(context, isDarkMode),
                ],

                const Spacer(flex: 3),

                // Bottom section with version
                _buildBottomSection(context, isDarkMode),
              ],
            )),
          ),
        ),
      ),
    );
  }

  // Background decoration with gradient
  BoxDecoration _buildBackgroundDecoration(bool isDarkMode) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode ? [
          const Color(0xFF0D1117), // Dark background start
          const Color(0xFF161B22), // Dark background end
          const Color(0xFF1976D2).withValues(alpha: 0.1), // Primary color hint
        ] : [
          const Color(0xFFE3F2FD), // Light blue start
          const Color(0xFFFFFFFF), // White
          const Color(0xFFF5F5F5), // Light grey
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
    );
  }

  // Animated logo with pulsing glow effect
  Widget _buildAnimatedLogo(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: AnimatedContainer(
            duration: Duration(milliseconds: (1500 * value).round()),
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4 * value),
                  blurRadius: 30 * value,
                  spreadRadius: 10 * value,
                ),
                // Inner shadow for depth
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, iconValue, child) {
                  return Transform.rotate(
                    angle: iconValue * 0.1, // Subtle rotation
                    child: Icon(
                      Icons.electric_bolt,
                      size: 70,
                      color: Colors.white.withValues(alpha: iconValue),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // App name with typewriter effect
  Widget _buildAppName(BuildContext context, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: isDarkMode ? [
                  Colors.white,
                  AppColors.primaryLight,
                ] : [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ).createShader(bounds),
              child: Text(
                Constants.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Will be overridden by shader
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  // Company name with slide up animation
  Widget _buildCompanyName(BuildContext context, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Constants.paddingL,
                vertical: Constants.paddingS,
              ),
              decoration: BoxDecoration(
                color: (isDarkMode ? Colors.white : AppColors.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isDarkMode ? Colors.white : AppColors.primary)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                Constants.companyName,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  // Animated loading indicator
  Widget _buildLoadingIndicator(bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        );
      },
    );
  }

  // Loading text with fade animation
  Widget _buildLoadingText(BuildContext context, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2200),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.paddingL,
              vertical: Constants.paddingS,
            ),
            decoration: BoxDecoration(
              color: (isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              controller.loadingText,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  // Bottom section with version and decorative elements
  Widget _buildBottomSection(BuildContext context, bool isDarkMode) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              // Decorative dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDarkMode ? Colors.white : AppColors.primary)
                          .withValues(alpha: 0.3 + (index * 0.2)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: Constants.paddingM),

              // Version text
              Text(
                'Версия ${Constants.appVersion}',
                style: TextStyle(
                  color: (isDarkMode ? Colors.white : Colors.black)
                      .withValues(alpha: 0.5),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: Constants.paddingL),
            ],
          ),
        );
      },
    );
  }
}