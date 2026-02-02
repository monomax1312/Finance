import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';

class TransactionsState extends Equatable {
  const TransactionsState({
    this.isLoading = false,
    this.transactions = const [],
    this.categories = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<Transaction> transactions;
  final List<Category> categories;
  final String? errorMessage;

  TransactionsState copyWith({
    bool? isLoading,
    List<Transaction>? transactions,
    List<Category>? categories,
    String? errorMessage,
  }) {
    return TransactionsState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, transactions, categories, errorMessage];
}
