/// Temple Live Service
/// Service for fetching live temple streams, schedules, and subscriptions

import 'dart:math';
import '../models/temple_live_model.dart';

class TempleLiveService {
  static final TempleLiveService _instance = TempleLiveService._internal();
  factory TempleLiveService() => _instance;
  TempleLiveService._internal();

  // Mock subscribed temple IDs
  final Set<String> _subscribedTemples = {};

  /// GET /temples/live - Get all currently live temples
  Future<List<TempleLive>> getLiveTemples() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final liveTemples = _getMockTemples().where((t) => t.isLive).toList();

    return liveTemples;
  }

  /// GET /temples - Get all temples (live and offline)
  Future<List<TempleLive>> getAllTemples({
    String? religion,
    String? city,
    bool? isLive,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var temples = _getMockTemples();

    if (religion != null && religion.isNotEmpty) {
      temples = temples
          .where((t) => t.religion?.toLowerCase() == religion.toLowerCase())
          .toList();
    }

    if (city != null && city.isNotEmpty) {
      temples = temples
          .where((t) => t.city.toLowerCase().contains(city.toLowerCase()))
          .toList();
    }

    if (isLive != null) {
      temples = temples.where((t) => t.isLive == isLive).toList();
    }

    return temples;
  }

  /// GET /temples/{id} - Get temple details by ID
  Future<TempleLive?> getTempleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final temples = _getMockTemples();
    try {
      return temples.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// POST /temples/subscribe - Subscribe to temple alerts
  Future<bool> subscribeToTemple(String templeId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _subscribedTemples.add(templeId);
    return true;
  }

  /// DELETE /temples/subscribe - Unsubscribe from temple alerts
  Future<bool> unsubscribeFromTemple(String templeId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _subscribedTemples.remove(templeId);
    return true;
  }

  /// Check if subscribed to a temple
  bool isSubscribedToTemple(String templeId) {
    return _subscribedTemples.contains(templeId);
  }

  /// Get user's subscribed temples
  Future<List<TempleLive>> getSubscribedTemples() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final temples = _getMockTemples();
    return temples.where((t) => _subscribedTemples.contains(t.id)).toList();
  }

  /// Get today's schedule for a temple
  Future<List<TempleEvent>> getTodaySchedule(String templeId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _getMockSchedule(templeId);
  }

  /// Get upcoming events for a temple
  Future<List<TempleEvent>> getUpcomingEvents(String templeId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _getMockUpcomingEvents(templeId);
  }

  /// Search temples by name or city
  Future<List<TempleLive>> searchTemples(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();
    return _getMockTemples()
        .where((t) =>
            t.name.toLowerCase().contains(lowerQuery) ||
            t.city.toLowerCase().contains(lowerQuery) ||
            (t.deity?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  // ==================== MOCK DATA ====================

  List<TempleLive> _getMockTemples() {
    final random = Random(42); // Fixed seed for consistent mock data
    final now = DateTime.now();

    return [
      // Live temples
      TempleLive(
        id: 'live_1',
        name: 'Tirupati Balaji Temple',
        city: 'Tirupati',
        state: 'Andhra Pradesh',
        religion: 'hinduism',
        deity: 'Lord Venkateswara',
        description:
            'One of the most visited religious sites in the world. The temple is dedicated to Lord Venkateswara, an incarnation of Vishnu.',
        timings: '3:00 AM - 12:00 AM',
        latitude: 13.6833,
        longitude: 79.3474,
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        isLive: true,
        thumbnailUrl: 'https://picsum.photos/400/300?random=201',
        viewerCount: random.nextInt(50000) + 10000,
        liveStartedAt: now.subtract(Duration(hours: random.nextInt(3))),
        createdAt: now.subtract(const Duration(days: 365)),
        todaySchedule: [
          '4:30 AM - Suprabhatam',
          '6:00 AM - Thomala Seva',
          '7:00 AM - Archana',
          '11:30 AM - Nijapada Darshanam',
          '6:00 PM - Sahasra Deepalankara Seva',
          '9:00 PM - Ekanta Seva',
        ],
        isSubscribed: _subscribedTemples.contains('live_1'),
      ),
      TempleLive(
        id: 'live_2',
        name: 'Golden Temple',
        city: 'Amritsar',
        state: 'Punjab',
        religion: 'sikhism',
        deity: 'Waheguru',
        description:
            'The holiest Gurdwara and the most important pilgrimage site of Sikhism. Known for its golden architecture and the sacred pool.',
        timings: 'Open 24 hours',
        latitude: 31.6200,
        longitude: 74.8765,
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        isLive: true,
        thumbnailUrl: 'https://picsum.photos/400/300?random=202',
        viewerCount: random.nextInt(30000) + 5000,
        liveStartedAt: now.subtract(Duration(hours: random.nextInt(5))),
        createdAt: now.subtract(const Duration(days: 365)),
        todaySchedule: [
          '4:00 AM - Prakash',
          '5:00 AM - Asa di Var',
          '9:00 AM - Sukhmani Sahib',
          '6:00 PM - Rehras Sahib',
          '9:45 PM - Kirtan Sohila',
        ],
        isSubscribed: _subscribedTemples.contains('live_2'),
      ),
      TempleLive(
        id: 'live_3',
        name: 'Kashi Vishwanath Temple',
        city: 'Varanasi',
        state: 'Uttar Pradesh',
        religion: 'hinduism',
        deity: 'Lord Shiva',
        description:
            'One of the twelve Jyotirlingas dedicated to Lord Shiva. One of the most famous Hindu temples.',
        timings: '3:00 AM - 11:00 PM',
        latitude: 25.3109,
        longitude: 83.0107,
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        isLive: true,
        thumbnailUrl: 'https://picsum.photos/400/300?random=203',
        viewerCount: random.nextInt(20000) + 3000,
        liveStartedAt: now.subtract(Duration(hours: random.nextInt(2))),
        createdAt: now.subtract(const Duration(days: 365)),
        todaySchedule: [
          '3:00 AM - Mangala Aarti',
          '4:00 AM - Bhog Aarti',
          '11:15 AM - Madhyan Bhog Aarti',
          '7:00 PM - Sandhya Aarti',
          '9:00 PM - Shringar Aarti',
          '10:30 PM - Shayan Aarti',
        ],
        isSubscribed: _subscribedTemples.contains('live_3'),
      ),
      TempleLive(
        id: 'live_4',
        name: 'ISKCON Temple',
        city: 'Bangalore',
        state: 'Karnataka',
        religion: 'hinduism',
        deity: 'Lord Krishna',
        description:
            'International Society for Krishna Consciousness temple, one of the largest ISKCON temples in the world.',
        timings: '4:15 AM - 8:30 PM',
        latitude: 13.0104,
        longitude: 77.5513,
        streamUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        isLive: true,
        thumbnailUrl: 'https://picsum.photos/400/300?random=204',
        viewerCount: random.nextInt(15000) + 2000,
        liveStartedAt: now.subtract(Duration(minutes: random.nextInt(60))),
        createdAt: now.subtract(const Duration(days: 200)),
        todaySchedule: [
          '4:15 AM - Mangala Aarti',
          '5:00 AM - Tulasi Aarti',
          '7:15 AM - Guru Puja',
          '8:00 AM - Bhagavatam Class',
          '1:00 PM - Raj Bhog Aarti',
          '7:00 PM - Gaura Aarti',
        ],
        isSubscribed: _subscribedTemples.contains('live_4'),
      ),

      // Offline temples (scheduled to go live)
      TempleLive(
        id: 'temple_5',
        name: 'Siddhivinayak Temple',
        city: 'Mumbai',
        state: 'Maharashtra',
        religion: 'hinduism',
        deity: 'Lord Ganesha',
        description:
            'One of the richest temples in Mumbai, dedicated to Lord Ganesha.',
        timings: '5:30 AM - 9:50 PM',
        latitude: 19.0168,
        longitude: 72.8302,
        streamUrl: null,
        isLive: false,
        thumbnailUrl: 'https://picsum.photos/400/300?random=205',
        viewerCount: 0,
        createdAt: now.subtract(const Duration(days: 180)),
        todaySchedule: [
          '5:30 AM - Kakad Aarti',
          '6:00 AM - Abhishek',
          '12:00 PM - Madhyan Aarti',
          '6:00 PM - Dhoop Aarti',
          '9:30 PM - Shej Aarti',
        ],
        isSubscribed: _subscribedTemples.contains('temple_5'),
      ),
      TempleLive(
        id: 'temple_6',
        name: 'Meenakshi Amman Temple',
        city: 'Madurai',
        state: 'Tamil Nadu',
        religion: 'hinduism',
        deity: 'Goddess Meenakshi',
        description:
            'Historic Hindu temple in the temple city of Madurai, known for its stunning architecture.',
        timings: '5:00 AM - 12:30 PM, 4:00 PM - 9:30 PM',
        latitude: 9.9195,
        longitude: 78.1193,
        streamUrl: null,
        isLive: false,
        thumbnailUrl: 'https://picsum.photos/400/300?random=206',
        viewerCount: 0,
        createdAt: now.subtract(const Duration(days: 300)),
        todaySchedule: [
          '5:00 AM - Palliarai',
          '6:00 AM - Kalasanthi',
          '10:00 AM - Uchikala',
          '6:00 PM - Sayarakshai',
          '9:00 PM - Ardha Jama',
        ],
        isSubscribed: _subscribedTemples.contains('temple_6'),
      ),
      TempleLive(
        id: 'temple_7',
        name: 'Jama Masjid',
        city: 'Delhi',
        state: 'Delhi',
        religion: 'islam',
        description:
            'One of the largest mosques in India, built by Mughal Emperor Shah Jahan.',
        timings: '7:00 AM - 12:00 PM, 1:30 PM - 6:30 PM',
        latitude: 28.6507,
        longitude: 77.2334,
        streamUrl: null,
        isLive: false,
        thumbnailUrl: 'https://picsum.photos/400/300?random=207',
        viewerCount: 0,
        createdAt: now.subtract(const Duration(days: 250)),
        todaySchedule: [
          '5:30 AM - Fajr',
          '1:00 PM - Dhuhr',
          '4:30 PM - Asr',
          '6:30 PM - Maghrib',
          '8:00 PM - Isha',
        ],
        isSubscribed: _subscribedTemples.contains('temple_7'),
      ),
      TempleLive(
        id: 'temple_8',
        name: 'Basilica of Bom Jesus',
        city: 'Goa',
        state: 'Goa',
        religion: 'christianity',
        deity: 'Jesus Christ',
        description:
            'UNESCO World Heritage Site containing remains of St. Francis Xavier.',
        timings: '9:00 AM - 6:30 PM',
        latitude: 15.5009,
        longitude: 73.9116,
        streamUrl: null,
        isLive: false,
        thumbnailUrl: 'https://picsum.photos/400/300?random=208',
        viewerCount: 0,
        createdAt: now.subtract(const Duration(days: 400)),
        todaySchedule: [
          '7:00 AM - Morning Mass',
          '9:00 AM - Sunday Service',
          '5:00 PM - Evening Prayer',
        ],
        isSubscribed: _subscribedTemples.contains('temple_8'),
      ),
      TempleLive(
        id: 'temple_9',
        name: 'Mahabodhi Temple',
        city: 'Bodh Gaya',
        state: 'Bihar',
        religion: 'buddhism',
        deity: 'Buddha',
        description:
            'UNESCO World Heritage Site - Place where Buddha attained enlightenment.',
        timings: '5:00 AM - 9:00 PM',
        latitude: 24.6961,
        longitude: 84.9911,
        streamUrl: null,
        isLive: false,
        thumbnailUrl: 'https://picsum.photos/400/300?random=209',
        viewerCount: 0,
        createdAt: now.subtract(const Duration(days: 500)),
        todaySchedule: [
          '5:00 AM - Morning Prayers',
          '6:00 AM - Meditation Session',
          '12:00 PM - Chanting',
          '6:00 PM - Evening Prayers',
        ],
        isSubscribed: _subscribedTemples.contains('temple_9'),
      ),
      TempleLive(
        id: 'temple_10',
        name: 'Charminar Mosque',
        city: 'Hyderabad',
        state: 'Telangana',
        religion: 'islam',
        description:
            'Iconic mosque and monument built in 1591, symbol of Hyderabad.',
        timings: '9:00 AM - 5:30 PM',
        latitude: 17.3616,
        longitude: 78.4747,
        streamUrl: null,
        isLive: false,
        thumbnailUrl: 'https://picsum.photos/400/300?random=210',
        viewerCount: 0,
        createdAt: now.subtract(const Duration(days: 150)),
        todaySchedule: [
          '5:30 AM - Fajr',
          '1:00 PM - Dhuhr',
          '6:30 PM - Maghrib',
        ],
        isSubscribed: _subscribedTemples.contains('temple_10'),
      ),
    ];
  }

  List<TempleEvent> _getMockSchedule(String templeId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      TempleEvent(
        id: '${templeId}_event_1',
        title: 'Morning Aarti',
        description: 'Daily morning prayer ceremony',
        dateTime: today.add(const Duration(hours: 5, minutes: 30)),
        type: 'aarti',
      ),
      TempleEvent(
        id: '${templeId}_event_2',
        title: 'Abhishekam',
        description: 'Sacred bathing ceremony',
        dateTime: today.add(const Duration(hours: 6, minutes: 30)),
        type: 'pooja',
      ),
      TempleEvent(
        id: '${templeId}_event_3',
        title: 'Darshan',
        description: 'Devotee viewing hours',
        dateTime: today.add(const Duration(hours: 8)),
        type: 'darshan',
      ),
      TempleEvent(
        id: '${templeId}_event_4',
        title: 'Madhyan Aarti',
        description: 'Afternoon prayer ceremony',
        dateTime: today.add(const Duration(hours: 12)),
        type: 'aarti',
      ),
      TempleEvent(
        id: '${templeId}_event_5',
        title: 'Evening Aarti',
        description: 'Evening prayer ceremony',
        dateTime: today.add(const Duration(hours: 18, minutes: 30)),
        type: 'aarti',
      ),
      TempleEvent(
        id: '${templeId}_event_6',
        title: 'Night Seva',
        description: 'Special evening service',
        dateTime: today.add(const Duration(hours: 21)),
        type: 'pooja',
        isSpecial: true,
      ),
    ];
  }

  List<TempleEvent> _getMockUpcomingEvents(String templeId) {
    final now = DateTime.now();

    return [
      TempleEvent(
        id: '${templeId}_upcoming_1',
        title: 'Maha Shivaratri',
        description: 'Grand celebration of Lord Shiva',
        dateTime: now.add(const Duration(days: 15)),
        type: 'festival',
        isSpecial: true,
      ),
      TempleEvent(
        id: '${templeId}_upcoming_2',
        title: 'Navratri Begins',
        description: '9-day festival celebration',
        dateTime: now.add(const Duration(days: 30)),
        type: 'festival',
        isSpecial: true,
      ),
      TempleEvent(
        id: '${templeId}_upcoming_3',
        title: 'Special Abhishekam',
        description: 'Monthly special ceremony',
        dateTime: now.add(const Duration(days: 7)),
        type: 'special',
        isSpecial: true,
      ),
      TempleEvent(
        id: '${templeId}_upcoming_4',
        title: 'Full Moon Pooja',
        description: 'Purnima special ceremony',
        dateTime: now.add(const Duration(days: 10)),
        type: 'pooja',
      ),
    ];
  }
}
