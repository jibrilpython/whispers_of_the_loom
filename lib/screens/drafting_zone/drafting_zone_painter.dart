import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/screens/drafting_zone/drafting_zone_physics.dart';

/// Atmospheric background painter — a dark gallery room with warm amber
/// lighting, floating dust motes, and a subtle wood floor glow.
class BackgroundPainter extends CustomPainter {
  final double time;
  final Size canvasSize;

  BackgroundPainter({required this.time, required this.canvasSize});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base darkness
    canvas.drawRect(rect, Paint()..color = kHearthDark);

    // Warm ambient glow from below (table/candle light)
    final warmGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment(0, 1.1),
        radius: 0.8,
        colors: [
          kSpindleAmber.withAlpha(22),
          kSpindleAmber.withAlpha(6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, warmGlow);

    // Cool ambient from above (moonlight)
    final coolGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment(0, -0.5),
        radius: 1.6,
        colors: [
          kDressedFlaxBlue.withAlpha(5),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, coolGlow);

    // Vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.transparent,
          kHearthDark.withAlpha(160),
        ],
        stops: const [0.4, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);

    // Floating dust motes
    for (int i = 0; i < 30; i++) {
      final seed = i * 7 + 3;
      final fx = ((seed * 13 + 7) % 100) / 100;
      final fy = ((seed * 11 + 5) % 90) / 100;
      final x = fx * size.width;
      final y = fy * size.height;

      final driftX = math.sin(time * 0.3 + seed * 1.7) * 6;
      final driftY = math.sin(time * 0.4 + seed * 2.3) * 4;
      final fade = 0.3 + 0.7 * math.sin(time * 0.5 + seed * 3.1).abs();

      canvas.drawCircle(
        Offset(x + driftX, y + driftY),
        0.4 + 0.8 * fade,
        Paint()..color = kRawWoolCream.withAlpha((3 + 6 * fade).round()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter old) => old.time != time;
}
