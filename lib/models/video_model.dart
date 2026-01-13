// STEP 4: Video Feed Model
// Create a Video model with fields:
// id, videoUrl, language, category, region,
// likes, comments, shares, views, watchTime, createdAt

class Video {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String language;
  final String category; // Regional, Business, Devotional
  final String region;
  final String state;
  final String city;
  final String creatorId;
  final String creatorName;
  final String creatorAvatar;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final double watchTime; // Average watch time in seconds
  final int replays;
  final DateTime createdAt;
  final List<String> hashtags;
  final bool isFestivalContent;
  final String? festivalTag;
  final bool isBoosted; // For monetization - boosted videos
  final bool isReported;
  final int reportCount;

  Video({
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
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatar,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.watchTime = 0,
    this.replays = 0,
    required this.createdAt,
    this.hashtags = const [],
    this.isFestivalContent = false,
    this.festivalTag,
    this.isBoosted = false,
    this.isReported = false,
    this.reportCount = 0,
  });

  // STEP 5: Trending Algorithm
  // score = views + (likes * 2) + (shares * 3) + (watchTime * 5)
  double get trendingScore {
    return views + (likes * 2) + (shares * 3) + (watchTime * 5) + (replays * 4);
  }

  // For boosted content, increase visibility
  double get boostedScore {
    return isBoosted ? trendingScore * 1.5 : trendingScore;
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? '',
      category: json['category'] ?? '',
      region: json['region'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      creatorId: json['creatorId'] ?? '',
      creatorName: json['creatorName'] ?? '',
      creatorAvatar: json['creatorAvatar'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      watchTime: (json['watchTime'] ?? 0).toDouble(),
      replays: json['replays'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      isFestivalContent: json['isFestivalContent'] ?? false,
      festivalTag: json['festivalTag'],
      isBoosted: json['isBoosted'] ?? false,
      isReported: json['isReported'] ?? false,
      reportCount: json['reportCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'description': description,
      'language': language,
      'category': category,
      'region': region,
      'state': state,
      'city': city,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'watchTime': watchTime,
      'replays': replays,
      'createdAt': createdAt.toIso8601String(),
      'hashtags': hashtags,
      'isFestivalContent': isFestivalContent,
      'festivalTag': festivalTag,
      'isBoosted': isBoosted,
      'isReported': isReported,
      'reportCount': reportCount,
    };
  }

  Video copyWith({
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
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    double? watchTime,
    int? replays,
    DateTime? createdAt,
    List<String>? hashtags,
    bool? isFestivalContent,
    String? festivalTag,
    bool? isBoosted,
    bool? isReported,
    int? reportCount,
  }) {
    return Video(
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
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      watchTime: watchTime ?? this.watchTime,
      replays: replays ?? this.replays,
      createdAt: createdAt ?? this.createdAt,
      hashtags: hashtags ?? this.hashtags,
      isFestivalContent: isFestivalContent ?? this.isFestivalContent,
      festivalTag: festivalTag ?? this.festivalTag,
      isBoosted: isBoosted ?? this.isBoosted,
      isReported: isReported ?? this.isReported,
      reportCount: reportCount ?? this.reportCount,
    );
  }
}

// Comment model for social interactions
class VideoComment {
  final String id;
  final String videoId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final String? voiceCommentUrl; // STEP 9: Voice comment option
  final List<EmojiReaction> reactions;
  final DateTime createdAt;

  VideoComment({
    required this.id,
    required this.videoId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    this.voiceCommentUrl,
    this.reactions = const [],
    required this.createdAt,
  });

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      id: json['id'] ?? '',
      videoId: json['videoId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      text: json['text'] ?? '',
      voiceCommentUrl: json['voiceCommentUrl'],
      reactions: (json['reactions'] as List?)
              ?.map((e) => EmojiReaction.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

// STEP 9: Emoji reactions
class EmojiReaction {
  final String emoji;
  final String userId;
  final DateTime createdAt;

  EmojiReaction({
    required this.emoji,
    required this.userId,
    required this.createdAt,
  });

  factory EmojiReaction.fromJson(Map<String, dynamic> json) {
    return EmojiReaction(
      emoji: json['emoji'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class VideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final double distanceKm;
  final String location;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.distanceKm,
    required this.location,
  });
}
