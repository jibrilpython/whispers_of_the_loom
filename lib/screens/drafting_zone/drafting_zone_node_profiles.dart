import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/screens/drafting_zone/drafting_zone_physics.dart';

/// 3D-shaded tool profiles rendered as beautiful objects on the hearth surface.
/// Each tool uses gradients, shadows, and highlights to feel physically present.
class DraftingZoneNodeProfiles {
  static void draw(
    Canvas canvas,
    CraftClassification craft,
    Offset center,
    double time,
    double omega,
    double yardage,
    bool bright,
  ) {
    switch (craft) {
      case CraftClassification.dropSpindle:
        drawDropSpindle(canvas, center, time * omega * 2.2, bright);
        break;
      case CraftClassification.walkingWheel:
        drawWalkingWheel(canvas, center, time * omega * 0.9, bright);
        break;
      case CraftClassification.cardingPaddle:
        drawCardingPaddle(canvas, center, bright);
        break;
      case CraftClassification.skeinWinder:
        drawSkeinWinder(canvas, center, yardage, bright);
        break;
      case CraftClassification.laceBobbin:
        drawLaceBobbin(canvas, center, time, bright);
        break;
    }
  }

  /// Drop spindle — 3D shaded shaft, metal hook, whorl with volume.
  static void drawDropSpindle(Canvas canvas, Offset c, double spin, bool bright) {
    canvas.save();
    canvas.translate(c.dx, c.dy);

    final op = bright ? 1.0 : 0.75;

    // === SHADOW ===
    canvas.save();
    canvas.translate(0, 16);
    canvas.rotate(spin * 0.15);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 26, height: 8),
      Paint()
        ..color = kHearthDark.withAlpha(80)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();

    // === WHORL ===
    canvas.save();
    canvas.translate(0, 10);
    canvas.rotate(spin);

