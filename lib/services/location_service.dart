import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Location Service - Auto-detect user location
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check if location permissions are granted
  Future<bool> checkLocationPermission() async {
    print('📍 Checking location permission...');

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      return false;
    }
    print('✅ Location services enabled');

    LocationPermission permission = await Geolocator.checkPermission();
    print('📍 Current permission status: $permission');

    if (permission == LocationPermission.denied) {
      print('📍 Requesting permission...');
      permission = await Geolocator.requestPermission();
      print('📍 Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        print('❌ Permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Permission denied forever - user must enable in settings');
      return false;
    }

    print('✅ Permission granted: $permission');
    return true;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      print('📍 Getting current position...');
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        print('❌ No permission to get position');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      print('✅ Got position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<LocationData?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      // Debug logging to understand what data we're getting
      print('🗺️ Reverse Geocoding Results:');
      print('  subLocality: ${place.subLocality}');
      print('  locality: ${place.locality}');
      print('  subAdministrativeArea: ${place.subAdministrativeArea}');
      print('  administrativeArea: ${place.administrativeArea}');
      print('  thoroughfare: ${place.thoroughfare}');
      print('  subThoroughfare: ${place.subThoroughfare}');
      print('  name: ${place.name}');

      // Priority for village/neighborhood: subLocality > thoroughfare > name
      String village =
          place.subLocality ?? place.thoroughfare ?? place.name ?? '';

      // City should be the locality, not subLocality
      String city = place.locality ?? place.subAdministrativeArea ?? '';

      // District for wider area context
      String district = place.subAdministrativeArea ?? place.locality ?? '';

      print(
          '  ➡️ Extracted - Village: $village, City: $city, District: $district');

      return LocationData(
        latitude: latitude,
        longitude: longitude,
        country: place.country ?? '',
        state: place.administrativeArea ?? '',
        district: district,
        city: city,
        village: village,
        postalCode: place.postalCode ?? '',
        fullAddress: _formatFullAddress(place),
      );
    } catch (e) {
      print('Error in reverse geocoding: $e');
      return null;
    }
  }

  /// Auto-detect location and get full address
  Future<LocationData?> autoDetectLocation() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return null;

      return await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Error in auto-detect location: $e');
      return null;
    }
  }

  /// Format full address from placemark
  String _formatFullAddress(Placemark place) {
    final parts = <String>[];

    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      parts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }
    if (place.subAdministrativeArea != null &&
        place.subAdministrativeArea!.isNotEmpty) {
      parts.add(place.subAdministrativeArea!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      parts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      parts.add(place.country!);
    }

    return parts.join(', ');
  }
}

/// Location Data Model
class LocationData {
  final double latitude;
  final double longitude;
  final String country;
  final String state;
  final String district;
  final String city;
  final String village;
  final String postalCode;
  final String fullAddress;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.state,
    required this.district,
    required this.city,
    required this.village,
    required this.postalCode,
    required this.fullAddress,
  });

  /// Get formatted display string - prioritize village/locality for more specific location
  String get displayString {
    // Priority: village > city > district > state
    if (village.isNotEmpty && village != city) {
      return '$village, $city';
    } else if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    } else if (district.isNotEmpty && state.isNotEmpty) {
      return '$district, $state';
    } else if (state.isNotEmpty) {
      return state;
    }
    return fullAddress;
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'state': state,
      'district': district,
      'city': city,
      'village': village,
      'postalCode': postalCode,
      'fullAddress': fullAddress,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      village: json['village'] ?? '',
      postalCode: json['postalCode'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
    );
  }
}
