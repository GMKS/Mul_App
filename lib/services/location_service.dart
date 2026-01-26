import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Location Service - Auto-detect user location
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location permissions are granted
  Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current position: $e');
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

      return LocationData(
        latitude: latitude,
        longitude: longitude,
        country: place.country ?? '',
        state: place.administrativeArea ?? '',
        district: place.subAdministrativeArea ?? place.locality ?? '',
        city: place.locality ?? place.subLocality ?? '',
        village: place.subLocality ?? '',
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

  /// Get formatted display string
  String get displayString {
    if (city.isNotEmpty && state.isNotEmpty) {
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
