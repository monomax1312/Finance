import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/settings_scope.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        leading: IconButton(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              context.go('/dashboard');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            child: Row(
              children: [
                Icon(
                  settings.notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: settings.notificationsEnabled
                      ? const Color(0xFF8EF3B5)
                      : const Color(0xFF8A93B2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    settings.notificationsEnabled
                        ? 'Уведомления включены'
                        : 'Уведомления выключены',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (settings.notificationsEnabled)
            _SectionCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF6C63FF),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Отправить тестовое уведомление',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await settings.sendTestNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Тестовое уведомление отправлено'),
                          ),
                        );
                      }
                    },
                    child: const Text('Отправить'),
                  ),
                ],
              ),
            ),
          if (settings.notificationsEnabled) const SizedBox(height: 12),
          if (settings.notificationsEnabled)
            ..._mockNotifications().map(
              (item) => _SectionCard(
                child: ListTile(
                  leading: const Icon(
                    Icons.bolt,
                    color: Color(0xFF6C63FF),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    item.subtitle,
                    style: const TextStyle(color: Color(0xFF8A93B2)),
                  ),
                ),
              ),
            ),
          if (!settings.notificationsEnabled)
            const _SectionCard(
              child: Text(
                'Включите уведомления в настройках, чтобы видеть события.',
                style: TextStyle(color: Color(0xFF8A93B2)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B223C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3352)),
      ),
      child: child,
    );
  }
}

class _NotificationItem {
  const _NotificationItem({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

List<_NotificationItem> _mockNotifications() {
  return const [
    _NotificationItem(
      title: 'Дневной лимит расходов',
      subtitle: 'Вы потратили 82% лимита за сегодня',
    ),
    _NotificationItem(
      title: 'Низкий баланс',
      subtitle: 'Рекомендуем пересмотреть расходы',
    ),
  ];
}
