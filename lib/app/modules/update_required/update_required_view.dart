// lib/app/modules/update_required/update_required_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/services/app_update_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/constants.dart';

class UpdateRequiredView extends StatelessWidget {
  const UpdateRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    final updateService = Get.find<AppUpdateService>();
    final versionInfo = updateService.versionInfo;

    // Проверяем, обязательное ли обновление
    final isForceUpdate = versionInfo?.forceUpdate ?? true;
    final accentColor = isForceUpdate ? AppColors.error : AppColors.info;

    return PopScope(
      canPop: !isForceUpdate, // Можно закрыть только если не forceUpdate
      child: Scaffold(
        // AppBar только если необязательное обновление
        appBar: !isForceUpdate ? AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: const Text('Доступно обновление'),
          centerTitle: true,
        ) : null,

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Constants.paddingL),
            child: Column(
              children: [
                // Spacer только если нет AppBar (forceUpdate)
                if (isForceUpdate) const Spacer(),
                if (!isForceUpdate) const SizedBox(height: Constants.paddingL),

                // Иконка предупреждения/обновления
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isForceUpdate ? Icons.system_update_alt : Icons.system_update,
                    size: 60,
                    color: accentColor,
                  ),
                ),

                const SizedBox(height: Constants.paddingXL),

                // Заголовок
                Text(
                  isForceUpdate ? 'Требуется обновление' : 'Доступно обновление',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: Constants.paddingM),

                // Сообщение
                if (versionInfo != null) ...[
                  Text(
                    versionInfo.updateMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Constants.paddingL),

                  // Информация о версиях
                  Container(
                    padding: const EdgeInsets.all(Constants.paddingM),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Constants.borderRadius),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildVersionRow(
                          context,
                          'Текущая версия',
                          updateService.currentVersion ?? '1.0.0',
                        ),
                        const SizedBox(height: Constants.paddingS),
                        _buildVersionRow(
                          context,
                          'Новая версия',
                          versionInfo.currentVersion,
                          isNew: true,
                        ),
                        const SizedBox(height: Constants.paddingS),
                        _buildVersionRow(
                          context,
                          'Размер',
                          versionInfo.formattedSize,
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Прогресс скачивания
                Obx(() {
                  if (updateService.isDownloading) {
                    return Column(
                      children: [
                        // Прогресс бар
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: updateService.downloadProgress,
                            minHeight: 8,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: Constants.paddingS),

                        // Процент и размер
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${updateService.progressPercentage}%',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              updateService.formattedProgress,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Constants.paddingL),

                        // Сообщение о скачивании
                        Text(
                          'Скачивание обновления...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: Constants.paddingL),

                // Кнопки
                Obx(() {
                  if (updateService.isDownloading) {
                    // Во время скачивания кнопки не показываем
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: [
                      // Кнопка "Обновить"
                      SizedBox(
                        width: double.infinity,
                        height: Constants.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => _downloadAndInstall(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download),
                              SizedBox(width: Constants.paddingS),
                              Text(
                                'Обновить приложение',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Кнопка "Назад" (если необязательное обновление)
                      if (!isForceUpdate) ...[
                        const SizedBox(height: Constants.paddingM),
                        SizedBox(
                          width: double.infinity,
                          height: Constants.buttonHeight,
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_back),
                                SizedBox(width: Constants.paddingS),
                                Text(
                                  'Вернуться назад',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Кнопка "Выйти" (только для обязательного обновления)
                      if (isForceUpdate) ...[
                        const SizedBox(height: Constants.paddingM),
                        SizedBox(
                          width: double.infinity,
                          height: Constants.buttonHeight,
                          child: OutlinedButton(
                            onPressed: () => _exitApp(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.exit_to_app),
                                SizedBox(width: Constants.paddingS),
                                Text(
                                  'Выйти из приложения',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),

                SizedBox(height: isForceUpdate ? Constants.paddingL : Constants.paddingM),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionRow(
      BuildContext context,
      String label,
      String value, {
        bool isNew = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isNew ? AppColors.success : null,
          ),
        ),
      ],
    );
  }

  // Скачивание и установка
  Future<void> _downloadAndInstall(BuildContext context) async {
    final updateService = Get.find<AppUpdateService>();

    try {
      // Скачиваем APK
      final apkPath = await updateService.downloadUpdate();

      if (apkPath == null) {
        throw Exception('Не удалось скачать файл обновления');
      }

      // Небольшая задержка для UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Запускаем установку
      await updateService.installApk(apkPath);

      // Показываем сообщение
      if (context.mounted) {
        Get.snackbar(
          'Обновление скачано',
          'Следуйте инструкциям для установки',
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print('[UPDATE SCREEN] Error: $e');

      if (context.mounted) {
        Get.snackbar(
          'Ошибка',
          'Не удалось скачать обновление: ${e.toString()}',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }

      // Сбрасываем состояние
      updateService.resetDownloadState();
    }
  }

  // Выход из приложения (только для forceUpdate)
  void _exitApp(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Выход из приложения'),
        content: const Text(
          'Для продолжения работы необходимо обновить приложение. '
              'Вы уверены, что хотите выйти?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // Закрываем приложение
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}