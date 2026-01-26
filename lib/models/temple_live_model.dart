/// Temple Live Model
/// Model for live streaming temples

class TempleLive {
  final String id;
  final String name;
  final String city;
  final String? state;
  final String? streamUrl;
  final bool isLive;
  final String? thumbnailUrl;
  final String? religion;
  final String? deity;
  final String description;
  final String? timings;
  final double? latitude;
  final double? longitude;
  final int viewerCount;
  final DateTime? liveStartedAt;
  final DateTime createdAt;
  final List<String> todaySchedule;
  final List<TempleEvent> upcomingEvents;
  final bool isSubscribed;

  TempleLive({
    required this.id,
    required this.name,
    required this.city,
    this.state,
    this.streamUrl,
    this.isLive = false,
    this.thumbnailUrl,
    this.religion,
    this.deity,
    this.description = '',
    this.timings,
    this.latitude,
    this.longitude,
    this.viewerCount = 0,
    this.liveStartedAt,
    required this.createdAt,
    this.todaySchedule = const [],
    this.upcomingEvents = const [],
    this.isSubscribed = false,
  });

  factory TempleLive.fromJson(Map<String, dynamic> json) {
    return TempleLive(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'],
      streamUrl: json['stream_url'],
      isLive: json['is_live'] ?? false,
      thumbnailUrl: json['thumbnail_url'],
      religion: json['religion'],
      deity: json['deity'],
      description: json['description'] ?? '',
      timings: json['timings'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      viewerCount: json['viewer_count'] ?? 0,
      liveStartedAt: json['live_started_at'] != null
          ? DateTime.parse(json['live_started_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      todaySchedule: List<String>.from(json['today_schedule'] ?? []),
      upcomingEvents: (json['upcoming_events'] as List<dynamic>?)
              ?.map((e) => TempleEvent.fromJson(e))
              .toList() ??
          [],
      isSubscribed: json['is_subscribed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'state': state,
      'stream_url': streamUrl,
      'is_live': isLive,
      'thumbnail_url': thumbnailUrl,
      'religion': religion,
      'deity': deity,
      'description': description,
      'timings': timings,
      'latitude': latitude,
      'longitude': longitude,
      'viewer_count': viewerCount,
      'live_started_at': liveStartedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'today_schedule': todaySchedule,
      'upcoming_events': upcomingEvents.map((e) => e.toJson()).toList(),
      'is_subscribed': isSubscribed,
    };
  }

  TempleLive copyWith({
    String? id,
    String? name,
    String? city,
    String? state,
    String? streamUrl,
    bool? isLive,
    String? thumbnailUrl,
    String? religion,
    String? deity,
    String? description,
    String? timings,
    double? latitude,
    double? longitude,
    int? viewerCount,
    DateTime? liveStartedAt,
    DateTime? createdAt,
    List<String>? todaySchedule,
    List<TempleEvent>? upcomingEvents,
    bool? isSubscribed,
  }) {
    return TempleLive(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      state: state ?? this.state,
      streamUrl: streamUrl ?? this.streamUrl,
      isLive: isLive ?? this.isLive,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      religion: religion ?? this.religion,
      deity: deity ?? this.deity,
      description: description ?? this.description,
      timings: timings ?? this.timings,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      viewerCount: viewerCount ?? this.viewerCount,
      liveStartedAt: liveStartedAt ?? this.liveStartedAt,
      createdAt: createdAt ?? this.createdAt,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  /// Get the religion icon emoji
  String get religionIcon {
    switch (religion?.toLowerCase()) {
      case 'hinduism':
        return '🛕';
      case 'islam':
        return '🕌';
      case 'christianity':
        return '⛪';
      case 'sikhism':
        return '🙏';
      case 'buddhism':
        return '☸️';
      case 'jainism':
        return '🕉️';
      default:
        return '🛕';
    }
  }

  /// Get formatted viewer count
  String get formattedViewers {
    if (viewerCount >= 1000000) {
      return '${(viewerCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewerCount >= 1000) {
      return '${(viewerCount / 1000).toStringAsFixed(1)}K';
    }
    return viewerCount.toString();
  }

  /// Get live duration
  String get liveDuration {
    if (liveStartedAt == null) return '';
    final duration = DateTime.now().difference(liveStartedAt!);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

/// Temple Event Model
class TempleEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final String type; // 'pooja', 'festival', 'special', 'darshan'
  final bool isSpecial;

  TempleEvent({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    required this.type,
    this.isSpecial = false,
  });

  factory TempleEvent.fromJson(Map<String, dynamic> json) {
    return TempleEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dateTime: json['date_time'] != null
          ? DateTime.parse(json['date_time'])
          : DateTime.now(),
      type: json['type'] ?? 'pooja',
      isSpecial: json['is_special'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'type': type,
      'is_special': isSpecial,
    };
  }

  /// Get event type icon
  String get typeIcon {
    switch (type) {
      case 'pooja':
        return '🪔';
      case 'festival':
        return '🎉';
      case 'special':
        return '⭐';
      case 'darshan':
        return '🙏';
      case 'aarti':
        return '🔥';
      default:
        return '📿';
    }
  }
}

/// Temple Subscription Model
class TempleSubscription {
  final String id;
  final String templeId;
  final String userId;
  final bool notifyLive;
  final bool notifyPooja;
  final bool notifyFestivals;
  final bool notifySpecialEvents;
  final DateTime subscribedAt;

  TempleSubscription({
    required this.id,
    required this.templeId,
    required this.userId,
    this.notifyLive = true,
    this.notifyPooja = true,
    this.notifyFestivals = true,
    this.notifySpecialEvents = true,
    required this.subscribedAt,
  });

  factory TempleSubscription.fromJson(Map<String, dynamic> json) {
    return TempleSubscription(
      id: json['id'] ?? '',
      templeId: json['temple_id'] ?? '',
      userId: json['user_id'] ?? '',
      notifyLive: json['notify_live'] ?? true,
      notifyPooja: json['notify_pooja'] ?? true,
      notifyFestivals: json['notify_festivals'] ?? true,
      notifySpecialEvents: json['notify_special_events'] ?? true,
      subscribedAt: json['subscribed_at'] != null
          ? DateTime.parse(json['subscribed_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temple_id': templeId,
      'user_id': userId,
      'notify_live': notifyLive,
      'notify_pooja': notifyPooja,
      'notify_festivals': notifyFestivals,
      'notify_special_events': notifySpecialEvents,
      'subscribed_at': subscribedAt.toIso8601String(),
    };
  }
}
