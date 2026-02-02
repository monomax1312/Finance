import 'dart:math';

import 'package:flutter/material.dart';

import 'neon_card.dart';

class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({
    super.key,
    required this.items,
    required this.title,
  });

  final List<CategoryBreakdownItem> items;
  final String title;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.total);

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'По категориям',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _DonutPainter(items: items, total: total),
              child: Center(
                child: Text(
                  '${total.toStringAsFixed(0)} ₽',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBreakdownItem {
  const CategoryBreakdownItem({
    required this.color,
    required this.total,
  });

  final Color color;
  final double total;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.items, required this.total});

  final List<CategoryBreakdownItem> items;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.35;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (total == 0) {
      paint.color = Colors.grey.withValues(alpha:0.2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        0,
        2 * pi,
        false,
        paint,
      );
      return;
    }

    var startAngle = -pi / 2;
    for (final item in items) {
      final sweep = (item.total / total) * 2 * pi;
      paint.color = item.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.total != total;
  }
}
