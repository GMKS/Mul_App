/// Feedback & Suggestions Models
/// Comprehensive models for community feedback, suggestions, polls, and voting

import 'package:flutter/material.dart';

enum FeedbackType {
  bug,
  feature,
  improvement,
  service,
  safety,
  event,
  general,
}

enum FeedbackStatus {
  received,
  underReview,
  inProgress,
  resolved,
  planned,
  rejected,
}

enum MediaType {
  image,
  video,
  audio,
}

class FeedbackMedia {
  final String id;
  final MediaType type;
  final String url;
  final String? thumbnail;

  FeedbackMedia({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
  });

  factory FeedbackMedia.fromJson(Map<String, dynamic> json) {
    return FeedbackMedia(
      id: json['id'] ?? '',
      type: MediaType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => MediaType.image,
      ),
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'url': url,
      'thumbnail': thumbnail,
    };
  }
}

class UserFeedback {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final FeedbackType type;
  final String title;
  final String description;
  final List<FeedbackMedia> media;
  final FeedbackStatus status;
  final bool isAnonymous;
  final String city;
  final String state;
  final String language;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;
  final DateTime? adminResponseAt;
  final List<String> tags;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.type,
    required this.title,
    required this.description,
    this.media = const [],
    required this.status,
    this.isAnonymous = false,
    required this.city,
    required this.state,
    required this.language,
    this.upvotes = 0,
    this.downvotes = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
    this.adminResponseAt,
    this.tags = const [],
  });

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatar: json['userAvatar'],
      type: FeedbackType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => FeedbackType.general,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      media: (json['media'] as List?)
              ?.map((m) => FeedbackMedia.fromJson(m))
              .toList() ??
          [],
      status: FeedbackStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => FeedbackStatus.received,
      ),
      isAnonymous: json['isAnonymous'] ?? false,
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      language: json['language'] ?? 'en',
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      adminResponse: json['adminResponse'],
      adminResponseAt: json['adminResponseAt'] != null
          ? DateTime.parse(json['adminResponseAt'])
          : null,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'type': type.toString(),
      'title': title,
      'description': description,
      'media': media.map((m) => m.toJson()).toList(),
      'status': status.toString(),
      'isAnonymous': isAnonymous,
      'city': city,
      'state': state,
      'language': language,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'adminResponse': adminResponse,
      'adminResponseAt': adminResponseAt?.toIso8601String(),
      'tags': tags,
    };
  }

  Color get statusColor {
    switch (status) {
      case FeedbackStatus.received:
        return Colors.blue;
      case FeedbackStatus.underReview:
        return Colors.orange;
      case FeedbackStatus.inProgress:
        return Colors.purple;
      case FeedbackStatus.resolved:
        return Colors.green;
      case FeedbackStatus.planned:
        return Colors.cyan;
      case FeedbackStatus.rejected:
        return Colors.red;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackType.feature:
        return Icons.lightbulb;
      case FeedbackType.improvement:
        return Icons.trending_up;
      case FeedbackType.service:
        return Icons.build;
      case FeedbackType.safety:
        return Icons.shield;
      case FeedbackType.event:
        return Icons.event;
      case FeedbackType.general:
        return Icons.feedback;
    }
  }
}

class CommunityPoll {
  final String id;
  final String title;
  final String description;
  final List<PollOption> options;
  final int totalVotes;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final bool allowMultipleVotes;
  final String city;
  final String state;

  CommunityPoll({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    this.totalVotes = 0,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.allowMultipleVotes = false,
    required this.city,
    required this.state,
  });

  factory CommunityPoll.fromJson(Map<String, dynamic> json) {
    return CommunityPoll(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      options: (json['options'] as List?)
              ?.map((o) => PollOption.fromJson(o))
              .toList() ??
          [],
      totalVotes: json['totalVotes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isActive: json['isActive'] ?? true,
      allowMultipleVotes: json['allowMultipleVotes'] ?? false,
      city: json['city'] ?? '',
      state: json['state'] ?? '',
    );
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class PollOption {
  final String id;
  final String text;
  final int votes;
  final Color? color;

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.color,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      votes: json['votes'] ?? 0,
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
      'color': color?.value,
    };
  }

  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0;
    return (votes / totalVotes) * 100;
  }
}

class FeedbackComment {
  final String id;
  final String feedbackId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String comment;
  final DateTime createdAt;
  final bool isAdminComment;

  FeedbackComment({
    required this.id,
    required this.feedbackId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.comment,
    required this.createdAt,
    this.isAdminComment = false,
  });

  factory FeedbackComment.fromJson(Map<String, dynamic> json) {
    return FeedbackComment(
      id: json['id'] ?? '',
      feedbackId: json['feedbackId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      userAvatar: json['userAvatar'],
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isAdminComment: json['isAdminComment'] ?? false,
    );
  }
}

class UserVote {
  final String userId;
  final String feedbackId;
  final bool isUpvote;
  final DateTime votedAt;

  UserVote({
    required this.userId,
    required this.feedbackId,
    required this.isUpvote,
    required this.votedAt,
  });
}
