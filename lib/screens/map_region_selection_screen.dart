import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/region_service.dart';
import 'home_screen.dart';

class MapRegionSelectionScreen extends StatefulWidget {
  final bool isInitialSetup;
  final VoidCallback? onComplete;

  const MapRegionSelectionScreen({
    super.key,
    this.isInitialSetup = true,
    this.onComplete,
  });

  @override
  State<MapRegionSelectionScreen> createState() =>
      _MapRegionSelectionScreenState();
}

class _MapRegionSelectionScreenState extends State<MapRegionSelectionScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(12.9716, 77.5946); // Bangalore default
  String _selectedCity = 'Bangalore';
  String _selectedState = 'Karnataka';
  String _selectedRegion = 'South India';
  bool _isLoading = false;
  bool _locationDetected = false;
  final Set<Marker> _markers = {};
  String? _mapError;

  // Indian regions with their cities
  final Map<String, Map<String, dynamic>> _indianCities = {
    'Bangalore': {
      'latLng': const LatLng(12.9716, 77.5946),
      'state': 'Karnataka',
      'region': 'South India'
    },
    'Mumbai': {
      'latLng': const LatLng(19.0760, 72.8777),
      'state': 'Maharashtra',
      'region': 'West India'
    },
    'Delhi': {
      'latLng': const LatLng(28.7041, 77.1025),
      'state': 'Delhi',
      'region': 'North India'
    },
    'Kolkata': {
      'latLng': const LatLng(22.5726, 88.3639),
      'state': 'West Bengal',
      'region': 'East India'
    },
    'Chennai': {
      'latLng': const LatLng(13.0827, 80.2707),
      'state': 'Tamil Nadu',
      'region': 'South India'
    },
    'Hyderabad': {
      'latLng': const LatLng(17.3850, 78.4867),
      'state': 'Telangana',
      'region': 'South India'
    },
    'Pune': {
      'latLng': const LatLng(18.5204, 73.8567),
      'state': 'Maharashtra',
      'region': 'West India'
    },
    'Ahmedabad': {
      'latLng': const LatLng(23.0225, 72.5714),
      'state': 'Gujarat',
      'region': 'West India'
    },
    'Jaipur': {
      'latLng': const LatLng(26.9124, 75.7873),
      'state': 'Rajasthan',
      'region': 'North India'
    },
    'Lucknow': {
      'latLng': const LatLng(26.8467, 80.9462),
      'state': 'Uttar Pradesh',
      'region': 'North India'
    },
  };

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _selectedCity = place.locality ?? 'Bangalore';
          _selectedState = place.administrativeArea ?? 'Karnataka';
          _selectedRegion = _getRegionFromState(_selectedState);
          _locationDetected = true;
          _updateMarker(_currentPosition);
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition, 12),
        );
      }
    } catch (e) {
      // Use default location if detection fails
      setState(() {
        _locationDetected = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRegionFromState(String state) {
    const Map<String, String> stateToRegion = {
      'Karnataka': 'South India',
      'Tamil Nadu': 'South India',
      'Kerala': 'South India',
      'Telangana': 'South India',
      'Andhra Pradesh': 'South India',
      'Maharashtra': 'West India',
      'Gujarat': 'West India',
      'Goa': 'West India',
      'Delhi': 'North India',
      'Punjab': 'North India',
      'Haryana': 'North India',
      'Uttar Pradesh': 'North India',
      'Rajasthan': 'North India',
      'Himachal Pradesh': 'North India',
      'West Bengal': 'East India',
      'Odisha': 'East India',
      'Bihar': 'East India',
      'Jharkhand': 'East India',
      'Assam': 'Northeast India',
    };
    return stateToRegion[state] ?? 'South India';
  }

  void _updateMarker(LatLng position) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: _selectedCity,
          snippet: _selectedState,
        ),
      ),
    );
  }

  Future<void> _onMapTapped(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentPosition = position;
          _selectedCity =
              place.locality ?? place.subAdministrativeArea ?? 'Unknown';
          _selectedState = place.administrativeArea ?? 'Unknown';
          _selectedRegion = _getRegionFromState(_selectedState);
          _updateMarker(position);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location details')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectCityFromList(String cityName) {
    final cityData = _indianCities[cityName];
    if (cityData != null) {
      setState(() {
        _currentPosition = cityData['latLng'];
        _selectedCity = cityName;
        _selectedState = cityData['state'];
        _selectedRegion = cityData['region'];
        _updateMarker(_currentPosition);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 12),
      );
    }
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await RegionService.saveRegionData(
        state: _selectedState,
        city: _selectedCity,
        region: _selectedRegion,
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude,
      );

      if (mounted) {
        if (widget.isInitialSetup) {
          // For initial setup, navigate to home screen
          widget.onComplete?.call();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          // For region change from home screen
          widget.onComplete?.call();
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving region: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Your Region',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map view with error handling
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              setState(() {
                _mapError = null; // Map loaded successfully
              });
              print('✅ Google Map created successfully');
            },
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),

          // Error overlay if map fails to load
          if (_mapError != null)
            Container(
              color: Colors.grey.shade300,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Map Failed to Load',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _mapError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _mapError = null;
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Show debug overlay temporarily
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Debug Info:',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'API Key: AIzaSyCGXWO...w (configured)',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    'Map Status: ${_mapController != null ? "✅ Loaded" : "⏳ Loading..."}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    'Position: ${_currentPosition.latitude.toStringAsFixed(2)}, ${_currentPosition.longitude.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          // Top info card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF4A90E2),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _locationDetected
                                  ? 'Location Detected'
                                  : 'Select Location',
                              style: TextStyle(
                                fontSize: 12,
                                color: _locationDetected
                                    ? const Color(0xFF00C853)
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$_selectedCity, $_selectedState',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.map,
                          size: 16,
                          color: Color(0xFF4A90E2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Your Region: $_selectedRegion',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A90E2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom city selector
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Popular Cities',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _detectCurrentLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: const Text('Detect'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF4A90E2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _indianCities.length,
                      itemBuilder: (context, index) {
                        final cityName = _indianCities.keys.elementAt(index);
                        final isSelected = cityName == _selectedCity;
                        return GestureDetector(
                          onTap: () => _selectCityFromList(cityName),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF4A90E2)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF4A90E2)
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cityName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
