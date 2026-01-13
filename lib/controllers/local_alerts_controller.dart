// Local Alerts Controller
import 'package:flutter/material.dart';
import '../models/local_alert_model.dart';
import '../repositories/local_alerts_repo.dart';

enum AlertDistanceFilter {
  all,
  km0to5,
  km5to10,
  km10to20,
}

class LocalAlertsController extends ChangeNotifier {
  final LocalAlertsRepository _repository = LocalAlertsRepository();

  List<LocalAlert> allAlerts = [];
  List<LocalAlert> filteredAlerts = [];
  bool isLoading = false;
  String? error;

  AlertDistanceFilter selectedFilter = AlertDistanceFilter.all;

  Future<void> loadAlerts({
    required String city,
    required String state,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      allAlerts = await _repository.fetchLocalAlerts(
        city: city,
        state: state,
      );

      // Filter out expired alerts
      allAlerts = allAlerts.where((alert) => alert.isActive).toList();

      // Sort by start time (latest first)
      allAlerts.sort((a, b) => b.startTime.compareTo(a.startTime));

      applyFilter(selectedFilter);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applyFilter(AlertDistanceFilter filter) {
    selectedFilter = filter;

    switch (filter) {
      case AlertDistanceFilter.all:
        filteredAlerts = allAlerts;
        break;
      case AlertDistanceFilter.km0to5:
        filteredAlerts = allAlerts.where((a) => a.distanceKm <= 5).toList();
        break;
      case AlertDistanceFilter.km5to10:
        filteredAlerts = allAlerts
            .where((a) => a.distanceKm > 5 && a.distanceKm <= 10)
            .toList();
        break;
      case AlertDistanceFilter.km10to20:
        filteredAlerts = allAlerts
            .where((a) => a.distanceKm > 10 && a.distanceKm <= 20)
            .toList();
        break;
    }

    notifyListeners();
  }

  Future<void> refresh({
    required String city,
    required String state,
  }) async {
    await loadAlerts(city: city, state: state);
  }
}
