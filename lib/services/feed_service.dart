// STEP 3, 5, 6: Feed Service
// Implement feed toggle for Trending and Latest.
// Trending should be sorted by engagement score.
// Latest should be sorted by upload time.
// Rank feed based on user behavior.

import '../models/video_model.dart';
import '../models/user_model.dart';
import '../models/hashtag_model.dart';

enum FeedType {
  trending,
  latest,
  personalized,
  festival,
  hashtag,
}

class FeedService {
  // STEP 5: Trending Algorithm
  // score = views + (likes * 2) + (shares * 3) + (watchTime * 5)
  // Sort videos by score descending.
  static List<Video> getTrendingFeed(List<Video> videos) {
    final sortedVideos = List<Video>.from(videos);
    sortedVideos.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
    return sortedVideos;
  }

  // Latest feed sorted by upload time
  static List<Video> getLatestFeed(List<Video> videos) {
    final sortedVideos = List<Video>.from(videos);
    sortedVideos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedVideos;
  }

  // STEP 6: Personalized Feed Ranking
  // Rank feed based on user behavior:
  // prioritize videos matching language and region,
  // boost videos with higher watch time and replays.
  static List<Video> getPersonalizedFeed(List<Video> videos, UserProfile user) {
    final scoredVideos = videos.map((video) {
      double score = video.trendingScore;

      // Boost for matching primary language (2x)
      if (video.language == user.primaryLanguage) {
        score *= 2.0;
      }
      // Boost for matching secondary language (1.5x)
      else if (video.language == user.secondaryLanguage) {
        score *= 1.5;
      }

      // Boost for matching region (1.8x)
      if (video.region == user.region || video.state == user.state) {
        score *= 1.8;
      }

      // Boost for matching city (1.3x)
      if (video.city == user.city) {
        score *= 1.3;
      }

      // Boost for preferred categories
      if (user.preferredCategories.contains(video.category)) {
        score *= 1.5;
      }

      // Boost for followed creators
      if (user.followedCreators.contains(video.creatorId)) {
        score *= 2.0;
      }

      // Boost for high watch time videos
      if (video.watchTime > 30) {
        score *= 1.2;
      }

      // Boost for videos with high replay rate
      if (video.views > 0 && (video.replays / video.views) > 0.1) {
        score *= 1.3;
      }

      // Boost for boosted videos (monetization)
      if (video.isBoosted) {
        score *= 1.5;
      }

      return MapEntry(video, score);
    }).toList();

    // Sort by personalized score
    scoredVideos.sort((a, b) => b.value.compareTo(a.value));

    return scoredVideos.map((e) => e.key).toList();
  }

  // Filter feed by category
  static List<Video> filterByCategory(List<Video> videos, String category) {
    return videos.where((v) => v.category == category).toList();
  }

  // Filter feed by language
  static List<Video> filterByLanguage(
      List<Video> videos, List<String> languages) {
    return videos.where((v) => languages.contains(v.language)).toList();
  }

  // Filter feed by region
  static List<Video> filterByRegion(List<Video> videos, String region,
      {String? state, String? city}) {
    return videos.where((v) {
      if (city != null && v.city == city) return true;
      if (state != null && v.state == state) return true;
      return v.region == region;
    }).toList();
  }

  // STEP 10: Filter by hashtag
  static List<Video> filterByHashtag(List<Video> videos, String hashtag) {
    final normalizedTag = hashtag.toLowerCase().replaceAll('#', '');
    return videos.where((v) {
      return v.hashtags
          .any((h) => h.toLowerCase().replaceAll('#', '') == normalizedTag);
    }).toList();
  }

  // STEP 8: Filter festival content
  static List<Video> filterFestivalContent(
      List<Video> videos, String? festivalTag) {
    if (festivalTag == null) {
      return videos.where((v) => v.isFestivalContent).toList();
    }
    return videos
        .where((v) => v.isFestivalContent && v.festivalTag == festivalTag)
        .toList();
  }

  // Get feed with mixed content (for engagement)
  static List<Video> getMixedFeed(List<Video> videos, UserProfile user,
      {int? limit}) {
    // Get different types of content
    final personalized = getPersonalizedFeed(videos, user);
    final trending = getTrendingFeed(videos);
    final latest = getLatestFeed(videos);

    // Mix content: 50% personalized, 30% trending, 20% latest
    final mixedFeed = <Video>[];
    final seen = <String>{};

    void addIfNotSeen(Video video) {
      if (!seen.contains(video.id)) {
        mixedFeed.add(video);
        seen.add(video.id);
      }
    }

    final targetLength = limit ?? videos.length;
    int pIndex = 0, tIndex = 0, lIndex = 0;

    while (mixedFeed.length < targetLength) {
      // Add 5 personalized
      for (int i = 0; i < 5 && pIndex < personalized.length; i++) {
        addIfNotSeen(personalized[pIndex++]);
      }

      // Add 3 trending
      for (int i = 0; i < 3 && tIndex < trending.length; i++) {
        addIfNotSeen(trending[tIndex++]);
      }

      // Add 2 latest
      for (int i = 0; i < 2 && lIndex < latest.length; i++) {
        addIfNotSeen(latest[lIndex++]);
      }

      // Break if we've exhausted all sources
      if (pIndex >= personalized.length &&
          tIndex >= trending.length &&
          lIndex >= latest.length) {
        break;
      }
    }

    return mixedFeed.take(limit ?? mixedFeed.length).toList();
  }

  // Insert ads into feed
  static List<dynamic> insertAdsIntoFeed(List<Video> videos,
      {int adFrequency = 5}) {
    final feedWithAds = <dynamic>[];

    for (int i = 0; i < videos.length; i++) {
      feedWithAds.add(videos[i]);

      // Insert ad placeholder every N videos
      if ((i + 1) % adFrequency == 0 && i < videos.length - 1) {
        feedWithAds.add({'type': 'ad', 'position': i + 1});
      }
    }

    return feedWithAds;
  }

  // Get trending hashtags
  static List<Hashtag> getTrendingHashtags(List<Video> videos,
      {int limit = 10}) {
    final hashtagCounts = <String, int>{};

    for (final video in videos) {
      for (final hashtag in video.hashtags) {
        final normalized = hashtag.toLowerCase();
        hashtagCounts[normalized] = (hashtagCounts[normalized] ?? 0) + 1;
      }
    }

    final sortedHashtags = hashtagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHashtags
        .take(limit)
        .map((e) => Hashtag(
              tag: e.key,
              usageCount: e.value,
              isTrending: true,
              lastUsedAt: DateTime.now(),
            ))
        .toList();
  }
}
