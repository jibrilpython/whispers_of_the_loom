import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/screens/drafting_zone/drafting_zone_physics.dart';
import 'package:whispers_of_the_loom/screens/showcase/thread_field_layout.dart';
import 'package:whispers_of_the_loom/screens/showcase/thread_field_state.dart';

/// Living thread web, woven texture, central hub.
class ThreadFieldPainter extends CustomPainter {
  final double time;
  final List<Offset> nodePositions;
  final List<double> spinBoost;
  final double hubBoost;
  final List<ThreadPulse> pulses;
  final List<LaceBond> bonds;
  final int? selectedIndex;
  final int? draggingIndex;

  ThreadFieldPainter({
    required this.time,
    required this.nodePositions,
    required this.spinBoost,
    required this.hubBoost,
    required this.pulses,
    required this.bonds,
    this.selectedIndex,
    this.draggingIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (rect.width <= 0 || rect.height <= 0) return;

    _drawAtmosphere(canvas, rect);
    _drawWovenTexture(canvas, rect);
    _drawFloorPlanks(canvas, rect);

    final hub = hubCenter(size);
    _drawHub(canvas, hub);
    _drawThreads(canvas, hub, nodePositions);
    _drawLaceBridges(canvas, nodePositions);
    _drawFiberTravelers(canvas, hub, nodePositions);
    _drawPulses(canvas);
  }

  Path _threadPath(Offset hub, Offset end, int i) {
    final boost = i < spinBoost.length ? spinBoost[i] : 0.0;
    final sway = 14 + boost * 10 + hubBoost * 6;
    final mid1 = Offset.lerp(hub, end, 0.35)! +
        Offset(math.sin(time * (0.6 + boost) + i) * sway, math.cos(time * 0.5 + i) * sway * 0.7);
    final mid2 = Offset.lerp(hub, end, 0.7)! +
        Offset(math.cos(time * 0.4 + i * 1.2) * sway * 0.8, math.sin(time * 0.55 + i) * sway * 0.6);

    return Path()
      ..moveTo(hub.dx, hub.dy)
      ..cubicTo(mid1.dx, mid1.dy, mid2.dx, mid2.dy, end.dx, end.dy);
  }

  void _drawAtmosphere(Canvas canvas, Rect rect) {
    const base = Color(0xFF1E1812);
    canvas.drawRect(rect, Paint()..color = base);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2A231C),
            const Color(0xFF1A1510),
            const Color(0xFF120E0A),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0, 1.08),
          radius: 0.95,
          colors: [
            kSpindleAmber.withAlpha(70),
            kSpindleAmber.withAlpha(22),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.75],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 1.2,
          colors: [
            kDressedFlaxBlue.withAlpha(18),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.05,
          colors: [
            Colors.transparent,
            kHearthDark.withAlpha(100),
          ],
          stops: const [0.5, 1.0],
        ).createShader(rect),
    );
  }

  void _drawWovenTexture(Canvas canvas, Rect rect) {
    final warp = Paint()
      ..color = kRawWoolCream.withAlpha(10)
      ..strokeWidth = 0.6;
    final weft = Paint()
      ..color = kTeaselBrown.withAlpha(8)
      ..strokeWidth = 0.5;

    const step = 14.0;
    for (double x = 0; x < rect.width; x += step) {
      final wave = math.sin(time * 0.15 + x * 0.02) * 1.5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + wave, rect.height),
        warp,
      );
    }
    for (double y = 0; y < rect.height; y += step) {
      final wave = math.cos(time * 0.12 + y * 0.018) * 1.2;
      canvas.drawLine(
        Offset(0, y),
        Offset(rect.width, y + wave),
        weft,
      );
    }

    final rng = math.Random(17);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * rect.width;
      final y = rng.nextDouble() * rect.height;
      canvas.drawCircle(
        Offset(x, y),
        0.35 + rng.nextDouble() * 0.5,
        Paint()..color = kRawWoolCream.withAlpha(6 + rng.nextInt(10)),
      );
    }

    for (int i = 0; i < 16; i++) {
      final x = rng.nextDouble() * rect.width;
      final y = rng.nextDouble() * rect.height * 0.8;
      final drift = Offset(
        math.sin(time * 0.2 + i) * 10,
        math.cos(time * 0.17 + i * 1.4) * 8,
      );
      canvas.drawCircle(
        Offset(x, y) + drift,
        0.6 + rng.nextDouble(),
        Paint()..color = kSpindleAmber.withAlpha(12 + rng.nextInt(18)),
      );
    }
  }

  void _drawFloorPlanks(Canvas canvas, Rect rect) {
    final floorTop = rect.height * 0.78;
    final floorRect = Rect.fromLTRB(0, floorTop, rect.width, rect.height);

    canvas.drawRect(
      floorRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kTeaselBrown.withAlpha(0),
            kTeaselBrown.withAlpha(35),
            kTeaselBrown.withAlpha(55),
          ],
        ).createShader(floorRect),
    );

    final plank = Paint()
      ..color = kTeaselBrown.withAlpha(22)
      ..strokeWidth = 0.8;
    for (double x = 0; x < rect.width; x += 48) {
      canvas.drawLine(
        Offset(x, floorTop),
        Offset(x - 12, rect.height),
        plank,
      );
    }
    canvas.drawLine(
      Offset(0, floorTop),
      Offset(rect.width, floorTop),
      Paint()..color = kRawWoolCream.withAlpha(18)..strokeWidth = 1,
    );
  }

  void _drawHub(Canvas canvas, Offset c) {
    final pulse = 0.88 + 0.12 * math.sin(time * (1.2 + hubBoost * 2));
    final r = 28.0 * pulse * (1 + hubBoost * 0.08);

    canvas.drawCircle(
      c,
      r + 22,
      Paint()
        ..color = kSpindleAmber.withAlpha(25 + (hubBoost * 40).round())
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(0, 6), width: r * 2.2, height: r * 0.55),
      Paint()..color = Colors.black.withAlpha(40),
    );

    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 2, height: r * 1.55),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.95,
          colors: [
            kRawWoolCream.withAlpha(110),
            kSpindleAmber.withAlpha(180),
            kTeaselBrown.withAlpha(210),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(time * (0.25 + hubBoost * 1.8));
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.72),
      0,
      math.pi * 1.6,
      false,
      Paint()
        ..color = kBoneWhite.withAlpha(80 + (hubBoost * 60).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.drawCircle(c, r * 0.14, Paint()..color = kHearthDark);
    canvas.drawCircle(
      c + Offset(-r * 0.22, -r * 0.18),
      r * 0.1,
      Paint()..color = kBoneWhite.withAlpha(60),
    );
  }

  void _drawThreads(Canvas canvas, Offset hub, List<Offset> nodes) {
    for (int i = 0; i < nodes.length; i++) {
      final end = nodes[i];
      if ((end - hub).distance < 8) continue;

      final selected = selectedIndex == i;
      final dragging = draggingIndex == i;
      final dim = selectedIndex != null && !selected && draggingIndex != i;
      final boost = i < spinBoost.length ? spinBoost[i] : 0.0;

      final path = _threadPath(hub, end, i);

      var alpha = dim ? 28 : (selected || dragging ? 160 : 70);
      alpha = (alpha + boost * 40 + hubBoost * 20).round().clamp(20, 200);

      canvas.drawPath(
        path,
        Paint()
          ..color = kRawWoolCream.withAlpha(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected || dragging ? 1.8 : 1.1
          ..strokeCap = StrokeCap.round,
      );

      if (!selected && boost < 0.15) continue;

      final metric = path.computeMetrics().firstOrNull;
      if (metric == null) continue;
      final len = metric.length;
      if (len <= 1) continue;

      final speed = 50 + boost * 80 + hubBoost * 40;
      final phase = (time * speed) % len;
      final endPhase = math.min(phase + 20 + boost * 16, len);
      if (endPhase <= phase) continue;

      canvas.drawPath(
        metric.extractPath(phase, endPhase),
        Paint()
          ..color = kSpindleAmber.withAlpha(160 + (boost * 60).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  double _laceStrength(int i, int j) {
    final bond = _bondBetween(i, j);
    if (bond != null) {
      return (0.5 + bond.tension * 0.5).clamp(0.0, 1.0);
    }
    final dist = (nodePositions[i] - nodePositions[j]).distance;
    if (dist >= ThreadFieldState.previewDist) return 0;
    return (1 - dist / ThreadFieldState.previewDist).clamp(0.0, 1.0);
  }

  LaceBond? _bondBetween(int i, int j) {
    final id = i < j ? i * 10000 + j : j * 10000 + i;
    for (final b in bonds) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Pillow-lace crosses — brighter when closer or under tension.
  void _drawLaceBridges(Canvas canvas, List<Offset> nodes) {
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final strength = _laceStrength(i, j);
        if (strength <= 0.05) continue;

        final a = nodes[i];
        final b = nodes[j];
        final bond = _bondBetween(i, j);
        final tension = bond?.tension ?? 0.0;
        final mid = Offset.lerp(a, b, 0.5)!;

        if (tension > 0.08) {
          canvas.drawLine(
            a,
            b,
            Paint()
              ..color = kRawWoolCream.withAlpha((90 + tension * 110).round())
              ..strokeWidth = 1.0 + tension * 2.2
              ..strokeCap = StrokeCap.round,
          );
        } else {
          final lift = math.sin(time * 1.4 + i + j) * 4 * (1 - tension);
          final bridge = Path()
            ..moveTo(a.dx, a.dy)
            ..quadraticBezierTo(mid.dx, mid.dy - 16 - lift, b.dx, b.dy);
          canvas.drawPath(
            bridge,
            Paint()
              ..color = kBoneWhite.withAlpha((50 + strength * 90).round())
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.9 + strength * 0.5,
          );
        }

        final stitch = 5.0 + strength * 5 + tension * 3;
        final crossAlpha = (100 + strength * 120 + tension * 35).round().clamp(60, 255);
        final crossPaint = Paint()
          ..color = kBoneWhite.withAlpha(crossAlpha)
          ..strokeWidth = 1.0 + tension * 0.8
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          mid + Offset(-stitch, -stitch),
          mid + Offset(stitch, stitch),
          crossPaint,
        );
        canvas.drawLine(
          mid + Offset(-stitch, stitch),
          mid + Offset(stitch, -stitch),
          crossPaint,
        );

        final glowR = 4.0 + strength * 8 + tension * 10;
        final glowAlpha = (80 + strength * 100 + tension * 75).round().clamp(40, 255);
        canvas.drawCircle(
          mid,
          glowR,
          Paint()
            ..color = kSpindleAmber.withAlpha(glowAlpha)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + tension * 10),
        );
        canvas.drawCircle(
          mid,
          1.6 + tension,
          Paint()..color = kBoneWhite.withAlpha((140 + strength * 115).round()),
        );
      }
    }
  }

  /// Luminous fiber motes draft along every thread from hub to whorl.
  void _drawFiberTravelers(Canvas canvas, Offset hub, List<Offset> nodes) {
    for (int i = 0; i < nodes.length; i++) {
      final end = nodes[i];
      if ((end - hub).distance < 8) continue;

      final boost = i < spinBoost.length ? spinBoost[i] : 0.0;
      final path = _threadPath(hub, end, i);
      final metric = path.computeMetrics().firstOrNull;
      if (metric == null) continue;

      final len = metric.length;
      if (len <= 1) continue;

      final speed = 28 + boost * 55 + hubBoost * 35 + i * 4;
      const moteCount = 3;

      for (int m = 0; m < moteCount; m++) {
        final offset = (time * speed + m * (len / moteCount)) % len;
        final tangent = metric.getTangentForOffset(offset);
        if (tangent == null) continue;

        final pos = tangent.position;
        final behind = metric.getTangentForOffset((offset - 6).clamp(0, len));
        if (behind == null) continue;

        canvas.drawLine(
          behind.position,
          pos,
          Paint()
            ..color = kSpindleAmber.withAlpha(50 + (boost * 40).round())
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round,
        );

        canvas.drawCircle(
          pos,
          2.2 + boost * 0.8,
          Paint()
            ..color = kRawWoolCream.withAlpha(160 + (boost * 60).round())
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
        canvas.drawCircle(
          pos,
          1.0,
          Paint()..color = kBoneWhite.withAlpha(220),
        );
      }
    }
  }

  void _drawPulses(Canvas canvas) {
    for (final pulse in pulses) {
      final age = time - pulse.startTime;
      if (age > 1.3) continue;
      final radius = age * 130;
      final alpha = ((1 - age / 1.3) * 100).round().clamp(0, 100);
      canvas.drawCircle(
        pulse.center,
        radius,
        Paint()
          ..color = kBoneWhite.withAlpha(alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(ThreadFieldPainter old) => true;
}
