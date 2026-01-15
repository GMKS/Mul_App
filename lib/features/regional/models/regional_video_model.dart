/// Regional Video Model with enhanced fields for regional feed
/// Supports city/district filtering, trending scores, and pagination

import '../../../models/video_model.dart';

/// Extended video model for regional feed with additional metadata
class RegionalVideo {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String language;
  final String category;
  final String region;
  final String state;
  final String city;
  final String? district;
  final String creatorId;
  final String creatorName;
  final String creatorAvatar;
  final bool isVerifiedCreator;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final double watchTime;
  final int replays;
  final DateTime createdAt;
  final List<String> hashtags;
  final bool isBoosted;
  final double? latitude;
  final double? longitude;

  RegionalVideo({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
    required this.region,
    required this.state,
    required this.city,
    this.district,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatar,
    this.isVerifiedCreator = false,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.watchTime = 0,
    this.replays = 0,
    required this.createdAt,
    this.hashtags = const [],
    this.isBoosted = false,
    this.latitude,
    this.longitude,
  });

  /// Calculate trending score based on engagement metrics
  /// score = views + (likes * 2) + (shares * 3) + (watchTime * 5) + (replays * 4)
  double get trendingScore {
    return views.toDouble() +
        (likes * 2) +
        (shares * 3) +
        (watchTime * 5) +
        (replays * 4);
  }

  /// Weighted trending score with recency boost
  /// Videos from the last 24 hours get 2x boost
  /// Videos from the last 7 days get 1.5x boost
  double get weightedTrendingScore {
    final now = DateTime.now();
    final age = now.difference(createdAt);

    double recencyMultiplier = 1.0;
    if (age.inHours < 24) {
      recencyMultiplier = 2.0;
    } else if (age.inDays < 7) {
      recencyMultiplier = 1.5;
    } else if (age.inDays < 30) {
      recencyMultiplier = 1.2;
    }

    // Boost for boosted content
    final boostMultiplier = isBoosted ? 1.5 : 1.0;

    return trendingScore * recencyMultiplier * boostMultiplier;
  }

  factory RegionalVideo.fromJson(Map<String, dynamic> json) {
    return RegionalVideo(
      id: json['id'] ?? '',
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? '',
      category: json['category'] ?? 'Regional',
      region: json['region'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      district: json['district'],
      creatorId: json['creator_id'] ?? json['creatorId'] ?? '',
      creatorName: json['creator_name'] ?? json['creatorName'] ?? '',
      creatorAvatar: json['creator_avatar'] ?? json['creatorAvatar'] ?? '',
      isVerifiedCreator:
          json['is_verified_creator'] ?? json['isVerifiedCreator'] ?? false,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      watchTime: (json['watch_time'] ?? json['watchTime'] ?? 0).toDouble(),
      replays: json['replays'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      isBoosted: json['is_boosted'] ?? json['isBoosted'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'title': title,
      'description': description,
      'language': language,
      'category': category,
      'region': region,
      'state': state,
      'city': city,
      'district': district,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'creator_avatar': creatorAvatar,
      'is_verified_creator': isVerifiedCreator,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'watch_time': watchTime,
      'replays': replays,
      'created_at': createdAt.toIso8601String(),
      'hashtags': hashtags,
      'is_boosted': isBoosted,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Convert from base Video model
  factory RegionalVideo.fromVideo(Video video) {
    return RegionalVideo(
      id: video.id,
      videoUrl: video.videoUrl,
      thumbnailUrl: video.thumbnailUrl,
      title: video.title,
      description: video.description,
      language: video.language,
      category: video.category,
      region: video.region,
      state: video.state,
      city: video.city,
      creatorId: video.creatorId,
      creatorName: video.creatorName,
      creatorAvatar: video.creatorAvatar,
      likes: video.likes,
      comments: video.comments,
      shares: video.shares,
      views: video.views,
      watchTime: video.watchTime,
      replays: video.replays,
      createdAt: video.createdAt,
      hashtags: video.hashtags,
      isBoosted: video.isBoosted,
    );
  }

  RegionalVideo copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    String? language,
    String? category,
    String? region,
    String? state,
    String? city,
    String? district,
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    bool? isVerifiedCreator,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    double? watchTime,
    int? replays,
    DateTime? createdAt,
    List<String>? hashtags,
    bool? isBoosted,
    double? latitude,
    double? longitude,
  }) {
    return RegionalVideo(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      category: category ?? this.category,
      region: region ?? this.region,
      state: state ?? this.state,
      city: city ?? this.city,
      district: district ?? this.district,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      isVerifiedCreator: isVerifiedCreator ?? this.isVerifiedCreator,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      watchTime: watchTime ?? this.watchTime,
      replays: replays ?? this.replays,
      createdAt: createdAt ?? this.createdAt,
      hashtags: hashtags ?? this.hashtags,
      isBoosted: isBoosted ?? this.isBoosted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionalVideo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
