// STEP 2: Region Detection (State / City)
// Detect user region using device locale or IP.
// Store state and city in user profile.
// Use fallback if location permission is denied.

import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class RegionService {
  static const String _regionKey = 'user_region';
  static const String _stateKey = 'user_state';
  static const String _cityKey = 'user_city';
  static const String _villageKey = 'user_village';
  static const String _latitudeKey = 'user_latitude';
  static const String _longitudeKey = 'user_longitude';
  static const String _regionDetectedKey = 'region_detected';

  // Indian states with their regions
  static final Map<String, String> stateToRegion = {
    // North India
    'Delhi': 'North',
    'Uttar Pradesh': 'North',
    'Punjab': 'North',
    'Haryana': 'North',
    'Rajasthan': 'North',
    'Himachal Pradesh': 'North',
    'Uttarakhand': 'North',
    'Jammu and Kashmir': 'North',
    'Ladakh': 'North',
    'Chandigarh': 'North',

    // South India
    'Tamil Nadu': 'South',
    'Karnataka': 'South',
    'Kerala': 'South',
    'Andhra Pradesh': 'South',
    'Telangana': 'South',
    'Puducherry': 'South',

    // East India
    'West Bengal': 'East',
    'Bihar': 'East',
    'Jharkhand': 'East',
    'Odisha': 'East',
    'Sikkim': 'East',

    // West India
    'Maharashtra': 'West',
    'Gujarat': 'West',
    'Goa': 'West',
    'Dadra and Nagar Haveli': 'West',
    'Daman and Diu': 'West',

    // Central India
    'Madhya Pradesh': 'Central',
    'Chhattisgarh': 'Central',

    // Northeast India
    'Assam': 'Northeast',
    'Meghalaya': 'Northeast',
    'Manipur': 'Northeast',
    'Mizoram': 'Northeast',
    'Tripura': 'Northeast',
    'Nagaland': 'Northeast',
    'Arunachal Pradesh': 'Northeast',
  };

  // Detect region from device locale
  static Future<Map<String, String>> detectRegionFromLocale() async {
    try {
      final locale = Platform.localeName;
      // Parse locale to get region hint
      // Example: en_IN -> India
      final parts = locale.split('_');
      if (parts.length > 1) {
        final countryCode = parts[1];
        if (countryCode == 'IN') {
          // Default to most common region if in India
          return {
            'region': 'North',
            'state': 'Delhi',
            'city': 'New Delhi',
            'source': 'locale',
          };
        }
      }
    } catch (e) {
      // Fallback
    }

    return {
      'region': 'North',
      'state': 'Delhi',
      'city': 'New Delhi',
      'source': 'fallback',
    };
  }

  // Detect region from IP (mock implementation)
  static Future<Map<String, String>> detectRegionFromIP() async {
    try {
      // TODO: Implement actual IP geolocation API call
      // Example:
      // final response = await http.get(Uri.parse('https://ipapi.co/json/'));
      // final data = json.decode(response.body);
      // return {
      //   'region': data['region'],
      //   'state': data['region'],
      //   'city': data['city'],
      // };

      await Future.delayed(const Duration(seconds: 1));

      // Mock response
      return {
        'region': 'South',
        'state': 'Karnataka',
        'city': 'Bangalore',
        'source': 'ip',
      };
    } catch (e) {
      return detectRegionFromLocale();
    }
  }

  // Save region locally
  static Future<void> saveRegion({
    required String region,
    required String state,
    required String city,
    String? village,
    double? latitude,
    double? longitude,
  }) async {
    print('💾 DEBUG RegionService saveRegion called:');
    print('  Region: $region, State: $state, City: $city, Village: $village');
    print('  Lat: $latitude, Lng: $longitude');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, region);
    await prefs.setString(_stateKey, state);
    await prefs.setString(_cityKey, city);
    if (village != null && village.isNotEmpty) {
      await prefs.setString(_villageKey, village);
    } else {
      await prefs.remove(_villageKey);
    }
    if (latitude != null) {
      await prefs.setDouble(_latitudeKey, latitude);
    }
    if (longitude != null) {
      await prefs.setDouble(_longitudeKey, longitude);
    }
    await prefs.setBool(_regionDetectedKey, true);

    print('  ✅ Saved to SharedPreferences');
  }

  // Save region data (alias for map region selection screen)
  static Future<void> saveRegionData({
    required String region,
    required String state,
    required String city,
    String? village,
    double? latitude,
    double? longitude,
  }) async {
    print('💾 DEBUG RegionService saveRegionData called (alias):');
    await saveRegion(
      region: region,
      state: state,
      city: city,
      village: village,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Get stored region
  static Future<Map<String, dynamic>> getStoredRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'region': prefs.getString(_regionKey) ?? '',
      'state': prefs.getString(_stateKey) ?? '',
      'city': prefs.getString(_cityKey) ?? '',
      'village': prefs.getString(_villageKey) ?? '',
      'latitude': prefs.getDouble(_latitudeKey),
      'longitude': prefs.getDouble(_longitudeKey),
    };

    print('📖 DEBUG RegionService getStoredRegion:');
    print('  Data retrieved: $data');

    return data;
  }

  // Check if region has been detected
  static Future<bool> hasDetectedRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_regionDetectedKey) ?? false;
  }

  // Auto-detect and save region
  static Future<Map<String, String>> autoDetectRegion() async {
    // Try IP detection first
    var regionData = await detectRegionFromIP();

    // If failed, try locale
    if (regionData['source'] == 'fallback') {
      regionData = await detectRegionFromLocale();
    }

    // Save detected region
    await saveRegion(
      region: regionData['region']!,
      state: regionData['state']!,
      city: regionData['city']!,
    );

    return regionData;
  }

  // Get region from state
  static String getRegionFromState(String state) {
    return stateToRegion[state] ?? 'North';
  }

  // Get all states
  static List<String> getAllStates() {
    return stateToRegion.keys.toList()..sort();
  }

  // Get states by region
  static List<String> getStatesByRegion(String region) {
    return stateToRegion.entries
        .where((e) => e.value == region)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  // Get all regions
  static List<String> getAllRegions() {
    return stateToRegion.values.toSet().toList()..sort();
  }

  // Sync to backend
  static Future<void> syncToBackend(
      String userId, String region, String state, String city) async {
    // TODO: Implement actual backend sync
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
