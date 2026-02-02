import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_dto.dart';

class TransactionsStorage {
  TransactionsStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _transactionsKey = 'transactions';

  Future<List<TransactionDto>> loadTransactions() async {
    final raw = _prefs.getString(_transactionsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => TransactionDto(
              id: item['id'] as String,
              amount: (item['amount'] as num).toDouble(),
              type: item['type'] as String,
              categoryId: item['categoryId'] as String,
              categoryName: item['categoryName'] as String,
              categoryColor: item['categoryColor'] as int,
              note: item['note'] as String,
              date: DateTime.parse(item['date'] as String),
            ))
        .toList(growable: false);
  }

  Future<void> saveTransactions(List<TransactionDto> items) async {
    final encoded = jsonEncode(
      items
          .map((item) => {
                'id': item.id,
                'amount': item.amount,
                'type': item.type,
                'categoryId': item.categoryId,
                'categoryName': item.categoryName,
                'categoryColor': item.categoryColor,
                'note': item.note,
                'date': item.date.toIso8601String(),
              })
          .toList(growable: false),
    );
    await _prefs.setString(_transactionsKey, encoded);
  }

  Future<void> clear() async {
    await _prefs.remove(_transactionsKey);
  }
}
