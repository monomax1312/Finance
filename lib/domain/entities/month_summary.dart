class MonthSummary {
  const MonthSummary({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get balance => income - expense;
}