    // Whorl underside shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 28, height: 8),
      Paint()..color = kSpindleAmber.withAlpha((60 * op).round()),
    );

    // Whorl body — radial gradient for 3D volume
    final whorlRect = Rect.fromCenter(center: Offset.zero, width: 28, height: 8);
    final whorlGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: [
        kSpindleAmber.withAlpha((255 * op).round()),
        kSpindleAmber.withAlpha((200 * op).round()),
        kSpindleAmber.withAlpha((150 * op).round()),
        kTeaselBrown.withAlpha((180 * op).round()),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );
    canvas.drawOval(
      whorlRect,
      Paint()..shader = whorlGradient.createShader(whorlRect),
    );

    // Whorl rim highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 26, height: 7),
      Paint()
        ..color = kSpindleAmber.withAlpha((120 * op).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Inner ring groove
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 16, height: 4.5),
      Paint()
        ..color = kHearthDark.withAlpha((80 * op).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Center hole
    canvas.drawCircle(Offset.zero, 2, Paint()..color = kHearthDark);
    canvas.restore();

    // === SHAFT ===
    final shaftRect = Rect.fromLTRB(-2, -26, 2, 10);
    final shaftGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        kSpindleAmber.withAlpha((180 * op).round()),
        kSpindleAmber.withAlpha((255 * op).round()),
        kSpindleAmber.withAlpha((200 * op).round()),
      ],
      stops: const [0.0, 0.4, 1.0],
    );
    final shaftPath = Path()
      ..moveTo(-1.8, -26)
      ..lineTo(1.8, -26)
      ..lineTo(2.5, 10)
      ..lineTo(-2.5, 10)
      ..close();
    canvas.drawPath(
      shaftPath,
      Paint()..shader = shaftGradient.createShader(shaftRect),
    );

    // Wood grain lines
    for (double y = -24; y < 9; y += 3) {
      canvas.drawLine(
        Offset(-1.2 + math.sin(y * 0.5) * 1, y),
        Offset(1.2 + math.sin(y * 0.5 + 1) * 1, y),
        Paint()
          ..color = kTeaselBrown.withAlpha((30 * op).round())
          ..strokeWidth = 0.4,
      );
    }

    // === HOOK ===
    final hookPaint = Paint()
      ..color = kBoneWhite.withAlpha((220 * op).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(-3.5, -30, 7, 7),
      math.pi,
      math.pi,
      false,
      hookPaint,
    );
    canvas.drawLine(
      const Offset(0, -30),
      const Offset(0, -27),
      hookPaint..strokeWidth = 2,
    );

    // Hook highlight
    canvas.drawArc(
      const Rect.fromLTWH(-2.5, -29, 5, 5),
      math.pi,
      math.pi * 0.8,
      false,
      Paint()
        ..color = kBoneWhite.withAlpha((100 * op).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Base knob
    final knobRect = Rect.fromCenter(center: const Offset(0, 13), width: 6, height: 4);
    final knobGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1,
      colors: [
        kSpindleAmber.withAlpha((255 * op).round()),
        kTeaselBrown.withAlpha((200 * op).round()),
      ],
    );
    canvas.drawOval(knobRect, Paint()..shader = knobGradient.createShader(knobRect));

    canvas.restore();
  }

  /// Walking wheel — 3D shaded front elevation with spoked wheel and frame.
  static void drawWalkingWheel(Canvas canvas, Offset c, double spin, bool bright) {
    canvas.save();
    canvas.translate(c.dx, c.dy);

    final op = bright ? 1.0 : 0.72;

    // === SHADOW ===
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(2, 34), width: 60, height: 10),
      Paint()
        ..color = kHearthDark.withAlpha(70)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // === WHEEL ===
    canvas.save();
    canvas.translate(-22, 0);
    canvas.rotate(spin);

    // Wheel shadow
    canvas.drawCircle(
      const Offset(2, 2),
      26,
      Paint()
        ..color = kHearthDark.withAlpha(40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Outer rim — gradient for 3D roundness
    final rimRect = Rect.fromCircle(center: Offset.zero, radius: 26);
    final rimGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 1.1,
      colors: [
        kSpindleAmber.withAlpha((200 * op).round()),
        kSpindleAmber.withAlpha((140 * op).round()),
        kTeaselBrown.withAlpha((160 * op).round()),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    canvas.drawCircle(
      Offset.zero,
      26,
      Paint()..shader = rimGradient.createShader(rimRect),
    );

    // Inner rim
    canvas.drawCircle(
      Offset.zero,
      24,
      Paint()
        ..color = kSpindleAmber.withAlpha((100 * op).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Spokes
    for (int i = 0; i < 10; i++) {
      final a = i * math.pi / 5;
      final outer = Offset(math.cos(a) * 24, math.sin(a) * 24);
      final inner = Offset(math.cos(a) * 5, math.sin(a) * 5);
      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = kSpindleAmber.withAlpha((190 * op).round())
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
      // Spoke highlight
      canvas.drawLine(
        inner + Offset(0.5, 0),
        outer + Offset(0.5, 0),
        Paint()
          ..color = kSpindleAmber.withAlpha((80 * op).round())
          ..strokeWidth = 0.5,
      );
    }

    // Hub
    final hubRect = Rect.fromCircle(center: Offset.zero, radius: 5);
    final hubGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1,
      colors: [
        kSpindleAmber.withAlpha((255 * op).round()),
        kTeaselBrown.withAlpha((200 * op).round()),
      ],
    );
    canvas.drawCircle(Offset.zero, 5, Paint()..shader = hubGradient.createShader(hubRect));
    canvas.drawCircle(Offset.zero, 5, Paint()
      ..color = kHearthDark.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);
    canvas.drawCircle(Offset.zero, 1.5, Paint()..color = kHearthDark);
    canvas.restore();

    // === FRAME ===
    final framePaint = Paint()
      ..color = kTeaselBrown.withAlpha((200 * op).round())
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final frameHighlight = Paint()
      ..color = kSpindleAmber.withAlpha((80 * op).round())
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Uprights
    canvas.drawLine(const Offset(-10, 22), const Offset(-10, 36), framePaint);
    canvas.drawLine(const Offset(14, 22), const Offset(14, 36), framePaint);
    canvas.drawLine(const Offset(-9, 22), const Offset(-9, 36), frameHighlight);
    canvas.drawLine(const Offset(15, 22), const Offset(15, 36), frameHighlight);

    // Cross braces
    canvas.drawLine(const Offset(-10, 36), const Offset(14, 36), framePaint);
    canvas.drawLine(const Offset(-10, 35), const Offset(14, 35), frameHighlight);
    canvas.drawLine(
      const Offset(-10, 28),
      const Offset(14, 28),
      Paint()
        ..color = kTeaselBrown.withAlpha((120 * op).round())
        ..strokeWidth = 1.5,
    );

    // === SPINDLE ARM ===
    canvas.drawLine(
      const Offset(6, 0),
      const Offset(26, -8),
      Paint()
        ..color = kSpindleAmber.withAlpha((220 * op).round())
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // === FLYER WHORL ===
    canvas.save();
    canvas.translate(26, -8);
    canvas.rotate(spin * 2.5);
    final flyerRect = Rect.fromCircle(center: Offset.zero, radius: 7);
    final flyerGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 1,
      colors: [
        kSpindleAmber.withAlpha((255 * op).round()),
        kTeaselBrown.withAlpha((180 * op).round()),
      ],
    );
    canvas.drawCircle(Offset.zero, 7, Paint()..shader = flyerGradient.createShader(flyerRect));
    canvas.drawCircle(Offset.zero, 4, Paint()
      ..color = kHearthDark.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6);
    canvas.drawCircle(Offset.zero, 1.5, Paint()..color = kHearthDark);
    canvas.restore();

    // === DRIVE BAND ===
    final bandPaint = Paint()
      ..color = kRawWoolCream.withAlpha((bright ? 140 : 80))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final bandPath = Path()
      ..moveTo(-22, -24)
      ..quadraticBezierTo(0, -36, 26, -8);
    canvas.drawPath(bandPath, bandPaint);
    final bandShadow = Path()
      ..moveTo(-22, -23)
      ..quadraticBezierTo(0, -35, 26, -7);
    canvas.drawPath(
      bandShadow,
      Paint()
        ..color = kRawWoolCream.withAlpha((bright ? 80 : 40))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    canvas.restore();
  }

  /// Carding paddle — twin leather paddles with 3D volume and wire teeth.
  static void drawCardingPaddle(Canvas canvas, Offset c, bool bright) {
    canvas.save();
    canvas.translate(c.dx, c.dy);

    final op = bright ? 1.0 : 0.75;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 44, height: 10),
      Paint()
        ..color = kHearthDark.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    for (final side in [-1.0, 1.0]) {
      final ox = side * 16;

      // Paddle shadow beneath
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(ox + 1, 2), width: 20, height: 34),
          const Radius.circular(3),
        ),
        Paint()
          ..color = kHearthDark.withAlpha(40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Paddle body — leather texture with gradient
      final paddleRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(ox, 0), width: 20, height: 34),
        const Radius.circular(3),
      );
      final paddleGradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          kTeaselBrown.withAlpha((200 * op).round()),
          kTeaselBrown.withAlpha((240 * op).round()),
          kTeaselBrown.withAlpha((180 * op).round()),
        ],
        stops: const [0.0, 0.5, 1.0],
      );
      canvas.drawRRect(
        paddleRect,
        Paint()..shader = paddleGradient.createShader(paddleRect.outerRect),
      );

      // Paddle edge outline
      canvas.drawRRect(
        paddleRect,
        Paint()
          ..color = kTeaselBrown.withAlpha((140 * op).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Leather inner panel
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(ox, 0), width: 16, height: 30),
          const Radius.circular(2),
        ),
        Paint()
          ..color = kTeaselBrown.withAlpha((100 * op).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );

      // Wire teeth rows
      for (double y = -14; y <= 14; y += 2.4) {
        final offset = (y / 2.4).round() % 2 == 0 ? 0.6 : 0.0;
        final left = ox - 7 + offset;
        final right = ox + 7 - offset;

        // Main wire
        canvas.drawLine(
          Offset(left, y),
          Offset(right, y),
          Paint()
            ..color = kBoneWhite.withAlpha((bright ? 180 : 120))
            ..strokeWidth = 0.5,
        );

        // Hook bends at ends
        canvas.drawLine(
          Offset(left, y),
          Offset(left - 0.8, y + 0.8),
          Paint()
            ..color = kBoneWhite.withAlpha((bright ? 140 : 90))
            ..strokeWidth = 0.4,
        );
        canvas.drawLine(
          Offset(right, y),
          Offset(right + 0.8, y + 0.8),
          Paint()
            ..color = kBoneWhite.withAlpha((bright ? 140 : 90))
            ..strokeWidth = 0.4,
        );
      }

      // Handle
      final handlePath = Path()
        ..moveTo(ox * 0.5, 12)
        ..lineTo(ox * 0.15, 20)
        ..lineTo(ox * 0.35, 20)
        ..lineTo(ox * 0.65, 12)
        ..close();
      final handleRect = handlePath.getBounds();
      final handleGradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          kTeaselBrown.withAlpha((170 * op).round()),
          kSpindleAmber.withAlpha((220 * op).round()),
        ],
      );
      canvas.drawPath(
        handlePath,
        Paint()..shader = handleGradient.createShader(handleRect),
      );
    }

    // Center joint
    canvas.drawCircle(
      Offset.zero,
      4,
      Paint()..color = kSpindleAmber.withAlpha((200 * op).round()),
    );

    canvas.restore();
  }

  /// Skein-winder clock — 3D reel with ratchet hub and live counter.
  static void drawSkeinWinder(Canvas canvas, Offset c, double yards, bool bright) {
    canvas.save();
    canvas.translate(c.dx, c.dy);

    final op = bright ? 1.0 : 0.72;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(1, 2), width: 52, height: 10),
      Paint()
        ..color = kHearthDark.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Arms
    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      final tip = Offset(math.cos(a) * 26, math.sin(a) * 26);

      // Arm shadow
      canvas.drawLine(
        Offset(1, 1),
        tip + const Offset(1, 1),
        Paint()
          ..color = kHearthDark.withAlpha(40)
          ..strokeWidth = 3.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Arm body with gradient
      final armPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            kSpindleAmber.withAlpha((180 * op).round()),
            kSpindleAmber.withAlpha((220 * op).round()),
          ],
        ).createShader(Rect.fromPoints(Offset.zero, tip));
      canvas.drawLine(Offset.zero, tip, armPaint..strokeWidth = 2.8..strokeCap = StrokeCap.round);

      // Arm highlight
      canvas.drawLine(
        const Offset(0, -0.5),
        tip - Offset(0, 0.5),
        Paint()
          ..color = kSpindleAmber.withAlpha((100 * op).round())
          ..strokeWidth = 1,
      );

      // Arm tip knob
      canvas.drawCircle(tip, 3.5, Paint()..color = kSpindleAmber.withAlpha((240 * op).round()));
      canvas.drawCircle(tip, 3.5, Paint()
        ..color = kHearthDark.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5);

      // Cross-brace wire
      final braceStart = Offset(math.cos(a) * 12, math.sin(a) * 12);
      final braceEnd = braceStart +
          Offset(-math.cos(a + math.pi / 2) * 5, -math.sin(a + math.pi / 2) * 5);
      canvas.drawLine(
        braceStart,
        braceEnd,
        Paint()
          ..color = kRawWoolCream.withAlpha((50 * op).round())
          ..strokeWidth = 0.5,
      );
    }

    // === HUB ===
    // Outer ring
    final hubRect = Rect.fromCircle(center: Offset.zero, radius: 9);
    final hubGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 1,
      colors: [
        kSpindleAmber.withAlpha((255 * op).round()),
        kTeaselBrown.withAlpha((200 * op).round()),
      ],
    );
    canvas.drawCircle(Offset.zero, 9, Paint()..shader = hubGradient.createShader(hubRect));
    canvas.drawCircle(Offset.zero, 9, Paint()
      ..color = kHearthDark.withAlpha(40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6);

    // Inner hub
    canvas.drawCircle(Offset.zero, 6, Paint()..color = kTeaselBrown.withAlpha((180 * op).round()));

    // Ratchet gear teeth
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 8;
      final inner = Offset(math.cos(a) * 6, math.sin(a) * 6);
      final outer = Offset(math.cos(a) * 9.5, math.sin(a) * 9.5);
      final trail = Offset(math.cos(a + 0.35) * 8, math.sin(a + 0.35) * 8);
      final tooth = Path()
        ..moveTo(inner.dx, inner.dy)
        ..lineTo(outer.dx, outer.dy)
        ..lineTo(trail.dx, trail.dy)
        ..close();
      canvas.drawPath(tooth, Paint()..color = kSpindleAmber.withAlpha((200 * op).round()));
    }

    // Pawl
    canvas.save();
    canvas.translate(5, 4);
    canvas.rotate(-0.3);
    canvas.drawLine(
      const Offset(5, -5),
      const Offset(0, 0),
      Paint()
        ..color = kHearthDark
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(5, -5),
      const Offset(6, -2),
      Paint()
        ..color = kHearthDark
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    // Center pin
    canvas.drawCircle(Offset.zero, 2, Paint()..color = kHearthDark);

    // Yardage badge
    if (yards > 0) {
      final tp = TextPainter(
        text: TextSpan(
          text: yards.round().toString(),
          style: const TextStyle(
            color: Color(0xFF1A1510),
            fontSize: 8,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: tp.width + 8,
          height: tp.height + 4,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(badgeRect, Paint()..color = kBoneWhite.withAlpha(210));
      canvas.drawRRect(badgeRect, Paint()
        ..color = kTeaselBrown.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    }

    canvas.restore();
  }

  /// Lace bobbin — turned bone spool, thread wraps, glass bead with refraction.
  static void drawLaceBobbin(Canvas canvas, Offset c, double time, bool bright) {
    canvas.save();
    canvas.translate(c.dx, c.dy);

    final op = bright ? 1.0 : 0.75;

    // Orbital drift
    final drift = Offset(
      math.cos(time * 0.8 + 1) * 6,
      math.sin(time * 1.1 + 1) * 5,
    );
    canvas.translate(drift.dx, drift.dy);

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(1, 15), width: 14, height: 4),
      Paint()
        ..color = kHearthDark.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // === SPOOL ===
    final spoolPath = Path()
      ..moveTo(-4, -15)
      ..lineTo(-5.5, -10)
      ..lineTo(-3, -3)
      ..lineTo(-4, 3)
      ..lineTo(-2.5, 8)
      ..lineTo(2.5, 8)
      ..lineTo(4, 3)
      ..lineTo(3, -3)
      ..lineTo(5.5, -10)
      ..lineTo(4, -15)
      ..close();

    // Spool shading — use multiple passes for 3D look
    final spoolBody = Paint()..color = kBoneWhite.withAlpha((230 * op).round());
    canvas.drawPath(spoolPath, spoolBody);

    // Spool outline
    canvas.drawPath(
      spoolPath,
      Paint()
        ..color = kTeaselBrown.withAlpha((60 * op).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Spool left highlight
    final highlightPath = Path()
      ..moveTo(-2.5, -14)
      ..lineTo(-3.5, -10)
      ..lineTo(-2, -3)
      ..lineTo(-2.5, 3)
      ..lineTo(-1.5, 7)
      ..lineTo(-0.8, 7)
      ..lineTo(-1.8, 3)
      ..lineTo(-1.3, -3)
      ..lineTo(-2.8, -10)
      ..lineTo(-1.8, -14)
      ..close();
    canvas.drawPath(
      highlightPath,
      Paint()..color = kBoneWhite.withAlpha((200 * op).round()),
    );

    // Spool right shadow
    final shadowPath = Path()
      ..moveTo(2, -14)
      ..lineTo(4, -10)
      ..lineTo(2.5, -3)
      ..lineTo(3, 3)
      ..lineTo(2, 7)
      ..lineTo(2.5, 7)
      ..lineTo(3.5, 3)
      ..lineTo(3, -3)
      ..lineTo(4.5, -10)
      ..lineTo(3, -14)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()..color = kTeaselBrown.withAlpha((40 * op).round()),
    );

    // Turned groove details
    canvas.drawLine(
      const Offset(-5, -10),
      const Offset(5, -10),
      Paint()
        ..color = kTeaselBrown.withAlpha((40 * op).round())
        ..strokeWidth = 0.5,
    );
    canvas.drawLine(
      const Offset(-4, 3),
      const Offset(4, 3),
      Paint()
        ..color = kTeaselBrown.withAlpha((40 * op).round())
        ..strokeWidth = 0.5,
    );

    // Thread wraps at waist
    for (double y = -2.5; y <= 2.5; y += 1.2) {
      canvas.drawLine(
        Offset(-3.2, y),
        Offset(3.2, y),
        Paint()
          ..color = kTeaselBrown.withAlpha((90 * op).round())
          ..strokeWidth = 0.6,
      );
    }

    // === GLASS BEAD ===
    final beadCenter = const Offset(0, 13);

    // Bead shadow
    canvas.drawCircle(
      beadCenter + const Offset(1, 1),
      4.5,
      Paint()
        ..color = kHearthDark.withAlpha(50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Bead body — glass effect with gradient
    final beadRect = Rect.fromCircle(center: beadCenter, radius: 4.5);
    final beadGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 1.2,
      colors: [
        kDressedFlaxBlue.withAlpha((255 * op).round()),
        kDressedFlaxBlue.withAlpha((200 * op).round()),
        kDressedFlaxBlue.withAlpha((160 * op).round()),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(beadCenter, 4.5, Paint()..shader = beadGradient.createShader(beadRect));

    // Bead outline
    canvas.drawCircle(
      beadCenter,
      4.5,
      Paint()
        ..color = kDressedFlaxBlue.withAlpha((120 * op).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    // Primary specular highlight
    canvas.drawCircle(
      beadCenter + const Offset(-1.8, -1.8),
      1.8,
      Paint()..color = kBoneWhite.withAlpha((180 * op).round()),
    );
    // Secondary sharp highlight
    canvas.drawCircle(
      beadCenter + const Offset(-1, -1),
      0.8,
      Paint()..color = kBoneWhite.withAlpha((240 * op).round()),
    );

    // Bottom reflection
    canvas.drawCircle(
      beadCenter + const Offset(0.8, 1.5),
      0.6,
      Paint()..color = kBoneWhite.withAlpha((60 * op).round()),
    );

    // === DANGLING THREAD ===
    final threadWave = math.sin(time * 1.5) * 2.5;
    final dangling = Path()
      ..moveTo(beadCenter.dx, beadCenter.dy + 4.5)
      ..cubicTo(
        beadCenter.dx + threadWave - 2,
        beadCenter.dy + 9,
        beadCenter.dx + threadWave + 1.5,
        beadCenter.dy + 14,
        beadCenter.dx + threadWave * 0.3,
        beadCenter.dy + 18,
      );
    canvas.drawPath(
      dangling,
      Paint()
        ..color = kRawWoolCream.withAlpha((100 * op).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    canvas.restore();
  }

  static double hitRadius(CraftClassification craft) {
    switch (craft) {
      case CraftClassification.walkingWheel:
        return 44;
      case CraftClassification.cardingPaddle:
        return 36;
      case CraftClassification.skeinWinder:
        return 28;
      case CraftClassification.laceBobbin:
        return 22;
      case CraftClassification.dropSpindle:
        return 26;
    }
  }
}
