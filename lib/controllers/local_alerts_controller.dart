import 'package:flutter/material.dart';
import '../models/local_alert_model.dart';
import '../repositories/local_alerts_repo.dart';

// Local Alerts Controller

enum AlertDistanceFilter {
  all,
  km0to5,
  km5to10,
  km10to20,
}

class LocalAlertsController extends ChangeNotifier {
  final LocalAlertsRepository _repository = LocalAlertsRepository();

  List<LocalAlert> allAlerts = [];
  List<LocalAlert> runtimeAlerts = [];
  List<LocalAlert> filteredAlerts = [];
  bool isLoading = false;
  String? error;

  AlertDistanceFilter selectedFilter = AlertDistanceFilter.all;

  // Add alert from FCM notification data
  void addAlertFromNotification(Map<String, dynamic> data) {
    final alert = LocalAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: data['title'] ?? 'Alert',
      message: data['customKey'] ?? data['body'] ?? '',
      area: data['area'] ?? '',
      locality: data['locality'] ?? '',
      distanceKm: 0,
      startTime: DateTime.now(),
      expiryTime: null,
      icon: null,
      category: data['category'] ?? 'announcement',
    );
    runtimeAlerts.insert(0, alert);
    _mergeAlerts();
    applyFilter(selectedFilter);
    notifyListeners();
  }

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
      allAlerts = allAlerts.where((alert) => alert.isActive).toList();
      allAlerts.sort((a, b) => b.startTime.compareTo(a.startTime));
      _mergeAlerts();
      applyFilter(selectedFilter);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _mergeAlerts() {
    // Combine loaded alerts and runtime alerts, with runtime alerts first
    allAlerts = [...runtimeAlerts, ...allAlerts];
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
