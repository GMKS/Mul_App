// BUSINESS FEATURE 10: Boost Video Service
// Allow BUSINESS users to boost a video for their city

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/business_video_model.dart';
import 'business_subscription_service.dart';

class BusinessBoostService {
  static const String _boostsKey = 'video_boosts';

  /// Boost duration options
  static const Map<String, BoostOption> boostOptions = {
    '24h': BoostOption(
      id: '24h',
      name: '24 Hours',
      duration: Duration(hours: 24),
      price: 99,
      multiplier: 1.5,
    ),
    '3d': BoostOption(
      id: '3d',
      name: '3 Days',
      duration: Duration(days: 3),
      price: 249,
      multiplier: 2.0,
    ),
    '7d': BoostOption(
      id: '7d',
      name: '7 Days',
      duration: Duration(days: 7),
      price: 499,
      multiplier: 2.5,
    ),
  };

  /// Boost a video
  static Future<Map<String, dynamic>> boostVideo({
    required String videoId,
    required String userId,
    required String boostOptionId,
    required String targetCity,
  }) async {
    try {
      // Check if user can boost
      final canBoost = await BusinessSubscriptionService.canBoost(userId);
      if (!canBoost) {
        return {
          'success': false,
          'message':
              'You have used all your boosts for this month. Upgrade your plan for more boosts.',
        };
      }

      final option = boostOptions[boostOptionId];
      if (option == null) {
        return {
          'success': false,
          'message': 'Invalid boost option',
        };
      }

      final boost = VideoBoost(
        id: 'boost_${DateTime.now().millisecondsSinceEpoch}',
        videoId: videoId,
        userId: userId,
        boostOption: boostOptionId,
        targetCity: targetCity,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(option.duration),
        rankingMultiplier: option.multiplier,
        isActive: true,
      );

      // Save boost
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_boostsKey);
      List<dynamic> boosts = [];
      if (data != null) {
        boosts = json.decode(data) as List;
      }
      boosts.add(boost.toJson());
      await prefs.setString(_boostsKey, json.encode(boosts));

      return {
        'success': true,
        'boost': boost,
        'message': 'Video boosted successfully for ${option.name}!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to boost video: $e',
      };
    }
  }

  /// Get active boosts for a video
  static Future<VideoBoost?> getActiveBoost(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_boostsKey);

    if (data == null) return null;

    final boosts = (json.decode(data) as List)
        .map((b) => VideoBoost.fromJson(b))
        .where((b) => b.videoId == videoId && b.isCurrentlyActive)
        .toList();

    return boosts.isNotEmpty ? boosts.first : null;
  }

  /// Get all active boosts for a user
  static Future<List<VideoBoost>> getUserBoosts(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_boostsKey);

    if (data == null) return [];

    return (json.decode(data) as List)
        .map((b) => VideoBoost.fromJson(b))
        .where((b) => b.userId == userId)
        .toList();
  }

  /// Get boost multiplier for a video
  static Future<double> getBoostMultiplier(String videoId) async {
    final boost = await getActiveBoost(videoId);
    return boost?.rankingMultiplier ?? 1.0;
  }

  /// Check if video is boosted
  static Future<bool> isVideoBoosted(String videoId) async {
    final boost = await getActiveBoost(videoId);
    return boost != null && boost.isCurrentlyActive;
  }

  /// Cancel a boost
  static Future<bool> cancelBoost(String boostId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_boostsKey);

    if (data == null) return false;

    final boosts =
        (json.decode(data) as List).map((b) => VideoBoost.fromJson(b)).toList();

    final index = boosts.indexWhere((b) => b.id == boostId);
    if (index == -1) return false;

    boosts[index] = boosts[index].copyWith(isActive: false);
    await prefs.setString(
        _boostsKey, json.encode(boosts.map((b) => b.toJson()).toList()));

    return true;
  }
}

/// Boost option configuration
class BoostOption {
  final String id;
  final String name;
  final Duration duration;
  final double price;
  final double multiplier;

  const BoostOption({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.multiplier,
  });

  String get priceDisplay => '₹${price.toInt()}';
}

/// Video boost data
class VideoBoost {
  final String id;
  final String videoId;
  final String userId;
  final String boostOption;
  final String targetCity;
  final DateTime startTime;
  final DateTime endTime;
  final double rankingMultiplier;
  final bool isActive;

  VideoBoost({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.boostOption,
    required this.targetCity,
    required this.startTime,
    required this.endTime,
    required this.rankingMultiplier,
    required this.isActive,
  });

  bool get isCurrentlyActive => isActive && endTime.isAfter(DateTime.now());

  Duration get remainingTime => endTime.difference(DateTime.now());

  String get remainingTimeDisplay {
    final remaining = remainingTime;
    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    } else {
      return '${remaining.inMinutes}m';
    }
  }

  factory VideoBoost.fromJson(Map<String, dynamic> json) {
    return VideoBoost(
      id: json['id'],
      videoId: json['videoId'],
      userId: json['userId'],
      boostOption: json['boostOption'],
      targetCity: json['targetCity'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      rankingMultiplier: (json['rankingMultiplier'] ?? 1.0).toDouble(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'userId': userId,
      'boostOption': boostOption,
      'targetCity': targetCity,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'rankingMultiplier': rankingMultiplier,
      'isActive': isActive,
    };
  }

  VideoBoost copyWith({
    String? id,
    String? videoId,
    String? userId,
    String? boostOption,
    String? targetCity,
    DateTime? startTime,
    DateTime? endTime,
    double? rankingMultiplier,
    bool? isActive,
  }) {
    return VideoBoost(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userId: userId ?? this.userId,
      boostOption: boostOption ?? this.boostOption,
      targetCity: targetCity ?? this.targetCity,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rankingMultiplier: rankingMultiplier ?? this.rankingMultiplier,
      isActive: isActive ?? this.isActive,
    );
  }
}
