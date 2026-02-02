import 'package:flutter/material.dart';

class FiltersNotifier extends ChangeNotifier {
  FiltersNotifier() : _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime _selectedMonth;
  DateTimeRange? _range;

  DateTime get selectedMonth => _selectedMonth;
  DateTimeRange? get range => _range;

  void setMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void setRange(DateTimeRange? range) {
    _range = range;
    notifyListeners();
  }
}
