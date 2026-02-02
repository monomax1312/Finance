import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/get_month_summary.dart';
import '../../bloc/transactions_bloc.dart';
import '../../bloc/transactions_event.dart';
import '../../bloc/transactions_state.dart';
import '../../providers/filters_scope.dart';
import '../widgets/income_expense_chart.dart';
import '../widgets/app_drawer.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = FiltersScope.of(context);
    const summaryUseCase = GetMonthSummary();

    return ListenableBuilder(
      listenable: filters,
      builder: (context, _) {
        final month = filters.selectedMonth;
        final formatter = DateFormat('LLLL yyyy', 'ru');
        final title = formatter.format(month);

        return Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            ),
            title: Text('Баланс • $title'),
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
                final recent = monthTransactions.take(5).toList();
              final series = _buildSeries(state.transactions);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _MonthHeader(
                      title: title,
                      onPrev: () => filters.setMonth(
                        DateTime(month.year, month.month - 1),
                      ),
                      onNext: () => filters.setMonth(
                        DateTime(month.year, month.month + 1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SummaryCard(summary: summary),
                    const SizedBox(height: 16),
                    IncomeExpenseChart(series: series),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Недавние операции',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              context.read<TransactionsBloc>().add(
                                    const TransactionsRequested(),
                                  ),
                          child: const Text('Обновить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...recent.map((item) => TransactionTile(transaction: item)),
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

  List<ChartSeries> _buildSeries(List<Transaction> items) {
    return [
      _buildDaySeries(items),
      _buildWeekSeries(items),
      _buildMonthSeries(items),
    ];
  }

  ChartSeries _buildDaySeries(List<Transaction> items) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 24));
    final labels = <String>[];
    for (var i = 0; i < 6; i++) {
      final hour = (start.hour + i * 4) % 24;
      labels.add(hour.toString().padLeft(2, '0'));
    }

    final income = List<double>.filled(6, 0);
    final expense = List<double>.filled(6, 0);
    for (final item in items) {
      if (item.date.isBefore(start) || item.date.isAfter(now)) {
        continue;
      }
      final diffHours = item.date.difference(start).inHours;
      final index = diffHours ~/ 4;
      if (index < 0 || index >= 6) {
        continue;
      }
      if (item.type == TransactionType.income) {
        income[index] += item.amount;
      } else {
        expense[index] += item.amount;
      }
    }

    return ChartSeries(income: income, expense: expense, labels: labels);
  }

  ChartSeries _buildWeekSeries(List<Transaction> items) {
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DateTime(date.year, date.month, date.day);
    });

    final income = List<double>.filled(7, 0);
    final expense = List<double>.filled(7, 0);
    for (final item in items) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      final index = days.indexWhere((day) => day == date);
      if (index != -1) {
        if (item.type == TransactionType.income) {
          income[index] += item.amount;
        } else {
          expense[index] += item.amount;
        }
      }
    }

    final labels = days
        .map((date) => date.day.toString().padLeft(2, '0'))
        .toList();

    return ChartSeries(income: income, expense: expense, labels: labels);
  }

  ChartSeries _buildMonthSeries(List<Transaction> items) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final labels = <String>[];
    const buckets = 6;
    for (var i = 0; i < buckets; i++) {
      final date = start.add(Duration(days: i * 5));
      labels.add(date.day.toString().padLeft(2, '0'));
    }

    final income = List<double>.filled(buckets, 0);
    final expense = List<double>.filled(buckets, 0);
    for (final item in items) {
      if (item.date.isBefore(start) || item.date.isAfter(now)) {
        continue;
      }
      final diffDays = item.date.difference(start).inDays;
      final index = diffDays ~/ 5;
      if (index < 0 || index >= buckets) {
        continue;
      }
      if (item.type == TransactionType.income) {
        income[index] += item.amount;
      } else {
        expense[index] += item.amount;
      }
    }

    return ChartSeries(income: income, expense: expense, labels: labels);
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.title,
    required this.onPrev,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
