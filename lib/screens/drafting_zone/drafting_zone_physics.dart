import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';

const Color kHearthDark = Color(0xFF0D0A07);
const Color kRawWoolCream = Color(0xFFF0E8D0);
const Color kSpindleAmber = Color(0xFFD4920A);
const Color kDressedFlaxBlue = Color(0xFF8AA8C8);
const Color kBoneWhite = Color(0xFFEDE8D8);
const Color kTeaselBrown = Color(0xFF6A4A2A);

enum NodePhysicsKind { sink, source, doublet, bobbin, integrator }

class DraftNode {
  final int index;
  final HearthFiberToolModel entry;
  Offset position;
  final NodePhysicsKind kind;
  double strength;
  double omega;
  double orbitPhase;
  double yardage;

  DraftNode({
    required this.index,
    required this.entry,
    required this.position,
    required this.kind,
    required this.strength,
    required this.omega,
    required this.orbitPhase,
    this.yardage = 0,
  });
}

class TwistPulse {
  final Offset center;
  final double startTime;
  TwistPulse(this.center, this.startTime);
}

class CombingWake {
  final Offset center;
  final double width;
  final double startTime;
  CombingWake(this.center, this.width, this.startTime);
}

class LaceCross {
  final Offset a;
  final Offset b;
  final double opacity;
  LaceCross(this.a, this.b, this.opacity);
}

NodePhysicsKind kindFor(CraftClassification craft) {
  switch (craft) {
    case CraftClassification.dropSpindle:
    case CraftClassification.walkingWheel:
      return NodePhysicsKind.sink;
    case CraftClassification.cardingPaddle:
      return NodePhysicsKind.doublet;
    case CraftClassification.skeinWinder:
      return NodePhysicsKind.integrator;
    case CraftClassification.laceBobbin:
      return NodePhysicsKind.bobbin;
  }
}

int targetYardageFor(FiberType fiber) {
  switch (fiber) {
    case FiberType.flax:
      return 240;
    case FiberType.wool:
      return 560;
    case FiberType.silk:
      return 120;
    default:
      return 360;
  }
}

String yarnCountLabel(HearthFiberToolModel entry, double speed) {
  final count = (speed * 12).clamp(4, 80).round();
  final fiber = entry.fiberType.label.split(' /').first.toUpperCase();
  if (entry.fiberType == FiberType.flax) {
    return 'LINEN COUNT: $count/1 — DRESS WEIGHT';
  }
  return 'WORSTED COUNT: 2/$count — $fiber';
}

List<DraftNode> layoutNodes(List<HearthFiberToolModel> entries, Size size) {
  if (entries.isEmpty) return [];
  final nodes = <DraftNode>[];
  final w = size.width;
  final h = size.height;
  final golden = (1 + math.sqrt(5)) / 2;

  for (int i = 0; i < entries.length; i++) {
    final t = (i + 1) / (entries.length + 1);
    final angle = i * golden * math.pi * 2;
    final radius = 0.22 + (i % 4) * 0.08;
    final x = w * (0.5 + radius * math.cos(angle) * (w / math.max(h, 1)) * 0.9);
    final y = h * (0.22 + t * 0.58 + 0.04 * math.sin(angle * 2));

    final craft = entries[i].craftClassification;
    final kind = kindFor(craft);
    final baseStrength = kind == NodePhysicsKind.sink ? 2800.0 : 1800.0;

    nodes.add(
      DraftNode(
        index: i,
        entry: entries[i],
        position: Offset(x.clamp(40.0, w - 40), y.clamp(60.0, h - 60)),
        kind: kind,
        strength: baseStrength,
        omega: 1.2 + (i % 3) * 0.4,
        orbitPhase: i * 1.7,
      ),
    );
  }
  return nodes;
}

