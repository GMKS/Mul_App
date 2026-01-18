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

  List<LocalAlert> _loadedAlerts = []; // Alerts from repository
  List<LocalAlert> runtimeAlerts = []; // Alerts from FCM notifications
  List<LocalAlert> allAlerts = []; // Combined alerts
  List<LocalAlert> filteredAlerts = [];
  bool isLoading = false;
  String? error;

  AlertDistanceFilter selectedFilter = AlertDistanceFilter.all;

  // Add alert from FCM notification data
  void addAlertFromNotification(Map<String, dynamic> data) {
    debugPrint('🔥🔥 addAlertFromNotification called with data: $data');

    // Extract message from customKey (your Telugu text) or fall back to body
    String message = '';
    if (data['customKey'] != null && data['customKey'].toString().isNotEmpty) {
      message = data['customKey'].toString();
      debugPrint('✅ Using customKey: $message');
    } else if (data['body'] != null && data['body'].toString().isNotEmpty) {
      message = data['body'].toString();
      debugPrint('⚠️ Using body: $message');
    } else if (data['message'] != null) {
      message = data['message'].toString();
      debugPrint('⚠️ Using message: $message');
    }

    debugPrint('🔥 Final message to display: $message');

    final title = data['title']?.toString() ?? 'Alert';
    final category = data['category']?.toString() ?? 'announcement';

    // Check if an alert with the same title and message already exists
    final isDuplicate = runtimeAlerts.any((existingAlert) =>
        existingAlert.title == title &&
        existingAlert.message == message &&
        existingAlert.category == category);

    if (isDuplicate) {
      debugPrint('⚠️ Duplicate alert detected - skipping');
      return;
    }

    final alert = LocalAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      area: data['area']?.toString() ?? '',
      locality: data['locality']?.toString() ?? '',
      distanceKm: 0,
      startTime: DateTime.now(),
      expiryTime: null,
      icon: null,
      category: category,
    );

    debugPrint('🔥 Created alert: ${alert.title} - ${alert.message}');
    runtimeAlerts.insert(0, alert);
    debugPrint('🔥 runtimeAlerts count: ${runtimeAlerts.length}');
    _mergeAlerts();
    debugPrint('🔥 allAlerts count after merge: ${allAlerts.length}');
    applyFilter(selectedFilter);
    debugPrint(
        '🔥 filteredAlerts count after filter: ${filteredAlerts.length}');
    notifyListeners();
    debugPrint('✅ Listeners notified!');
  }

  Future<void> loadAlerts({
    required String city,
    required String state,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _loadedAlerts = await _repository.fetchLocalAlerts(
        city: city,
        state: state,
      );
      _loadedAlerts = _loadedAlerts.where((alert) => alert.isActive).toList();
      _loadedAlerts.sort((a, b) => b.startTime.compareTo(a.startTime));
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
    // Combine runtime alerts (FCM) and loaded alerts (repository)
    // Runtime alerts first (most recent)
    allAlerts = [...runtimeAlerts, ..._loadedAlerts];
    debugPrint(
        '📊 Merged alerts: ${runtimeAlerts.length} runtime + ${_loadedAlerts.length} loaded = ${allAlerts.length} total');
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
