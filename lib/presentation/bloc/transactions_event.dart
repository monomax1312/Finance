import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsRequested extends TransactionsEvent {
  const TransactionsRequested();
}

class TransactionAdded extends TransactionsEvent {
  const TransactionAdded(this.draft);

  final TransactionDraft draft;

  @override
  List<Object?> get props => [draft];
}

class TransactionUpdated extends TransactionsEvent {
  const TransactionUpdated(this.transaction);

  final Transaction transaction;

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionsEvent {
  const TransactionDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TransactionsCleared extends TransactionsEvent {
  const TransactionsCleared();
}
