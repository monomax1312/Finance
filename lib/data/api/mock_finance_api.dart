import 'finance_api.dart';
import '../local/transactions_storage.dart';
import '../models/category_dto.dart';
import '../models/transaction_dto.dart';

class MockFinanceApi implements FinanceApi {
  MockFinanceApi({required this.storage});

  final TransactionsStorage storage;
  final List<CategoryDto> _categories = [];
  final List<TransactionDto> _transactions = [];
  bool _initialized = false;

  @override
  Future<List<CategoryDto>> fetchCategories() async {
    _ensureCategories();
    return List.unmodifiable(_categories);
  }

  @override
  Future<List<TransactionDto>> fetchTransactions() async {
    await _ensureInitialized();
    return List.unmodifiable(_transactions);
  }

  @override
  Future<TransactionDto> createTransaction(TransactionDto draft) async {
    await _ensureInitialized();
    final created = draft.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
    );
    _transactions.insert(0, created);
    await storage.saveTransactions(_transactions);
    return created;
  }

  @override
  Future<TransactionDto> updateTransaction(TransactionDto transaction) async {
    await _ensureInitialized();
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
    await storage.saveTransactions(_transactions);
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _ensureInitialized();
    _transactions.removeWhere((item) => item.id == id);
    await storage.saveTransactions(_transactions);
  }

  @override
  Future<void> clearTransactions() async {
    await _ensureInitialized();
    _transactions.clear();
    await storage.clear();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _ensureCategories();
    final stored = await storage.loadTransactions();
    if (stored.isNotEmpty) {
      if (_looksLikeDemo(stored)) {
        await storage.clear();
      } else {
        _transactions.addAll(stored);
      }
    }
    _initialized = true;
  }

  void _ensureCategories() {
    if (_categories.isNotEmpty) {
      return;
    }
    _categories.addAll([
      const CategoryDto(
        id: 'food',
        name: 'Еда',
        color: 0xFFF2994A,
      ),
      const CategoryDto(
        id: 'transport',
        name: 'Транспорт',
        color: 0xFF56CCF2,
      ),
      const CategoryDto(
        id: 'salary',
        name: 'Зарплата',
        color: 0xFF27AE60,
      ),
      const CategoryDto(
        id: 'home',
        name: 'Дом',
        color: 0xFF9B51E0,
      ),
      const CategoryDto(
        id: 'fun',
        name: 'Развлечения',
        color: 0xFFEB5757,
      ),
    ]);

  }

  bool _looksLikeDemo(List<TransactionDto> items) {
    if (items.isEmpty) {
      return false;
    }
    return items.every(
      (item) =>
          item.id.startsWith('tx_') &&
          (item.note == 'Покупка' || item.note == 'Начисление'),
    );
  }
}
