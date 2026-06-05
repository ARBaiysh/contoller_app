import 'package:flutter/material.dart';

import '../../../core/values/constants.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // ===== APP INFO =====
            const _SectionTitle(title: 'Информация'),
            const _InfoTile(
              icon: Icons.apps,
              title: 'Название',
              subtitle: Constants.appName,
            ),
            _InfoTile(
              icon: Icons.verified,
              title: 'Версия',
              subtitle: Constants.appVersion,
            ),
            const _InfoTile(
              icon: Icons.developer_mode,
              title: 'Разработчик',
              subtitle: 'АСУ ОшПЭС',
            ),

            const SizedBox(height: 16),

            // ===== DESCRIPTION =====
            const _SectionTitle(title: 'Описание'),
            const _DescriptionCard(
              text:
              'Мобильное приложение для контролёров: работа с трансформаторными '
                  'подстанциями, абонентами и снятие показаний счётчиков. '
                  'Обеспечивает быстрый доступ к данным и инструментам обхода.',
            ),

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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

