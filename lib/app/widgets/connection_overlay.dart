import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/connectivity_service.dart';
import '../core/theme/app_colors.dart';
import '../core/values/constants.dart';

/// Полноэкранный оверлей, перекрывающий любой экран при потере связи.
/// Подключается один раз через GetMaterialApp.builder.
class ConnectionOverlay extends StatelessWidget {
  const ConnectionOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = Get.find<ConnectivityService>();

    return Obx(() {
      final status = service.status.value;
      if (status == NetStatus.ok) {
        return const SizedBox.shrink();
      }

      final isServerDown = status == NetStatus.serverDown;

      // Перекрываем всё (включая текущий экран и диалоги) непрозрачным слоем.
      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Constants.paddingXL),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isServerDown ? AppColors.warning : AppColors.error)
                          .withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      isServerDown
                          ? Icons.engineering_outlined
                          : Icons.wifi_off_rounded,
                      size: 60,
                      color: isServerDown ? AppColors.warning : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: Constants.paddingXL),
                  Text(
                    isServerDown
                        ? 'Ведутся технические работы'
                        : 'Нет подключения к интернету',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Constants.paddingM),
                  Text(
                    isServerDown
                        ? 'Сервер временно недоступен. Мы уже работаем над этим — попробуйте чуть позже.'
                        : 'Проверьте подключение к Wi-Fi или мобильному интернету. Экран закроется автоматически, когда связь восстановится.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Constants.paddingXL),
                  SizedBox(
                    width: double.infinity,
                    height: Constants.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: service.retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Constants.borderRadius),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Повторить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
