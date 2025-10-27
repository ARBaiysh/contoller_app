import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/subscriber_model.dart';
import '../../../widgets/phone_edit_dialog.dart';
import '../controllers/subscriber_detail_controller.dart';

class SubscriberInfoCard extends StatelessWidget {
  const SubscriberInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriberDetailController>();

    return Obx(() {
      final subscriber = controller.subscriber;
      if (subscriber == null) return const SizedBox.shrink();

      // ОТЛАДКА: Выводим информацию о телефоне
      print('═══════════════════════════════════════');
      print('DEBUG SubscriberInfoCard:');
      print('Phone value: "${subscriber.phone}"');
      print('Phone is null: ${subscriber.phone == null}');
      print('Phone isEmpty: ${subscriber.phone?.isEmpty ?? "null"}');
      print('Phone trimmed: "${subscriber.phone?.trim()}"');
      print('Phone length: ${subscriber.phone?.length ?? 0}');
      print('hasValidPhone: ${_hasValidPhone(subscriber)}');
      print('═══════════════════════════════════════');

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

            // Телефон с кнопкой редактирования
            _PhoneRow(
              subscriber: subscriber,
              hasValidPhone: _hasValidPhone(subscriber),
            ),

            _InfoRow(label: 'Тариф', value: subscriber.tariffName),

            // Последняя синхронизация
            if (subscriber.lastSync != null)
              _InfoRow(
                label: 'Последняя синхронизация',
                value: subscriber.formattedLastSync,
              ),

            // КНОПКИ ДЕЙСТВИЙ (ТОЛЬКО если есть валидный телефон)
            if (_hasValidPhone(subscriber)) ...[
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

  // Проверка наличия валидного телефона
  bool _hasValidPhone(SubscriberModel subscriber) {
    // Проверка 1: null
    if (subscriber.phone == null) {
      print('  ❌ Phone is NULL');
      return false;
    }

    // Проверка 2: пустая строка
    if (subscriber.phone!.isEmpty) {
      print('  ❌ Phone is EMPTY string');
      return false;
    }

    // Проверка 3: только пробелы
    if (subscriber.phone!.trim().isEmpty) {
      print('  ❌ Phone is only WHITESPACE');
      return false;
    }

    // Проверка 4: строка "null"
    if (subscriber.phone!.toLowerCase() == 'null') {
      print('  ❌ Phone is string "null"');
      return false;
    }

    // Проверка 5: минимальная длина (хотя бы 9 цифр)
    String digitsOnly = subscriber.phone!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (digitsOnly.length < 9) {
      print('  ❌ Phone too short (only $digitsOnly.length digits)');
      return false;
    }

    print('  ✅ Phone is VALID');
    return true;
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

// Строка с телефоном и кнопкой редактирования
class _PhoneRow extends StatelessWidget {
  final SubscriberModel subscriber;
  final bool hasValidPhone;

  const _PhoneRow({
    required this.subscriber,
    required this.hasValidPhone,
  });

  void _showPhoneEditDialog() {
    final controller = Get.find<SubscriberDetailController>();

    Get.dialog(
      PhoneEditDialog(
        currentPhone: subscriber.phone,
        accountNumber: subscriber.accountNumber,
        onSave: (phoneNumber) async {
          await controller.addOrUpdatePhone(phoneNumber);
        },
        onDelete: hasValidPhone
            ? () async {
                await controller.deletePhone();
              }
            : null,
      ),
    );
  }

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
              'Телефон',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hasValidPhone
                  ? (subscriber.formattedPhone ?? subscriber.phone!)
                  : 'Не указан',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: hasValidPhone ? null : Colors.grey,
              ),
            ),
          ),
          // Кнопка редактирования
          InkWell(
            onTap: _showPhoneEditDialog,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                hasValidPhone ? Icons.edit_outlined : Icons.add_circle_outline,
                size: 18,
                color: AppColors.primary,
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

    // WhatsApp использует формат без + и пробелов
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
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

    final message = _getDebtMessage();
    final Uri smsUri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Не удалось отправить SMS');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    }
  }

  String _getDebtMessage() {
    final balance = subscriber.balance > 0
        ? '+${subscriber.balance.toStringAsFixed(2)}'
        : subscriber.balance.toStringAsFixed(2);

    return '''
Уважаемый абонент!

Лицевой счет: ${subscriber.accountNumber}
Адрес: ${subscriber.address}
Тариф: ${subscriber.tariffName}

Счет на текущий момент: $balance сом.

${subscriber.lastReading != null ? 'Последнее показание: ${subscriber.lastReading}' : ''}

${subscriber.balance > 0 ? 'Просим своевременно погасить задолженность.' : ''}

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
          label: 'Позвонить',
          color: AppColors.success,
          onTap: _makePhoneCall,
        ),

        const SizedBox(width: Constants.paddingS),

        // Кнопка WhatsApp
        _ActionButton(
          label: 'WhatsApp',
          color: const Color(0xFF25D366),
          onTap: _openWhatsApp,
        ),

        const SizedBox(width: Constants.paddingS),

        // Кнопка отправки уведомления
        _ActionButton(
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
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}