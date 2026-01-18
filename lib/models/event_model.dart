/// Event Model
/// Model for events and festivals with location-based filtering

import '../models/devotional_video_model.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String
      category; // festival, cultural, religious, community, sports, etc.
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final String distanceCategory; // nearby, medium, far, national
  final String organizerName;
  final String? contactInfo;
  final String? imageUrl;
  final String? ticketUrl;
  final double? ticketPrice;
  final bool isApproved;
  final bool isExpired;
  final bool isFeatured;
  final String? religion; // For religious events
  final List<String> tags;
  final DateTime createdAt;
  final String? createdBy;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startDatetime,
    required this.endDatetime,
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.distanceCategory,
    required this.organizerName,
    this.contactInfo,
    this.imageUrl,
    this.ticketUrl,
    this.ticketPrice,
    this.isApproved = false,
    this.isExpired = false,
    this.isFeatured = false,
    this.religion,
    this.tags = const [],
    required this.createdAt,
    this.createdBy,
  });

  /// Check if event is happening today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return startDatetime.isAfter(today.subtract(const Duration(seconds: 1))) &&
        startDatetime.isBefore(tomorrow);
  }

  /// Check if event is tomorrow
  bool get isTomorrow {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final dayAfter = tomorrow.add(const Duration(days: 1));
    return startDatetime
            .isAfter(tomorrow.subtract(const Duration(seconds: 1))) &&
        startDatetime.isBefore(dayAfter);
  }

  /// Check if event is currently live (ongoing)
  bool get isLive {
    final now = DateTime.now();
    return now.isAfter(startDatetime) && now.isBefore(endDatetime);
  }

  /// Check if event is upcoming (not started yet)
  bool get isUpcoming {
    return DateTime.now().isBefore(startDatetime);
  }

  /// Check if event is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return startDatetime
            .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        startDatetime.isBefore(endOfWeek);
  }

  /// Check if event is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return startDatetime.year == now.year && startDatetime.month == now.month;
  }

  /// Get time until event starts
  Duration get timeUntilStart {
    return startDatetime.difference(DateTime.now());
  }

  /// Get registration URL (alias for ticketUrl)
  String? get registrationUrl => ticketUrl;

  /// Get formatted date string
  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${startDatetime.day} ${months[startDatetime.month - 1]} ${startDatetime.year}';
  }

  /// Get formatted time string
  String get formattedTime {
    final hour = startDatetime.hour;
    final minute = startDatetime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Get formatted date range
  String get formattedDateRange {
    if (startDatetime.day == endDatetime.day &&
        startDatetime.month == endDatetime.month &&
        startDatetime.year == endDatetime.year) {
      return formattedDate;
    }
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${startDatetime.day} ${months[startDatetime.month - 1]} - ${endDatetime.day} ${months[endDatetime.month - 1]}';
  }

  /// Get event status tag
  String get statusTag {
    if (isLive) return 'LIVE';
    if (isToday) return 'TODAY';
    if (isTomorrow) return 'TOMORROW';
    if (isUpcoming) return 'UPCOMING';
    return '';
  }

  /// Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'festival':
        return '🎉';
      case 'cultural':
        return '🎭';
      case 'religious':
        return '🙏';
      case 'community':
        return '👥';
      case 'sports':
        return '🏆';
      case 'music':
        return '🎵';
      case 'food':
        return '🍽️';
      case 'art':
        return '🎨';
      case 'education':
        return '📚';
      case 'charity':
        return '❤️';
      default:
        return '📅';
    }
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'general',
      startDatetime: json['start_datetime'] != null
          ? DateTime.parse(json['start_datetime'])
          : DateTime.now(),
      endDatetime: json['end_datetime'] != null
          ? DateTime.parse(json['end_datetime'])
          : DateTime.now().add(const Duration(hours: 2)),
      locationName: json['location_name'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distanceCategory: json['distance_category'] ?? 'nearby',
      organizerName: json['organizer_name'] ?? '',
      contactInfo: json['contact_info'],
      imageUrl: json['image_url'],
      ticketUrl: json['ticket_url'],
      ticketPrice: json['ticket_price']?.toDouble(),
      isApproved: json['is_approved'] ?? false,
      isExpired: json['is_expired'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      religion: json['religion'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'distance_category': distanceCategory,
      'organizer_name': organizerName,
      'contact_info': contactInfo,
      'image_url': imageUrl,
      'ticket_url': ticketUrl,
      'ticket_price': ticketPrice,
      'is_approved': isApproved,
      'is_expired': isExpired,
      'is_featured': isFeatured,
      'religion': religion,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? startDatetime,
    DateTime? endDatetime,
    String? locationName,
    double? latitude,
    double? longitude,
    String? distanceCategory,
    String? organizerName,
    String? contactInfo,
    String? imageUrl,
    String? ticketUrl,
    double? ticketPrice,
    bool? isApproved,
    bool? isExpired,
    bool? isFeatured,
    String? religion,
    List<String>? tags,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startDatetime: startDatetime ?? this.startDatetime,
      endDatetime: endDatetime ?? this.endDatetime,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceCategory: distanceCategory ?? this.distanceCategory,
      organizerName: organizerName ?? this.organizerName,
      contactInfo: contactInfo ?? this.contactInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      isApproved: isApproved ?? this.isApproved,
      isExpired: isExpired ?? this.isExpired,
      isFeatured: isFeatured ?? this.isFeatured,
      religion: religion ?? this.religion,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Get predefined sample events for testing
  static List<EventModel> getSampleEvents() {
    final now = DateTime.now();
    return [
      EventModel(
        id: 'event_1',
        title: 'Makar Sankranti Celebration',
        description:
            'Join us for the grand celebration of Makar Sankranti with kite flying, traditional food, and cultural performances.',
        category: 'festival',
        startDatetime: DateTime(now.year, now.month, now.day, 9, 0),
        endDatetime: DateTime(now.year, now.month, now.day, 18, 0),
        locationName: 'Ahmedabad, Gujarat',
        latitude: 23.0225,
        longitude: 72.5714,
        distanceCategory: 'nearby',
        organizerName: 'Gujarat Tourism',
        contactInfo: '+91 9876543210',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        isApproved: true,
        isFeatured: true,
        religion: 'hinduism',
        tags: ['sankranti', 'kite_festival', 'gujarat'],
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      EventModel(
        id: 'event_2',
        title: 'Republic Day Parade',
        description:
            'Witness the grand Republic Day parade showcasing India\'s cultural diversity and military strength.',
        category: 'cultural',
        startDatetime: DateTime(now.year, now.month, now.day + 1, 8, 0),
        endDatetime: DateTime(now.year, now.month, now.day + 1, 12, 0),
        locationName: 'Rajpath, New Delhi',
        latitude: 28.6139,
        longitude: 77.2090,
        distanceCategory: 'national',
        organizerName: 'Government of India',
        imageUrl:
            'https://images.unsplash.com/photo-1532375810709-75b1da00537c?w=400',
        isApproved: true,
        isFeatured: true,
        tags: ['republic_day', 'parade', 'national'],
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      EventModel(
        id: 'event_3',
        title: 'Pongal Festival',
        description:
            'Celebrate the harvest festival of Tamil Nadu with traditional kolam, sweet pongal, and bullock cart races.',
        category: 'festival',
        startDatetime: now.subtract(const Duration(hours: 2)),
        endDatetime: now.add(const Duration(hours: 6)),
        locationName: 'Chennai, Tamil Nadu',
        latitude: 13.0827,
        longitude: 80.2707,
        distanceCategory: 'medium',
        organizerName: 'Tamil Nadu Tourism',
        contactInfo: '+91 9876543211',
        imageUrl:
            'https://images.unsplash.com/photo-1610024062303-e355e94c7a8c?w=400',
        isApproved: true,
        religion: 'hinduism',
        tags: ['pongal', 'harvest', 'tamil_nadu'],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      EventModel(
        id: 'event_4',
        title: 'Local Music Concert',
        description:
            'Enjoy an evening of classical and folk music by renowned local artists.',
        category: 'music',
        startDatetime: DateTime(now.year, now.month, now.day + 2, 18, 0),
        endDatetime: DateTime(now.year, now.month, now.day + 2, 22, 0),
        locationName: 'Town Hall Auditorium',
        latitude: 12.9716,
        longitude: 77.5946,
        distanceCategory: 'nearby',
        organizerName: 'Cultural Committee',
        ticketPrice: 200,
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        isApproved: true,
        tags: ['music', 'concert', 'classical'],
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      EventModel(
        id: 'event_5',
        title: 'Community Blood Donation Camp',
        description:
            'Save lives by donating blood. Free health checkup for all donors.',
        category: 'charity',
        startDatetime: DateTime(now.year, now.month, now.day + 3, 9, 0),
        endDatetime: DateTime(now.year, now.month, now.day + 3, 17, 0),
        locationName: 'City Hospital',
        latitude: 19.0760,
        longitude: 72.8777,
        distanceCategory: 'nearby',
        organizerName: 'Red Cross Society',
        contactInfo: '+91 9876543212',
        isApproved: true,
        tags: ['blood_donation', 'health', 'charity'],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      EventModel(
        id: 'event_6',
        title: 'Basant Panchami Celebration',
        description:
            'Celebrate the arrival of spring with Saraswati Puja and cultural programs.',
        category: 'religious',
        startDatetime: DateTime(now.year, now.month, now.day + 5, 6, 0),
        endDatetime: DateTime(now.year, now.month, now.day + 5, 20, 0),
        locationName: 'Saraswati Temple',
        distanceCategory: 'nearby',
        organizerName: 'Temple Committee',
        isApproved: true,
        religion: 'hinduism',
        tags: ['basant_panchami', 'saraswati_puja', 'spring'],
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }
}

/// Event category enum for filtering
enum EventCategory {
  all,
  festival,
  cultural,
  religious,
  community,
  sports,
  music,
  food,
  art,
  education,
  charity;

  String get displayName {
    switch (this) {
      case EventCategory.all:
        return 'All Events';
      case EventCategory.festival:
        return 'Festivals';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.religious:
        return 'Religious';
      case EventCategory.community:
        return 'Community';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.music:
        return 'Music';
      case EventCategory.food:
        return 'Food';
      case EventCategory.art:
        return 'Art';
      case EventCategory.education:
        return 'Education';
      case EventCategory.charity:
        return 'Charity';
    }
  }

  String get icon {
    switch (this) {
      case EventCategory.all:
        return '📅';
      case EventCategory.festival:
        return '🎉';
      case EventCategory.cultural:
        return '🎭';
      case EventCategory.religious:
        return '🙏';
      case EventCategory.community:
        return '👥';
      case EventCategory.sports:
        return '🏆';
      case EventCategory.music:
        return '🎵';
      case EventCategory.food:
        return '🍽️';
      case EventCategory.art:
        return '🎨';
      case EventCategory.education:
        return '📚';
      case EventCategory.charity:
        return '❤️';
    }
  }
}

/// Date filter enum
enum DateFilter {
  today,
  tomorrow,
  thisWeek,
  thisMonth,
  all;

  String get displayName {
    switch (this) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.tomorrow:
        return 'Tomorrow';
      case DateFilter.thisWeek:
        return 'This Week';
      case DateFilter.thisMonth:
        return 'This Month';
      case DateFilter.all:
        return 'All';
    }
  }
}
