import 'category.dart';

enum TransactionType { income, expense }

class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final Category category;
  final String note;
  final DateTime date;
}

class TransactionDraft {
  const TransactionDraft({
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.date,
  });

  final double amount;
  final TransactionType type;
  final Category category;
  final String note;
  final DateTime date;
}
