import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';
import 'package:whispers_of_the_loom/screens/drafting_zone/drafting_zone_physics.dart';
import 'package:whispers_of_the_loom/utils/const.dart';

/// Unified 3D spindle-whorl node — same silhouette for every tool.
class WhorlNode extends StatelessWidget {
  final HearthFiberToolModel entry;
  final double time;
  final int index;
  final bool selected;
  final bool dragging;
  final double spinBoost;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const WhorlNode({
    super.key,
    required this.entry,
    required this.time,
    required this.index,
    required this.selected,
    this.dragging = false,
    this.spinBoost = 0,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final desired = selected || dragging ? 88.0 : 72.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSide = constraints.biggest.shortestSide;
        final size = maxSide.isFinite && maxSide > 0
            ? math.min(desired, maxSide)
            : desired;

        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _Whorl3DPainter(
                time: time,
                index: index,
                ringWeight: whorlRingWeight(entry.fiberType),
                accent: _nodeAccent(entry),
                selected: selected || dragging,
                usable: entry.mechanicalSoundness.isUsable,
                spinBoost: spinBoost,
                floatY: math.sin(time * 0.9 + index * 1.7) * 4,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _nodeAccent(HearthFiberToolModel entry) {
    if (!entry.mechanicalSoundness.isUsable) return kHerbGreen;
    switch (entry.fiberType) {
      case FiberType.wool:
        return kSpindleAmber;
      case FiberType.flax:
        return kDressedFlaxBlue;
      case FiberType.silk:
        return const Color(0xFFC4A882);
      case FiberType.cotton:
        return kRawWoolCream;
      default:
        return kTeaselBrown;
    }
  }
}

class _Whorl3DPainter extends CustomPainter {
  final double time;
  final int index;
  final double ringWeight;
  final Color accent;
  final bool selected;
  final bool usable;
  final double spinBoost;
  final double floatY;

  _Whorl3DPainter({
    required this.time,
    required this.index,
    required this.ringWeight,
    required this.accent,
    required this.selected,
    required this.usable,
    this.spinBoost = 0,
    this.floatY = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + floatY);
    final r = size.shortestSide / 2 - 6;
    final spin = time * (0.4 + index * 0.03 + spinBoost * 4);

    if (selected || spinBoost > 0.1) {
      canvas.drawCircle(
        c,
        r + 8 + spinBoost * 5,
        Paint()
          ..color = kSpindleAmber.withAlpha(35 + (spinBoost * 50).round())
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
    }

    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(1, 4), width: r * 1.9, height: r * 0.5),
      Paint()..color = Colors.black.withAlpha(50),
    );

    final bodyRect = Rect.fromCenter(center: c, width: r * 2, height: r * 1.55);
    canvas.drawOval(
      bodyRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.42),
          radius: 1.0,
          colors: [
            Color.lerp(accent, kBoneWhite, 0.45)!,
            accent,
            Color.lerp(accent, kHearthDark, 0.35)!,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bodyRect),
    );

    canvas.drawOval(
      bodyRect,
      Paint()
        ..color = kBoneWhite.withAlpha(25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(spin);
    final ringR = r * 0.78;
    final thickness = ringR * ringWeight * 2;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: ringR),
      0.2,
      math.pi * 1.85,
      false,
      Paint()
        ..color = usable
            ? Color.lerp(accent, kBoneWhite, 0.3)!
            : kHerbGreen.withAlpha(200)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness.clamp(2.0, 8.0)
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    final holeR = r * 0.13;
    canvas.drawCircle(c, holeR, Paint()..color = kHearthDark);
    canvas.drawCircle(
      c,
      holeR,
      Paint()
        ..color = kBoneWhite.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    canvas.drawCircle(
      c + Offset(-r * 0.28, -r * 0.22),
      r * 0.1,
      Paint()..color = kBoneWhite.withAlpha(selected ? 90 : 55),
    );
  }

  @override
  bool shouldRepaint(_Whorl3DPainter old) =>
      old.time != time ||
      old.selected != selected ||
      old.accent != accent ||
      old.spinBoost != spinBoost ||
      old.floatY != floatY;
}
