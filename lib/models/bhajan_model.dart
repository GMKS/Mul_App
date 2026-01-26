/// Bhajan Model
/// Model for Daily Bhajan feature with 2026+ trends
/// Supports audio/video bhajans, categories, AI-curated playlists, offline favorites

/// Main Bhajan model
class Bhajan {
  final String id;
  final String title;
  final String mediaUrl;
  final BhajanType type; // audio or video
  final String language;
  final String? uploadedBy;
  final String? uploaderName;
  final String? uploaderAvatar;
  final BhajanCategory category;
  final List<String> tags;
  final BhajanMood? mood;
  final String? festival;
  final String? deity;
  final String? religion;
  final String? lyricsUrl;
  final String? subtitlesUrl;
  final String? coverImageUrl;
  final String? description;
  final Duration duration;
  final bool isTrending;
  final bool isFeatured;
  final int playCount;
  final int favoriteCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool approved;
  final bool aiGenerated;
  final bool aiUpscaled;
  final bool hasLyrics;
  final bool hasSubtitles;
  final bool isOfflineAvailable;
  final bool isFavorite;
  final StreamingQuality availableQuality;
  final List<String> availableLanguages;
  final double? userRating;
  final int ratingCount;

  Bhajan({
    required this.id,
    required this.title,
    required this.mediaUrl,
    required this.type,
    required this.language,
    this.uploadedBy,
    this.uploaderName,
    this.uploaderAvatar,
    this.category = BhajanCategory.general,
    this.tags = const [],
    this.mood,
    this.festival,
    this.deity,
    this.religion,
    this.lyricsUrl,
    this.subtitlesUrl,
    this.coverImageUrl,
    this.description,
    this.duration = Duration.zero,
    this.isTrending = false,
    this.isFeatured = false,
    this.playCount = 0,
    this.favoriteCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.approved = false,
    this.aiGenerated = false,
    this.aiUpscaled = false,
    this.hasLyrics = false,
    this.hasSubtitles = false,
    this.isOfflineAvailable = false,
    this.isFavorite = false,
    this.availableQuality = StreamingQuality.hd,
    this.availableLanguages = const [],
    this.userRating,
    this.ratingCount = 0,
  });

