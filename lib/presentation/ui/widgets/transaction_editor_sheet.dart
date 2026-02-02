import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/transactions_bloc.dart';
import '../../bloc/transactions_event.dart';
import '../../bloc/transactions_state.dart';
import '../../utils/dialogs.dart';

class TransactionEditorSheet extends StatefulWidget {
  const TransactionEditorSheet({
    super.key,
    this.existing,
    this.initialDate,
  });

  final Transaction? existing;
  final DateTime? initialDate;

  static Future<void> show({
    required BuildContext context,
    Transaction? existing,
    DateTime? initialDate,
  }) {
    return AppDialogs.showBottomSheet(
      context: context,
      builder: (_) => TransactionEditorSheet(
        existing: existing,
        initialDate: initialDate,
      ),
    );
  }

  @override
  State<TransactionEditorSheet> createState() => _TransactionEditorSheetState();
}

class _TransactionEditorSheetState extends State<TransactionEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _type;
  Category? _category;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(0),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _type = existing?.type ?? TransactionType.expense;
    _category = existing?.category;
    _date = existing?.date ?? widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding + 16,
      ),
      child: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          final categories = state.categories;
          if (categories.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Загрузка категорий...'),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.existing == null
                      ? 'Новая операция'
                      : 'Редактирование',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Расход'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Доход'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (value) {
                    setState(() => _type = value.first);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Сумма',
                    prefixText: '₽ ',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Введите сумму';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Category>(
                  value: _category ?? (categories.isNotEmpty ? categories.first : null),
                  items: categories
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.name),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value),
                  decoration: const InputDecoration(labelText: 'Категория'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Комментарий'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          '${_date.day}.${_date.month}.${_date.year}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _save(categories),
                  child: const Text('Сохранить'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await AppDialogs.pickDate(
      context: context,
      initialDate: _date,
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _save(List<Category> categories) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    if (categories.isEmpty) {
      return;
    }
    final selected = _category ?? categories.first;

    if (widget.existing == null) {
      context.read<TransactionsBloc>().add(
            TransactionAdded(
              TransactionDraft(
                amount: amount,
                type: _type,
                category: selected,
                note: _noteController.text,
                date: _date,
              ),
            ),
          );
    } else {
      context.read<TransactionsBloc>().add(
            TransactionUpdated(
              Transaction(
                id: widget.existing!.id,
                amount: amount,
                type: _type,
                category: selected,
                note: _noteController.text,
                date: _date,
              ),
            ),
          );
    }

    Navigator.of(context).pop();
  }
}
