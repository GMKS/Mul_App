/// Air Quality Index Model
class AQIData {
  final int aqi;
  final String status;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final Map<String, double>? pollutants;

  AQIData({
    required this.aqi,
    required this.status,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.pollutants,
  });

  // Get AQI status and color based on value
  static String getStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static int getColor(int aqi) {
    if (aqi <= 50) return 0xFF00E400; // Green
    if (aqi <= 100) return 0xFFFFFF00; // Yellow
    if (aqi <= 150) return 0xFFFF7E00; // Orange
    if (aqi <= 200) return 0xFFFF0000; // Red
    if (aqi <= 300) return 0xFF8F3F97; // Purple
    return 0xFF7E0023; // Maroon
  }

  factory AQIData.fromJson(Map<String, dynamic> json) {
    return AQIData(
      aqi: json['aqi'] ?? 0,
      status: json['status'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      pollutants: json['pollutants'] != null
          ? Map<String, double>.from(json['pollutants'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'status': status,
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'pollutants': pollutants,
    };
  }
}
