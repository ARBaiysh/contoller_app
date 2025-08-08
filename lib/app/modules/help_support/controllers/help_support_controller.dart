import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class HelpSupportController extends GetxController {
  final supportEmail = 'support@example.com'.obs;        // TODO: replace
  final supportChatHint = 'Telegram: @your_support_bot'.obs; // TODO: replace
  final deviceInfoShort = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _buildDeviceInfo();
  }

  Future<void> _buildDeviceInfo() async {
    final platform = Platform.operatingSystem;
    final osVersion = Platform.operatingSystemVersion;
    deviceInfoShort.value = '$platform • $osVersion';
  }

  Future<void> copyDeviceInfo() async {
    final data = 'Device: ${deviceInfoShort.value}';
    await Clipboard.setData(ClipboardData(text: data));
    Get.snackbar('Скопировано', 'Информация об устройстве в буфере обмена');
  }

  Future<void> sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail.value,
      queryParameters: {
        'subject': 'Support',
        'body': 'Опишите проблему:\n\nУстройство: ${deviceInfoShort.value}\n',
      },
    );
    await _launch(uri.toString());
  }

  Future<void> openChat() async {
    final uri = Uri.parse('https://t.me/your_support_bot'); // TODO: replace
    await _launch(uri.toString());
  }

  Future<void> sendBugReport() async {
    final mail = Uri(
      scheme: 'mailto',
      path: supportEmail.value,
      queryParameters: {
        'subject': 'Bug report',
        'body': 'Шаги воспроизведения:\n1)\n2)\n3)\n\nОжидаемо:\nФактически:\n\n'
            'Устройство: ${deviceInfoShort.value}\n',
      },
    );
    await _launch(mail.toString());
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('Ошибка', 'Не удалось открыть: $url');
    }
  }
}
