import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Finance Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.dashboard,
              label: 'Главная',
              onTap: () => context.go('/dashboard'),
            ),
            _DrawerItem(
              icon: Icons.list_alt,
              label: 'Операции',
              onTap: () => context.go('/transactions'),
            ),
            _DrawerItem(
              icon: Icons.analytics,
              label: 'Статистика',
              onTap: () => context.go('/stats'),
            ),
            _DrawerItem(
              icon: Icons.notifications_none,
              label: 'Уведомления',
              onTap: () => context.go('/notifications'),
            ),
            _DrawerItem(
              icon: Icons.settings,
              label: 'Настройки',
              onTap: () => context.go('/settings'),
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Версия 0.1.0',
                style: TextStyle(color: Color(0xFF8A93B2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.pop();
        onTap();
      },
      leading: Icon(icon, color: const Color(0xFF8A93B2)),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
