/// DevotionalVideo Model
/// Model for devotional videos with religion, deity, temple info

class DevotionalVideo {
  final String id;
  final String title;
  final String religion;
  final String? deity;
  final String? templeName;
  final String videoUrl;
  final String thumbnailUrl;
  final List<String> festivalTags;
  final String distanceCategory; // 'nearby', 'regional', 'national'
  final String language;
  final bool isVerified;
  final DateTime createdAt;
  final String? description;
  final String? creatorId;
  final String? creatorName;
  final int views;
  final int likes;

  DevotionalVideo({
    required this.id,
    required this.title,
    required this.religion,
    this.deity,
    this.templeName,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.festivalTags = const [],
    required this.distanceCategory,
    required this.language,
    this.isVerified = false,
    required this.createdAt,
    this.description,
    this.creatorId,
    this.creatorName,
    this.views = 0,
    this.likes = 0,
  });

  factory DevotionalVideo.fromJson(Map<String, dynamic> json) {
    return DevotionalVideo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      religion: json['religion'] ?? '',
      deity: json['deity'],
      templeName: json['temple_name'],
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      festivalTags: List<String>.from(json['festival_tags'] ?? []),
      distanceCategory: json['distance_category'] ?? 'regional',
      language: json['language'] ?? 'en',
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      description: json['description'],
      creatorId: json['creator_id'],
      creatorName: json['creator_name'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'religion': religion,
      'deity': deity,
      'temple_name': templeName,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'festival_tags': festivalTags,
      'distance_category': distanceCategory,
      'language': language,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'views': views,
      'likes': likes,
    };
  }

  DevotionalVideo copyWith({
    String? id,
    String? title,
    String? religion,
    String? deity,
    String? templeName,
    String? videoUrl,
    String? thumbnailUrl,
    List<String>? festivalTags,
    String? distanceCategory,
    String? language,
    bool? isVerified,
    DateTime? createdAt,
    String? description,
    String? creatorId,
    String? creatorName,
    int? views,
    int? likes,
  }) {
    return DevotionalVideo(
      id: id ?? this.id,
      title: title ?? this.title,
      religion: religion ?? this.religion,
      deity: deity ?? this.deity,
      templeName: templeName ?? this.templeName,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      festivalTags: festivalTags ?? this.festivalTags,
      distanceCategory: distanceCategory ?? this.distanceCategory,
      language: language ?? this.language,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      views: views ?? this.views,
      likes: likes ?? this.likes,
    );
  }
}

/// Religion enum for type safety
enum Religion {
  hinduism,
  islam,
  christianity,
  sikhism,
  buddhism;

  String get displayName {
    switch (this) {
      case Religion.hinduism:
        return 'Hinduism';
      case Religion.islam:
        return 'Islam';
      case Religion.christianity:
        return 'Christianity';
      case Religion.sikhism:
        return 'Sikhism';
      case Religion.buddhism:
        return 'Buddhism';
    }
  }

  String get icon {
    switch (this) {
      case Religion.hinduism:
        return '🕉️';
      case Religion.islam:
        return '☪️';
      case Religion.christianity:
        return '✝️';
      case Religion.sikhism:
        return '☬';
      case Religion.buddhism:
        return '☸️';
    }
  }

  static Religion? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'hinduism':
        return Religion.hinduism;
      case 'islam':
        return Religion.islam;
      case 'christianity':
        return Religion.christianity;
      case 'sikhism':
        return Religion.sikhism;
      case 'buddhism':
        return Religion.buddhism;
      default:
        return null;
    }
  }
}

/// Distance category enum
enum DistanceCategory {
  nearby,
  regional,
  national;

  String get displayName {
    switch (this) {
      case DistanceCategory.nearby:
        return 'Nearby';
      case DistanceCategory.regional:
        return 'Regional';
      case DistanceCategory.national:
        return 'National';
    }
  }
}
