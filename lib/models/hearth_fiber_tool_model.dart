import 'package:whispers_of_the_loom/enum/my_enums.dart';

class HearthFiberToolModel {
  String id;
  String spindleRegistryScroll;
  CraftClassification craftClassification;
  FiberType fiberType;
  String artisanHallmark;
  String era;
  String orificeWhorlGeometry;
  String timberJoineryComposition;
  String teethCountDensity;
  String physicalProportions;
  MechanicalSoundness mechanicalSoundness;
  HomesteadRegion homesteadRegion;
  String homesteadGroundZero;
  String temperatureRange;
  String calibrationFacility;
  String notes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  HearthFiberToolModel({
    required this.id,
    required this.spindleRegistryScroll,
    required this.craftClassification,
    required this.fiberType,
    required this.artisanHallmark,
    required this.era,
    required this.orificeWhorlGeometry,
    required this.timberJoineryComposition,
    required this.teethCountDensity,
    required this.physicalProportions,
    required this.mechanicalSoundness,
    required this.homesteadRegion,
    required this.homesteadGroundZero,
    required this.temperatureRange,
    required this.calibrationFacility,
    required this.notes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'spindleRegistryScroll': spindleRegistryScroll,
        'craftClassification': craftClassification.name,
        'fiberType': fiberType.name,
        'artisanHallmark': artisanHallmark,
        'era': era,
        'orificeWhorlGeometry': orificeWhorlGeometry,
        'timberJoineryComposition': timberJoineryComposition,
        'teethCountDensity': teethCountDensity,
        'physicalProportions': physicalProportions,
        'mechanicalSoundness': mechanicalSoundness.name,
        'homesteadRegion': homesteadRegion.name,
        'homesteadGroundZero': homesteadGroundZero,
        'temperatureRange': temperatureRange,
        'calibrationFacility': calibrationFacility,
        'notes': notes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory HearthFiberToolModel.fromJson(Map<String, dynamic> json) =>
      HearthFiberToolModel(
        id: json['id'] ?? '',
        spindleRegistryScroll: json['spindleRegistryScroll'] ?? '',
        craftClassification: CraftClassification.values
                .asNameMap()[json['craftClassification']] ??
            CraftClassification.dropSpindle,
        fiberType:
            FiberType.values.asNameMap()[json['fiberType']] ?? FiberType.wool,
        artisanHallmark: json['artisanHallmark'] ?? '',
        era: json['era'] ?? '',
        orificeWhorlGeometry: json['orificeWhorlGeometry'] ?? '',
        timberJoineryComposition: json['timberJoineryComposition'] ?? '',
        teethCountDensity: json['teethCountDensity'] ?? '',
        physicalProportions: json['physicalProportions'] ?? '',
        mechanicalSoundness: MechanicalSoundness.values
                .asNameMap()[json['mechanicalSoundness']] ??
            MechanicalSoundness.unknown,
        homesteadRegion: HomesteadRegion.values
                .asNameMap()[json['homesteadRegion']] ??
            HomesteadRegion.shenandoahValley,
        homesteadGroundZero: json['homesteadGroundZero'] ?? '',
        temperatureRange: json['temperatureRange'] ?? '',
        calibrationFacility: json['calibrationFacility'] ?? '',
        notes: json['notes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
