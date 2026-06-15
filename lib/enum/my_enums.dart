enum CraftClassification {
  walkingWheel('Walking Wheel'),
  dropSpindle('Drop Spindle'),
  cardingPaddle('Carding Paddle'),
  skeinWinder('Skein Winder'),
  laceBobbin('Lace Bobbin');

  const CraftClassification(this.label);
  final String label;
}

enum FiberType {
  wool('Wool / worsted'),
  flax('Flax / linen'),
  silk('Silk'),
  cotton('Cotton'),
  bastFiber('Bast fiber'),
  blended('Blended');

  const FiberType(this.label);
  final String label;

  String get code {
    switch (this) {
      case FiberType.wool:
        return 'WOOL';
      case FiberType.flax:
        return 'FLAX';
      case FiberType.silk:
        return 'SILK';
      case FiberType.cotton:
        return 'COTTON';
      case FiberType.bastFiber:
        return 'BAST';
      case FiberType.blended:
        return 'BLEND';
    }
  }
}

enum MechanicalSoundness {
  fullyOperational('Fully operational'),
  minorWobble('Wheel wobble offset'),
  grooveWear('Drive-band groove wear'),
  bearingFriction('Bearing friction'),
  museumDisplay('Museum display only'),
  unknown('Condition unknown');

  const MechanicalSoundness(this.label);
  final String label;

  bool get isUsable =>
      this == MechanicalSoundness.fullyOperational ||
      this == MechanicalSoundness.minorWobble;
}

enum HomesteadRegion {
  shenandoahValley('Shenandoah Valley'),
  maritimeWeavingVillage('Maritime weaving village'),
  frontierTradingPost('Frontier trading post'),
  yorkshireDales('Yorkshire Dales'),
  appalachian('Appalachian'),
  scandinavian('Scandinavian'),
  breton('Breton'),
  himalayan('Himalayan');

  const HomesteadRegion(this.label);
  final String label;
}
