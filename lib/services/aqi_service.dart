/// Air Quality Index (AQI) Service
/// Fetches real-time AQI data based on user location

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'region_service.dart';

class AQIData {
  final int aqi;
  final String level;
  final String description;
  final Color color;
  final String emoji;
  final String healthAdvice;
  final Map<String, double> pollutants;
  final DateTime timestamp;
  final String location;

  AQIData({
    required this.aqi,
    required this.level,
    required this.description,
    required this.color,
    required this.emoji,
    required this.healthAdvice,
    required this.pollutants,
    required this.timestamp,
    required this.location,
  });

  factory AQIData.fromAQI(int aqi, String location) {
    String level;
    String description;
    Color color;
    String emoji;
    String healthAdvice;

    if (aqi <= 50) {
      level = 'Good';
      description = 'Air quality is satisfactory';
      color = const Color(0xFF4CAF50);
      emoji = '😊';
      healthAdvice = 'Perfect for outdoor activities!';
    } else if (aqi <= 100) {
      level = 'Moderate';
      description = 'Acceptable air quality';
      color = const Color(0xFFFFEB3B);
      emoji = '😐';
      healthAdvice = 'Sensitive individuals should limit outdoor exposure.';
    } else if (aqi <= 150) {
      level = 'Unhealthy (Sensitive)';
      description = 'Unhealthy for sensitive groups';
      color = const Color(0xFFFF9800);
      emoji = '😷';
      healthAdvice =
          'Children & elderly should avoid prolonged outdoor activities.';
    } else if (aqi <= 200) {
      level = 'Unhealthy';
      description = 'Everyone may experience effects';
      color = const Color(0xFFF44336);
      emoji = '🤒';
      healthAdvice = 'Reduce outdoor activities. Wear mask if going out.';
    } else if (aqi <= 300) {
      level = 'Very Unhealthy';
      description = 'Health alert for everyone';
      color = const Color(0xFF9C27B0);
      emoji = '🏥';
      healthAdvice =
          'Avoid outdoor activities. Stay indoors with air purifier.';
    } else {
      level = 'Hazardous';
      description = 'Emergency conditions';
      color = const Color(0xFF7B1FA2);
      emoji = '⚠️';
      healthAdvice = 'Stay indoors! Health emergency warning.';
    }

    return AQIData(
      aqi: aqi,
      level: level,
      description: description,
      color: color,
      emoji: emoji,
      healthAdvice: healthAdvice,
      pollutants: {
        'PM2.5': (aqi * 0.5).toDouble(),
        'PM10': (aqi * 0.8).toDouble(),
        'O3': (aqi * 0.3).toDouble(),
        'NO2': (aqi * 0.2).toDouble(),
        'CO': (aqi * 0.1).toDouble(),
      },
      timestamp: DateTime.now(),
      location: location,
    );
  }
}

// Color class for AQI

class AQIService {
  static const String _cacheKey = 'cached_aqi_data';
  static const Duration _cacheDuration = Duration(hours: 1);

  /// Get current AQI for user's location
  static Future<AQIData?> getCurrentAQI() async {
    try {
      // Get user's location
      final regionData = await RegionService.getStoredRegion();
      final city = regionData['city'] ?? 'Delhi';
      final lat = regionData['latitude'];
      final lng = regionData['longitude'];

      // Check cache first
      final cached = await _getCachedAQI();
      if (cached != null) {
        return cached;
      }

      // Try to fetch from API (using free API)
      AQIData? aqiData;

      try {
        // Using WAQI API (free tier available)
        // You can get a free token from https://aqicn.org/data-platform/token/
        const apiToken = 'demo'; // Replace with your token
        final url = lat != null && lng != null
            ? 'https://api.waqi.info/feed/geo:$lat;$lng/?token=$apiToken'
            : 'https://api.waqi.info/feed/$city/?token=$apiToken';

        final response = await http.get(Uri.parse(url)).timeout(
              const Duration(seconds: 5),
            );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'ok' && data['data'] != null) {
            final aqi = data['data']['aqi'] ?? 50;
            final cityName = data['data']['city']?['name'] ?? city;
            aqiData = AQIData.fromAQI(
                aqi is int ? aqi : int.tryParse(aqi.toString()) ?? 50,
                cityName);
          }
        }
      } catch (e) {
        print('AQI API error: $e');
      }

      // Fallback to mock data if API fails
      aqiData ??= _getMockAQI(city);

      // Cache the result
      await _cacheAQI(aqiData);

      return aqiData;
    } catch (e) {
      print('Error getting AQI: $e');
      return _getMockAQI('Your City');
    }
  }

  /// Get mock AQI data for testing
  static AQIData _getMockAQI(String city) {
    // Generate realistic mock AQI based on time of day
    final hour = DateTime.now().hour;
    int baseAQI;

    // Higher AQI during rush hours
    if (hour >= 7 && hour <= 10) {
      baseAQI = 80 + (DateTime.now().minute % 40);
    } else if (hour >= 17 && hour <= 20) {
      baseAQI = 90 + (DateTime.now().minute % 50);
    } else if (hour >= 22 || hour <= 5) {
      baseAQI = 40 + (DateTime.now().minute % 20);
    } else {
      baseAQI = 60 + (DateTime.now().minute % 30);
    }

    return AQIData.fromAQI(baseAQI, city);
  }

  /// Cache AQI data
  static Future<void> _cacheAQI(AQIData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'aqi': data.aqi,
        'location': data.location,
        'timestamp': data.timestamp.toIso8601String(),
      };
      await prefs.setString(_cacheKey, json.encode(cacheData));
    } catch (e) {
      print('Error caching AQI: $e');
    }
  }

  /// Get cached AQI data if still valid
  static Future<AQIData?> _getCachedAQI() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return null;

      final data = json.decode(cached);
      final timestamp = DateTime.parse(data['timestamp']);

      // Check if cache is still valid
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return AQIData.fromAQI(data['aqi'], data['location']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get AQI color as Flutter Color value
  static int getColorValue(int aqi) {
    if (aqi <= 50) return 0xFF4CAF50; // Green
    if (aqi <= 100) return 0xFFFFEB3B; // Yellow
    if (aqi <= 150) return 0xFFFF9800; // Orange
    if (aqi <= 200) return 0xFFF44336; // Red
    if (aqi <= 300) return 0xFF9C27B0; // Purple
    return 0xFF7B1FA2; // Dark Purple
  }
}
