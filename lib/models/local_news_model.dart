/// Local News Model
/// Hyperlocal, AI-verified news with community validation
/// Features: Short-form, multi-media, real-time, social engagement

/// News Status Enum
enum NewsStatus {
  pending,
  aiReview,
  communityVerified,
  adminVerified,
  published,
  rejected,
}

/// News Category Enum
enum NewsCategory {
  breaking,
  accident,
  crime,
  traffic,
  weather,
  event,
  development,
  education,
  health,
  politics,
  sports,
  entertainment,
  business,
  community,
  announcement,
  other,
}

/// News Priority Enum
enum NewsPriority {
  low,
  normal,
  high,
  urgent,
  breaking,
}

/// Reaction Type Enum
enum ReactionType {
  like,
  love,
  sad,
  angry,
  wow,
  support,
  pray,
}

/// Local News Model
class LocalNews {
  final String id;
  final String title;
  final String content;
  final String? tldr; // Short summary
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String? audioUrl; // Voice note

  // Location
  final double? latitude;
  final double? longitude;
  final String? locationName; // e.g., "Jubilee Hills, Hyderabad"
  final String? address;
  final double? radius; // Affected radius in km

  // Categorization
  final NewsCategory category;
  final List<String> tags;
  final NewsPriority priority;
  final String language;

  // Author/Reporter
  final String reportedBy; // User ID
  final String reporterName;
  final String? reporterAvatar;
  final bool isVerifiedReporter;
  final int reporterPoints; // Gamification

  // Verification & Trust
  final NewsStatus status;
  final double credibilityScore; // 0.0 to 1.0
  final bool aiVerified;
  final bool communityVerified;
  final bool adminVerified;
  final String? verifiedBy; // Admin ID
  final DateTime? verifiedAt;
  final String? rejectionReason;

  // Engagement
  final int viewCount;
  final int upvotes;
  final int downvotes;
  final int flagCount;
  final Map<String, int> reactions; // ReactionType -> count
  final int commentsCount;
  final int sharesCount;

  // Trending & Visibility
  final bool isTrending;
  final bool isBreaking;
  final bool isFeatured;
  final bool isPinned;
  final double trendingScore;

  // Timestamps
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? expiresAt; // For stories/breaking news
  final DateTime updatedAt;

  // Metadata
  final Map<String, dynamic>? metadata; // Flexible JSON field
  final List<String> relatedNewsIds;
  final String? sourceUrl; // If from external source

  const LocalNews({
    required this.id,
    required this.title,
    required this.content,
    this.tldr,
    this.imageUrls = const [],
    this.videoUrls = const [],
    this.audioUrl,
    this.latitude,
    this.longitude,
    this.locationName,
    this.address,
    this.radius,
    required this.category,
    this.tags = const [],
    this.priority = NewsPriority.normal,
    this.language = 'en',
    required this.reportedBy,
    required this.reporterName,
    this.reporterAvatar,
    this.isVerifiedReporter = false,
    this.reporterPoints = 0,
    this.status = NewsStatus.pending,
    this.credibilityScore = 0.5,
    this.aiVerified = false,
    this.communityVerified = false,
    this.adminVerified = false,
    this.verifiedBy,
    this.verifiedAt,
    this.rejectionReason,
    this.viewCount = 0,
    this.upvotes = 0,
    this.downvotes = 0,
    this.flagCount = 0,
    this.reactions = const {},
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isTrending = false,
    this.isBreaking = false,
    this.isFeatured = false,
    this.isPinned = false,
    this.trendingScore = 0.0,
    required this.createdAt,
    this.publishedAt,
    this.expiresAt,
    required this.updatedAt,
    this.metadata,
    this.relatedNewsIds = const [],
    this.sourceUrl,
  });

