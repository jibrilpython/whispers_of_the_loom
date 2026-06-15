import 'package:flutter/material.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';

const Color kBackground = Color(0xFFF8F5F0);
const Color kPrimaryText = Color(0xFF1A1510);
const Color kSecondaryText = Color(0xFF7D7468);
const Color kAccent = Color(0xFF7A4F2E);
const Color kOutline = Color(0xFFEAE5DC);
const Color kHerbGreen = Color(0xFF4A7358);
const Color kError = Color(0xFFC0392B);
const Color kCardSurface = Color(0xFFFFFFFF);
const Color kActiveBg = Color(0xFFF7F0E8);

const double kRadiusStandard = 10.0;
const double kRadiusSubtle = 6.0;
const double kRadiusPill = 999.0;

const Duration kTransitionDuration = Duration(milliseconds: 250);

Color getCraftColor(CraftClassification type) {
  switch (type) {
    case CraftClassification.walkingWheel:
      return kAccent;
    case CraftClassification.dropSpindle:
      return const Color(0xFF5C4033);
    case CraftClassification.cardingPaddle:
      return kHerbGreen;
    case CraftClassification.skeinWinder:
      return const Color(0xFF6B5B4E);
    case CraftClassification.laceBobbin:
      return const Color(0xFF8B6F5E);
  }
}

Color getSoundnessColor(MechanicalSoundness state) {
  switch (state) {
    case MechanicalSoundness.fullyOperational:
      return kAccent;
    case MechanicalSoundness.minorWobble:
      return const Color(0xFF8B6914);
    case MechanicalSoundness.grooveWear:
      return const Color(0xFF9A6B4F);
    case MechanicalSoundness.bearingFriction:
      return const Color(0xFF7D5A3C);
    case MechanicalSoundness.museumDisplay:
      return kHerbGreen;
    case MechanicalSoundness.unknown:
      return kSecondaryText;
  }
}

double whorlRingWeight(FiberType fiber) {
  switch (fiber) {
    case FiberType.silk:
      return 0.12;
    case FiberType.flax:
      return 0.18;
    case FiberType.cotton:
      return 0.22;
    case FiberType.wool:
      return 0.32;
    case FiberType.bastFiber:
      return 0.26;
    case FiberType.blended:
      return 0.24;
  }
}

String generateRegistryScroll(FiberType fiber) {
  final code = 1000 + DateTime.now().millisecondsSinceEpoch % 9000;
  return 'WOL-FIBER-$code-${fiber.code}-S';
}
