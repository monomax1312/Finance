import '../entities/month_summary.dart';
import '../entities/transaction.dart';

class GetMonthSummary {
  const GetMonthSummary();

  MonthSummary call(List<Transaction> transactions, DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);

    var income = 0.0;
    var expense = 0.0;

    for (final item in transactions) {
      if (item.date.isBefore(start) || !item.date.isBefore(end)) {
        continue;
      }
      if (item.type == TransactionType.income) {
        income += item.amount;
      } else {
        expense += item.amount;
      }
    }

    return MonthSummary(income: income, expense: expense);
  }
}