Offset velocityAt(Offset p, List<DraftNode> nodes, {Offset? focusSink}) {
  var vx = 0.0;
  var vy = 0.0;

  if (focusSink != null) {
    final dx = p.dx - focusSink.dx;
    final dy = p.dy - focusSink.dy;
    final r2 = math.max(dx * dx + dy * dy, 400.0);
    vx -= 4200 * dx / r2;
    vy -= 4200 * dy / r2;
    return Offset(vx, vy);
  }

  for (final n in nodes) {
    final dx = p.dx - n.position.dx;
    final dy = p.dy - n.position.dy;
    final r2 = math.max(dx * dx + dy * dy, 625.0);
    final q = n.strength;

    switch (n.kind) {
      case NodePhysicsKind.sink:
        vx -= q * dx / r2;
        vy -= q * dy / r2;
        break;
      case NodePhysicsKind.source:
        vx += q * dx / r2;
        vy += q * dy / r2;
        break;
      case NodePhysicsKind.doublet:
        vx += q * 0.55 * (-dy) / r2;
        vy += q * 0.55 * dx / r2;
        vx -= q * 0.35 * dx / r2;
        vy -= q * 0.35 * dy / r2;
        break;
      case NodePhysicsKind.integrator:
        vx -= q * 0.25 * dx / r2;
        vy -= q * 0.25 * dy / r2;
        break;
      case NodePhysicsKind.bobbin:
        break;
    }
  }
  return Offset(vx, vy);
}

double speedAt(Offset p, List<DraftNode> nodes, {Offset? focusSink}) {
  final v = velocityAt(p, nodes, focusSink: focusSink);
  return math.sqrt(v.dx * v.dx + v.dy * v.dy);
}

Offset rk4Step(Offset p, double dt, List<DraftNode> nodes, {Offset? focusSink}) {
  Offset f(Offset pos) => velocityAt(pos, nodes, focusSink: focusSink);

  final k1 = f(p);
  final k2 = f(p + k1 * (dt * 0.5));
  final k3 = f(p + k2 * (dt * 0.5));
  final k4 = f(p + k3 * dt);
  return p + (k1 + k2 * 2 + k3 * 2 + k4) * (dt / 6);
}

List<List<Offset>> traceStreamlines(
  Size size,
  List<DraftNode> nodes, {
  int seeds = 14,
  int steps = 48,
  Offset? focusSink,
}) {
  final lines = <List<Offset>>[];
  final dt = 2.8;

  for (int s = 0; s < seeds; s++) {
    var p = Offset(size.width * (s + 1) / (seeds + 1), 8);
    final line = <Offset>[p];

    for (int i = 0; i < steps; i++) {
      p = rk4Step(p, dt, nodes, focusSink: focusSink);
      if (p.dx < -20 || p.dx > size.width + 20 || p.dy > size.height + 20) {
        break;
      }
      line.add(p);
    }
    if (line.length > 2) lines.add(line);
  }
  return lines;
}

List<LaceCross> computeLaceCrosses(List<DraftNode> nodes, double time) {
  final bobbins = nodes.where((n) => n.kind == NodePhysicsKind.bobbin).toList();
  final crosses = <LaceCross>[];

  for (int i = 0; i < bobbins.length; i++) {
    for (int j = i + 1; j < bobbins.length; j++) {
      final a = bobbins[i];
      final b = bobbins[j];
      final dist = (a.position - b.position).distance;
      if (dist > 120) continue;

      final pa = a.position +
          Offset(
            math.cos(time * 0.8 + a.orbitPhase) * 14,
            math.sin(time * 1.1 + a.orbitPhase) * 10,
          );
      final pb = b.position +
          Offset(
            math.cos(time * 0.9 + b.orbitPhase) * 12,
            math.sin(time * 0.7 + b.orbitPhase) * 11,
          );
      final opacity = (1 - dist / 120).clamp(0.2, 0.9);
      crosses.add(LaceCross(pa, pb, opacity));
    }
  }
  return crosses;
}
