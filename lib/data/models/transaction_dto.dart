class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.note,
    required this.date,
  });

  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final String categoryName;
  final int categoryColor;
  final String note;
  final DateTime date;

  TransactionDto copyWith({
    String? id,
    double? amount,
    String? type,
    String? categoryId,
    String? categoryName,
    int? categoryColor,
    String? note,
    DateTime? date,
  }) {
    return TransactionDto(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }
}
