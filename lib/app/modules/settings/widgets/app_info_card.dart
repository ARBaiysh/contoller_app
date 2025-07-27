import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class AppInfoCard extends StatelessWidget {
  final SettingsController controller;

  const AppInfoCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context).copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.primary.withValues(alpha: 0.05)
            : AppColors.primary.withValues(alpha: 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'Информация о приложении',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          // App info items
          _buildInfoRow(
            context: context,
            label: 'Версия приложения',
            value: Constants.appVersion,
          ),
          _buildInfoRow(
            context: context,
            label: 'Компания',
            value: Constants.companyName,
          ),
          _buildInfoRow(
            context: context,
            label: 'Размер кэша',
            value: controller.cacheFormattedSize,
          ),
          _buildInfoRow(
            context: context,
            label: 'Последнее обновление',
            value: DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
          ),

          const SizedBox(height: Constants.paddingM),

          // Status indicators
          Row(
            children: [
              _buildStatusChip(
                context: context,
                label: 'Уведомления',
                isActive: controller.notificationsEnabled,
              ),
              const SizedBox(width: Constants.paddingS),
              _buildStatusChip(
                context: context,
                label: 'Автосинхронизация',
                isActive: controller.autoSyncEnabled,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required BuildContext context,
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Constants.paddingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Constants.paddingXS),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.success : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}