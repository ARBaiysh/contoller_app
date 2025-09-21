import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class QuickActionsCard extends StatelessWidget {
  final HomeController controller;

  const QuickActionsCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Padding(
          padding: const EdgeInsets.only(bottom: Constants.paddingM),
          child: Text(
            'Быстрые действия',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Карточка с действиями
        Container(
          padding: const EdgeInsets.all(Constants.paddingL),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Constants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      title: 'ТП на участке',
                      subtitle: 'Список подстанций',
                      icon: Icons.electrical_services,
                      color: AppColors.primary,
                      onTap: controller.navigateToTpList,
                    ),
                  ),
                  const SizedBox(width: Constants.paddingM),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      title: 'Поиск',
                      subtitle: 'Найти абонента',
                      icon: Icons.search,
                      color: AppColors.info,
                      onTap: controller.navigateToSearch,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Constants.paddingM),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      title: 'Отчеты',
                      subtitle: 'Создать отчет',
                      icon: Icons.description,
                      color: AppColors.success,
                      onTap: controller.navigateToReports,
                    ),
                  ),
                  const SizedBox(width: Constants.paddingM),
                  Expanded(
                    child: _buildActionButton(
                      context: context,
                      title: 'Настройки',
                      subtitle: 'Параметры',
                      icon: Icons.settings,
                      color: AppColors.warning,
                      onTap: () {
                        // Навигация к настройкам через drawer или прямую навигацию
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(Constants.paddingM),
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(Constants.borderRadius),
          ),
          child: Column(
            children: [
              // Иконка
              Container(
                padding: const EdgeInsets.all(Constants.paddingM),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Constants.borderRadius),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(height: Constants.paddingS),

              // Заголовок
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Constants.paddingXS),

              // Подзаголовок
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}