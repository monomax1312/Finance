import '../models/category_dto.dart';
import '../models/transaction_dto.dart';

abstract class FinanceApi {
  Future<List<CategoryDto>> fetchCategories();
  Future<List<TransactionDto>> fetchTransactions();
  Future<TransactionDto> createTransaction(TransactionDto draft);
  Future<TransactionDto> updateTransaction(TransactionDto transaction);
  Future<void> deleteTransaction(String id);
  Future<void> clearTransactions();
}
