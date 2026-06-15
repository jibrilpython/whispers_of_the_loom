import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/screens/showcase/thread_field_layout.dart';

class ThreadPulse {
  final Offset center;
  final double startTime;
  ThreadPulse(this.center, this.startTime);
}

class LaceBond {
  final int a;
  final int b;
  double tension;

  LaceBond(this.a, this.b, [this.tension = 0]);

  int get id => a < b ? a * 10000 + b : b * 10000 + a;

  int partnerOf(int index) => a == index ? b : a;
}

class ThreadFieldState {
  static const double formDist = 74;
  static const double restDist = 58;
  static const double breakDist = 124;
  static const double previewDist = 98;

  List<Offset> positions = [];
  List<double> spinBoost = [];
  double hubBoost = 0;
  final List<ThreadPulse> pulses = [];
  final List<LaceBond> bonds = [];

  void sync(int count, Size size) {
    if (positions.length != count) {
      positions = layoutThreadField(count, size);
      spinBoost = List.filled(count, 0);
      bonds.clear();
    }
  }

  void decay() {
    hubBoost *= 0.97;
    for (int i = 0; i < spinBoost.length; i++) {
      spinBoost[i] *= 0.94;
      if (spinBoost[i] < 0.02) spinBoost[i] = 0;
    }
    for (final bond in bonds) {
      if (bond.tension > 0) bond.tension *= 0.92;
      if (bond.tension < 0.02) bond.tension = 0;
    }
  }

  void flickNode(int index) {
    if (index < spinBoost.length) {
      spinBoost[index] = (spinBoost[index] + 0.55).clamp(0, 1.2);
    }
  }

  void windHub() {
    hubBoost = (hubBoost + 0.35).clamp(0, 1.5);
  }

  void addPulse(Offset c, double time) {
    pulses.add(ThreadPulse(c, time));
  }

  void prunePulses(double time) {
    pulses.removeWhere((p) => time - p.startTime > 1.4);
  }

  LaceBond? bondBetween(int i, int j) {
    final id = i < j ? i * 10000 + j : j * 10000 + i;
    for (final b in bonds) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Drag physics with lace-stick resistance. Returns (snapped, newlyBonded).
  (bool snapped, bool bonded) applyNodeDrag(int index, Offset delta, Size size) {
    if (index >= positions.length) return (false, false);

    var snapped = false;
    var newlyBonded = false;
    var target = _clamp(positions[index] + delta, size);
  var movement = target - positions[index];
    final snapIds = <int>{};

    for (final bond in bonds.where((b) => b.a == index || b.b == index)) {
      if (snapIds.contains(bond.id)) continue;

      final pIdx = bond.partnerOf(index);
      final partner = positions[pIdx];
      var dist = (target - partner).distance;

      if (dist >= breakDist) {
        snapIds.add(bond.id);
        snapped = true;
        target = _clamp(positions[index] + delta, size);
        movement = target - positions[index];
        bond.tension = 1;
        continue;
      }

      bond.tension = _tensionFor(dist);

      if (bond.tension > 0) {
        final resist = 1 - bond.tension * 0.72;
        movement = movement * resist;
        target = _clamp(positions[index] + movement, size);
        dist = (target - partner).distance;
        bond.tension = _tensionFor(dist);

        final tug = movement * (0.38 + bond.tension * 0.12);
        positions[pIdx] = _clamp(partner + tug, size);
      } else if (dist < restDist * 0.9) {
        final dir = target - partner;
        if (dir.distance > 0.01) {
          target = _clamp(partner + dir / dir.distance * restDist, size);
        }
      }
    }

    if (snapIds.isNotEmpty) {
      bonds.removeWhere((b) => snapIds.contains(b.id));
    }

    positions[index] = target;
    newlyBonded = _scanNewBonds();
    _updateBondTensions();
    return (snapped, newlyBonded);
  }

  double proximityStrength(int i, int j) {
    final bond = bondBetween(i, j);
    if (bond != null) {
      return (0.45 + bond.tension * 0.55).clamp(0.0, 1.0);
    }
    final dist = (positions[i] - positions[j]).distance;
    if (dist >= previewDist) return 0;
    return (1 - dist / previewDist).clamp(0.0, 1.0);
  }

  double _tensionFor(double dist) {
    if (dist <= restDist) return 0;
    return ((dist - restDist) / (breakDist - restDist)).clamp(0.0, 1.0);
  }

  bool _scanNewBonds() {
    var added = false;
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        if (bondBetween(i, j) != null) continue;
        if ((positions[i] - positions[j]).distance > formDist) continue;
        bonds.add(LaceBond(i, j));
        _seatBond(i, j);
        added = true;
      }
    }
    return added;
  }

  void _seatBond(int i, int j) {
    final a = positions[i];
    final b = positions[j];
    final mid = Offset.lerp(a, b, 0.5)!;
    final dir = b - a;
    if (dir.distance < 0.01) return;
    final norm = dir / dir.distance;
    positions[i] = mid - norm * (restDist / 2);
    positions[j] = mid + norm * (restDist / 2);
  }

  void _updateBondTensions() {
    for (final bond in bonds) {
      final dist = (positions[bond.a] - positions[bond.b]).distance;
      bond.tension = _tensionFor(dist);
    }
  }

  Offset _clamp(Offset p, Size size) {
    const pad = 48.0;
    return Offset(
      p.dx.clamp(pad, size.width - pad),
      p.dy.clamp(100, size.height - 140),
    );
  }
}
