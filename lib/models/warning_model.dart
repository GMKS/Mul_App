/// User Warning/Strike Model
/// For tracking warnings given to users

import 'package:flutter/material.dart';

enum WarningType {
  spam,
  inappropriateContent,
  misinformation,
  harassment,
  other,
}

enum WarningSeverity {
  low, // First-time offender
  medium, // Second offense
  high, // Final warning
  ban, // Banned
}

class UserWarning {
  final String id;
  final String userId;
  final String userName;
  final WarningType type;
  final WarningSeverity severity;
  final String reason;
  final String? relatedContentId;
  final String? relatedReportId;
  final DateTime createdAt;
  final String issuedBy;
  final String issuedByName;
  final DateTime? expiresAt; // Temporary mute/restriction expiry
  final bool isActive;
  final String? userResponse; // User's appeal or acknowledgment

  UserWarning({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.severity,
    required this.reason,
    this.relatedContentId,
    this.relatedReportId,
    required this.createdAt,
    required this.issuedBy,
    required this.issuedByName,
    this.expiresAt,
    this.isActive = true,
    this.userResponse,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'type': type.name,
      'severity': severity.name,
      'reason': reason,
      'related_content_id': relatedContentId,
      'related_report_id': relatedReportId,
      'created_at': createdAt.toIso8601String(),
      'issued_by': issuedBy,
      'issued_by_name': issuedByName,
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
      'user_response': userResponse,
    };
  }

  factory UserWarning.fromJson(Map<String, dynamic> json) {
    return UserWarning(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      type: WarningType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      severity: WarningSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
      ),
      reason: json['reason'],
      relatedContentId: json['related_content_id'],
      relatedReportId: json['related_report_id'],
      createdAt: DateTime.parse(json['created_at']),
      issuedBy: json['issued_by'],
      issuedByName: json['issued_by_name'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      isActive: json['is_active'] ?? true,
      userResponse: json['user_response'],
    );
  }

  String get severityDisplayName {
    switch (severity) {
      case WarningSeverity.low:
        return 'Warning';
      case WarningSeverity.medium:
        return 'Serious Warning';
      case WarningSeverity.high:
        return 'Final Warning';
      case WarningSeverity.ban:
        return 'Banned';
    }
  }

  Color get severityColor {
    switch (severity) {
      case WarningSeverity.low:
        return Color(0xFFf59e0b); // Orange
      case WarningSeverity.medium:
        return Color(0xFFef4444); // Red
      case WarningSeverity.high:
        return Color(0xFF991b1b); // Dark Red
      case WarningSeverity.ban:
        return Color(0xFF1f2937); // Black
    }
  }
}
