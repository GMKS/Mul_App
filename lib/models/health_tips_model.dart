/// Health Tips Models
/// Comprehensive health guidance with AI personalization, verified tips, and alerts
/// Categories: General, Women & Child, Senior Care, Mental Wellness, Seasonal

// ==================== ENUMS ====================

/// Health tip categories
enum HealthCategory {
  general('General Health', '💊', 'General wellness and prevention tips'),
  womenChild('Women & Child Care', '👶', 'Maternal and child health guidance'),
  seniorCare('Senior Care', '👴', 'Health tips for elderly citizens'),
  mentalWellness(
      'Mental Wellness', '🧠', 'Mental health and stress management'),
  seasonal('Seasonal Health', '🌡️', 'Weather and season-based health advice'),
  nutrition('Nutrition', '🥗', 'Diet and healthy eating tips'),
  fitness('Fitness', '🏃', 'Exercise and physical activity'),
  firstAid('First Aid', '🩹', 'Emergency and first aid guidance'),
  chronicCare('Chronic Care', '💉', 'Managing chronic conditions'),
  hygiene('Hygiene', '🧼', 'Cleanliness and hygiene practices');

  final String displayName;
  final String emoji;
  final String description;

  const HealthCategory(this.displayName, this.emoji, this.description);
}

/// Verification source for tips
enum VerificationSource {
  doctorVerified(
      'Doctor Verified', '👨‍⚕️', 'Verified by medical professionals'),
  govtHealth(
      'Govt Health Dept', '🏛️', 'Official government health guidelines'),
  whoApproved('WHO Approved', '🌍', 'World Health Organization guidelines'),
  ayushCertified('AYUSH Certified', '🪷', 'Traditional medicine certified'),
  communityTested('Community Tested', '👥', 'Tested by community members'),
  aiGenerated('AI Generated', '🤖', 'AI-assisted health tip');

  final String displayName;
  final String emoji;
  final String description;

  const VerificationSource(this.displayName, this.emoji, this.description);
}

/// Alert trigger type
enum AlertTrigger {
  aqi('Air Quality', 'Triggered by AQI levels'),
  weather('Weather', 'Triggered by weather conditions'),
  outbreak('Disease Outbreak', 'Admin-triggered health alert'),
  seasonal('Seasonal', 'Season-based automatic tip'),
  festival('Festival', 'Festival/fasting related'),
  emergency('Emergency', 'Emergency health broadcast');

  final String displayName;
  final String description;

  const AlertTrigger(this.displayName, this.description);
}

/// Tip priority level
enum TipPriority {
  low('Low', 0),
  normal('Normal', 1),
  high('High', 2),
  urgent('Urgent', 3),
  emergency('Emergency', 4);

  final String displayName;
  final int level;

  const TipPriority(this.displayName, this.level);
}

/// User age group for personalization
enum AgeGroup {
  child('0-12', 'Children'),
  teen('13-19', 'Teenagers'),
  youngAdult('20-35', 'Young Adults'),
  middleAge('36-55', 'Middle Age'),
  senior('56+', 'Seniors');

  final String range;
  final String displayName;

  const AgeGroup(this.range, this.displayName);
}

/// Content type
enum TipContentType { text, image, video, infographic, audio }

// ==================== MAIN MODELS ====================

/// Health Tip Model
class HealthTip {
  final String id;
  final String title;
  final String shortDescription;
  final String fullContent;
  final HealthCategory category;
  final TipContentType contentType;

  // Media
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? thumbnailUrl;
  final List<String> infographicUrls;

  // Verification & Trust
  final VerificationSource verificationSource;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final int trustScore; // 0-100

  // Targeting
  final String? city;
  final List<String> cities;
  final AgeGroup? targetAgeGroup;
  final String? targetGender;
  final List<String> tags;

  // Alerts & Triggers
  final bool isAlert;
  final AlertTrigger? alertTrigger;
  final TipPriority priority;
  final String? alertCondition; // e.g., "AQI > 150"

  // Scheduling
  final DateTime validFrom;
  final DateTime? validTo;
  final bool isTipOfTheDay;
  final bool isPinned;

  // Engagement
  final int viewCount;
  final int saveCount;
  final int shareCount;
  final int helpfulCount;
  final int notHelpfulCount;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final bool isSponsored;
  final String? sponsorName;
  final String? sponsorLogo;

  // Multi-language
  final String language;
  final Map<String, String>? translations;

