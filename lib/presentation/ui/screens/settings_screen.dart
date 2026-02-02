import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../providers/settings_scope.dart';
import '../../bloc/transactions_bloc.dart';
import '../../bloc/transactions_event.dart';
import '../../utils/dialogs.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Настройки'),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Валюта',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 8),
                _CurrencySelector(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: SwitchListTile(
              value: settings.draftNeonEnabled,
              onChanged: settings.setNeonEnabled,
              title: const Text(
                'Неоновый фон',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Подсветка и атмосферный фон',
                style: TextStyle(color: Color(0xFF8A93B2)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: SwitchListTile(
              value: settings.draftNotificationsEnabled,
              onChanged: settings.setNotificationsEnabled,
              title: const Text(
                'Уведомления',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Напоминания и важные события',
                style: TextStyle(color: Color(0xFF8A93B2)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: ListTile(
              leading: const Icon(Icons.tune, color: Color(0xFF8A93B2)),
              title: const Text(
                'Условия уведомлений',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Дневной лимит: ${settings.draftDailyLimit.toStringAsFixed(0)} ${settings.currencySymbol}',
                style: const TextStyle(color: Color(0xFF8A93B2)),
              ),
              onTap: () => context.go('/notification-rules'),
            ),
          ),
          const SizedBox(height: 12),
          const _SectionCard(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF8A93B2)),
              title: Text(
                'О приложении',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Finance Tracker • версия 0.1.0',
                style: TextStyle(color: Color(0xFF8A93B2)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: settings.hasChanges
                ? () async {
                    await settings.save();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Настройки сохранены')),
                      );
                    }
                  }
                : null,
            child: const Text('Сохранить'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await AppDialogs.confirm(
                context: context,
                title: 'Сбросить данные',
                message:
                    'Это удалит все операции. Действие нельзя отменить.',
                confirmText: 'Удалить',
                cancelText: 'Отмена',
              );
              if (confirmed == true && context.mounted) {
                context.read<TransactionsBloc>().add(const TransactionsCleared());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Данные удалены')),
                );
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Сбросить данные'),
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

class _CurrencySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    return DropdownButtonFormField<String>(
      value: settings.draftCurrencySymbol,
      items: const [
        DropdownMenuItem(value: '₽', child: Text('₽  Рубль')),
        DropdownMenuItem(value: '\$', child: Text('\$  Доллар')),
        DropdownMenuItem(value: '€', child: Text('€  Евро')),
      ],
      onChanged: (value) {
        if (value != null) {
          settings.setCurrency(value);
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        filled: true,
      ),
    );
  }
}
