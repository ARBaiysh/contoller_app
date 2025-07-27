import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../data/models/tp_model.dart';
import '../../../data/repositories/tp_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class TpSelectorCard extends StatelessWidget {
  final ReportsController controller;

  const TpSelectorCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.electrical_services,
                color: AppColors.primary,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'Выбор ТП',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          // Description
          Text(
            'Выберите трансформаторный пункт для формирования отчета',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: Constants.paddingM),

          // TP Selector
          FutureBuilder<List<TpModel>>(
            future: Get.find<TpRepository>().getTpList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingSelector(context);
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptySelector(context);
              }

              final tps = snapshot.data!;
              return _buildTpDropdown(context, tps);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTpDropdown(BuildContext context, List<TpModel> tps) {
    return Obx(() {
      final selectedTpId = controller.selectedTpId;

      return Column(
        children: [
          // All TPs option
          _buildTpOption(
            context: context,
            tpId: '',
            title: 'Все ТП',
            subtitle: 'Отчет по всем трансформаторным пунктам',
            icon: Icons.select_all,
            isSelected: selectedTpId.isEmpty,
          ),
          const SizedBox(height: Constants.paddingS),

          // Individual TPs
          ...tps.map((tp) => Padding(
            padding: const EdgeInsets.only(bottom: Constants.paddingS),
            child: _buildTpOption(
              context: context,
              tpId: tp.id,
              title: '${tp.number} ${tp.name}',
              subtitle: tp.address,
              icon: Icons.electrical_services,
              isSelected: selectedTpId == tp.id,
              progressPercentage: tp.progressPercentage,
            ),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildTpOption({
    required BuildContext context,
    required String tpId,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    double? progressPercentage,
  }) {
    return InkWell(
      onTap: () => controller.setSelectedTp(tpId),
      borderRadius: BorderRadius.circular(Constants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(Constants.borderRadius),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(Constants.paddingS),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: Constants.paddingM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (progressPercentage != null) ...[
                    const SizedBox(height: Constants.paddingS),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progressPercentage / 100,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressPercentage == 100
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: Constants.paddingS),
                        Text(
                          '${progressPercentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Theme.of(context).dividerColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSelector(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptySelector(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Text(
          'Нет доступных ТП',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}