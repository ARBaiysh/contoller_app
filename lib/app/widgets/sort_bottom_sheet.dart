import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/sort_prefs_service.dart';
import '../core/values/constants.dart';

/// Единая шторка выбора сортировки в стиле приложения.
///
/// Открывается через [SortBottomSheet.show]. Текущий выбор подсвечивается
/// primary-цветом и галочкой. Выбор сразу возвращается через [onSelected]
/// (вызывающий код решает, сохранять его постоянно или нет).
class SortBottomSheet extends StatelessWidget {
  final String title;
  final List<SortOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const SortBottomSheet({
    Key? key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  static Future<void> show({
    required String title,
    required List<SortOption> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Get.bottomSheet(
      SortBottomSheet(
        title: title,
        options: options,
        selected: selected,
        onSelected: onSelected,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(Constants.paddingS),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(Constants.borderRadius + 4),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.grey.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ручка-handle
            Container(
              margin: const EdgeInsets.only(top: Constants.paddingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Constants.paddingL,
                Constants.paddingM,
                Constants.paddingL,
                Constants.paddingS,
              ),
              child: Row(
                children: [
                  Icon(Icons.sort, size: Constants.iconSizeMedium, color: primary),
                  const SizedBox(width: Constants.paddingS),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            ...options.map((o) => _buildOption(context, o, primary)),
            const SizedBox(height: Constants.paddingS),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, SortOption option, Color primary) {
    final isSelected = option.value == selected;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onSelected(option.value);
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constants.paddingM,
            vertical: 2,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.paddingM,
              vertical: Constants.paddingM,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
              border: Border.all(
                color: isSelected
                    ? primary.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  size: Constants.iconSizeMedium,
                  color: isSelected
                      ? primary
                      : theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                ),
                const SizedBox(width: Constants.paddingM),
                Expanded(
                  child: Text(
                    option.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? primary : null,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, size: Constants.iconSizeMedium, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
