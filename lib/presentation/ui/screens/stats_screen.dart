import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/month_summary.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/get_month_summary.dart';
import '../../bloc/transactions_bloc.dart';
import '../../bloc/transactions_state.dart';
import '../../providers/filters_scope.dart';
import '../../providers/settings_scope.dart';
import '../../utils/formatters.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/month_picker.dart';
import '../widgets/app_drawer.dart';
import '../widgets/transaction_tile.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _categoryMode = 0;

  @override
  Widget build(BuildContext context) {
    final filters = FiltersScope.of(context);
    const summaryUseCase = GetMonthSummary();

    return ListenableBuilder(
      listenable: filters,
      builder: (context, _) {
        final month = filters.selectedMonth;
        final title = DateFormat('LLLL yyyy', 'ru').format(month);

        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: Text('Статистика • $title'),
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => context.go('/notifications'),
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),
          body: BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.errorMessage != null) {
                  return Center(child: Text(state.errorMessage!));
                }

                final monthTransactions =
                    _filterByMonth(state.transactions, month);
                final summary =
                    summaryUseCase.call(state.transactions, month);
                final categories = _aggregateByCategory(
                  monthTransactions,
                  _categoryMode == 0
                      ? TransactionType.expense
                      : TransactionType.income,
                );
                final chartItems = categories
                    .map(
                      (item) => CategoryBreakdownItem(
                        color: Color(item.color),
                        total: item.total,
                      ),
                    )
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    MonthPicker(
                      month: month,
                      onChanged: filters.setMonth,
                    ),
                    const SizedBox(height: 16),
                    CategoryBreakdownChart(
                      items: chartItems,
                      title: _categoryMode == 0
                          ? 'Структура расходов'
                          : 'Структура доходов',
                    ),
                    const SizedBox(height: 12),
                    _ModeSwitcher(
                      selectedIndex: _categoryMode,
                      onChanged: (value) {
                        setState(() => _categoryMode = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow(summary: summary),
                    const SizedBox(height: 16),
                    Text(
                      'Категории',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...categories.map((item) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(item.color),
                            radius: 16,
                          ),
                          title: Text(item.name),
                          trailing:
                              Text('- ${item.total.toStringAsFixed(0)} ₽'),
                        )),
                    const SizedBox(height: 16),
                    Text(
                      'Операции за месяц',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...monthTransactions
                        .take(8)
                        .map((item) => TransactionTile(transaction: item)),
                  ],
                );
              },
            ),
        );
      },
    );
  }

  List<Transaction> _filterByMonth(List<Transaction> items, DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return items
        .where((item) =>
            !item.date.isBefore(start) && item.date.isBefore(end))
        .toList();
  }

  List<_CategorySummary> _aggregateByCategory(
    List<Transaction> items,
    TransactionType type,
  ) {
    final map = <String, _CategorySummary>{};
    for (final item in items) {
      if (item.type != type) {
        continue;
      }
      map.update(
        item.category.id,
        (existing) =>
            existing.copyWith(total: existing.total + item.amount),
        ifAbsent: () => _CategorySummary(
          id: item.category.id,
          name: item.category.name,
          color: item.category.color,
          total: item.amount,
        ),
      );
    }
    return map.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3352)),
      ),
      child: Row(
        children: [
          _ModeChip(
            label: 'Расходы',
            isSelected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _ModeChip(
            label: 'Доходы',
            isSelected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2A3352) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF8A93B2),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySummary {
  const _CategorySummary({
    required this.id,
    required this.name,
    required this.color,
    required this.total,
  });

  final String id;
  final String name;
  final int color;
  final double total;

  _CategorySummary copyWith({double? total}) {
    return _CategorySummary(
      id: id,
      name: name,
      color: color,
      total: total ?? this.total,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final balance = summary.balance;
    final balanceColor = balance >= 0 ? Colors.green : Colors.red;
    final currency = SettingsScope.of(context).currencySymbol;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatChip(
          label: 'Доход',
          value: summary.income,
          color: Colors.green,
          currency: currency,
        ),
        _StatChip(
          label: 'Расход',
          value: summary.expense,
          color: Colors.red,
          currency: currency,
        ),
        _StatChip(
          label: 'Баланс',
          value: balance,
          color: balanceColor,
          currency: currency,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
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
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 4),
        Text(
          formatCurrency(value, currency),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
