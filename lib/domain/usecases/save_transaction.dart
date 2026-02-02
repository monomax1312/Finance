import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class SaveTransaction {
  const SaveTransaction(this.repository);

  final TransactionsRepository repository;

  Future<Transaction> add(TransactionDraft draft) {
    return repository.addTransaction(draft);
  }

  Future<Transaction> update(Transaction transaction) {
    return repository.updateTransaction(transaction);
  }
}
