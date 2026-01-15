/// Video Cache Service
/// Caches video data and manages memory efficiently

import 'dart:collection';
import '../models/models.dart';

class VideoCacheService {
  static final VideoCacheService _instance = VideoCacheService._internal();
  factory VideoCacheService() => _instance;
  VideoCacheService._internal();

  // LRU Cache for videos
  static const int _maxCacheSize = 100;
  final LinkedHashMap<String, RegionalVideo> _videoCache = LinkedHashMap();

  // Response cache
  final Map<String, _CachedResponse> _responseCache = {};
  static const Duration _responseCacheDuration = Duration(minutes: 5);

  /// Get cached video
  RegionalVideo? getVideo(String id) {
    if (_videoCache.containsKey(id)) {
      // Move to end (most recently used)
      final video = _videoCache.remove(id);
      if (video != null) {
        _videoCache[id] = video;
      }
      return video;
    }
    return null;
  }

  /// Cache video
  void cacheVideo(RegionalVideo video) {
    // Remove oldest if at capacity
    while (_videoCache.length >= _maxCacheSize) {
      _videoCache.remove(_videoCache.keys.first);
    }
    _videoCache[video.id] = video;
  }

  /// Cache multiple videos
  void cacheVideos(List<RegionalVideo> videos) {
    for (final video in videos) {
      cacheVideo(video);
    }
  }

  /// Get cached response
  PaginatedResponse<RegionalVideo>? getCachedResponse(String key) {
    final cached = _responseCache[key];
    if (cached != null) {
      if (DateTime.now().difference(cached.timestamp) <
          _responseCacheDuration) {
        return cached.response;
      } else {
        _responseCache.remove(key);
      }
    }
    return null;
  }

  /// Cache response
  void cacheResponse(String key, PaginatedResponse<RegionalVideo> response) {
    _responseCache[key] = _CachedResponse(
      response: response,
      timestamp: DateTime.now(),
    );

    // Also cache individual videos
    cacheVideos(response.items);
  }

  /// Clear all caches
  void clearAll() {
    _videoCache.clear();
    _responseCache.clear();
  }

  /// Clear response cache only
  void clearResponseCache() {
    _responseCache.clear();
  }

  /// Get cache stats
  Map<String, int> getCacheStats() {
    return {
      'videoCount': _videoCache.length,
      'responseCount': _responseCache.length,
    };
  }
}

class _CachedResponse {
  final PaginatedResponse<RegionalVideo> response;
  final DateTime timestamp;

  _CachedResponse({
    required this.response,
    required this.timestamp,
  });
}
