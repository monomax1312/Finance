import 'package:flutter/material.dart';

import '../../../domain/entities/month_summary.dart';
import '../../providers/settings_scope.dart';
import '../../utils/formatters.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final balance = summary.balance;
    final balanceColor = balance >= 0 ? Colors.green : Colors.red;
    final currency = SettingsScope.of(context).currencySymbol;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF202748), Color(0xFF1A203B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF2A3352)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha:0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Баланс',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF8A93B2),
                ),
          ),
          const SizedBox(height: 8),
          _AnimatedAmount(
            value: balance,
            color: balanceColor,
            currency: currency,
            textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
                _SummaryItem(
                  label: 'Доход',
                  value: summary.income,
                  color: const Color(0xFF8EF3B5),
                  currency: currency,
                ),
              const SizedBox(width: 12),
                _SummaryItem(
                  label: 'Расход',
                  value: summary.expense,
                  color: const Color(0xFFFF8B8B),
                  currency: currency,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.currency,
  });

  final String label;
  final double value;
  final Color color;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha:0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFB3BDD8),
                  ),
            ),
            const SizedBox(height: 4),
            _AnimatedAmount(
              value: value,
              color: color,
              currency: currency,
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedAmount extends StatelessWidget {
  const _AnimatedAmount({
    required this.value,
    required this.color,
    required this.textStyle,
    required this.currency,
  });

  final double value;
  final Color color;
  final TextStyle? textStyle;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(
          formatCurrency(animatedValue, currency),
          style: textStyle?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
