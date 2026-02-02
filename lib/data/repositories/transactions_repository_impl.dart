import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../api/finance_api.dart';
import '../models/category_dto.dart';
import '../models/transaction_dto.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl({required this.api});

  final FinanceApi api;

  @override
  Future<List<Category>> getCategories() async {
    final dtos = await api.fetchCategories();
    return dtos.map(_mapCategory).toList(growable: false);
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    final dtos = await api.fetchTransactions();
    return dtos.map(_mapTransaction).toList(growable: false);
  }

  @override
  Future<Transaction> addTransaction(TransactionDraft draft) async {
    final dto = TransactionDto(
      id: 'draft',
      amount: draft.amount,
      type: _mapTypeToString(draft.type),
      categoryId: draft.category.id,
      categoryName: draft.category.name,
      categoryColor: draft.category.color,
      note: draft.note,
      date: draft.date,
    );
    final created = await api.createTransaction(dto);
    return _mapTransaction(created);
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final dto = TransactionDto(
      id: transaction.id,
      amount: transaction.amount,
      type: _mapTypeToString(transaction.type),
      categoryId: transaction.category.id,
      categoryName: transaction.category.name,
      categoryColor: transaction.category.color,
      note: transaction.note,
      date: transaction.date,
    );
    final updated = await api.updateTransaction(dto);
    return _mapTransaction(updated);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await api.deleteTransaction(id);
  }

  @override
  Future<void> clearTransactions() async {
    await api.clearTransactions();
  }

  Category _mapCategory(CategoryDto dto) {
    return Category(id: dto.id, name: dto.name, color: dto.color);
  }

  Transaction _mapTransaction(TransactionDto dto) {
    return Transaction(
      id: dto.id,
      amount: dto.amount,
      type: _mapType(dto.type),
      category: Category(
        id: dto.categoryId,
        name: dto.categoryName,
        color: dto.categoryColor,
      ),
      note: dto.note,
      date: dto.date,
    );
  }

  TransactionType _mapType(String type) {
    return type == 'income' ? TransactionType.income : TransactionType.expense;
  }

  String _mapTypeToString(TransactionType type) {
    return type == TransactionType.income ? 'income' : 'expense';
  }
}
