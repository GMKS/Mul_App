// STEP 11: Content Moderation Service
// Implement content reporting.
// Flag abusive content.
// Apply soft ban or shadow ban on repeat violations.

import '../models/moderation_model.dart';

class ModerationService {
  // Report content
  static Future<ContentReport> reportContent({
    required String contentId,
    required String contentType,
    required String reporterId,
    required ReportReason reason,
    String description = '',
  }) async {
    final report = ContentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      contentId: contentId,
      contentType: contentType,
      reporterId: reporterId,
      reason: reason,
      description: description,
      reportedAt: DateTime.now(),
    );

    // TODO: Save to backend
    // await api.submitReport(report.toJson());

    return report;
  }

  // Check if content should be hidden (shadow banned)
  static bool shouldHideContent({
    required bool isCreatorShadowBanned,
    required int reportCount,
    required bool isReported,
  }) {
    // Hide if creator is shadow banned
    if (isCreatorShadowBanned) return true;

    // Hide if report count exceeds threshold
    if (reportCount >= 5) return true;

    return false;
  }

  // Determine action based on violation count
  static BanType determineAction(int violationCount) {
    return UserViolation.determineBanType(violationCount);
  }

  // Get ban message
  static String getBanMessage(BanType banType, DateTime? expiresAt) {
    switch (banType) {
      case BanType.warning:
        return 'You have received a warning for violating community guidelines.';
      case BanType.temporaryBan:
        final days = expiresAt?.difference(DateTime.now()).inDays ?? 7;
        return 'Your account has been temporarily restricted for $days days.';
      case BanType.shadowBan:
        return 'Your content visibility has been reduced due to repeated violations.';
      case BanType.permanentBan:
        return 'Your account has been permanently banned for severe violations.';
      case BanType.none:
        return '';
    }
  }

  // Check if user can post content
  static bool canUserPost(BanType banType, DateTime? banExpiresAt) {
    switch (banType) {
      case BanType.none:
      case BanType.warning:
      case BanType.shadowBan: // Shadow ban allows posting but limits visibility
        return true;
      case BanType.temporaryBan:
        if (banExpiresAt == null) return false;
        return DateTime.now().isAfter(banExpiresAt);
      case BanType.permanentBan:
        return false;
    }
  }

  // Get report reasons for display
  static List<Map<String, dynamic>> getReportReasons() {
    return ReportReason.values.map((reason) {
      return {
        'reason': reason,
        'text': ContentReport.getReasonDisplayText(reason),
        'icon': _getReasonIcon(reason),
      };
    }).toList();
  }

  static String _getReasonIcon(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return '🚫';
      case ReportReason.harassment:
        return '😠';
      case ReportReason.hateContent:
        return '🛑';
      case ReportReason.violence:
        return '⚠️';
      case ReportReason.nudity:
        return '🔞';
      case ReportReason.misinformation:
        return '❌';
      case ReportReason.copyright:
        return '©️';
      case ReportReason.other:
        return '📝';
    }
  }

  // Auto-moderate content (basic implementation)
  static Future<bool> autoModerateText(String text) async {
    // Basic word filter (expand in production)
    final blockedWords = [
      // Add blocked words here
    ];

    final lowerText = text.toLowerCase();
    for (final word in blockedWords) {
      if (lowerText.contains(word)) {
        return false; // Content should be blocked
      }
    }

    return true; // Content is okay
  }
}
