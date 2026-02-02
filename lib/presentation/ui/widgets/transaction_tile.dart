import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/transaction.dart';
import '../../providers/settings_scope.dart';
import '../../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? Colors.green : Colors.red;
    final date = DateFormat('dd MMM', 'ru').format(transaction.date);
    final currency = SettingsScope.of(context).currencySymbol;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B223C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3352)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha:0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(transaction.category.color),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.category.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.note} • $date',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF8A93B2),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix ${formatCurrency(transaction.amount, currency)}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFF8A93B2),
                  iconSize: 18,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
