import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<HomeController>(
      init: Get.find<HomeController>(),
      builder: (controller) {
        return Obx(() {
          final dashboard = controller.dashboard;
          if (dashboard == null) return const SizedBox.shrink();

          // Показываем карточку только если есть информация о синхронизации
          final showCard = controller.isFullSyncInProgress.value ||
              controller.dashboard.value?.lastFullSyncCompleted != null;

          if (!showCard) return const SizedBox.shrink();

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Constants.paddingL),
            margin: const EdgeInsets.only(top: Constants.paddingM),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(Constants.borderRadius),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Row(
                  children: [
                    Text(
                      'ПОЛНАЯ СИНХРОНИЗАЦИЯ',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    if (controller.isFullSyncInProgress.value)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.paddingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'В процессе',
                              style: TextStyle(
                                color: AppColors.info,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: Constants.paddingM),

                // Информация о статусе
                if (controller.isFullSyncInProgress.value && controller.dashboard.value.fullSyncStartedAt != null) ...[
                  _buildStatusRow(
                    context: context,
                    icon: Icons.play_circle_outline,
                    label: 'Начата:',
                    value: _formatDateTime(controller.dashboard.value.fullSyncStartedAt!),
                    color: AppColors.info,
                  ),
                ] else if (controller.dashboard.value.lastFullSyncCompleted != null) ...[
                  _buildStatusRow(
                    context: context,
                    icon: Icons.check_circle_outline,
                    label: 'Завершена:',
                    value: _formatDateTime(controller.dashboard.value.lastFullSyncCompleted!),
                    color: AppColors.success,
                  ),
                ],

                const SizedBox(height: Constants.paddingL),

                // Кнопка синхронизации
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.canStartSync.value
                        ? controller.startFullSync
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isFullSyncInProgress.value
                          ? theme.disabledColor
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Constants.borderRadius),
                      ),
                      disabledBackgroundColor: theme.cardColor,
                      disabledForegroundColor: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                    child: controller.isFullSyncInProgress.value
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: Constants.paddingS),
                        Text(
                          'Идет синхронизация...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                        : Text(
                      controller.syncButtonText.value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ),

                // Информация о задержке
                Obx(() {
                  if (!controller.canStartSync.value &&
                      controller.minutesUntilSyncAvailable.value > 0 &&
                      !controller.isFullSyncInProgress.value) {
                    return Column(
                      children: [
                        const SizedBox(height: Constants.paddingS),
                        Text(
                          'Повторная синхронизация возможна не ранее, чем через ${Constants.fullSyncCooldown.inMinutes} минут после завершения предыдущей',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildStatusRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: Constants.paddingS),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: Constants.paddingXS),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(dateTime);
  }
}