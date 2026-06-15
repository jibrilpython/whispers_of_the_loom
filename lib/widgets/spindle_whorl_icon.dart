import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/utils/const.dart';

class SpindleWhorlIcon extends StatelessWidget {
  final FiberType fiberType;
  final MechanicalSoundness soundness;
  final double size;

  const SpindleWhorlIcon({
    super.key,
    required this.fiberType,
    required this.soundness,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final color = soundness.isUsable ? kAccent : kHerbGreen;
    return CustomPaint(
      size: Size(size, size),
      painter: _SpindleWhorlPainter(
        ringWeight: whorlRingWeight(fiberType),
        color: color,
      ),
    );
  }
}

class _SpindleWhorlPainter extends CustomPainter {
  final double ringWeight;
  final Color color;

  _SpindleWhorlPainter({required this.ringWeight, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 1;
    final ringThickness = outerR * ringWeight;

    canvas.drawCircle(
      center,
      outerR,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness,
    );

    canvas.drawCircle(
      center,
      outerR * 0.12,
      Paint()
        ..color = kBackground
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      outerR * 0.12,
      Paint()
        ..color = color.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _SpindleWhorlPainter old) =>
      old.ringWeight != ringWeight || old.color != color;
}
