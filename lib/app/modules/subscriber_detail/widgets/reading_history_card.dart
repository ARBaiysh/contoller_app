import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../controllers/subscriber_detail_controller.dart';

class ReadingHistoryCard extends StatelessWidget {
  const ReadingHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberDetailController>();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Constants.paddingM,
        vertical: Constants.paddingS,
      ),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: Constants.paddingS),
                  Text(
                    'История показаний',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              // Кнопка обновления
              Obx(() {
                if (controller.isLoadingHistory) {
                  return SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                return IconButton(
                  icon: Icon(Icons.refresh, size: 20),
                  onPressed: controller.loadReadingHistory,
                  tooltip: 'Обновить историю',
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                );
              }),
            ],
          ),
          const SizedBox(height: Constants.paddingM),
          Obx(() {
            if (controller.isLoadingHistory && controller.readingHistory.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.paddingL),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // ИСПРАВЛЕНО: Если история пуста, показываем предыдущее показание из данных абонента
            if (controller.readingHistory.isEmpty) {
              final subscriber = controller.subscriber;
              if (subscriber == null) return SizedBox.shrink();

              return _PreviousReadingCard(
                previousReading: subscriber.currentReading,
                previousReadingDate: subscriber.lastReadingDate,
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.readingHistory.length,
              separatorBuilder: (context, index) => Divider(height: Constants.paddingM),
              itemBuilder: (context, index) {
                final reading = controller.readingHistory[index];
                return _ReadingHistoryItem(reading: reading);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _ReadingHistoryItem extends StatelessWidget {
  final Map<String, dynamic> reading;

  const _ReadingHistoryItem({
    Key? key,
    required this.reading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberDetailController>();
    final subscriber = controller.subscriber;

    final status = reading['status'] as String;
    final message = reading['message'] as String? ?? '';
    final documentNumber = reading['documentNumber'] as String?;
    final currentReading = reading['currentReading'] as int?;
    final readingDate = reading['readingDate'] as String?;

    // Берем предыдущее показание из данных абонента
    final previousReading = subscriber?.currentReading;
    final previousReadingDate = subscriber?.lastReadingDate;

    // Определяем цвет и иконку статуса
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'COMPLETED':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusText = 'Успешно';
        break;
      case 'ERROR':
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        statusText = 'Ошибка';
        break;
      case 'PROCESSING':
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Обработка';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статус и номер документа
          Row(
            children: [
              Icon(
                statusIcon,
                size: 20,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                    ),
                    if (documentNumber != null)
                      Text(
                        'Документ: $documentNumber',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: statusColor.withValues(alpha: 0.8),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Информация о показаниях (всегда показываем)
          const SizedBox(height: Constants.paddingS),
          Container(
            padding: const EdgeInsets.all(Constants.paddingS),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Предыдущее показание (из данных абонента)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Предыдущее',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      previousReading != null ? '$previousReading' : '—',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),

                // Стрелка (только если есть новое показание)
                if (currentReading != null)
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
                  ),

                // Новое показание (попытка передачи)
                if (currentReading != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Новое',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currentReading',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Дата предыдущего показания (из данных абонента)
          if (previousReadingDate != null) ...[
            const SizedBox(height: Constants.paddingS),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Дата предыдущего: ${DateFormat('dd.MM.yyyy').format(previousReadingDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ],

          // Сообщение
          if (message.isNotEmpty) ...[
            const SizedBox(height: Constants.paddingS),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                  ),
              maxLines: 5,
            ),
          ],
        ],
      ),
    );
  }
}

// Карточка с предыдущим показанием (когда истории нет)
class _PreviousReadingCard extends StatelessWidget {
  final int previousReading;
  final DateTime? previousReadingDate;

  const _PreviousReadingCard({
    Key? key,
    required this.previousReading,
    this.previousReadingDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Текущее показание',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          // Показание
          Container(
            padding: const EdgeInsets.all(Constants.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Показание',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$previousReading',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Дата последнего показания
          if (previousReadingDate != null) ...[
            const SizedBox(height: Constants.paddingS),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Дата: ${DateFormat('dd.MM.yyyy').format(previousReadingDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ],

          // Информационное сообщение
          const SizedBox(height: Constants.paddingS),
          Text(
            'Попыток передачи показаний пока не было',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}
