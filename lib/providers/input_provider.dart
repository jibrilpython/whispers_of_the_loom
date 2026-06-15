import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whispers_of_the_loom/enum/my_enums.dart';
import 'package:whispers_of_the_loom/utils/const.dart';

class InputNotifier extends ChangeNotifier {
  String _spindleRegistryScroll = '';
  CraftClassification _craftClassification = CraftClassification.dropSpindle;
  FiberType _fiberType = FiberType.wool;
  String _artisanHallmark = '';
  String _era = '';
  String _orificeWhorlGeometry = '';
  String _timberJoineryComposition = '';
  String _teethCountDensity = '';
  String _physicalProportions = '';
  MechanicalSoundness _mechanicalSoundness = MechanicalSoundness.unknown;
  HomesteadRegion _homesteadRegion = HomesteadRegion.shenandoahValley;
  String _homesteadGroundZero = '';
  String _temperatureRange = '';
  String _calibrationFacility = '';
  String _notes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get spindleRegistryScroll => _spindleRegistryScroll;
  CraftClassification get craftClassification => _craftClassification;
  FiberType get fiberType => _fiberType;
  String get artisanHallmark => _artisanHallmark;
  String get era => _era;
  String get orificeWhorlGeometry => _orificeWhorlGeometry;
  String get timberJoineryComposition => _timberJoineryComposition;
  String get teethCountDensity => _teethCountDensity;
  String get physicalProportions => _physicalProportions;
  MechanicalSoundness get mechanicalSoundness => _mechanicalSoundness;
  HomesteadRegion get homesteadRegion => _homesteadRegion;
  String get homesteadGroundZero => _homesteadGroundZero;
  String get temperatureRange => _temperatureRange;
  String get calibrationFacility => _calibrationFacility;
  String get notes => _notes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set spindleRegistryScroll(String v) {
    _spindleRegistryScroll = v;
    notifyListeners();
  }

  set craftClassification(CraftClassification v) {
    _craftClassification = v;
    notifyListeners();
  }

  set fiberType(FiberType v) {
    _fiberType = v;
    notifyListeners();
  }

  set artisanHallmark(String v) {
    _artisanHallmark = v;
    notifyListeners();
  }

  set era(String v) {
    _era = v;
    notifyListeners();
  }

  set orificeWhorlGeometry(String v) {
    _orificeWhorlGeometry = v;
    notifyListeners();
  }

  set timberJoineryComposition(String v) {
    _timberJoineryComposition = v;
    notifyListeners();
  }

  set teethCountDensity(String v) {
    _teethCountDensity = v;
    notifyListeners();
  }

  set physicalProportions(String v) {
    _physicalProportions = v;
    notifyListeners();
  }

  set mechanicalSoundness(MechanicalSoundness v) {
    _mechanicalSoundness = v;
    notifyListeners();
  }

  set homesteadRegion(HomesteadRegion v) {
    _homesteadRegion = v;
    notifyListeners();
  }

  set homesteadGroundZero(String v) {
    _homesteadGroundZero = v;
    notifyListeners();
  }

  set temperatureRange(String v) {
    _temperatureRange = v;
    notifyListeners();
  }

  set calibrationFacility(String v) {
    _calibrationFacility = v;
    notifyListeners();
  }

  set notes(String v) {
    _notes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void prepareNewEntry() {
    _spindleRegistryScroll = generateRegistryScroll(_fiberType);
    _craftClassification = CraftClassification.dropSpindle;
    _fiberType = FiberType.wool;
    _artisanHallmark = '';
    _era = '';
    _orificeWhorlGeometry = '';
    _timberJoineryComposition = '';
    _teethCountDensity = '';
    _physicalProportions = '';
    _mechanicalSoundness = MechanicalSoundness.unknown;
    _homesteadRegion = HomesteadRegion.shenandoahValley;
    _homesteadGroundZero = '';
    _temperatureRange = '';
    _calibrationFacility = '';
    _notes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }

  void clearAll() {
    prepareNewEntry();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
