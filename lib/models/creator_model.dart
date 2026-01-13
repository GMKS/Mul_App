// STEP 7: Creator Badges
// Assign creator badges based on metrics:
// Rising Star, Regional Hero, Comedy Star.
// Update badges automatically.

enum CreatorBadge {
  none,
  risingStar, // New creators with good engagement
  regionalHero, // Popular in specific region
  comedyStar, // High engagement on comedy content
  businessGuru, // Popular business content creator
  devotionalGuide, // Popular devotional content creator
  verified, // Verified creator
  topCreator, // Overall top creator
}

class Creator {
  final String id;
  final String name;
  final String avatarUrl;
  final String bio;
  final String region;
  final String state;
  final String primaryLanguage;
  final int followers;
  final int totalViews;
  final int totalLikes;
  final int totalShares;
  final int totalVideos;
  final double averageWatchTime;
  final List<CreatorBadge> badges;
  final Map<String, int> categoryVideoCounts; // Videos per category
  final DateTime joinedAt;
  final bool isVerified;
  final bool isBanned;
  final bool isShadowBanned; // STEP 11: Shadow ban
  final int violationCount;

  Creator({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.bio = '',
    required this.region,
    required this.state,
    required this.primaryLanguage,
    this.followers = 0,
    this.totalViews = 0,
    this.totalLikes = 0,
    this.totalShares = 0,
    this.totalVideos = 0,
    this.averageWatchTime = 0,
    this.badges = const [],
    this.categoryVideoCounts = const {},
    required this.joinedAt,
    this.isVerified = false,
    this.isBanned = false,
    this.isShadowBanned = false,
    this.violationCount = 0,
  });

  // Calculate badges based on metrics
  List<CreatorBadge> calculateBadges() {
    List<CreatorBadge> earnedBadges = [];

    // Rising Star: New creator (< 3 months) with > 1000 followers
    final monthsSinceJoined = DateTime.now().difference(joinedAt).inDays / 30;
    if (monthsSinceJoined < 3 && followers > 1000) {
      earnedBadges.add(CreatorBadge.risingStar);
    }

    // Regional Hero: > 10000 followers from same region
    if (followers > 10000) {
      earnedBadges.add(CreatorBadge.regionalHero);
    }

    // Category-specific badges
    final businessVideos = categoryVideoCounts['Business'] ?? 0;
    final devotionalVideos = categoryVideoCounts['Devotional'] ?? 0;
    final regionalVideos = categoryVideoCounts['Regional'] ?? 0;

    if (businessVideos > 50 && totalLikes > 5000) {
      earnedBadges.add(CreatorBadge.businessGuru);
    }

    if (devotionalVideos > 50 && totalLikes > 5000) {
      earnedBadges.add(CreatorBadge.devotionalGuide);
    }

    // Comedy Star: High engagement rate (likes/views > 10%)
    if (totalViews > 0 && (totalLikes / totalViews) > 0.1) {
      earnedBadges.add(CreatorBadge.comedyStar);
    }

    // Top Creator: Overall metrics
    if (followers > 100000 && totalViews > 1000000) {
      earnedBadges.add(CreatorBadge.topCreator);
    }

    if (isVerified) {
      earnedBadges.add(CreatorBadge.verified);
    }

    return earnedBadges;
  }

  // Get badge display info
  static Map<String, dynamic> getBadgeInfo(CreatorBadge badge) {
    switch (badge) {
      case CreatorBadge.risingStar:
        return {
          'name': 'Rising Star',
          'icon': '⭐',
          'color': 0xFFFFD700,
          'description': 'New creator with great potential',
        };
      case CreatorBadge.regionalHero:
        return {
          'name': 'Regional Hero',
          'icon': '🏆',
          'color': 0xFF4CAF50,
          'description': 'Popular in your region',
        };
      case CreatorBadge.comedyStar:
        return {
          'name': 'Comedy Star',
          'icon': '😂',
          'color': 0xFFFF9800,
          'description': 'Master of entertainment',
        };
      case CreatorBadge.businessGuru:
        return {
          'name': 'Business Guru',
          'icon': '💼',
          'color': 0xFF2196F3,
          'description': 'Expert business content creator',
        };
      case CreatorBadge.devotionalGuide:
        return {
          'name': 'Devotional Guide',
          'icon': '🙏',
          'color': 0xFF9C27B0,
          'description': 'Spiritual content creator',
        };
      case CreatorBadge.verified:
        return {
          'name': 'Verified',
          'icon': '✓',
          'color': 0xFF1DA1F2,
          'description': 'Verified creator',
        };
      case CreatorBadge.topCreator:
        return {
          'name': 'Top Creator',
          'icon': '👑',
          'color': 0xFFE91E63,
          'description': 'Top performing creator',
        };
      case CreatorBadge.none:
        return {
          'name': '',
          'icon': '',
          'color': 0xFF9E9E9E,
          'description': '',
        };
    }
  }

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      region: json['region'] ?? '',
      state: json['state'] ?? '',
      primaryLanguage: json['primaryLanguage'] ?? '',
      followers: json['followers'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      totalLikes: json['totalLikes'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      totalVideos: json['totalVideos'] ?? 0,
      averageWatchTime: (json['averageWatchTime'] ?? 0).toDouble(),
      badges: (json['badges'] as List?)
              ?.map((e) => CreatorBadge.values.firstWhere(
                    (b) => b.toString() == e,
                    orElse: () => CreatorBadge.none,
                  ))
              .toList() ??
          [],
      categoryVideoCounts:
          Map<String, int>.from(json['categoryVideoCounts'] ?? {}),
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      isBanned: json['isBanned'] ?? false,
      isShadowBanned: json['isShadowBanned'] ?? false,
      violationCount: json['violationCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'region': region,
      'state': state,
      'primaryLanguage': primaryLanguage,
      'followers': followers,
      'totalViews': totalViews,
      'totalLikes': totalLikes,
      'totalShares': totalShares,
      'totalVideos': totalVideos,
      'averageWatchTime': averageWatchTime,
      'badges': badges.map((b) => b.toString()).toList(),
      'categoryVideoCounts': categoryVideoCounts,
      'joinedAt': joinedAt.toIso8601String(),
      'isVerified': isVerified,
      'isBanned': isBanned,
      'isShadowBanned': isShadowBanned,
      'violationCount': violationCount,
    };
  }
}
