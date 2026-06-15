import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whispers_of_the_loom/models/hearth_fiber_tool_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<HearthFiberToolModel> filteredList(List<HearthFiberToolModel> list) {
    if (searchQuery.isEmpty) return list;

    final query = searchQuery.toLowerCase();
    return list
        .where(
          (item) =>
              item.spindleRegistryScroll.toLowerCase().contains(query) ||
              item.artisanHallmark.toLowerCase().contains(query) ||
              item.timberJoineryComposition.toLowerCase().contains(query) ||
              item.homesteadGroundZero.toLowerCase().contains(query) ||
              item.era.toLowerCase().contains(query) ||
              item.orificeWhorlGeometry.toLowerCase().contains(query) ||
              item.calibrationFacility.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)),
        )
        .toList();
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
