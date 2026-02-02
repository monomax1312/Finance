
import 'package:flutter/material.dart';

class NeonBackground extends StatelessWidget {
  const NeonBackground({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }
    return Stack(
      children: [
        const _BaseGradient(),
        const _NeonGlowLayer(),
        child,
      ],
    );
  }
}

class _BaseGradient extends StatelessWidget {
  const _BaseGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0F1F), Color(0xFF1A2140)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _NeonGlowLayer extends StatefulWidget {
  const _NeonGlowLayer();

  @override
  State<_NeonGlowLayer> createState() => _NeonGlowLayerState();
}

class _NeonGlowLayerState extends State<_NeonGlowLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = 0.9 + (_controller.value * 0.15);
          return Opacity(
            opacity: 0.85,
            child: CustomPaint(
              painter: _GlowPainter(pulse: value),
              size: Size.infinite,
            ),
          );
        },
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF5AC8FA),
      const Color(0xFFFF5FD2),
    ];

    final centers = [
      Offset(size.width * 0.2, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.35),
      Offset(size.width * 0.15, size.height * 0.75),
    ];

    for (var i = 0; i < centers.length; i++) {
      final radius = size.shortestSide * (0.36 + i * 0.06) * pulse;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i].withValues(alpha:0.45),
            colors[i].withValues(alpha:0.05),
            colors[i].withValues(alpha:0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: centers[i], radius: radius))
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(centers[i], radius, paint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF141A2E).withValues(alpha:0.0),
          const Color(0xFF141A2E).withValues(alpha:0.7),
        ],
        stops: const [0.55, 1],
      ).createShader(Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.shortestSide * 0.7,
      ));
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return (oldDelegate.pulse - pulse).abs() > 0.01;
  }
}
