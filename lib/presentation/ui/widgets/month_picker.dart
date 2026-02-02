import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPicker extends StatelessWidget {
  const MonthPicker({
    super.key,
    required this.month,
    required this.onChanged,
  });

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('LLLL yyyy', 'ru').format(month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => onChanged(
            DateTime(month.year, month.month - 1),
          ),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          onPressed: () => onChanged(
            DateTime(month.year, month.month + 1),
          ),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
