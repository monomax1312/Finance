import '../entities/category.dart';
import '../entities/transaction.dart';

abstract class TransactionsRepository {
  Future<List<Transaction>> getTransactions();
  Future<List<Category>> getCategories();
  Future<Transaction> addTransaction(TransactionDraft draft);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<void> clearTransactions();
}
