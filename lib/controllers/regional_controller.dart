// regional_controller.dart
// Controller for regional content

import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../repositories/regional_repo.dart';

enum DistanceFilter {
  km0to100,
  km100to200,
  km200to500,
}

class RegionalController extends ChangeNotifier {
  final RegionalRepository _repository = RegionalRepository();

  List<VideoModel> allVideos = [];
  List<VideoModel> filteredVideos = [];

  DistanceFilter selectedFilter = DistanceFilter.km0to100;

  RegionalController() {
    loadVideos();
  }

  void loadVideos() {
    allVideos = _repository.fetchRegionalVideos();
    applyFilter(selectedFilter);
  }

  void applyFilter(DistanceFilter filter) {
    selectedFilter = filter;

    if (filter == DistanceFilter.km0to100) {
      filteredVideos = allVideos.where((v) => v.distanceKm <= 100).toList();
    } else if (filter == DistanceFilter.km100to200) {
      filteredVideos = allVideos
          .where((v) => v.distanceKm > 100 && v.distanceKm <= 200)
          .toList();
    } else {
      filteredVideos = allVideos
          .where((v) => v.distanceKm > 200 && v.distanceKm <= 500)
          .toList();
    }

    notifyListeners();
  }
}
