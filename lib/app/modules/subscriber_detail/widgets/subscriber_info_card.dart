// lib/app/modules/subscriber_detail/widgets/subscriber_info_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/subscriber_model.dart';
import '../controllers/subscriber_detail_controller.dart';

class SubscriberInfoCard extends StatelessWidget {
  const SubscriberInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberDetailController>();

    return Obx(() {
      final subscriber = controller.subscriber;
      if (subscriber == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(Constants.paddingM),
        padding: const EdgeInsets.all(Constants.paddingM),
        decoration: Constants.getCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'Информация об абоненте',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.paddingM),

            _InfoRow(label: 'ФИО', value: subscriber.fullName),
            _InfoRow(label: 'Лицевой счет', value: subscriber.accountNumber),
            _InfoRow(label: 'Адрес', value: subscriber.address),

            // Телефон без кнопок
            if (subscriber.phone != null && subscriber.phone!.isNotEmpty)
              _InfoRow(label: 'Телефон', value: subscriber.formattedPhone ?? subscriber.phone!),

            _InfoRow(label: 'Тариф', value: subscriber.tariffName),

            // Последняя синхронизация
            if (subscriber.lastSync != null)
              _InfoRow(
                label: 'Последняя синхронизация',
                value: subscriber.fullFormattedLastSync,
              ),

            // Кнопки действий внизу (если есть телефон)
            if (subscriber.phone != null && subscriber.phone!.isNotEmpty) ...[
              const SizedBox(height: Constants.paddingM),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: Constants.paddingM),
              _PhoneActions(subscriber: subscriber),
            ],
          ],
        ),
      );
    });
  }
}

// Обычная строка информации
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Кнопки действий с телефоном
class _PhoneActions extends StatelessWidget {
  final SubscriberModel subscriber;

  const _PhoneActions({required this.subscriber});

  Future<void> _makePhoneCall() async {
    final phoneNumber = subscriber.phoneForCall;
    if (phoneNumber == null) {
      _showError('Некорректный номер телефона');
      return;
    }

    final Uri phoneUri = Uri.parse('tel:$phoneNumber');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Не удалось выполнить звонок');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  Future<void> _openWhatsApp() async {
    final phoneNumber = subscriber.phoneForCall;
    if (phoneNumber == null) {
      _showError('Некорректный номер телефона');
      return;
    }

    final cleanNumber = phoneNumber.replaceAll('+', '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showError('WhatsApp не установлен');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  Future<void> _sendDebtMessage() async {
    final phoneNumber = subscriber.phoneForCall;
    if (phoneNumber == null) {
      _showError('Некорректный номер телефона');
      return;
    }

    final message = _generateDebtMessage();
    final cleanNumber = phoneNumber.replaceAll('+', '');
    final encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber?text=$encodedMessage');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showError('WhatsApp не установлен');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  String _generateDebtMessage() {
    final balance = subscriber.balance;

    return '''
Уважаемый(ая) ${subscriber.fullName}!

Лицевой счет: ${subscriber.accountNumber}
Адрес: ${subscriber.address}
Тариф: ${subscriber.tariffName}

Счет на текущий момент: ${balance}

${subscriber.lastReading != null ? 'Последнее показание: ${subscriber.lastReading}' : ''}

${balance > 0 ? 'Просим своевременно погасить задолженность.' : ''}

С уважением,
ОАО "ОшПЭС"
''';
  }

  void _showError(String message) {
    Get.snackbar(
      'Ошибка',
      message,
      backgroundColor: Constants.error.withValues(alpha: 0.1),
      colorText: Constants.error,
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Кнопка обычного звонка
        _ActionButton(
          icon: Icons.phone,
          label: 'Позвонить',
          color: AppColors.success,
          onTap: _makePhoneCall,
        ),

        const SizedBox(width: Constants.paddingS),

        // Кнопка WhatsApp (используем chat_bubble вместо whatsapp)
        _ActionButton(
          icon: Icons.chat_bubble,
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: _openWhatsApp,
        ),

        const SizedBox(width: Constants.paddingS),

        // Кнопка отправки уведомления (ВСЕГДА показывается)
        _ActionButton(
          icon: Icons.message,
          label: 'Уведомить',
          color: AppColors.info,
          onTap: _sendDebtMessage,
        ),
      ],
    );
  }
}

// Кнопка действия
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Constants.borderRadiusMin),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constants.paddingS,
              vertical: Constants.paddingS,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}