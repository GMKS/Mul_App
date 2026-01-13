// STEP 11: Content Moderation
// Implement content reporting.
// Flag abusive content.
// Apply soft ban or shadow ban on repeat violations.

enum ReportReason {
  spam,
  harassment,
  hateContent,
  violence,
  nudity,
  misinformation,
  copyright,
  other,
}

enum ModerationStatus {
  pending,
  reviewed,
  approved,
  rejected,
  removed,
}

enum BanType {
  none,
  warning,
  temporaryBan,
  shadowBan,
  permanentBan,
}

class ContentReport {
  final String id;
  final String contentId; // Video ID or Comment ID
  final String contentType; // 'video' or 'comment'
  final String reporterId;
  final ReportReason reason;
  final String description;
  final DateTime reportedAt;
  final ModerationStatus status;
  final String? moderatorId;
  final String? moderatorNotes;
  final DateTime? reviewedAt;

  ContentReport({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.reporterId,
    required this.reason,
    this.description = '',
    required this.reportedAt,
    this.status = ModerationStatus.pending,
    this.moderatorId,
    this.moderatorNotes,
    this.reviewedAt,
  });

  factory ContentReport.fromJson(Map<String, dynamic> json) {
    return ContentReport(
      id: json['id'] ?? '',
      contentId: json['contentId'] ?? '',
      contentType: json['contentType'] ?? 'video',
      reporterId: json['reporterId'] ?? '',
      reason: ReportReason.values.firstWhere(
        (r) => r.toString() == json['reason'],
        orElse: () => ReportReason.other,
      ),
      description: json['description'] ?? '',
      reportedAt: json['reportedAt'] != null
          ? DateTime.parse(json['reportedAt'])
          : DateTime.now(),
      status: ModerationStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => ModerationStatus.pending,
      ),
      moderatorId: json['moderatorId'],
      moderatorNotes: json['moderatorNotes'],
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentId': contentId,
      'contentType': contentType,
      'reporterId': reporterId,
      'reason': reason.toString(),
      'description': description,
      'reportedAt': reportedAt.toIso8601String(),
      'status': status.toString(),
      'moderatorId': moderatorId,
      'moderatorNotes': moderatorNotes,
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  static String getReasonDisplayText(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam or misleading';
      case ReportReason.harassment:
        return 'Harassment or bullying';
      case ReportReason.hateContent:
        return 'Hate speech or symbols';
      case ReportReason.violence:
        return 'Violence or dangerous acts';
      case ReportReason.nudity:
        return 'Nudity or sexual content';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.copyright:
        return 'Copyright violation';
      case ReportReason.other:
        return 'Other';
    }
  }
}

// User violation tracking
class UserViolation {
  final String id;
  final String userId;
  final String contentId;
  final ReportReason reason;
  final DateTime violatedAt;
  final BanType actionTaken;
  final DateTime? banExpiresAt;

  UserViolation({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.reason,
    required this.violatedAt,
    this.actionTaken = BanType.warning,
    this.banExpiresAt,
  });

  factory UserViolation.fromJson(Map<String, dynamic> json) {
    return UserViolation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      contentId: json['contentId'] ?? '',
      reason: ReportReason.values.firstWhere(
        (r) => r.toString() == json['reason'],
        orElse: () => ReportReason.other,
      ),
      violatedAt: json['violatedAt'] != null
          ? DateTime.parse(json['violatedAt'])
          : DateTime.now(),
      actionTaken: BanType.values.firstWhere(
        (b) => b.toString() == json['actionTaken'],
        orElse: () => BanType.warning,
      ),
      banExpiresAt: json['banExpiresAt'] != null
          ? DateTime.parse(json['banExpiresAt'])
          : null,
    );
  }

  // Determine ban type based on violation count
  static BanType determineBanType(int violationCount) {
    if (violationCount <= 1) {
      return BanType.warning;
    } else if (violationCount <= 3) {
      return BanType.temporaryBan;
    } else if (violationCount <= 5) {
      return BanType.shadowBan;
    } else {
      return BanType.permanentBan;
    }
  }

  // Get ban duration based on type
  static Duration? getBanDuration(BanType banType) {
    switch (banType) {
      case BanType.warning:
        return null;
      case BanType.temporaryBan:
        return const Duration(days: 7);
      case BanType.shadowBan:
        return const Duration(days: 30);
      case BanType.permanentBan:
        return null; // Permanent
      case BanType.none:
        return null;
    }
  }
}
