// STEP 12: Monetization Service
// Add video boost feature for creators.
// Integrate AdMob ads into feed.
// Show region-based advertisements.

import '../models/monetization_model.dart';

class MonetizationService {
  // Create a video boost
  static Future<VideoBoost> createVideoBoost({
    required String videoId,
    required String creatorId,
    required BoostDuration duration,
    List<String> targetRegions = const [],
    List<String> targetLanguages = const [],
  }) async {
    final now = DateTime.now();
    final durationValue = VideoBoost.getDurationValue(duration);
    final price = VideoBoost.pricing[duration] ?? 99.0;

    final boost = VideoBoost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      videoId: videoId,
      creatorId: creatorId,
      duration: duration,
      startedAt: now,
      expiresAt: now.add(durationValue),
      amountPaid: price,
      targetRegions: targetRegions,
      targetLanguages: targetLanguages,
    );

    // TODO: Process payment and save to backend
    // await paymentService.processPayment(price);
    // await api.createBoost(boost.toJson());

    return boost;
  }

  // Check if video is currently boosted
  static bool isVideoBoosted(VideoBoost? boost) {
    if (boost == null) return false;
    return boost.isActive && !boost.isExpired;
  }

  // Get boost price display
  static String getBoostPriceDisplay(BoostDuration duration) {
    final price = VideoBoost.pricing[duration] ?? 0;
    return '₹${price.toStringAsFixed(0)}';
  }

  // Get boost duration display
  static String getBoostDurationDisplay(BoostDuration duration) {
    switch (duration) {
      case BoostDuration.oneDay:
        return '1 Day';
      case BoostDuration.threeDays:
        return '3 Days';
      case BoostDuration.sevenDays:
        return '7 Days';
    }
  }

  // Should show ad at position
  static bool shouldShowAdAtPosition(int position, {int frequency = 5}) {
    return position > 0 && position % frequency == 0;
  }

  // Get ad for user
  static FeedAd? getAdForUser({
    required String userRegion,
    required String userLanguage,
    required List<FeedAd> availableAds,
  }) {
    // Filter ads matching user's region and language
    final matchingAds = availableAds.where((ad) {
      return ad.shouldShowToUser(userRegion, userLanguage);
    }).toList();

    if (matchingAds.isEmpty) return null;

    // Return random matching ad
    matchingAds.shuffle();
    return matchingAds.first;
  }

  // Calculate creator earnings
  static double calculateEarnings({
    required int impressions,
    double cpmRate = 10.0, // ₹10 per 1000 impressions
  }) {
    return (impressions / 1000) * cpmRate;
  }

  // Get boost options for display
  static List<Map<String, dynamic>> getBoostOptions() {
    return BoostDuration.values.map((duration) {
      return {
        'duration': duration,
        'display': getBoostDurationDisplay(duration),
        'price': getBoostPriceDisplay(duration),
        'priceValue': VideoBoost.pricing[duration],
      };
    }).toList();
  }

  // Track ad impression
  static Future<void> trackAdImpression({
    required String adId,
    required String userId,
    required String region,
  }) async {
    // TODO: Send to analytics
    // await analytics.trackEvent('ad_impression', {
    //   'adId': adId,
    //   'userId': userId,
    //   'region': region,
    // });
  }

  // Track ad click
  static Future<void> trackAdClick({
    required String adId,
    required String userId,
  }) async {
    // TODO: Send to analytics
    // await analytics.trackEvent('ad_click', {
    //   'adId': adId,
    //   'userId': userId,
    // });
  }
}
