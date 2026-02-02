import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/transaction.dart';
import '../../bloc/transactions_bloc.dart';
import '../../bloc/transactions_event.dart';
import '../../bloc/transactions_state.dart';
import '../../providers/filters_scope.dart';
import '../../providers/settings_scope.dart';
import '../../utils/formatters.dart';
import '../../utils/dialogs.dart';
import '../widgets/month_picker.dart';
import '../widgets/app_drawer.dart';
import '../widgets/transaction_editor_sheet.dart';
import '../widgets/transaction_tile.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = FiltersScope.of(context);

    return ListenableBuilder(
      listenable: filters,
      builder: (context, _) {
        final month = filters.selectedMonth;
        final range = filters.range;

        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: const Text('Операции'),
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  final picked = await AppDialogs.pickDateRange(
                    context: context,
                    initialRange: range,
                  );
                  filters.setRange(picked);
                },
                icon: const Icon(Icons.filter_alt_outlined),
              ),
              if (range != null)
                IconButton(
                  onPressed: () => filters.setRange(null),
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => TransactionEditorSheet.show(
              context: context,
              initialDate: _defaultDateForMonth(filters.selectedMonth),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Операция'),
          ),
          body: BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage != null) {
                  return Center(child: Text(state.errorMessage!));
                }

                final filtered = _filter(
                  state.transactions,
                  month,
                  range,
                );
                final totals = _calculateTotals(filtered);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    MonthPicker(
                      month: month,
                      onChanged: filters.setMonth,
                    ),
                    const SizedBox(height: 12),
                    _FiltersSummary(
                      total: filtered.length,
                      range: range,
                    ),
                    const SizedBox(height: 12),
                    _TotalsRow(totals: totals),
                    const SizedBox(height: 12),
                    ...filtered.map(
                      (item) => TransactionTile(
                        transaction: item,
                        onTap: () => TransactionEditorSheet.show(
                          context: context,
                          existing: item,
                          initialDate: item.date,
                        ),
                        onDelete: () => context
                            .read<TransactionsBloc>()
                            .add(TransactionDeleted(item.id)),
                      ),
                    ),
                  ],
                );
              },
            ),
        );
      },
    );
  }

  List<Transaction> _filter(
    List<Transaction> items,
    DateTime month,
    DateTimeRange? range,
  ) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final monthFiltered = items
        .where((item) =>
            !item.date.isBefore(start) && item.date.isBefore(end))
        .toList();

    if (range == null) {
      return monthFiltered;
    }

    return monthFiltered
        .where((item) =>
            !item.date.isBefore(range.start) &&
            !item.date.isAfter(range.end))
        .toList();
  }

  _Totals _calculateTotals(List<Transaction> items) {
    var income = 0.0;
    var expense = 0.0;
    for (final item in items) {
      if (item.type == TransactionType.income) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }
    return _Totals(income: income, expense: expense);
  }

  DateTime _defaultDateForMonth(DateTime month) {
    final now = DateTime.now();
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final day = now.day > lastDay ? lastDay : now.day;
    return DateTime(month.year, month.month, day);
  }
}

class _FiltersSummary extends StatelessWidget {
  const _FiltersSummary({required this.total, required this.range});

  final int total;
  final DateTimeRange? range;

  @override
  Widget build(BuildContext context) {
    final label = range == null
        ? 'Фильтр по месяцу'
        : 'Диапазон: ${DateFormat('dd.MM').format(range!.start)} – '
            '${DateFormat('dd.MM').format(range!.end)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text('Всего: $total'),
      ],
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({required this.totals});

  final _Totals totals;

  @override
  Widget build(BuildContext context) {
    final balance = totals.income - totals.expense;
    final balanceColor = balance >= 0 ? Colors.green : Colors.red;
    final currency = SettingsScope.of(context).currencySymbol;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatPill(
          label: 'Доход',
          value: totals.income,
          color: Colors.green,
          currency: currency,
        ),
        _StatPill(
          label: 'Расход',
          value: totals.expense,
          color: Colors.red,
          currency: currency,
        ),
        _StatPill(
          label: 'Баланс',
          value: balance,
          color: balanceColor,
          currency: currency,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              formatCurrency(value, currency),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _Totals {
  const _Totals({required this.income, required this.expense});

  final double income;
  final double expense;
}