  factory Bhajan.fromJson(Map<String, dynamic> json) {
    return Bhajan(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      type: BhajanType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BhajanType.audio,
      ),
      language: json['language'] ?? 'hindi',
      uploadedBy: json['uploaded_by'],
      uploaderName: json['uploader_name'],
      uploaderAvatar: json['uploader_avatar'],
      category: BhajanCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BhajanCategory.general,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      mood: json['mood'] != null
          ? BhajanMood.values.firstWhere(
              (e) => e.name == json['mood'],
              orElse: () => BhajanMood.peaceful,
            )
          : null,
      festival: json['festival'],
      deity: json['deity'],
      religion: json['religion'],
      lyricsUrl: json['lyrics_url'],
      subtitlesUrl: json['subtitles_url'],
      coverImageUrl: json['cover_image_url'],
      description: json['description'],
      duration: Duration(seconds: json['duration_seconds'] ?? 0),
      isTrending: json['is_trending'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      playCount: json['play_count'] ?? 0,
      favoriteCount: json['favorite_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      shareCount: json['share_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      approved: json['approved'] ?? false,
      aiGenerated: json['ai_generated'] ?? false,
      aiUpscaled: json['ai_upscaled'] ?? false,
      hasLyrics: json['has_lyrics'] ?? false,
      hasSubtitles: json['has_subtitles'] ?? false,
      isOfflineAvailable: json['is_offline_available'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      availableQuality: StreamingQuality.values.firstWhere(
        (e) => e.name == json['available_quality'],
        orElse: () => StreamingQuality.hd,
      ),
      availableLanguages: List<String>.from(json['available_languages'] ?? []),
      userRating: json['user_rating']?.toDouble(),
      ratingCount: json['rating_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'media_url': mediaUrl,
      'type': type.name,
      'language': language,
      'uploaded_by': uploadedBy,
      'uploader_name': uploaderName,
      'uploader_avatar': uploaderAvatar,
      'category': category.name,
      'tags': tags,
      'mood': mood?.name,
      'festival': festival,
      'deity': deity,
      'religion': religion,
      'lyrics_url': lyricsUrl,
      'subtitles_url': subtitlesUrl,
      'cover_image_url': coverImageUrl,
      'description': description,
      'duration_seconds': duration.inSeconds,
      'is_trending': isTrending,
      'is_featured': isFeatured,
      'play_count': playCount,
      'favorite_count': favoriteCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'approved': approved,
      'ai_generated': aiGenerated,
      'ai_upscaled': aiUpscaled,
      'has_lyrics': hasLyrics,
      'has_subtitles': hasSubtitles,
      'is_offline_available': isOfflineAvailable,
      'is_favorite': isFavorite,
      'available_quality': availableQuality.name,
      'available_languages': availableLanguages,
      'user_rating': userRating,
      'rating_count': ratingCount,
    };
  }

  Bhajan copyWith({
    String? id,
    String? title,
    String? mediaUrl,
    BhajanType? type,
    String? language,
    String? uploadedBy,
    String? uploaderName,
    String? uploaderAvatar,
    BhajanCategory? category,
    List<String>? tags,
    BhajanMood? mood,
    String? festival,
    String? deity,
    String? religion,
    String? lyricsUrl,
    String? subtitlesUrl,
    String? coverImageUrl,
    String? description,
    Duration? duration,
    bool? isTrending,
    bool? isFeatured,
    int? playCount,
    int? favoriteCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? approved,
    bool? aiGenerated,
    bool? aiUpscaled,
    bool? hasLyrics,
    bool? hasSubtitles,
    bool? isOfflineAvailable,
    bool? isFavorite,
    StreamingQuality? availableQuality,
    List<String>? availableLanguages,
    double? userRating,
    int? ratingCount,
  }) {
    return Bhajan(
      id: id ?? this.id,
      title: title ?? this.title,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      language: language ?? this.language,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderAvatar: uploaderAvatar ?? this.uploaderAvatar,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      festival: festival ?? this.festival,
      deity: deity ?? this.deity,
      religion: religion ?? this.religion,
      lyricsUrl: lyricsUrl ?? this.lyricsUrl,
      subtitlesUrl: subtitlesUrl ?? this.subtitlesUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      isTrending: isTrending ?? this.isTrending,
      isFeatured: isFeatured ?? this.isFeatured,
      playCount: playCount ?? this.playCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approved: approved ?? this.approved,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      aiUpscaled: aiUpscaled ?? this.aiUpscaled,
      hasLyrics: hasLyrics ?? this.hasLyrics,
      hasSubtitles: hasSubtitles ?? this.hasSubtitles,
      isOfflineAvailable: isOfflineAvailable ?? this.isOfflineAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      availableQuality: availableQuality ?? this.availableQuality,
      availableLanguages: availableLanguages ?? this.availableLanguages,
      userRating: userRating ?? this.userRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

/// Bhajan Type Enum
enum BhajanType {
  audio,
  video,
}

/// Bhajan Category Enum
enum BhajanCategory {
  morning,
  evening,
  festival,
  aarti,
  kirtan,
  mantra,
  chalisa,
  stotram,
  bhakti,
  meditation,
  general,
}

/// Bhajan Mood Enum
enum BhajanMood {
  peaceful,
  energetic,
  devotional,
  meditative,
  celebratory,
  soulful,
  uplifting,
}

/// Streaming Quality Enum
enum StreamingQuality {
  auto,
  low, // 360p
  medium, // 480p
  hd, // 720p
  fullHd, // 1080p
  ultraHd, // 4K
  spatialAudio, // Spatial Audio for immersive experience
}

/// Bhajan Playlist Model (AI-Curated)
class BhajanPlaylist {
  final String id;
  final String name;
  final String description;
  final String? coverImageUrl;
  final List<Bhajan> bhajans;
  final PlaylistType playlistType;
  final bool isAiCurated;
  final bool isPublic;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int followerCount;
  final Duration totalDuration;

  BhajanPlaylist({
    required this.id,
    required this.name,
    required this.description,
    this.coverImageUrl,
    this.bhajans = const [],
    this.playlistType = PlaylistType.userCreated,
    this.isAiCurated = false,
    this.isPublic = true,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.followerCount = 0,
    this.totalDuration = Duration.zero,
  });

  factory BhajanPlaylist.fromJson(Map<String, dynamic> json) {
    return BhajanPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      coverImageUrl: json['cover_image_url'],
      bhajans: (json['bhajans'] as List<dynamic>?)
              ?.map((b) => Bhajan.fromJson(b))
              .toList() ??
          [],
      playlistType: PlaylistType.values.firstWhere(
        (e) => e.name == json['playlist_type'],
        orElse: () => PlaylistType.userCreated,
      ),
      isAiCurated: json['is_ai_curated'] ?? false,
      isPublic: json['is_public'] ?? true,
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      followerCount: json['follower_count'] ?? 0,
      totalDuration: Duration(seconds: json['total_duration_seconds'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image_url': coverImageUrl,
      'bhajans': bhajans.map((b) => b.toJson()).toList(),
      'playlist_type': playlistType.name,
      'is_ai_curated': isAiCurated,
      'is_public': isPublic,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'follower_count': followerCount,
      'total_duration_seconds': totalDuration.inSeconds,
    };
  }
}

/// Playlist Type Enum
enum PlaylistType {
  userCreated,
  aiCurated,
  festivalSpecial,
  morningRitual,
  eveningRitual,
  trending,
  editorial,
}

/// Live Bhajan Room Model
class BhajanRoom {
  final String id;
  final String name;
  final String description;
  final String hostId;
  final String hostName;
  final String? hostAvatar;
  final String? currentBhajanId;
  final Bhajan? currentBhajan;
  final int participantCount;
  final int maxParticipants;
  final bool isLive;
  final bool isPrivate;
  final String? roomCode;
  final DateTime startedAt;
  final List<BhajanRoomParticipant> participants;
  final List<BhajanRoomMessage> recentMessages;

  BhajanRoom({
    required this.id,
    required this.name,
    required this.description,
    required this.hostId,
    required this.hostName,
    this.hostAvatar,
    this.currentBhajanId,
    this.currentBhajan,
    this.participantCount = 0,
    this.maxParticipants = 100,
    this.isLive = false,
    this.isPrivate = false,
    this.roomCode,
    required this.startedAt,
    this.participants = const [],
    this.recentMessages = const [],
  });

  factory BhajanRoom.fromJson(Map<String, dynamic> json) {
    return BhajanRoom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      hostId: json['host_id'] ?? '',
      hostName: json['host_name'] ?? '',
      hostAvatar: json['host_avatar'],
      currentBhajanId: json['current_bhajan_id'],
      currentBhajan: json['current_bhajan'] != null
          ? Bhajan.fromJson(json['current_bhajan'])
          : null,
      participantCount: json['participant_count'] ?? 0,
      maxParticipants: json['max_participants'] ?? 100,
      isLive: json['is_live'] ?? false,
      isPrivate: json['is_private'] ?? false,
      roomCode: json['room_code'],
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => BhajanRoomParticipant.fromJson(p))
              .toList() ??
          [],
      recentMessages: (json['recent_messages'] as List<dynamic>?)
              ?.map((m) => BhajanRoomMessage.fromJson(m))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'host_id': hostId,
      'host_name': hostName,
      'host_avatar': hostAvatar,
      'current_bhajan_id': currentBhajanId,
      'current_bhajan': currentBhajan?.toJson(),
      'participant_count': participantCount,
      'max_participants': maxParticipants,
      'is_live': isLive,
      'is_private': isPrivate,
      'room_code': roomCode,
      'started_at': startedAt.toIso8601String(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'recent_messages': recentMessages.map((m) => m.toJson()).toList(),
    };
  }
}

/// Bhajan Room Participant
class BhajanRoomParticipant {
  final String id;
  final String name;
  final String? avatar;
  final bool isHost;
  final DateTime joinedAt;

  BhajanRoomParticipant({
    required this.id,
    required this.name,
    this.avatar,
    this.isHost = false,
    required this.joinedAt,
  });

  factory BhajanRoomParticipant.fromJson(Map<String, dynamic> json) {
    return BhajanRoomParticipant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      isHost: json['is_host'] ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'is_host': isHost,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

/// Bhajan Room Message
class BhajanRoomMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final MessageType messageType;
  final DateTime sentAt;

  BhajanRoomMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    this.messageType = MessageType.text,
    required this.sentAt,
  });

  factory BhajanRoomMessage.fromJson(Map<String, dynamic> json) {
    return BhajanRoomMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      senderAvatar: json['sender_avatar'],
      message: json['message'] ?? '',
      messageType: MessageType.values.firstWhere(
        (e) => e.name == json['message_type'],
        orElse: () => MessageType.text,
      ),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'message': message,
      'message_type': messageType.name,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}

/// Message Type Enum
enum MessageType {
  text,
  emoji,
  reaction,
  system,
}

/// Bhajan Favorite Model
class BhajanFavorite {
  final String id;
  final String userId;
  final String bhajanId;
  final Bhajan? bhajan;
  final bool isOfflineDownloaded;
  final DateTime addedAt;

  BhajanFavorite({
    required this.id,
    required this.userId,
    required this.bhajanId,
    this.bhajan,
    this.isOfflineDownloaded = false,
    required this.addedAt,
  });

  factory BhajanFavorite.fromJson(Map<String, dynamic> json) {
    return BhajanFavorite(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bhajanId: json['bhajan_id'] ?? '',
      bhajan: json['bhajan'] != null ? Bhajan.fromJson(json['bhajan']) : null,
      isOfflineDownloaded: json['is_offline_downloaded'] ?? false,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bhajan_id': bhajanId,
      'bhajan': bhajan?.toJson(),
      'is_offline_downloaded': isOfflineDownloaded,
      'added_at': addedAt.toIso8601String(),
    };
  }
}

/// Bhajan Upload Request Model (for contributor uploads)
class BhajanUploadRequest {
  final String id;
  final String title;
  final String mediaUrl;
  final BhajanType type;
  final String language;
  final String uploadedBy;
  final BhajanCategory category;
  final List<String> tags;
  final String? deity;
  final String? religion;
  final String? description;
  final String? lyricsText;
  final UploadStatus status;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  BhajanUploadRequest({
    required this.id,
    required this.title,
    required this.mediaUrl,
    required this.type,
    required this.language,
    required this.uploadedBy,
    this.category = BhajanCategory.general,
    this.tags = const [],
    this.deity,
    this.religion,
    this.description,
    this.lyricsText,
    this.status = UploadStatus.pending,
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory BhajanUploadRequest.fromJson(Map<String, dynamic> json) {
    return BhajanUploadRequest(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      mediaUrl: json['media_url'] ?? '',
      type: BhajanType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BhajanType.audio,
      ),
      language: json['language'] ?? 'hindi',
      uploadedBy: json['uploaded_by'] ?? '',
      category: BhajanCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BhajanCategory.general,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      deity: json['deity'],
      religion: json['religion'],
      description: json['description'],
      lyricsText: json['lyrics_text'],
      status: UploadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UploadStatus.pending,
      ),
      rejectionReason: json['rejection_reason'],
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      reviewedBy: json['reviewed_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'media_url': mediaUrl,
      'type': type.name,
      'language': language,
      'uploaded_by': uploadedBy,
      'category': category.name,
      'tags': tags,
      'deity': deity,
      'religion': religion,
      'description': description,
      'lyrics_text': lyricsText,
      'status': status.name,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
    };
  }
}

/// Upload Status Enum
enum UploadStatus {
  pending,
  aiReview,
  humanReview,
  approved,
  rejected,
}

/// Bhajan Comment Model
class BhajanComment {
  final String id;
  final String bhajanId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<BhajanComment> replies;

  BhajanComment({
    required this.id,
    required this.bhajanId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.replies = const [],
  });

  factory BhajanComment.fromJson(Map<String, dynamic> json) {
    return BhajanComment(
      id: json['id'] ?? '',
      bhajanId: json['bhajan_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      content: json['content'] ?? '',
      likeCount: json['like_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => BhajanComment.fromJson(r))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bhajan_id': bhajanId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'like_count': likeCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}

/// Listening History Model
class BhajanListeningHistory {
  final String id;
  final String userId;
  final String bhajanId;
  final Bhajan? bhajan;
  final Duration listenedDuration;
  final DateTime listenedAt;
  final bool completed;

  BhajanListeningHistory({
    required this.id,
    required this.userId,
    required this.bhajanId,
    this.bhajan,
    required this.listenedDuration,
    required this.listenedAt,
    this.completed = false,
  });

  factory BhajanListeningHistory.fromJson(Map<String, dynamic> json) {
    return BhajanListeningHistory(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      bhajanId: json['bhajan_id'] ?? '',
      bhajan: json['bhajan'] != null ? Bhajan.fromJson(json['bhajan']) : null,
      listenedDuration:
          Duration(seconds: json['listened_duration_seconds'] ?? 0),
      listenedAt: json['listened_at'] != null
          ? DateTime.parse(json['listened_at'])
          : DateTime.now(),
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bhajan_id': bhajanId,
      'bhajan': bhajan?.toJson(),
      'listened_duration_seconds': listenedDuration.inSeconds,
      'listened_at': listenedAt.toIso8601String(),
      'completed': completed,
    };
  }
}
