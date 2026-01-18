import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/devotional_video_model.dart';
import '../data/mock/devotional_videos_mock.dart';

/// Repository for fetching devotional videos
/// Supports both mock data (for testing) and Supabase (for production)
class DevotionalRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Toggle this flag for testing vs production
  // Set to false before publishing to Play Store
  static const bool useMockData = false;

  /// Fetch devotional videos based on religion/deity filter
  Future<List<DevotionalVideo>> fetchDevotionalVideos({
    String? deity,
    String? language,
    String? festivalTag,
    int limit = 20,
  }) async {
    if (useMockData) {
      return _fetchMockVideos(
        deity: deity,
        language: language,
        festivalTag: festivalTag,
        limit: limit,
      );
    } else {
      return _fetchFromSupabase(
        deity: deity,
        language: language,
        festivalTag: festivalTag,
        limit: limit,
      );
    }
  }

  /// Fetch mock data for testing
  Future<List<DevotionalVideo>> _fetchMockVideos({
    String? deity,
    String? language,
    String? festivalTag,
    int limit = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var videos = DevotionalVideosMock.videos.map((json) {
      return DevotionalVideo.fromJson(json);
    }).toList();

    // Apply filters
    if (deity != null && deity.isNotEmpty) {
      videos = videos
          .where((v) =>
              v.deity?.toLowerCase().contains(deity.toLowerCase()) ?? false)
          .toList();
    }

    if (language != null && language.isNotEmpty) {
      videos = videos
          .where((v) => v.language.toLowerCase() == language.toLowerCase())
          .toList();
    }

    if (festivalTag != null && festivalTag.isNotEmpty) {
      videos =
          videos.where((v) => v.festivalTags.contains(festivalTag)).toList();
    }

    // Apply limit
    return videos.take(limit).toList();
  }

  /// Fetch from Supabase for production
  Future<List<DevotionalVideo>> _fetchFromSupabase({
    String? deity,
    String? language,
    String? festivalTag,
    int limit = 20,
  }) async {
    try {
      var query =
          _supabase.from('devotional_videos').select().eq('is_verified', true);

      // Apply filters BEFORE limit
      if (deity != null && deity.isNotEmpty) {
        query = query.ilike('deity', '%$deity%');
      }

      if (language != null && language.isNotEmpty) {
        query = query.eq('language', language.toLowerCase());
      }

      if (festivalTag != null && festivalTag.isNotEmpty) {
        query = query.contains('festival_tags', [festivalTag]);
      }

      // Apply ordering and limit at the end - don't reassign to avoid type mismatch
      final response =
          await query.order('created_at', ascending: false).limit(limit);

      return (response as List)
          .map((json) => DevotionalVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch devotional videos: $e');
    }
  }

  /// Fetch videos for a specific temple
  Future<List<DevotionalVideo>> fetchTempleVideos({
    required String templeName,
    int limit = 10,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var videos = DevotionalVideosMock.videos
          .where((v) => v['temple_name'] == templeName)
          .map((json) => DevotionalVideo.fromJson(json))
          .toList();
      return videos.take(limit).toList();
    } else {
      try {
        final response = await _supabase
            .from('devotional_videos')
            .select()
            .eq('temple_name', templeName)
            .eq('is_verified', true)
            .order('created_at', ascending: false)
            .limit(limit);

        return (response as List)
            .map((json) => DevotionalVideo.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception('Failed to fetch temple videos: $e');
      }
    }
  }

  /// Fetch videos by location proximity
  Future<List<DevotionalVideo>> fetchNearbyVideos({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    int limit = 20,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      // For mock, return all videos (in real app, calculate distance)
      return DevotionalVideosMock.videos
          .map((json) => DevotionalVideo.fromJson(json))
          .take(limit)
          .toList();
    } else {
      try {
        // Note: You'll need to implement PostGIS distance calculation in Supabase
        final response = await _supabase
            .from('devotional_videos')
            .select()
            .eq('is_verified', true)
            .order('created_at', ascending: false)
            .limit(limit);

        return (response as List)
            .map((json) => DevotionalVideo.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception('Failed to fetch nearby videos: $e');
      }
    }
  }

  /// Stream devotional videos in real-time
  /// Returns a stream that updates whenever new videos are added
  Stream<List<DevotionalVideo>> streamDevotionalVideos({
    String? deity,
    String? language,
    String? festivalTag,
  }) {
    if (useMockData) {
      // For mock data, return a stream with initial data
      return Stream.value(DevotionalVideosMock.videos
          .map((json) => DevotionalVideo.fromJson(json))
          .toList());
    } else {
      // Real-time Supabase stream
      var query = _supabase
          .from('devotional_videos')
          .stream(primaryKey: ['id'])
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      return query.map((data) {
        var videos =
            data.map((json) => DevotionalVideo.fromJson(json)).toList();

        // Apply filters
        if (deity != null && deity.isNotEmpty) {
          videos = videos
              .where((v) =>
                  v.deity?.toLowerCase().contains(deity.toLowerCase()) ?? false)
              .toList();
        }

        if (language != null && language.isNotEmpty) {
          videos = videos
              .where((v) => v.language.toLowerCase() == language.toLowerCase())
              .toList();
        }

        if (festivalTag != null && festivalTag.isNotEmpty) {
          videos = videos
              .where((v) => v.festivalTags.contains(festivalTag))
              .toList();
        }

        return videos;
      });
    }
  }
}
