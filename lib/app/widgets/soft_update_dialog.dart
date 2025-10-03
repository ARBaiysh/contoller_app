// lib/app/widgets/soft_update_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/app_update_service.dart';
import '../core/theme/app_colors.dart';
import '../core/values/constants.dart';
import '../routes/app_pages.dart';

class SoftUpdateDialog {
  static void show() {
    final updateService = Get.find<AppUpdateService>();
    final versionInfo = updateService.versionInfo;

    if (versionInfo == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.system_update,
                color: AppColors.info,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Доступно обновление',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              versionInfo.updateMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Информация о версиях
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildVersionRow(
                    'Текущая версия',
                    versionInfo.minVersion,
                  ),
                  const SizedBox(height: 8),
                  _buildVersionRow(
                    'Новая версия',
                    versionInfo.currentVersion,
                    isNew: true,
                  ),
                  const SizedBox(height: 8),
                  _buildVersionRow(
                    'Размер',
                    versionInfo.formattedSize,
                  ),
                ],
              ),
            ),

            if (versionInfo.releaseNotes != null && versionInfo.releaseNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Что нового:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                versionInfo.releaseNotes!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Закрываем диалог и больше не показываем в этой сессии
              updateService.softUpdateAvailable = false;
              Get.back();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Позже',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Get.theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Переходим на экран обновления
              Get.toNamed(Routes.UPDATE_REQUIRED);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Обновить',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static Widget _buildVersionRow(String label, String value, {bool isNew = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Get.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isNew ? AppColors.success : null,
          ),
        ),
      ],
    );
  }
}