import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/settings_scope.dart';

class NotificationRulesScreen extends StatefulWidget {
  const NotificationRulesScreen({super.key});

  @override
  State<NotificationRulesScreen> createState() =>
      _NotificationRulesScreenState();
}

class _NotificationRulesScreenState extends State<NotificationRulesScreen> {
  late final TextEditingController _dailyLimitController;
  late final TextEditingController _bigExpenseController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _dailyLimitController = TextEditingController();
    _bigExpenseController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final settings = SettingsScope.of(context);
    _dailyLimitController.text =
        settings.draftDailyLimit.toStringAsFixed(0);
    _bigExpenseController.text =
        settings.draftBigExpenseLimit.toStringAsFixed(0);
    _initialized = true;
  }

  @override
  void dispose() {
    _dailyLimitController.dispose();
    _bigExpenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    final currency = settings.currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Условия уведомлений'),
        leading: IconButton(
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              context.go('/settings');
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Лимиты',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dailyLimitController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Дневной лимит расходов',
                    prefixText: '$currency ',
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      settings.setDailyLimit(parsed);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bigExpenseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Крупный расход',
                    prefixText: '$currency ',
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      settings.setBigExpenseLimit(parsed);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.draftNotifyDailyLimit,
                  onChanged: settings.setNotifyDailyLimit,
                  title: const Text(
                    'Уведомлять о дневном лимите',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SwitchListTile(
                  value: settings.draftNotifyBigExpense,
                  onChanged: settings.setNotifyBigExpense,
                  title: const Text(
                    'Уведомлять о крупном расходе',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SwitchListTile(
                  value: settings.draftNotifyNegativeBalance,
                  onChanged: settings.setNotifyNegativeBalance,
                  title: const Text(
                    'Уведомлять, если баланс < 0',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: SwitchListTile(
              value: settings.draftPushTopicEnabled,
              onChanged: settings.setPushTopicEnabled,
              title: const Text(
                'Server push (topic finance_alerts)',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Подписка на серверные пуши',
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
                        const SnackBar(content: Text('Условия сохранены')),
                      );
                    }
                  }
                : null,
            child: const Text('Сохранить'),
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
