/// Content Report Model
/// For reporting inappropriate or problematic content

import 'package:flutter/material.dart';

enum ReportCategory {
  spam,
  inappropriate,
  misinformation,
  copyright,
  harassment,
  violence,
  hateSpeech,
  other,
}

enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
}

enum ReportedContentType {
  devotionalVideo,
  businessVideo,
  regionalVideo,
  businessPost,
  event,
  comment,
  user,
}

class ContentReport {
  final String id;
  final String reporterId;
  final String reporterName;
  final String contentId;
  final ReportedContentType contentType;
  final String contentOwnerId;
  final String contentOwnerName;
  final ReportCategory category;
  final String? additionalComment;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final DateTime? resolvedAt;
  final String? adminId;
  final String? adminName;
  final String? adminAction;
  final String? adminNotes;
  final String? feedbackToReporter;
  final bool isAnonymous;

  // Content details for display
  final String contentTitle;
  final String? contentDescription;
  final String? contentThumbnail;

  ContentReport({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.contentId,
    required this.contentType,
    required this.contentOwnerId,
    required this.contentOwnerName,
    required this.category,
    this.additionalComment,
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.reviewedAt,
    this.resolvedAt,
    this.adminId,
    this.adminName,
    this.adminAction,
    this.adminNotes,
    this.feedbackToReporter,
    this.isAnonymous = true,
    required this.contentTitle,
    this.contentDescription,
    this.contentThumbnail,
  });

  ContentReport copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? contentId,
    ReportedContentType? contentType,
    String? contentOwnerId,
    String? contentOwnerName,
    ReportCategory? category,
    String? additionalComment,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    DateTime? resolvedAt,
    String? adminId,
    String? adminName,
    String? adminAction,
    String? adminNotes,
    String? feedbackToReporter,
    bool? isAnonymous,
    String? contentTitle,
    String? contentDescription,
    String? contentThumbnail,
  }) {
    return ContentReport(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      contentId: contentId ?? this.contentId,
      contentType: contentType ?? this.contentType,
      contentOwnerId: contentOwnerId ?? this.contentOwnerId,
      contentOwnerName: contentOwnerName ?? this.contentOwnerName,
      category: category ?? this.category,
      additionalComment: additionalComment ?? this.additionalComment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      adminAction: adminAction ?? this.adminAction,
      adminNotes: adminNotes ?? this.adminNotes,
      feedbackToReporter: feedbackToReporter ?? this.feedbackToReporter,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      contentTitle: contentTitle ?? this.contentTitle,
      contentDescription: contentDescription ?? this.contentDescription,
      contentThumbnail: contentThumbnail ?? this.contentThumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reporter_name': reporterName,
      'content_id': contentId,
      'content_type': contentType.name,
      'content_owner_id': contentOwnerId,
      'content_owner_name': contentOwnerName,
      'category': category.name,
      'additional_comment': additionalComment,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'admin_id': adminId,
      'admin_name': adminName,
      'admin_action': adminAction,
      'admin_notes': adminNotes,
      'feedback_to_reporter': feedbackToReporter,
      'is_anonymous': isAnonymous,
      'content_title': contentTitle,
      'content_description': contentDescription,
      'content_thumbnail': contentThumbnail,
    };
  }

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    return ContentReport(
      id: json['id'],
      reporterId: json['reporter_id'],
      reporterName: json['reporter_name'],
      contentId: json['content_id'],
      contentType: ReportedContentType.values.firstWhere(
        (e) => e.name == json['content_type'],
      ),
      contentOwnerId: json['content_owner_id'],
      contentOwnerName: json['content_owner_name'],
      category: ReportCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      additionalComment: json['additional_comment'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      adminId: json['admin_id'],
      adminName: json['admin_name'],
      adminAction: json['admin_action'],
      adminNotes: json['admin_notes'],
      feedbackToReporter: json['feedback_to_reporter'],
      isAnonymous: json['is_anonymous'] ?? true,
      contentTitle: json['content_title'],
      contentDescription: json['content_description'],
      contentThumbnail: json['content_thumbnail'],
    );
  }

  // Get category display name
  String get categoryDisplayName {
    switch (category) {
      case ReportCategory.spam:
        return 'Spam';
      case ReportCategory.inappropriate:
        return 'Inappropriate Content';
      case ReportCategory.misinformation:
        return 'Misinformation';
      case ReportCategory.copyright:
        return 'Copyright Violation';
      case ReportCategory.harassment:
        return 'Harassment';
      case ReportCategory.violence:
        return 'Violence';
      case ReportCategory.hateSpeech:
        return 'Hate Speech';
      case ReportCategory.other:
        return 'Other';
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  // Get status color
  Color get statusColor {
    switch (status) {
      case ReportStatus.pending:
        return Color(0xFFf59e0b); // Orange
      case ReportStatus.underReview:
        return Color(0xFF3b82f6); // Blue
      case ReportStatus.resolved:
        return Color(0xFF10b981); // Green
      case ReportStatus.dismissed:
        return Color(0xFF6b7280); // Gray
    }
  }
}

// Extension methods for report categories
extension ReportCategoryExtension on ReportCategory {
  String get displayName {
    switch (this) {
      case ReportCategory.spam:
        return 'Spam';
      case ReportCategory.inappropriate:
        return 'Inappropriate Content';
      case ReportCategory.misinformation:
        return 'Misinformation';
      case ReportCategory.copyright:
        return 'Copyright Violation';
      case ReportCategory.harassment:
        return 'Harassment';
      case ReportCategory.violence:
        return 'Violence';
      case ReportCategory.hateSpeech:
        return 'Hate Speech';
      case ReportCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ReportCategory.spam:
        return '🚫';
      case ReportCategory.inappropriate:
        return '⚠️';
      case ReportCategory.misinformation:
        return '❌';
      case ReportCategory.copyright:
        return '©️';
      case ReportCategory.harassment:
        return '😡';
      case ReportCategory.violence:
        return '⚔️';
      case ReportCategory.hateSpeech:
        return '🗣️';
      case ReportCategory.other:
        return '📝';
    }
  }
}