  factory LocalNews.fromJson(Map<String, dynamic> json) {
    return LocalNews(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      tldr: json['tldr'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      videoUrls: List<String>.from(json['video_urls'] ?? []),
      audioUrl: json['audio_url'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationName: json['location_name'],
      address: json['address'],
      radius: json['radius']?.toDouble(),
      category: NewsCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NewsCategory.other,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      priority: NewsPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NewsPriority.normal,
      ),
      language: json['language'] ?? 'en',
      reportedBy: json['reported_by'] ?? '',
      reporterName: json['reporter_name'] ?? '',
      reporterAvatar: json['reporter_avatar'],
      isVerifiedReporter: json['is_verified_reporter'] ?? false,
      reporterPoints: json['reporter_points'] ?? 0,
      status: NewsStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NewsStatus.pending,
      ),
      credibilityScore: json['credibility_score']?.toDouble() ?? 0.5,
      aiVerified: json['ai_verified'] ?? false,
      communityVerified: json['community_verified'] ?? false,
      adminVerified: json['admin_verified'] ?? false,
      verifiedBy: json['verified_by'],
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      rejectionReason: json['rejection_reason'],
      viewCount: json['view_count'] ?? 0,
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      flagCount: json['flag_count'] ?? 0,
      reactions: Map<String, int>.from(json['reactions'] ?? {}),
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      isTrending: json['is_trending'] ?? false,
      isBreaking: json['is_breaking'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      trendingScore: json['trending_score']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'])
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
      metadata: json['metadata'],
      relatedNewsIds: List<String>.from(json['related_news_ids'] ?? []),
      sourceUrl: json['source_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tldr': tldr,
      'image_urls': imageUrls,
      'video_urls': videoUrls,
      'audio_url': audioUrl,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'address': address,
      'radius': radius,
      'category': category.name,
      'tags': tags,
      'priority': priority.name,
      'language': language,
      'reported_by': reportedBy,
      'reporter_name': reporterName,
      'reporter_avatar': reporterAvatar,
      'is_verified_reporter': isVerifiedReporter,
      'reporter_points': reporterPoints,
      'status': status.name,
      'credibility_score': credibilityScore,
      'ai_verified': aiVerified,
      'community_verified': communityVerified,
      'admin_verified': adminVerified,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'view_count': viewCount,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'flag_count': flagCount,
      'reactions': reactions,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'is_trending': isTrending,
      'is_breaking': isBreaking,
      'is_featured': isFeatured,
      'is_pinned': isPinned,
      'trending_score': trendingScore,
      'created_at': createdAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
      'related_news_ids': relatedNewsIds,
      'source_url': sourceUrl,
    };
  }

  LocalNews copyWith({
    String? id,
    String? title,
    String? content,
    String? tldr,
    List<String>? imageUrls,
    List<String>? videoUrls,
    String? audioUrl,
    double? latitude,
    double? longitude,
    String? locationName,
    String? address,
    double? radius,
    NewsCategory? category,
    List<String>? tags,
    NewsPriority? priority,
    String? language,
    int? viewCount,
    int? upvotes,
    int? downvotes,
    bool? isTrending,
    bool? isBreaking,
  }) {
    return LocalNews(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tldr: tldr ?? this.tldr,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      address: address ?? this.address,
      radius: radius ?? this.radius,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      language: language ?? this.language,
      reportedBy: reportedBy,
      reporterName: reporterName,
      reporterAvatar: reporterAvatar,
      isVerifiedReporter: isVerifiedReporter,
      reporterPoints: reporterPoints,
      status: status,
      credibilityScore: credibilityScore,
      aiVerified: aiVerified,
      communityVerified: communityVerified,
      adminVerified: adminVerified,
      verifiedBy: verifiedBy,
      verifiedAt: verifiedAt,
      rejectionReason: rejectionReason,
      viewCount: viewCount ?? this.viewCount,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      flagCount: flagCount,
      reactions: reactions,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      isTrending: isTrending ?? this.isTrending,
      isBreaking: isBreaking ?? this.isBreaking,
      isFeatured: isFeatured,
      isPinned: isPinned,
      trendingScore: trendingScore,
      createdAt: createdAt,
      publishedAt: publishedAt,
      expiresAt: expiresAt,
      updatedAt: DateTime.now(),
      metadata: metadata,
      relatedNewsIds: relatedNewsIds,
      sourceUrl: sourceUrl,
    );
  }
}

/// News Comment Model
class NewsComment {
  final String id;
  final String newsId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String> imageUrls;
  final String? voiceNoteUrl;
  final String? parentId; // For threaded comments
  final int likeCount;
  final int replyCount;
  final bool isPinned;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NewsComment({
    required this.id,
    required this.newsId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrls = const [],
    this.voiceNoteUrl,
    this.parentId,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isPinned = false,
    this.isHidden = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsComment.fromJson(Map<String, dynamic> json) {
    return NewsComment(
      id: json['id'] ?? '',
      newsId: json['news_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      content: json['content'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      voiceNoteUrl: json['voice_note_url'],
      parentId: json['parent_id'],
      likeCount: json['like_count'] ?? 0,
      replyCount: json['reply_count'] ?? 0,
      isPinned: json['is_pinned'] ?? false,
      isHidden: json['is_hidden'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'news_id': newsId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'image_urls': imageUrls,
      'voice_note_url': voiceNoteUrl,
      'parent_id': parentId,
      'like_count': likeCount,
      'reply_count': replyCount,
      'is_pinned': isPinned,
      'is_hidden': isHidden,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// News Poll Model
class NewsPoll {
  final String id;
  final String newsId;
  final String question;
  final List<PollOption> options;
  final int totalVotes;
  final DateTime? expiresAt;
  final DateTime createdAt;

  const NewsPoll({
    required this.id,
    required this.newsId,
    required this.question,
    required this.options,
    this.totalVotes = 0,
    this.expiresAt,
    required this.createdAt,
  });

  factory NewsPoll.fromJson(Map<String, dynamic> json) {
    return NewsPoll(
      id: json['id'] ?? '',
      newsId: json['news_id'] ?? '',
      question: json['question'] ?? '',
      options: (json['options'] as List?)
              ?.map((o) => PollOption.fromJson(o))
              .toList() ??
          [],
      totalVotes: json['total_votes'] ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PollOption {
  final String id;
  final String text;
  final int votes;

  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      votes: json['votes'] ?? 0,
    );
  }
}

/// News Submission Request
class NewsSubmissionRequest {
  final String title;
  final String content;
  final String? tldr;
  final List<String> imagePaths;
  final List<String> videoPaths;
  final String? audioPath;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final NewsCategory category;
  final List<String> tags;
  final NewsPriority priority;
  final String language;

  const NewsSubmissionRequest({
    required this.title,
    required this.content,
    this.tldr,
    this.imagePaths = const [],
    this.videoPaths = const [],
    this.audioPath,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.category,
    this.tags = const [],
    this.priority = NewsPriority.normal,
    this.language = 'en',
  });
}

/// User Reporter Profile
class ReporterProfile {
  final String userId;
  final String userName;
  final String? avatar;
  final bool isVerified;
  final int totalReports;
  final int approvedReports;
  final int points;
  final double trustScore;
  final List<String> badges;
  final DateTime joinedAt;

  const ReporterProfile({
    required this.userId,
    required this.userName,
    this.avatar,
    this.isVerified = false,
    this.totalReports = 0,
    this.approvedReports = 0,
    this.points = 0,
    this.trustScore = 0.5,
    this.badges = const [],
    required this.joinedAt,
  });

  factory ReporterProfile.fromJson(Map<String, dynamic> json) {
    return ReporterProfile(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      avatar: json['avatar'],
      isVerified: json['is_verified'] ?? false,
      totalReports: json['total_reports'] ?? 0,
      approvedReports: json['approved_reports'] ?? 0,
      points: json['points'] ?? 0,
      trustScore: json['trust_score']?.toDouble() ?? 0.5,
      badges: List<String>.from(json['badges'] ?? []),
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }
}
