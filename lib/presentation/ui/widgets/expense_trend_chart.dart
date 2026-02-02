
import 'package:flutter/material.dart';

import 'neon_card.dart';

class ExpenseTrendChart extends StatelessWidget {
  const ExpenseTrendChart({
    super.key,
    required this.values,
    required this.labels,
  });

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);
    final color = Theme.of(context).colorScheme.primary;

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Динамика расходов',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Последние 7 дней',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) {
                return CustomPaint(
                  painter: _BarsPainter(
                    values: values,
                    maxValue: maxValue,
                    color: color,
                    progress: progress,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((label) => Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.maxValue,
    required this.color,
    required this.progress,
  });

  final List<double> values;
  final double maxValue;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = values.length;
    if (barCount == 0) {
      return;
    }

    final paint = Paint()
      ..color = color.withValues(alpha:0.85)
      ..style = PaintingStyle.fill;
    final background = Paint()
      ..color = color.withValues(alpha:0.08)
      ..style = PaintingStyle.fill;
    final glow = Paint()
      ..color = color.withValues(alpha:0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    const spacing = 8.0;
    final totalSpacing = spacing * (barCount - 1);
    final barWidth = (size.width - totalSpacing) / barCount;
    final maxBarHeight = size.height;

    for (var i = 0; i < barCount; i++) {
      final left = i * (barWidth + spacing);
      final value = values[i];
      final barHeight = maxValue == 0
          ? 0.0
          : (value / maxValue) * maxBarHeight * progress;
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          maxBarHeight - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(8),
      );
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, barWidth, maxBarHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(bgRect, background);
      canvas.drawRRect(barRect, glow);
      canvas.drawRRect(barRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.maxValue != maxValue;
  }
}
