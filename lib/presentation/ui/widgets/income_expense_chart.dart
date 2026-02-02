import 'package:flutter/material.dart';

import 'neon_card.dart';

class IncomeExpenseChart extends StatefulWidget {
  const IncomeExpenseChart({
    super.key,
    required this.series,
    this.initialIndex = 1,
  });

  final List<ChartSeries> series;
  final int initialIndex;

  @override
  State<IncomeExpenseChart> createState() => _IncomeExpenseChartState();
}

class _IncomeExpenseChartState extends State<IncomeExpenseChart> {
  late int _selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final current = widget.series[_selectedIndex];

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Статистика',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              _SegmentedTab(
                labels: const ['День', 'Неделя', 'Месяц'],
                selectedIndex: _selectedIndex,
                onSelected: (value) {
                  setState(() => _selectedIndex = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 620),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) {
                return CustomPaint(
                  painter: _LineChartPainter(
                    income: current.income,
                    expense: current.expense,
                    gridColor: const Color(0xFF2A3352),
                    progress: progress,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: current.labels
                .map((label) => Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF8A93B2),
                          ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class ChartSeries {
  const ChartSeries({
    required this.income,
    required this.expense,
    required this.labels,
  });

  final List<double> income;
  final List<double> expense;
  final List<String> labels;
}

class _SegmentedTab extends StatelessWidget {
  const _SegmentedTab({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2A3352) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                labels[index],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF8A93B2),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.income,
    required this.expense,
    required this.gridColor,
    required this.progress,
  });

  final List<double> income;
  final List<double> expense;
  final Color gridColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final maxIncome = income.isEmpty
        ? 0.0
        : income.reduce((a, b) => a > b ? a : b);
    final maxExpense = expense.isEmpty
        ? 0.0
        : expense.reduce((a, b) => a > b ? a : b);
    final maxValue = maxIncome > maxExpense ? maxIncome : maxExpense;
    final strokePaintIncome = Paint()
      ..color = const Color(0xFF8EF3B5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final strokePaintExpense = Paint()
      ..color = const Color(0xFFFF8B8B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final glowIncome = Paint()
      ..color = const Color(0xFF8EF3B5).withValues(alpha:0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    final glowExpense = Paint()
      ..color = const Color(0xFFFF8B8B).withValues(alpha:0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 3; i++) {
      final dy = size.height * (i + 1) / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    _drawLine(
      canvas,
      size,
      income,
      maxValue,
      glowIncome,
      strokePaintIncome,
      const Color(0xFF8EF3B5),
    );
    _drawLine(
      canvas,
      size,
      expense,
      maxValue,
      glowExpense,
      strokePaintExpense,
      const Color(0xFFFF8B8B),
    );
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> values,
    double maxValue,
    Paint glowPaint,
    Paint strokePaint,
    Color dotColor,
  ) {
    if (values.isEmpty) {
      return;
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : i / (values.length - 1) * size.width;
      final y = maxValue == 0
          ? size.height
          : size.height -
              ((values[i] * progress) / maxValue) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = dotColor);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.income != income ||
        oldDelegate.expense != expense ||
        oldDelegate.progress != progress;
  }
}
