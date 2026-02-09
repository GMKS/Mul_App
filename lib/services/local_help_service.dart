/// Local Help Service
/// Handles help requests, matching, and community support

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/local_help_model.dart';

class LocalHelpService {
  static final LocalHelpService _instance = LocalHelpService._internal();
  factory LocalHelpService() => _instance;
  LocalHelpService._internal();

  static const String _requestsKey = 'local_help_requests';
  static const String _myRequestsKey = 'my_help_requests';
  static const String _helperStatsKey = 'helper_stats';

  // Create a new help request
  Future<HelpRequest> createHelpRequest({
    required String userId,
    required String userName,
    required HelpCategory category,
    required String subcategory,
    required String description,
    required HelpUrgency urgency,
    required double latitude,
    required double longitude,
    required String address,
    bool isAnonymous = false,
    int expiresInHours = 24,
  }) async {
    final request = HelpRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      userName: isAnonymous ? 'Anonymous' : userName,
      category: category,
      subcategory: subcategory,
      description: description,
      urgency: urgency,
      status: HelpStatus.pending,
      latitude: latitude,
      longitude: longitude,
      address: address,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: expiresInHours)),
      isAnonymous: isAnonymous,
    );

    // Save to local storage (in production, this would go to backend)
    await _saveRequest(request);

    return request;
  }

  // Save request to local storage
  Future<void> _saveRequest(HelpRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final requests = await getMyRequests();
    requests.add(request);

    final jsonList = requests.map((r) => r.toJson()).toList();
    await prefs.setString(_myRequestsKey, jsonEncode(jsonList));
  }

  // Get user's own requests
  Future<List<HelpRequest>> getMyRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_myRequestsKey);

    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => HelpRequest.fromJson(json)).toList();
  }

  // Get nearby help requests (mock data for now)
  Future<List<HelpRequest>> getNearbyRequests({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    HelpCategory? category,
  }) async {
    // In production, this would query backend with location filter
    // For now, return mock data
    return _getMockNearbyRequests(category);
  }

  // Accept a help request
  Future<bool> acceptRequest({
    required String requestId,
    required String helperId,
    required String helperName,
  }) async {
    // In production, this would update the backend
    print('Helper $helperName accepting request $requestId');
    return true;
  }

  // Complete a help request
  Future<bool> completeRequest(String requestId) async {
    // In production, this would update the backend
    print('Completing request $requestId');
    return true;
  }

  // Cancel a help request
  Future<bool> cancelRequest(String requestId) async {
    // In production, this would update the backend
    print('Cancelling request $requestId');
    return true;
  }

  // Get helper stats
  Future<Map<String, dynamic>> getHelperStats(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_helperStatsKey}_$userId');

    if (jsonString == null) {
      return {
        'helpCount': 0,
        'rating': 0.0,
        'badges': <String>[],
        'trustScore': 0,
        'isVerified': false,
      };
    }

    return jsonDecode(jsonString);
  }

  // Update helper stats
  Future<void> updateHelperStats(
      String userId, Map<String, dynamic> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_helperStatsKey}_$userId', jsonEncode(stats));
  }

  // Mock nearby requests
  List<HelpRequest> _getMockNearbyRequests(HelpCategory? filterCategory) {
    final mockRequests = [
      HelpRequest(
        id: '1',
        userId: 'user1',
        userName: 'Ravi Kumar',
        category: HelpCategory.elderFamily,
        subcategory: 'Elder check-in requests',
        description:
            'Please check on my father who lives alone. He hasn\'t answered calls today.',
        urgency: HelpUrgency.high,
        status: HelpStatus.pending,
        latitude: 10.0055,
        longitude: 76.3484,
        address: 'Kakkanad, Kochi',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(hours: 22)),
      ),
      HelpRequest(
        id: '2',
        userId: 'user2',
        userName: 'Priya Menon',
        category: HelpCategory.studentYouth,
        subcategory: 'Resume review help',
        description:
            'Need help reviewing my resume for IT jobs. Fresh graduate.',
        urgency: HelpUrgency.low,
        status: HelpStatus.pending,
        latitude: 10.0100,
        longitude: 76.3500,
        address: 'Infopark, Kakkanad',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        expiresAt: DateTime.now().add(const Duration(hours: 19)),
      ),
      HelpRequest(
        id: '3',
        userId: 'user3',
        userName: 'Anonymous',
        category: HelpCategory.mentalSupport,
        subcategory: 'Exam stress support',
        description:
            'Feeling very anxious about upcoming exams. Need someone to talk to.',
        urgency: HelpUrgency.medium,
        status: HelpStatus.pending,
        latitude: 10.0020,
        longitude: 76.3450,
        address: 'Kakkanad',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().add(const Duration(hours: 23)),
        isAnonymous: true,
      ),
      HelpRequest(
        id: '4',
        userId: 'user4',
        userName: 'Suresh Nair',
        category: HelpCategory.dailyHousehold,
        subcategory: 'Water/gas refill help',
        description:
            'Need help getting LPG cylinder. Unable to carry due to back pain.',
        urgency: HelpUrgency.medium,
        status: HelpStatus.pending,
        latitude: 10.0080,
        longitude: 76.3520,
        address: 'Thrikkakara, Kochi',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        expiresAt: DateTime.now().add(const Duration(hours: 21)),
      ),
      HelpRequest(
        id: '5',
        userId: 'user5',
        userName: 'Mary Thomas',
        category: HelpCategory.governmentCivic,
        subcategory: 'Form filling help',
        description:
            'Need help filling pension form. Not familiar with online process.',
        urgency: HelpUrgency.low,
        status: HelpStatus.pending,
        latitude: 10.0030,
        longitude: 76.3460,
        address: 'Kakkanad, Kochi',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        expiresAt: DateTime.now().add(const Duration(hours: 18)),
      ),
    ];

    if (filterCategory != null) {
      return mockRequests.where((r) => r.category == filterCategory).toList();
    }
    return mockRequests;
  }

  // Get urgency color
  static Color getUrgencyColor(HelpUrgency urgency) {
    switch (urgency) {
      case HelpUrgency.low:
        return const Color(0xFF4CAF50);
      case HelpUrgency.medium:
        return const Color(0xFFFF9800);
      case HelpUrgency.high:
        return const Color(0xFFF44336);
      case HelpUrgency.critical:
        return const Color(0xFF9C27B0);
    }
  }

  // Get urgency label
  static String getUrgencyLabel(HelpUrgency urgency) {
    switch (urgency) {
      case HelpUrgency.low:
        return 'Low';
      case HelpUrgency.medium:
        return 'Medium';
      case HelpUrgency.high:
        return 'High';
      case HelpUrgency.critical:
        return 'Critical';
    }
  }

  // Get status color
  static Color getStatusColor(HelpStatus status) {
    switch (status) {
      case HelpStatus.pending:
        return const Color(0xFFFF9800);
      case HelpStatus.accepted:
        return const Color(0xFF2196F3);
      case HelpStatus.inProgress:
        return const Color(0xFF9C27B0);
      case HelpStatus.completed:
        return const Color(0xFF4CAF50);
      case HelpStatus.cancelled:
        return const Color(0xFF9E9E9E);
      case HelpStatus.expired:
        return const Color(0xFF795548);
    }
  }
}
