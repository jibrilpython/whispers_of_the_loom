import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';
import 'package:whispers_of_the_loom/providers/image_provider.dart';
import 'package:whispers_of_the_loom/providers/input_provider.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<HearthFiberToolModel> entries = [];
  bool isLoading = true;
  static const String _storageKey = 'wol_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => HearthFiberToolModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  void addEntry(WidgetRef ref) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);

    entries.add(
      HearthFiberToolModel(
        id: _uuid.v4(),
        spindleRegistryScroll: p.spindleRegistryScroll,
        craftClassification: p.craftClassification,
        fiberType: p.fiberType,
        artisanHallmark: p.artisanHallmark,
        era: p.era,
        orificeWhorlGeometry: p.orificeWhorlGeometry,
        timberJoineryComposition: p.timberJoineryComposition,
        teethCountDensity: p.teethCountDensity,
        physicalProportions: p.physicalProportions,
        mechanicalSoundness: p.mechanicalSoundness,
        homesteadRegion: p.homesteadRegion,
        homesteadGroundZero: p.homesteadGroundZero,
        temperatureRange: p.temperatureRange,
        calibrationFacility: p.calibrationFacility,
        notes: p.notes,
        photoPath:
            imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
        tags: List<String>.from(p.tags),
        dateAdded: p.dateAdded,
      ),
    );

    _save();
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final existing = entries[index];

    entries[index] = HearthFiberToolModel(
      id: existing.id,
      spindleRegistryScroll: p.spindleRegistryScroll,
      craftClassification: p.craftClassification,
      fiberType: p.fiberType,
      artisanHallmark: p.artisanHallmark,
      era: p.era,
      orificeWhorlGeometry: p.orificeWhorlGeometry,
      timberJoineryComposition: p.timberJoineryComposition,
      teethCountDensity: p.teethCountDensity,
      physicalProportions: p.physicalProportions,
      mechanicalSoundness: p.mechanicalSoundness,
      homesteadRegion: p.homesteadRegion,
      homesteadGroundZero: p.homesteadGroundZero,
      temperatureRange: p.temperatureRange,
      calibrationFacility: p.calibrationFacility,
      notes: p.notes,
      photoPath: imgProv.resultImage.isNotEmpty
          ? imgProv.resultImage
          : existing.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: existing.dateAdded,
    );

    _save();
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    _save();
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.spindleRegistryScroll = entry.spindleRegistryScroll;
    p.craftClassification = entry.craftClassification;
    p.fiberType = entry.fiberType;
    p.artisanHallmark = entry.artisanHallmark;
    p.era = entry.era;
    p.orificeWhorlGeometry = entry.orificeWhorlGeometry;
    p.timberJoineryComposition = entry.timberJoineryComposition;
    p.teethCountDensity = entry.teethCountDensity;
    p.physicalProportions = entry.physicalProportions;
    p.mechanicalSoundness = entry.mechanicalSoundness;
    p.homesteadRegion = entry.homesteadRegion;
    p.homesteadGroundZero = entry.homesteadGroundZero;
    p.temperatureRange = entry.temperatureRange;
    p.calibrationFacility = entry.calibrationFacility;
    p.notes = entry.notes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;
    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
