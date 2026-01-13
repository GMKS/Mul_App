// BUSINESS FEATURE 11: Business Feed Ranking Service
// Rank business videos based on city, engagement, boost status, and recency

import '../models/business_video_model.dart';
import 'business_boost_service.dart';

class BusinessFeedRankingService {
  /// Rank business videos for a user's feed
  /// Priority: Same city > Boosted > Engagement > Recency
  static Future<List<BusinessVideo>> rankVideos({
    required List<BusinessVideo> videos,
    required String userCity,
    String? userArea,
  }) async {
    if (videos.isEmpty) return [];

    // Calculate scores for each video
    final scoredVideos = <_ScoredVideo>[];

    for (final video in videos) {
      if (!video.isActive) continue;

      final score = await _calculateScore(
        video: video,
        userCity: userCity,
        userArea: userArea,
      );

      scoredVideos.add(_ScoredVideo(video: video, score: score));
    }

    // Sort by score descending
    scoredVideos.sort((a, b) => b.score.compareTo(a.score));

    return scoredVideos.map((sv) => sv.video).toList();
  }

  /// Calculate ranking score for a video
  static Future<double> _calculateScore({
    required BusinessVideo video,
    required String userCity,
    String? userArea,
  }) async {
    double score = 0;

    // 1. Location matching (highest priority)
    score += _calculateLocationScore(
      videoCity: video.city,
      videoArea: video.area,
      userCity: userCity,
      userArea: userArea,
    );

    // 2. Boost status
    final boostMultiplier =
        await BusinessBoostService.getBoostMultiplier(video.id);
    score *= boostMultiplier;

    // 3. Engagement score
    score += _calculateEngagementScore(video);

    // 4. Recency score
    score += _calculateRecencyScore(video.createdAt);

    // 5. Offer bonus
    if (video.offerTag != null && video.offerTag!.isNotEmpty) {
      score += 5; // Small bonus for videos with offers
    }

    return score;
  }

  /// Calculate location-based score
  static double _calculateLocationScore({
    required String videoCity,
    required String videoArea,
    required String userCity,
    String? userArea,
  }) {
    double score = 0;

    // Same city = 100 points
    if (videoCity.toLowerCase() == userCity.toLowerCase()) {
      score += 100;

      // Same area = additional 50 points
      if (userArea != null &&
          videoArea.toLowerCase() == userArea.toLowerCase()) {
        score += 50;
      }
    } else {
      // Different city = 10 points (still show, but lower priority)
      score += 10;
    }

    return score;
  }

  /// Calculate engagement-based score
  static double _calculateEngagementScore(BusinessVideo video) {
    // Weight different engagement types
    const viewWeight = 0.1;
    const callWeight = 5.0; // Calls are high-intent
    const whatsappWeight = 3.0; // WhatsApp is medium-high intent

    return (video.views * viewWeight) +
        (video.callClicks * callWeight) +
        (video.whatsappClicks * whatsappWeight);
  }

  /// Calculate recency-based score
  static double _calculateRecencyScore(DateTime createdAt) {
    final hoursSinceCreation = DateTime.now().difference(createdAt).inHours;

    // Recent videos get higher scores
    if (hoursSinceCreation < 24) {
      return 50; // Less than a day old
    } else if (hoursSinceCreation < 72) {
      return 30; // 1-3 days old
    } else if (hoursSinceCreation < 168) {
      return 15; // 3-7 days old
    } else if (hoursSinceCreation < 720) {
      return 5; // 1-30 days old
    }
    return 0; // Older than 30 days
  }

  /// Get videos filtered by city
  static List<BusinessVideo> filterByCity(
    List<BusinessVideo> videos,
    String city,
  ) {
    return videos
        .where((v) => v.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  /// Get videos filtered by category
  static List<BusinessVideo> filterByCategory(
    List<BusinessVideo> videos,
    String category,
  ) {
    return videos
        .where(
            (v) => v.businessCategory.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get boosted videos only
  static Future<List<BusinessVideo>> getBoostedVideos(
    List<BusinessVideo> videos,
  ) async {
    final boostedVideos = <BusinessVideo>[];

    for (final video in videos) {
      if (await BusinessBoostService.isVideoBoosted(video.id)) {
        boostedVideos.add(video);
      }
    }

    return boostedVideos;
  }

  /// Get trending business videos
  static List<BusinessVideo> getTrendingVideos(
    List<BusinessVideo> videos, {
    int limit = 10,
  }) {
    final sortedByEngagement = List<BusinessVideo>.from(videos)
      ..sort((a, b) => b.engagementScore.compareTo(a.engagementScore));

    return sortedByEngagement.take(limit).toList();
  }

  /// Get nearby business videos (within same city and area)
  static List<BusinessVideo> getNearbyVideos(
    List<BusinessVideo> videos,
    String userCity,
    String userArea,
  ) {
    return videos.where((v) {
      final sameCity = v.city.toLowerCase() == userCity.toLowerCase();
      final sameArea = v.area.toLowerCase() == userArea.toLowerCase();
      return sameCity && sameArea;
    }).toList();
  }
}

/// Internal class for scoring videos
class _ScoredVideo {
  final BusinessVideo video;
  final double score;

  _ScoredVideo({required this.video, required this.score});
}

/// Feed filter options
enum BusinessFeedFilter {
  all,
  nearby,
  trending,
  offers,
  category,
}
