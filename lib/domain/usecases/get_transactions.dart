import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class GetTransactions {
  const GetTransactions(this.repository);

  final TransactionsRepository repository;

  Future<List<Transaction>> call() => repository.getTransactions();
}
