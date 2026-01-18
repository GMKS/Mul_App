/// Temple Service
/// Service for fetching temples with distance-based filtering

import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/temple_model.dart';
import '../models/devotional_video_model.dart';

class TempleService {
  static const String _userLatKey = 'user_latitude';
  static const String _userLngKey = 'user_longitude';

  /// Get user's current location
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // Cache the location
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_userLatKey, position.latitude);
      await prefs.setDouble(_userLngKey, position.longitude);

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get cached user location
  static Future<Position?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_userLatKey);
      final lng = prefs.getDouble(_userLngKey);

      if (lat != null && lng != null) {
        return Position(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two coordinates in km
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Fetch temples with distance-based filtering
  static Future<List<Temple>> fetchTemples({
    String? religion,
    DistanceCategory? distanceCategory,
    List<String>? festivalTags,
    double? userLat,
    double? userLng,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    List<Temple> temples = Temple.getPredefinedTemples();

    // Filter by religion
    if (religion != null && religion.isNotEmpty) {
      temples = temples
          .where((t) => t.religion.toLowerCase() == religion.toLowerCase())
          .toList();
    }

    // Filter by festival tags
    if (festivalTags != null && festivalTags.isNotEmpty) {
      temples = temples.where((t) {
        return t.festivalTags.any((tag) => festivalTags.contains(tag));
      }).toList();
    }

    // Calculate distances if user location is available
    if (userLat != null && userLng != null) {
      temples = temples.map((temple) {
        final distance = calculateDistanceKm(
          userLat,
          userLng,
          temple.latitude,
          temple.longitude,
        );
        return temple.copyWith(distanceKm: distance);
      }).toList();

      // Filter by distance category
      if (distanceCategory != null) {
        temples = temples.where((t) {
          if (t.distanceKm == null) return false;
          return t.distanceKm! >= distanceCategory.minKm &&
              t.distanceKm! <= distanceCategory.maxKm;
        }).toList();
      }

      // Sort by distance
      temples.sort((a, b) {
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });
    }

    return temples.take(limit).toList();
  }

  /// Fetch nearby temples within a specific km range
  static Future<List<Temple>> fetchNearbyTemples({
    required double userLat,
    required double userLng,
    double maxDistanceKm = 100,
    String? religion,
    int limit = 10,
  }) async {
    final temples = await fetchTemples(
      religion: religion,
      userLat: userLat,
      userLng: userLng,
    );

    return temples
        .where((t) => t.distanceKm != null && t.distanceKm! <= maxDistanceKm)
        .take(limit)
        .toList();
  }

  /// Get temples by distance bucket
  static Future<Map<DistanceCategory, List<Temple>>>
      getTemplesByDistanceBucket({
    required double userLat,
    required double userLng,
    String? religion,
  }) async {
    final allTemples = await fetchTemples(
      religion: religion,
      userLat: userLat,
      userLng: userLng,
      limit: 100,
    );

    final Map<DistanceCategory, List<Temple>> buckets = {
      DistanceCategory.nearby: [],
      DistanceCategory.medium: [],
      DistanceCategory.far: [],
      DistanceCategory.national: [],
    };

    for (final temple in allTemples) {
      if (temple.distanceKm != null) {
        final category = DistanceCategory.fromKm(temple.distanceKm!);
        buckets[category]?.add(temple);
      }
    }

    return buckets;
  }
}
