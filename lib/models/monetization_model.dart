// STEP 12: Monetization Hooks
// Add video boost feature for creators.
// Integrate AdMob ads into feed.
// Show region-based advertisements.

enum AdType {
  banner,
  interstitial,
  rewarded,
  native,
}

enum BoostDuration {
  oneDay,
  threeDays,
  sevenDays,
}

class VideoBoost {
  final String id;
  final String videoId;
  final String creatorId;
  final BoostDuration duration;
  final DateTime startedAt;
  final DateTime expiresAt;
  final double amountPaid;
  final List<String> targetRegions;
  final List<String> targetLanguages;
  final int impressions;
  final int clicks;
  final bool isActive;

  VideoBoost({
    required this.id,
    required this.videoId,
    required this.creatorId,
    required this.duration,
    required this.startedAt,
    required this.expiresAt,
    required this.amountPaid,
    this.targetRegions = const [],
    this.targetLanguages = const [],
    this.impressions = 0,
    this.clicks = 0,
    this.isActive = true,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory VideoBoost.fromJson(Map<String, dynamic> json) {
    return VideoBoost(
      id: json['id'] ?? '',
      videoId: json['videoId'] ?? '',
      creatorId: json['creatorId'] ?? '',
      duration: BoostDuration.values.firstWhere(
        (d) => d.toString() == json['duration'],
        orElse: () => BoostDuration.oneDay,
      ),
      startedAt: DateTime.parse(json['startedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      targetRegions: List<String>.from(json['targetRegions'] ?? []),
      targetLanguages: List<String>.from(json['targetLanguages'] ?? []),
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'creatorId': creatorId,
      'duration': duration.toString(),
      'startedAt': startedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'amountPaid': amountPaid,
      'targetRegions': targetRegions,
      'targetLanguages': targetLanguages,
      'impressions': impressions,
      'clicks': clicks,
      'isActive': isActive,
    };
  }

  // Boost pricing (Updated January 2026)
  static Map<BoostDuration, double> get pricing => {
        BoostDuration.oneDay: 149.0,
        BoostDuration.threeDays: 349.0,
        BoostDuration.sevenDays: 649.0,
      };

  static Duration getDurationValue(BoostDuration duration) {
    switch (duration) {
      case BoostDuration.oneDay:
        return const Duration(days: 1);
      case BoostDuration.threeDays:
        return const Duration(days: 3);
      case BoostDuration.sevenDays:
        return const Duration(days: 7);
    }
  }
}

// Ad configuration for feed
class FeedAd {
  final String id;
  final AdType type;
  final String adUnitId;
  final List<String> targetRegions;
  final List<String> targetLanguages;
  final String? imageUrl;
  final String? title;
  final String? description;
  final String? actionUrl;
  final bool isRegionalAd;

  FeedAd({
    required this.id,
    required this.type,
    required this.adUnitId,
    this.targetRegions = const [],
    this.targetLanguages = const [],
    this.imageUrl,
    this.title,
    this.description,
    this.actionUrl,
    this.isRegionalAd = false,
  });

  factory FeedAd.fromJson(Map<String, dynamic> json) {
    return FeedAd(
      id: json['id'] ?? '',
      type: AdType.values.firstWhere(
        (t) => t.toString() == json['type'],
        orElse: () => AdType.native,
      ),
      adUnitId: json['adUnitId'] ?? '',
      targetRegions: List<String>.from(json['targetRegions'] ?? []),
      targetLanguages: List<String>.from(json['targetLanguages'] ?? []),
      imageUrl: json['imageUrl'],
      title: json['title'],
      description: json['description'],
      actionUrl: json['actionUrl'],
      isRegionalAd: json['isRegionalAd'] ?? false,
    );
  }

  // Check if ad should be shown to user
  bool shouldShowToUser(String userRegion, String userLanguage) {
    if (targetRegions.isEmpty && targetLanguages.isEmpty) {
      return true;
    }

    final matchesRegion = targetRegions.isEmpty ||
        targetRegions.contains(userRegion) ||
        targetRegions.contains('all');

    final matchesLanguage = targetLanguages.isEmpty ||
        targetLanguages.contains(userLanguage) ||
        targetLanguages.contains('all');

    return matchesRegion && matchesLanguage;
  }
}

// AdMob configuration
class AdMobConfig {
  // Test ad unit IDs (replace with real ones in production)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String nativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  // Ad frequency in feed (show ad every N videos)
  static const int adFrequencyInFeed = 4;

  // Reward for watching rewarded ad (Updated January 2026)
  static const int rewardCoins = 20;
}

// Creator earnings tracking
class CreatorEarnings {
  final String creatorId;
  final double totalEarnings;
  final double pendingPayout;
  final double adRevenue;
  final double tipsReceived;
  final int totalAdImpressions;
  final DateTime lastPayoutAt;

  CreatorEarnings({
    required this.creatorId,
    this.totalEarnings = 0,
    this.pendingPayout = 0,
    this.adRevenue = 0,
    this.tipsReceived = 0,
    this.totalAdImpressions = 0,
    required this.lastPayoutAt,
  });

  factory CreatorEarnings.fromJson(Map<String, dynamic> json) {
    return CreatorEarnings(
      creatorId: json['creatorId'] ?? '',
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      pendingPayout: (json['pendingPayout'] ?? 0).toDouble(),
      adRevenue: (json['adRevenue'] ?? 0).toDouble(),
      tipsReceived: (json['tipsReceived'] ?? 0).toDouble(),
      totalAdImpressions: json['totalAdImpressions'] ?? 0,
      lastPayoutAt: json['lastPayoutAt'] != null
          ? DateTime.parse(json['lastPayoutAt'])
          : DateTime.now(),
    );
  }

  // Calculate earnings per 1000 impressions (CPM)
  double get cpm {
    if (totalAdImpressions == 0) return 0;
    return (adRevenue / totalAdImpressions) * 1000;
  }
}
