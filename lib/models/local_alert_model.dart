// Local Alert Model
class LocalAlert {
  final String id;
  final String title;
  final String message;
  final String area;
  final String locality;
  final double distanceKm;
  final DateTime startTime;
  final DateTime? expiryTime;
  final String? icon;
  final String category; // 'offer', 'announcement', 'update', 'event'

  LocalAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.area,
    required this.locality,
    required this.distanceKm,
    required this.startTime,
    this.expiryTime,
    this.icon,
    required this.category,
  });

  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  bool get isActive => !isExpired;
}
