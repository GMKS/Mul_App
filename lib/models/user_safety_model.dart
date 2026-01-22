/// User Safety Models
/// For blocking users and muting keywords

import 'package:flutter/material.dart';

/// Blocked User Model
class BlockedUser {
  final String id;
  final String userId; // Who blocked
  final String blockedUserId; // Who got blocked
  final String blockedUserName;
  final String? blockedUserAvatar;
  final String reason;
  final DateTime blockedAt;
  final bool isActive;

  BlockedUser({
    required this.id,
    required this.userId,
    required this.blockedUserId,
    required this.blockedUserName,
    this.blockedUserAvatar,
    required this.reason,
    required this.blockedAt,
    this.isActive = true,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      userId: json['user_id'],
      blockedUserId: json['blocked_user_id'],
      blockedUserName: json['blocked_user_name'],
      blockedUserAvatar: json['blocked_user_avatar'],
      reason: json['reason'] ?? '',
      blockedAt: DateTime.parse(json['blocked_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'blocked_user_id': blockedUserId,
      'blocked_user_name': blockedUserName,
      'blocked_user_avatar': blockedUserAvatar,
      'reason': reason,
      'blocked_at': blockedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

/// Muted Keyword Model
class MutedKeyword {
  final String id;
  final String userId;
  final String keyword;
  final DateTime createdAt;
  final bool isActive;

  MutedKeyword({
    required this.id,
    required this.userId,
    required this.keyword,
    required this.createdAt,
    this.isActive = true,
  });

  factory MutedKeyword.fromJson(Map<String, dynamic> json) {
    return MutedKeyword(
      id: json['id'],
      userId: json['user_id'],
      keyword: json['keyword'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'keyword': keyword.toLowerCase(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  String get displayKeyword => keyword.toLowerCase();
}

/// User Trust Level Model
class UserTrustLevel {
  final String userId;
  final int validReports;
  final int invalidReports;
  final int helpfulVotes;
  final TrustBadge trustBadge;
  final double accuracyRate;
  final int reportLimit;

  UserTrustLevel({
    required this.userId,
    this.validReports = 0,
    this.invalidReports = 0,
    this.helpfulVotes = 0,
    TrustBadge? trustBadge,
    double? accuracyRate,
    int? reportLimit,
  })  : trustBadge = trustBadge ?? TrustBadge.newUser,
        accuracyRate = accuracyRate ??
            (validReports + invalidReports > 0
                ? validReports / (validReports + invalidReports)
                : 0.0),
        reportLimit = reportLimit ?? _calculateReportLimit(trustBadge);

  static int _calculateReportLimit(TrustBadge? badge) {
    switch (badge ?? TrustBadge.newUser) {
      case TrustBadge.communityMod:
        return 999999; // Unlimited
      case TrustBadge.powerUser:
        return 50;
      case TrustBadge.trusted:
        return 20;
      case TrustBadge.newUser:
        return 5;
    }
  }

  factory UserTrustLevel.fromJson(Map<String, dynamic> json) {
    return UserTrustLevel(
      userId: json['user_id'],
      validReports: json['valid_reports'] ?? 0,
      invalidReports: json['invalid_reports'] ?? 0,
      helpfulVotes: json['helpful_votes'] ?? 0,
      trustBadge: TrustBadge.values.firstWhere(
        (e) => e.toString() == 'TrustBadge.${json['trust_badge']}',
        orElse: () => TrustBadge.newUser,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'valid_reports': validReports,
      'invalid_reports': invalidReports,
      'helpful_votes': helpfulVotes,
      'trust_badge': trustBadge.name,
      'accuracy_rate': accuracyRate,
      'report_limit': reportLimit,
    };
  }

  String get badgeEmoji {
    switch (trustBadge) {
      case TrustBadge.communityMod:
        return '🛡️';
      case TrustBadge.powerUser:
        return '⭐';
      case TrustBadge.trusted:
        return '✓';
      case TrustBadge.newUser:
        return '';
    }
  }

  String get badgeText {
    switch (trustBadge) {
      case TrustBadge.communityMod:
        return 'Community Moderator';
      case TrustBadge.powerUser:
        return 'Trusted Member';
      case TrustBadge.trusted:
        return 'Trusted';
      case TrustBadge.newUser:
        return 'New User';
    }
  }

  Color get badgeColor {
    switch (trustBadge) {
      case TrustBadge.communityMod:
        return Color(0xFF10b981); // Green
      case TrustBadge.powerUser:
        return Color(0xFFf59e0b); // Orange
      case TrustBadge.trusted:
        return Color(0xFF3b82f6); // Blue
      case TrustBadge.newUser:
        return Color(0xFF6b7280); // Gray
    }
  }
}

enum TrustBadge {
  newUser, // 0-10 valid reports
  trusted, // 10-50 valid reports
  powerUser, // 50-200 valid reports
  communityMod, // Invited by admins
}
