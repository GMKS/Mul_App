// Local Alerts Repository
import '../models/local_alert_model.dart';

class LocalAlertsRepository {
  // Mock API call - replace with actual API
  Future<List<LocalAlert>> fetchLocalAlerts({
    required String city,
    required String state,
    double? maxDistanceKm,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - In production, this would be an API call
    final now = DateTime.now();

    return [
      LocalAlert(
        id: '1',
        title: '20% discount at Sri Medical Store',
        message: 'Get 20% off on all medicines until 8 PM today',
        area: 'Kompally',
        locality: 'Near Bus Stop',
        distanceKm: 2.5,
        startTime: now.subtract(const Duration(hours: 2)),
        expiryTime: now.add(const Duration(hours: 6)),
        icon: 'local_offer',
        category: 'offer',
      ),
      LocalAlert(
        id: '2',
        title: 'Fresh vegetables arrived',
        message: 'Sunday Market has fresh stock of vegetables',
        area: 'Alwal',
        locality: 'Main Market',
        distanceKm: 5.2,
        startTime: now.subtract(const Duration(minutes: 30)),
        expiryTime: now.add(const Duration(hours: 3)),
        icon: 'shopping_basket',
        category: 'announcement',
      ),
      LocalAlert(
        id: '3',
        title: 'Power cut in MG Road area',
        message: 'Scheduled maintenance for 1 hour',
        area: 'Malkajgiri',
        locality: 'MG Road',
        distanceKm: 3.8,
        startTime: now.subtract(const Duration(minutes: 15)),
        expiryTime: now.add(const Duration(minutes: 45)),
        icon: 'power_off',
        category: 'update',
      ),
      LocalAlert(
        id: '4',
        title: 'Temple pooja starting soon',
        message: 'Evening aarti at Sri Rama Temple in 30 minutes',
        area: 'Medchal',
        locality: 'Temple Road',
        distanceKm: 7.1,
        startTime: now,
        expiryTime: now.add(const Duration(minutes: 30)),
        icon: 'temple_hindu',
        category: 'event',
      ),
      LocalAlert(
        id: '5',
        title: 'Traffic update: Road diversion',
        message: 'NH 44 diverted due to VIP movement',
        area: 'Bowenpally',
        locality: 'NH 44',
        distanceKm: 4.5,
        startTime: now.subtract(const Duration(minutes: 10)),
        expiryTime: now.add(const Duration(hours: 2)),
        icon: 'traffic',
        category: 'update',
      ),
    ];
  }
}
