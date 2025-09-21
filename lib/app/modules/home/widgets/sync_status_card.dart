import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class SyncStatusCard extends StatelessWidget {
  final HomeController controller;

  const SyncStatusCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dashboard = controller.dashboard;
      if (dashboard == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Constants.paddingL),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: _getBorderColor(dashboard.fullSyncInProgress),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок секции
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(dashboard.fullSyncInProgress),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(dashboard.fullSyncInProgress),
                    color: _getIconColor(dashboard.fullSyncInProgress),
                    size: 20,
                  ),
                ),
                const SizedBox(width: Constants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Синхронизация данных',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dashboard.fullSyncStatusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusTextColor(dashboard.fullSyncInProgress),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: Constants.paddingM),

            // Время последней синхронизации
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  dashboard.fullSyncTimeText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Constants.paddingL),

            // Кнопка синхронизации
            SizedBox(
              width: double.infinity,
              child: _buildSyncButton(context, dashboard),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSyncButton(BuildContext context, dashboard) {
    final canSync = controller.canStartFullSync;
    final isStarting = controller.isFullSyncStarting;
    final inProgress = dashboard.fullSyncInProgress;

    if (inProgress) {
      // Показываем прогресс если синхронизация идет
      return Container(
        padding: const EdgeInsets.symmetric(vertical: Constants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
          border: Border.all(
            color: AppColors.info.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
              ),
            ),
            const SizedBox(width: Constants.paddingS),
            Text(
              'Синхронизация...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Обычная кнопка синхронизации
    return ElevatedButton.icon(
      onPressed: canSync && !isStarting ? controller.startFullSync : null,
      icon: isStarting
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Icon(Icons.sync),
      label: Text(isStarting ? 'Запуск...' : 'Синхронизировать все'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: Constants.paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
        ),
        elevation: 0,
      ),
    );
  }

  Color _getBorderColor(bool inProgress) {
    if (inProgress) return AppColors.info;
    return Colors.transparent;
  }

  Color _getIconBackgroundColor(bool inProgress) {
    if (inProgress) return AppColors.info.withValues(alpha: 0.1);
    return AppColors.success.withValues(alpha: 0.1);
  }

  Color _getIconColor(bool inProgress) {
    if (inProgress) return AppColors.info;
    return AppColors.success;
  }

  Color _getStatusTextColor(bool inProgress) {
    if (inProgress) return AppColors.info;
    return AppColors.success;
  }

  IconData _getStatusIcon(bool inProgress) {
    if (inProgress) return Icons.sync;
    return Icons.check_circle;
  }
}