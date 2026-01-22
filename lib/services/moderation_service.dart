/// Moderation Service
/// Handles content reporting, warnings, and moderation actions

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';
import '../models/warning_model.dart';
// import '../models/moderation_model.dart'; // Commented out - using new report_model.dart instead

class ModerationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Community Guidelines
  static const String communityGuidelines = '''
**Community Guidelines**

We're committed to making this a safe, respectful community for everyone. Please follow these guidelines:

**1. Be Respectful**
• Treat others with kindness and respect
• No harassment, hate speech, or bullying
• Respect different viewpoints and backgrounds

**2. Share Authentic Content**
• No spam or misleading information
• Don't impersonate others
• Respect intellectual property and copyright

**3. Keep It Safe**
• No violent or graphic content
• No content that promotes harm
• Report anything that makes you uncomfortable

**4. Privacy Matters**
• Don't share personal information of others
• Respect privacy and consent

**Violations**
• First offense: Warning + education
• Second offense: Temporary restriction
• Repeated violations: Account suspension

Thank you for helping keep our community safe! 🙏
''';

  /// Submit a content report
  static Future<bool> submitReport({
    required String contentId,
    required ReportedContentType contentType,
    required ReportCategory category,
    required String contentTitle,
    required String contentOwnerId,
    required String contentOwnerName,
    String? additionalComment,
    String? contentDescription,
    String? contentThumbnail,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final report = ContentReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reporterId: user.id,
        reporterName: user.email ?? 'Anonymous',
        contentId: contentId,
        contentType: contentType,
        contentOwnerId: contentOwnerId,
        contentOwnerName: contentOwnerName,
        category: category,
        additionalComment: additionalComment,
        createdAt: DateTime.now(),
        contentTitle: contentTitle,
        contentDescription: contentDescription,
        contentThumbnail: contentThumbnail,
      );

      // Check for duplicate reports from same user
      final existingReport = await _checkDuplicateReport(
        reporterId: user.id,
        contentId: contentId,
      );

      if (existingReport) {
        throw Exception('You have already reported this content');
      }

      // Save to database (mock implementation for now)
      // await _supabase.from('content_reports').insert(report.toJson());
      debugPrint('Report submitted: ${report.id}');

      return true;
    } catch (e) {
      debugPrint('Error submitting report: $e');
      return false;
    }
  }

  /// Check if user already reported this content
  static Future<bool> _checkDuplicateReport({
    required String reporterId,
    required String contentId,
  }) async {
    try {
      // TODO: Implement with actual database check
      return false;
    } catch (e) {
      debugPrint('Error checking duplicate report: $e');
      return false;
    }
  }

  /// Get user's reports
  static Future<List<ContentReport>> getUserReports(String userId) async {
    try {
      // TODO: Implement with actual database
      return _getMockUserReports(userId);
    } catch (e) {
      debugPrint('Error getting user reports: $e');
      return [];
    }
  }

  /// Get all reports (admin only)
  static Future<List<ContentReport>> getAllReports({
    ReportStatus? status,
    ReportCategory? category,
  }) async {
    try {
      // TODO: Implement with actual database
      return _getMockAllReports(status: status, category: category);
    } catch (e) {
      debugPrint('Error getting all reports: $e');
      return [];
    }
  }

  /// Update report status (admin only)
  static Future<bool> updateReportStatus({
    required String reportId,
    required ReportStatus status,
    required String adminId,
    required String adminName,
    String? adminAction,
    String? adminNotes,
    String? feedbackToReporter,
  }) async {
    try {
      // TODO: Implement with actual database
      debugPrint('Updating report $reportId to status: ${status.name}');
      return true;
    } catch (e) {
      debugPrint('Error updating report status: $e');
      return false;
    }
  }

  /// Issue a warning to user
  static Future<bool> issueWarning({
    required String userId,
    required String userName,
    required WarningType type,
    required WarningSeverity severity,
    required String reason,
    String? relatedContentId,
    String? relatedReportId,
    DateTime? expiresAt,
  }) async {
    try {
      final admin = _supabase.auth.currentUser;
      if (admin == null) return false;

      final warning = UserWarning(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        type: type,
        severity: severity,
        reason: reason,
        relatedContentId: relatedContentId,
        relatedReportId: relatedReportId,
        createdAt: DateTime.now(),
        issuedBy: admin.id,
        issuedByName: admin.email ?? 'Admin',
        expiresAt: expiresAt,
      );

      // TODO: Save to database
      debugPrint('Warning issued: ${warning.id}');

      // Send notification to user
      await _sendWarningNotification(warning);

      return true;
    } catch (e) {
      debugPrint('Error issuing warning: $e');
      return false;
    }
  }

  /// Get user's warnings
  static Future<List<UserWarning>> getUserWarnings(String userId) async {
    try {
      // TODO: Implement with actual database
      return [];
    } catch (e) {
      debugPrint('Error getting user warnings: $e');
      return [];
    }
  }

  /// Get user warning count
  static Future<int> getUserWarningCount(String userId) async {
    try {
      // TODO: Implement with actual database
      return 0;
    } catch (e) {
      debugPrint('Error getting warning count: $e');
      return 0;
    }
  }

  /// Send warning notification to user
  static Future<void> _sendWarningNotification(UserWarning warning) async {
    // TODO: Integrate with notification service
    debugPrint('Sending warning notification to user: ${warning.userId}');
  }

  /// Soft delete content (hide from users but keep for review)
  static Future<bool> softDeleteContent({
    required String contentId,
    required ReportedContentType contentType,
    required String reason,
  }) async {
    try {
      // TODO: Implement with actual database
      debugPrint('Soft deleting content: $contentId');
      return true;
    } catch (e) {
      debugPrint('Error soft deleting content: $e');
      return false;
    }
  }

  /// Restore soft deleted content
  static Future<bool> restoreContent({
    required String contentId,
    required ReportedContentType contentType,
  }) async {
    try {
      // TODO: Implement with actual database
      debugPrint('Restoring content: $contentId');
      return true;
    } catch (e) {
      debugPrint('Error restoring content: $e');
      return false;
    }
  }

  // Legacy methods for backwards compatibility
  static Future<ContentReport> reportContent({
    required String contentId,
    required String contentType,
    required String reporterId,
    required ReportCategory reason,
    String description = '',
  }) async {
    final report = ContentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reporterId: reporterId,
      reporterName: 'User',
      contentId: contentId,
      contentType: ReportedContentType.regionalVideo,
      contentOwnerId: 'unknown',
      contentOwnerName: 'Unknown',
      category: reason, // Use the passed reason parameter
      additionalComment: description,
      createdAt: DateTime.now(),
      contentTitle: contentType,
    );

    return report;
  }

  static bool shouldHideContent({
    required bool isCreatorShadowBanned,
    required int reportCount,
    required bool isReported,
  }) {
    if (isCreatorShadowBanned) return true;
    if (reportCount >= 5) return true;
    return false;
  }

  // ===== LEGACY METHODS - COMMENTED OUT =====
  // These methods use old BanType enum from moderation_model.dart
  // Use the new UserWarning model and issueWarning() method instead

  // static BanType determineAction(int violationCount) {
  //   return UserViolation.determineBanType(violationCount);
  // }

  // static String getBanMessage(BanType banType, DateTime? expiresAt) {
  //   switch (banType) {
  //     case BanType.warning:
  //       return 'You have received a warning for violating community guidelines.';
  //     case BanType.temporaryBan:
  //       final days = expiresAt?.difference(DateTime.now()).inDays ?? 7;
  //       return 'Your account has been temporarily restricted for $days days.';
  //     case BanType.shadowBan:
  //       return 'Your content visibility has been reduced due to repeated violations.';
  //     case BanType.permanentBan:
  //       return 'Your account has been permanently banned for severe violations.';
  //     case BanType.none:
  //       return '';
  //   }
  // }

  // static bool canUserPost(BanType banType, DateTime? banExpiresAt) {
  //   switch (banType) {
  //     case BanType.none:
  //     case BanType.warning:
  //     case BanType.shadowBan:
  //       return true;
  //     case BanType.temporaryBan:
  //       if (banExpiresAt == null) return false;
  //       return DateTime.now().isAfter(banExpiresAt);
  //     case BanType.permanentBan:
  //       return false;
  //   }
  // }

  // Get report reasons for display
  static List<Map<String, dynamic>> getReportReasons() {
    return ReportCategory.values.map((reason) {
      return {
        'reason': reason,
        'text': reason.displayName,
        'icon': _getReasonIcon(reason),
      };
    }).toList();
  }

  static String _getReasonIcon(ReportCategory reason) {
    switch (reason) {
      case ReportCategory.spam:
        return '🚫';
      case ReportCategory.harassment:
        return '😠';
      case ReportCategory.hateSpeech:
        return '🛑';
      case ReportCategory.violence:
        return '⚠️';
      case ReportCategory.inappropriate:
        return '🔞';
      case ReportCategory.misinformation:
        return '❌';
      case ReportCategory.copyright:
        return '©️';
      case ReportCategory.other:
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

  // Mock data for development
  static List<ContentReport> _getMockUserReports(String userId) {
    final now = DateTime.now();
    return [
      ContentReport(
        id: '1',
        reporterId: userId,
        reporterName: 'Current User',
        contentId: 'video_123',
        contentType: ReportedContentType.regionalVideo,
        contentOwnerId: 'user_456',
        contentOwnerName: 'Content Creator',
        category: ReportCategory.spam,
        additionalComment: 'This looks like spam content',
        status: ReportStatus.underReview,
        createdAt: now.subtract(const Duration(hours: 2)),
        contentTitle: 'Promotional Video',
        contentDescription: 'Excessive promotional content',
      ),
      ContentReport(
        id: '2',
        reporterId: userId,
        reporterName: 'Current User',
        contentId: 'video_789',
        contentType: ReportedContentType.devotionalVideo,
        contentOwnerId: 'user_101',
        contentOwnerName: 'Another Creator',
        category: ReportCategory.inappropriate,
        additionalComment: 'Contains inappropriate content',
        status: ReportStatus.resolved,
        createdAt: now.subtract(const Duration(days: 1)),
        resolvedAt: now.subtract(const Duration(hours: 12)),
        feedbackToReporter:
            'Thank you for reporting. Content has been removed.',
        contentTitle: 'Inappropriate Video',
      ),
    ];
  }

  static List<ContentReport> _getMockAllReports({
    ReportStatus? status,
    ReportCategory? category,
  }) {
    final now = DateTime.now();
    final allReports = [
      ContentReport(
        id: 'report_1',
        reporterId: 'user_1',
        reporterName: 'User One',
        contentId: 'video_001',
        contentType: ReportedContentType.regionalVideo,
        contentOwnerId: 'creator_1',
        contentOwnerName: 'Creator One',
        category: ReportCategory.spam,
        additionalComment: 'Repeated spam posts',
        status: ReportStatus.pending,
        createdAt: now.subtract(const Duration(hours: 1)),
        contentTitle: 'Spam Content',
        contentThumbnail: 'https://picsum.photos/200/300?random=1',
      ),
      ContentReport(
        id: 'report_2',
        reporterId: 'user_2',
        reporterName: 'User Two',
        contentId: 'video_002',
        contentType: ReportedContentType.businessVideo,
        contentOwnerId: 'creator_2',
        contentOwnerName: 'Creator Two',
        category: ReportCategory.inappropriate,
        additionalComment: 'Inappropriate for general audience',
        status: ReportStatus.underReview,
        createdAt: now.subtract(const Duration(hours: 3)),
        reviewedAt: now.subtract(const Duration(hours: 2)),
        contentTitle: 'Inappropriate Business Video',
        contentThumbnail: 'https://picsum.photos/200/300?random=2',
      ),
      ContentReport(
        id: 'report_3',
        reporterId: 'user_3',
        reporterName: 'User Three',
        contentId: 'video_003',
        contentType: ReportedContentType.devotionalVideo,
        contentOwnerId: 'creator_3',
        contentOwnerName: 'Creator Three',
        category: ReportCategory.misinformation,
        additionalComment: 'Contains false information',
        status: ReportStatus.resolved,
        createdAt: now.subtract(const Duration(days: 1)),
        reviewedAt: now.subtract(const Duration(hours: 20)),
        resolvedAt: now.subtract(const Duration(hours: 18)),
        adminId: 'admin_1',
        adminName: 'Admin User',
        adminAction: 'Content removed',
        adminNotes: 'Verified misinformation',
        feedbackToReporter: 'Thank you. Content has been removed.',
        contentTitle: 'Misinformation Video',
        contentThumbnail: 'https://picsum.photos/200/300?random=3',
      ),
    ];

    var filtered = allReports;
    if (status != null) {
      filtered = filtered.where((r) => r.status == status).toList();
    }
    if (category != null) {
      filtered = filtered.where((r) => r.category == category).toList();
    }

    return filtered;
  }

  /// Get educational messages for warnings
  static Map<WarningSeverity, String> getEducationalMessages() {
    return {
      WarningSeverity.low: '''
**Gentle Reminder** ⚠️

We noticed your recent content may not align with our Community Guidelines. This is just a friendly reminder to help you understand our standards.

**What happened:**
Your content was flagged for review.

**What to do:**
• Review our Community Guidelines
• Be mindful of content you share
• Reach out if you have questions

This is your first notice. We're here to help you succeed in our community! 🙏
''',
      WarningSeverity.medium: '''
**Serious Warning** 🚫

This is your second violation of our Community Guidelines. We take community safety seriously and need you to understand the importance of following our rules.

**What happened:**
Your content violated our guidelines again.

**What to do:**
• Carefully review our Community Guidelines
• Delete any similar content
• Future violations may result in account restrictions

We believe in second chances, but we need to see improvement. 💪
''',
      WarningSeverity.high: '''
**Final Warning** ⛔

This is your final warning. Further violations will result in permanent account suspension.

**What happened:**
Multiple violations of Community Guidelines.

**What to do:**
• Immediately review Community Guidelines
• Remove any violating content
• Contact support if you have questions

We want you to remain part of our community, but you must comply with our guidelines. This is your last chance. ⚖️
''',
      WarningSeverity.ban: '''
**Account Suspended** 🚨

Your account has been suspended due to repeated violations of our Community Guidelines.

**What happened:**
Multiple serious violations despite previous warnings.

**What you can do:**
• Review our Community Guidelines
• Submit an appeal explaining your situation
• Wait for review team response

We take community safety seriously. Appeals are reviewed within 72 hours. 📋
''',
    };
  }
}