  HealthTip({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.fullContent,
    required this.category,
    this.contentType = TipContentType.text,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.thumbnailUrl,
    this.infographicUrls = const [],
    required this.verificationSource,
    this.verifiedBy,
    this.verifiedAt,
    this.trustScore = 0,
    this.city,
    this.cities = const [],
    this.targetAgeGroup,
    this.targetGender,
    this.tags = const [],
    this.isAlert = false,
    this.alertTrigger,
    this.priority = TipPriority.normal,
    this.alertCondition,
    required this.validFrom,
    this.validTo,
    this.isTipOfTheDay = false,
    this.isPinned = false,
    this.viewCount = 0,
    this.saveCount = 0,
    this.shareCount = 0,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.isSponsored = false,
    this.sponsorName,
    this.sponsorLogo,
    this.language = 'en',
    this.translations,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'] as String,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String,
      fullContent: json['full_content'] as String,
      category: HealthCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => HealthCategory.general,
      ),
      contentType: TipContentType.values.firstWhere(
        (t) => t.name == json['content_type'],
        orElse: () => TipContentType.text,
      ),
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      infographicUrls: List<String>.from(json['infographic_urls'] ?? []),
      verificationSource: VerificationSource.values.firstWhere(
        (v) => v.name == json['verification_source'],
        orElse: () => VerificationSource.communityTested,
      ),
      verifiedBy: json['verified_by'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      trustScore: json['trust_score'] as int? ?? 0,
      city: json['city'] as String?,
      cities: List<String>.from(json['cities'] ?? []),
      targetAgeGroup: json['target_age_group'] != null
          ? AgeGroup.values.firstWhere(
              (a) => a.name == json['target_age_group'],
              orElse: () => AgeGroup.youngAdult,
            )
          : null,
      targetGender: json['target_gender'] as String?,
      tags: List<String>.from(json['tags'] ?? []),
      isAlert: json['is_alert'] as bool? ?? false,
      alertTrigger: json['alert_trigger'] != null
          ? AlertTrigger.values.firstWhere(
              (a) => a.name == json['alert_trigger'],
              orElse: () => AlertTrigger.seasonal,
            )
          : null,
      priority: TipPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TipPriority.normal,
      ),
      alertCondition: json['alert_condition'] as String?,
      validFrom: DateTime.parse(json['valid_from']),
      validTo:
          json['valid_to'] != null ? DateTime.parse(json['valid_to']) : null,
      isTipOfTheDay: json['is_tip_of_the_day'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      saveCount: json['save_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      notHelpfulCount: json['not_helpful_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdBy: json['created_by'] as String?,
      isSponsored: json['is_sponsored'] as bool? ?? false,
      sponsorName: json['sponsor_name'] as String?,
      sponsorLogo: json['sponsor_logo'] as String?,
      language: json['language'] as String? ?? 'en',
      translations: json['translations'] != null
          ? Map<String, String>.from(json['translations'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'short_description': shortDescription,
      'full_content': fullContent,
      'category': category.name,
      'content_type': contentType.name,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'thumbnail_url': thumbnailUrl,
      'infographic_urls': infographicUrls,
      'verification_source': verificationSource.name,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt?.toIso8601String(),
      'trust_score': trustScore,
      'city': city,
      'cities': cities,
      'target_age_group': targetAgeGroup?.name,
      'target_gender': targetGender,
      'tags': tags,
      'is_alert': isAlert,
      'alert_trigger': alertTrigger?.name,
      'priority': priority.name,
      'alert_condition': alertCondition,
      'valid_from': validFrom.toIso8601String(),
      'valid_to': validTo?.toIso8601String(),
      'is_tip_of_the_day': isTipOfTheDay,
      'is_pinned': isPinned,
      'view_count': viewCount,
      'save_count': saveCount,
      'share_count': shareCount,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'is_sponsored': isSponsored,
      'sponsor_name': sponsorName,
      'sponsor_logo': sponsorLogo,
      'language': language,
      'translations': translations,
    };
  }

  /// Get helpfulness percentage
  double get helpfulnessScore {
    final total = helpfulCount + notHelpfulCount;
    if (total == 0) return 0;
    return (helpfulCount / total) * 100;
  }

  /// Check if tip is currently valid
  bool get isValid {
    final now = DateTime.now();
    if (now.isBefore(validFrom)) return false;
    if (validTo != null && now.isAfter(validTo!)) return false;
    return true;
  }

  /// Get verification badge color
  String get verificationColor {
    switch (verificationSource) {
      case VerificationSource.doctorVerified:
        return '#4CAF50'; // Green
      case VerificationSource.govtHealth:
        return '#2196F3'; // Blue
      case VerificationSource.whoApproved:
        return '#00BCD4'; // Cyan
      case VerificationSource.ayushCertified:
        return '#9C27B0'; // Purple
      case VerificationSource.communityTested:
        return '#FF9800'; // Orange
      case VerificationSource.aiGenerated:
        return '#607D8B'; // Blue Grey
    }
  }
}

/// User's tip feedback
class TipFeedback {
  final String id;
  final String tipId;
  final String userId;
  final bool isHelpful;
  final String? comment;
  final DateTime createdAt;

  TipFeedback({
    required this.id,
    required this.tipId,
    required this.userId,
    required this.isHelpful,
    this.comment,
    required this.createdAt,
  });

  factory TipFeedback.fromJson(Map<String, dynamic> json) {
    return TipFeedback(
      id: json['id'] as String,
      tipId: json['tip_id'] as String,
      userId: json['user_id'] as String,
      isHelpful: json['is_helpful'] as bool,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tip_id': tipId,
      'user_id': userId,
      'is_helpful': isHelpful,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// User's saved tip
class SavedTip {
  final String id;
  final String tipId;
  final String userId;
  final DateTime savedAt;
  final String? note;

  SavedTip({
    required this.id,
    required this.tipId,
    required this.userId,
    required this.savedAt,
    this.note,
  });

  factory SavedTip.fromJson(Map<String, dynamic> json) {
    return SavedTip(
      id: json['id'] as String,
      tipId: json['tip_id'] as String,
      userId: json['user_id'] as String,
      savedAt: DateTime.parse(json['saved_at']),
      note: json['note'] as String?,
    );
  }
}

/// Health alert notification
class HealthAlert {
  final String id;
  final String title;
  final String message;
  final AlertTrigger trigger;
  final TipPriority priority;
  final String? actionUrl;
  final String? tipId;
  final String? city;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isRead;

  HealthAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.trigger,
    this.priority = TipPriority.high,
    this.actionUrl,
    this.tipId,
    this.city,
    required this.createdAt,
    this.expiresAt,
    this.isRead = false,
  });

  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      trigger: AlertTrigger.values.firstWhere(
        (t) => t.name == json['trigger'],
        orElse: () => AlertTrigger.seasonal,
      ),
      priority: TipPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => TipPriority.high,
      ),
      actionUrl: json['action_url'] as String?,
      tipId: json['tip_id'] as String?,
      city: json['city'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

/// User health preferences for personalization
class HealthPreferences {
  final String userId;
  final AgeGroup? ageGroup;
  final String? gender;
  final List<HealthCategory> preferredCategories;
  final List<String> healthConditions;
  final bool dailyReminder;
  final String reminderTime;
  final bool emergencyAlerts;
  final String preferredLanguage;
  final DateTime updatedAt;

  HealthPreferences({
    required this.userId,
    this.ageGroup,
    this.gender,
    this.preferredCategories = const [],
    this.healthConditions = const [],
    this.dailyReminder = true,
    this.reminderTime = '08:00',
    this.emergencyAlerts = true,
    this.preferredLanguage = 'en',
    required this.updatedAt,
  });

  factory HealthPreferences.fromJson(Map<String, dynamic> json) {
    return HealthPreferences(
      userId: json['user_id'] as String,
      ageGroup: json['age_group'] != null
          ? AgeGroup.values.firstWhere(
              (a) => a.name == json['age_group'],
              orElse: () => AgeGroup.youngAdult,
            )
          : null,
      gender: json['gender'] as String?,
      preferredCategories: (json['preferred_categories'] as List?)
              ?.map((c) => HealthCategory.values.firstWhere(
                    (cat) => cat.name == c,
                    orElse: () => HealthCategory.general,
                  ))
              .toList() ??
          [],
      healthConditions: List<String>.from(json['health_conditions'] ?? []),
      dailyReminder: json['daily_reminder'] as bool? ?? true,
      reminderTime: json['reminder_time'] as String? ?? '08:00',
      emergencyAlerts: json['emergency_alerts'] as bool? ?? true,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'age_group': ageGroup?.name,
      'gender': gender,
      'preferred_categories': preferredCategories.map((c) => c.name).toList(),
      'health_conditions': healthConditions,
      'daily_reminder': dailyReminder,
      'reminder_time': reminderTime,
      'emergency_alerts': emergencyAlerts,
      'preferred_language': preferredLanguage,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
