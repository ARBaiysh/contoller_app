import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_support_controller.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final HelpSupportController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Помощь и поддержка'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // ===== FAQ =====
            _SectionTitle(title: 'Частые вопросы'),
            const _FaqTile(
              question: 'Не загружается список ТП',
              answer:
              'Проверьте подключение к интернету и авторизацию. '
                  'В режиме мок-данных требуется войти тестовым пользователем.',
            ),
            const _FaqTile(
              question: 'Нет доступа к абонентам',
              answer:
              'Убедитесь, что учетная запись имеет нужные права. '
                  'Перезапустите приложение после смены окружения.',
            ),
        
            const SizedBox(height: 16),
        
            // ===== CONTACTS =====
            const _SectionTitle(title: 'Связаться с поддержкой'),
            Obx(() => _ActionTile(
              icon: Icons.email,
              title: 'Написать на почту',
              subtitle: controller.supportEmail.value,
              onTap: controller.sendEmail,
            )),
            Obx(() => _ActionTile(
              icon: Icons.chat,
              title: 'Открыть чат (Telegram/WhatsApp)',
              subtitle: controller.supportChatHint.value,
              onTap: controller.openChat,
            )),
            _ActionTile(
              icon: Icons.bug_report,
              title: 'Отправить отчёт об ошибке',
              subtitle: 'С системной информацией и логами',
              onTap: controller.sendBugReport,
            ),
        
            const SizedBox(height: 16),
        
            // ===== TOOLS =====
            _SectionTitle(title: 'Инструменты'),
            Obx(() => _ActionTile(
              icon: Icons.copy,
              title: 'Скопировать информацию об устройстве',
              subtitle: controller.deviceInfoShort.value,
              onTap: controller.copyDeviceInfo,
            )),
        
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// -------------------- UI components --------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(question),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
