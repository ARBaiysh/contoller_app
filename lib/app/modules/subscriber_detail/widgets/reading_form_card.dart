import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../controllers/subscriber_detail_controller.dart';

class ReadingFormCard extends StatelessWidget {
  final SubscriberDetailController controller;

  const ReadingFormCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Constants.paddingM),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context).copyWith(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: AppColors.primary,
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'Новое показание',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.paddingM),

            // Предыдущее показание
            Obx(() {
              final subscriber = controller.subscriber;
              if (subscriber == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(Constants.paddingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.05),
                      AppColors.primary.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Иконка
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.history,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: Constants.paddingS),

                    // Информация
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Предыдущее показание',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${subscriber.currentReading}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 20,
                            ),
                          ),
                          if (subscriber.lastReadingDate != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd.MM.yyyy').format(subscriber.lastReadingDate!),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: Constants.paddingM),

            // Reading input (АСКУЭ-aware): при свежем показании из АСКУЭ
            // поле предзаполнено и заблокировано для правки.
            Obx(() {
              // Идёт проверка наличия показания в АСКУЭ
              if (controller.isAskueChecking) {
                return _buildAskueChecking(context);
              }
              final locked = controller.isAskueLocked;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: controller.readingController,
                    validator: controller.validateReading,
                    readOnly: locked,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      labelText: locked
                          ? 'Показание из АСКУЭ'
                          : 'Новое показание счетчика',
                      hintText: locked ? null : 'Введите текущее показание',
                      prefixIcon:
                          Icon(locked ? Icons.cloud_done : Icons.speed),
                      suffixIcon:
                          locked ? const Icon(Icons.lock_outline) : null,
                      helperText: locked
                          ? (controller.askueLatestDate != null
                              ? 'Источник: система АСКУЭ (от ${controller.askueLatestDate})'
                              : 'Источник: система АСКУЭ')
                          : 'Введите текущее показание счетчика',
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: Constants.paddingM),

            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting
                    ? null
                    : () {
                  // Закрываем клавиатуру перед отправкой
                  FocusScope.of(context).unfocus();

                  if (controller.formKey.currentState!.validate()) {
                    controller.submitReading();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: Constants.paddingM),
                ),
                child: controller.isSubmitting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: Constants.paddingS),
                    Text(controller.submissionMessage.isNotEmpty
                        ? controller.submissionMessage
                        : 'Отправка...'),
                  ],
                )
                    : const Text(
                  'Отправить показание',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Индикатор проверки показания в системе АСКУЭ (пока грузится статус).
  Widget _buildAskueChecking(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Constants.paddingM),
          Expanded(
            child: Text(
              'Проверяем показание в системе АСКУЭ…',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}