import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Golden-spiral placement around a central drafting hub.
List<Offset> layoutThreadField(int count, Size size) {
  if (count == 0) return [];

  final cx = size.width * 0.5;
  final cy = size.height * 0.44;
  final maxR = math.min(size.width, size.height) * 0.38;
  const golden = 2.399963229728653; // golden angle in radians

  if (count == 1) {
    // Offset slightly so the lone whorl doesn't sit on the hub.
    return [Offset(cx, cy - maxR * 0.35)];
  }

  return List.generate(count, (i) {
    final angle = i * golden - math.pi / 2;
    final t = (i + 1) / count;
    final r = maxR * (0.42 + 0.58 * math.sqrt(t));
    return Offset(
      cx + math.cos(angle) * r,
      cy + math.sin(angle) * r * 0.9,
    );
  });
}

Offset hubCenter(Size size) => Offset(size.width * 0.5, size.height * 0.44);
