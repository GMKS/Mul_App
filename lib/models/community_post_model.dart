/// Community Post Model
/// Model for user-generated community posts

class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final PostCategory category;
  final String locality;
  final String? city;
  final String? state;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByUser;
  final bool isVerified;
  final bool isApproved;
  final bool isFlagged;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrls = const [],
    this.videoUrl,
    required this.category,
    required this.locality,
    this.city,
    this.state,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByUser = false,
    this.isVerified = false,
    this.isApproved = true,
    this.isFlagged = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? json['profiles']?['name'] ?? 'Anonymous',
      userAvatar: json['user_avatar'] ?? json['profiles']?['avatar_url'],
      content: json['content'] ?? '',
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videoUrl: json['video_url'],
      category: PostCategory.fromString(json['category']),
      locality: json['locality'] ?? '',
      city: json['city'],
      state: json['state'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
      isVerified: json['is_verified'] ?? false,
      isApproved: json['is_approved'] ?? true,
      isFlagged: json['is_flagged'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'category': category.value,
      'locality': locality,
      'city': city,
      'state': state,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_verified': isVerified,
      'is_approved': isApproved,
      'is_flagged': isFlagged,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CommunityPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? imageUrls,
    String? videoUrl,
    PostCategory? category,
    String? locality,
    String? city,
    String? state,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByUser,
    bool? isVerified,
    bool? isApproved,
    bool? isFlagged,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      locality: locality ?? this.locality,
      city: city ?? this.city,
      state: state ?? this.state,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      isVerified: isVerified ?? this.isVerified,
      isApproved: isApproved ?? this.isApproved,
      isFlagged: isFlagged ?? this.isFlagged,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Post categories
enum PostCategory {
  localIssues('local_issues', 'Local Issues', '🏘️'),
  communityHelp('community_help', 'Community Help', '🤝'),
  lostAndFound('lost_and_found', 'Lost & Found', '🔍'),
  events('events', 'Events', '🎉'),
  achievements('achievements', 'Achievements', '🏆'),
  general('general', 'General', '📝');

  final String value;
  final String label;
  final String emoji;

  const PostCategory(this.value, this.label, this.emoji);

  static PostCategory fromString(String? value) {
    switch (value) {
      case 'local_issues':
        return PostCategory.localIssues;
      case 'community_help':
        return PostCategory.communityHelp;
      case 'lost_and_found':
        return PostCategory.lostAndFound;
      case 'events':
        return PostCategory.events;
      case 'achievements':
        return PostCategory.achievements;
      default:
        return PostCategory.general;
    }
  }
}

/// Post Comment Model
class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int likesCount;
  final bool isLikedByUser;
  final bool isFlagged;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.likesCount = 0,
    this.isLikedByUser = false,
    this.isFlagged = false,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? json['profiles']?['name'] ?? 'Anonymous',
      userAvatar: json['user_avatar'] ?? json['profiles']?['avatar_url'],
      content: json['content'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      isLikedByUser: json['is_liked_by_user'] ?? false,
      isFlagged: json['is_flagged'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'content': content,
    };
  }
}
