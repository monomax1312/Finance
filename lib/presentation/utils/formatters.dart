import 'package:intl/intl.dart';

String formatCurrency(double value, String symbol) {
  final formatted = NumberFormat.decimalPattern('ru').format(value.round());
  return '$formatted $symbol';
}
