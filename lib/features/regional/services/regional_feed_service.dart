/// Regional Feed Service
/// Handles data fetching with cursor-based pagination and location-based filtering

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'video_storage_service.dart';

class RegionalFeedService {
  static const int _defaultPageSize = 10;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sample video URLs for demo purposes
  static const List<String> _sampleVideoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  ];

  static const List<String> _sampleThumbnails = [
    'https://picsum.photos/seed/vid1/400/700',
    'https://picsum.photos/seed/vid2/400/700',
    'https://picsum.photos/seed/vid3/400/700',
    'https://picsum.photos/seed/vid4/400/700',
    'https://picsum.photos/seed/vid5/400/700',
    'https://picsum.photos/seed/vid6/400/700',
    'https://picsum.photos/seed/vid7/400/700',
  ];

  /// Get latest videos sorted by upload time
  Future<PaginatedResponse<RegionalVideo>> getLatestVideos({
    String? city,
    String? district,
    String? state,
    String? language,
    String? cursor,
    int pageSize = _defaultPageSize,
  }) async {
    try {
      // Get user-posted videos from local storage
      final userVideos = await VideoStorageService.getPostedVideos(
        city: city,
        state: state,
        language: language,
      );

      // Try to fetch from Supabase
      final response = await _fetchFromSupabase(
        city: city,
        district: district,
        state: state,
        language: language,
        cursor: cursor,
        pageSize: pageSize,
        sortBy: 'created_at',
        ascending: false,
      );

      // Combine user videos with Supabase videos
      final allVideos = [...userVideos, ...response.items];

      // Sort by created date (latest first)
      allVideos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Return paginated response
      return _paginateVideos(allVideos, cursor, pageSize);
    } catch (e) {
      // If error, return only user-posted videos
      final userVideos = await VideoStorageService.getPostedVideos(
        city: city,
        state: state,
        language: language,
      );

      return _paginateVideos(userVideos, cursor, pageSize);
    }
  }

  /// Get trending videos sorted by weighted score
  Future<PaginatedResponse<RegionalVideo>> getTrendingVideos({
    String? city,
    String? district,
    String? state,
    String? language,
    String? cursor,
    int pageSize = _defaultPageSize,
  }) async {
    try {
      // Get user-posted videos from local storage
      final userVideos = await VideoStorageService.getPostedVideos(
        city: city,
        state: state,
        language: language,
      );

      // Try to fetch from Supabase
      final response = await _fetchFromSupabase(
        city: city,
        district: district,
        state: state,
        language: language,
        cursor: cursor,
        pageSize: pageSize,
        sortBy: 'views', // Sort by views as proxy for trending
        ascending: false,
      );

      // Combine user videos with Supabase videos
      final allVideos = [...userVideos, ...response.items];

      // Sort by trending score
      allVideos.sort(
          (a, b) => b.weightedTrendingScore.compareTo(a.weightedTrendingScore));

      // Return paginated response
      return _paginateVideos(allVideos, cursor, pageSize);
    } catch (e) {
      // If error, return only user-posted videos
      final userVideos = await VideoStorageService.getPostedVideos(
        city: city,
        state: state,
        language: language,
      );

      userVideos.sort(
          (a, b) => b.weightedTrendingScore.compareTo(a.weightedTrendingScore));

      return _paginateVideos(userVideos, cursor, pageSize);
    }
  }

  /// Fetch videos from Supabase with location-based filtering
  Future<PaginatedResponse<RegionalVideo>> _fetchFromSupabase({
    String? city,
    String? district,
    String? state,
    String? language,
    String? cursor,
    required int pageSize,
    required String sortBy,
    required bool ascending,
  }) async {
    // Build query with location priority:
    // 1. Same city (highest priority)
    // 2. Same district
    // 3. Same state (fallback)

    var query = _supabase.from('videos').select().eq('category', 'Regional');

    // Apply language filter
    if (language != null) {
      query = query.eq('language', language);
    }

    // Apply location filter with priority
    if (city != null) {
      // Try city first
      query = query.eq('city', city);
    } else if (district != null) {
      query = query.eq('district', district);
    } else if (state != null) {
      query = query.eq('state', state);
    }

    // Apply cursor-based pagination
    if (cursor != null) {
      query = query.lt('id', cursor);
    }

    // Apply sorting and limit - execute and get data
    final data = await query
        .order(sortBy, ascending: ascending)
        .limit(pageSize + 1); // Fetch one extra to check if there's more

    final items = (data as List)
        .take(pageSize)
        .map((json) => RegionalVideo.fromJson(json))
        .toList();

    final hasMore = data.length > pageSize;
    final nextCursor = items.isNotEmpty ? items.last.id : null;

    return PaginatedResponse(
      items: items,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }

  /// Generate mock latest videos for demo
  PaginatedResponse<RegionalVideo> _getMockLatestVideos({
    String? city,
    String? district,
    String? state,
    String? language,
    String? cursor,
    int pageSize = _defaultPageSize,
  }) {
    final allVideos = _generateMockVideos(
      city: city ?? 'Hyderabad',
      district: district,
      state: state ?? 'Telangana',
      language: language ?? 'te',
      count: 50,
    );

    // Sort by created date (latest first)
    allVideos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _paginateVideos(allVideos, cursor, pageSize);
  }

  /// Generate mock trending videos for demo
  PaginatedResponse<RegionalVideo> _getMockTrendingVideos({
    String? city,
    String? district,
    String? state,
    String? language,
    String? cursor,
    int pageSize = _defaultPageSize,
  }) {
    final allVideos = _generateMockVideos(
      city: city ?? 'Hyderabad',
      district: district,
      state: state ?? 'Telangana',
      language: language ?? 'te',
      count: 50,
    );

    // Sort by weighted trending score
    allVideos.sort(
        (a, b) => b.weightedTrendingScore.compareTo(a.weightedTrendingScore));

    return _paginateVideos(allVideos, cursor, pageSize);
  }

  /// Paginate video list with cursor
  PaginatedResponse<RegionalVideo> _paginateVideos(
    List<RegionalVideo> videos,
    String? cursor,
    int pageSize,
  ) {
    int startIndex = 0;

    if (cursor != null) {
      final cursorIndex = videos.indexWhere((v) => v.id == cursor);
      if (cursorIndex != -1) {
        startIndex = cursorIndex + 1;
      }
    }

    final endIndex = (startIndex + pageSize).clamp(0, videos.length);
    final items = videos.sublist(startIndex, endIndex);
    final hasMore = endIndex < videos.length;
    final nextCursor = items.isNotEmpty ? items.last.id : null;

    return PaginatedResponse(
      items: items,
      nextCursor: nextCursor,
      hasMore: hasMore,
      totalCount: videos.length,
    );
  }

  /// Generate mock videos for demo
  List<RegionalVideo> _generateMockVideos({
    required String city,
    String? district,
    required String state,
    required String language,
    int count = 50,
  }) {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch;

    final titles = [
      'Local Market Day in $city',
      'Street Food Tour - $city Special',
      'Traditional Festival Celebration',
      'Hidden Gems of $city',
      'Morning Walk Through Old Town',
      'Local Artisan Showcase',
      'Weekend Vibes in $city',
      'Sunset Views from $city',
      'Cultural Heritage Walk',
      'Best Cafes in $city',
      'Local News Update',
      'Community Event Highlights',
      'Sports Day Celebration',
      'Temple Visit - $city',
      'Night Life in $city',
    ];

    final creators = [
      ('creator_1', 'Local Explorer', 'https://i.pravatar.cc/150?img=1'),
      ('creator_2', 'City Wanderer', 'https://i.pravatar.cc/150?img=2'),
      ('creator_3', 'Food Hunter', 'https://i.pravatar.cc/150?img=3'),
      ('creator_4', 'Culture Connect', 'https://i.pravatar.cc/150?img=4'),
      ('creator_5', 'Street Stories', 'https://i.pravatar.cc/150?img=5'),
      ('creator_6', 'Daily Diaries', 'https://i.pravatar.cc/150?img=6'),
    ];

    return List.generate(count, (index) {
      final titleIndex = index % titles.length;
      final creatorIndex = index % creators.length;
      final videoIndex = index % _sampleVideoUrls.length;
      final thumbIndex = index % _sampleThumbnails.length;

      // Vary the created time
      final hoursAgo = index * 2 + (random % 5);
      final createdAt = now.subtract(Duration(hours: hoursAgo));

      // Vary engagement metrics
      final views = 100 + (index * 50) + ((random + index) % 1000);
      final likes = (views * 0.1).round() + (index % 50);
      final shares = (views * 0.02).round() + (index % 10);
      final comments = (views * 0.05).round() + (index % 20);

      return RegionalVideo(
        id: 'regional_video_${index}_$random',
        videoUrl: _sampleVideoUrls[videoIndex],
        thumbnailUrl: '${_sampleThumbnails[thumbIndex]}&v=$index',
        title: titles[titleIndex],
        description:
            'Discover the beauty of $city through this amazing video. #$city #regional #local',
        language: language,
        category: 'Regional',
        region: _getRegionForState(state),
        state: state,
        city: city,
        district: district,
        creatorId: creators[creatorIndex].$1,
        creatorName: creators[creatorIndex].$2,
        creatorAvatar: creators[creatorIndex].$3,
        isVerifiedCreator: index % 3 == 0,
        likes: likes,
        comments: comments,
        shares: shares,
        views: views,
        watchTime: 15.0 + (index % 30),
        replays: (views * 0.05).round(),
        createdAt: createdAt,
        hashtags: ['#$city', '#regional', '#local', '#${language}content'],
        isBoosted: index % 10 == 0,
      );
    });
  }

  /// Get region for state
  String _getRegionForState(String state) {
    final stateToRegion = {
      'Telangana': 'South',
      'Andhra Pradesh': 'South',
      'Tamil Nadu': 'South',
      'Karnataka': 'South',
      'Kerala': 'South',
      'Maharashtra': 'West',
      'Gujarat': 'West',
      'Delhi': 'North',
      'Uttar Pradesh': 'North',
      'Punjab': 'North',
      'West Bengal': 'East',
      'Bihar': 'East',
    };
    return stateToRegion[state] ?? 'Central';
  }

  /// Search videos
  Future<PaginatedResponse<RegionalVideo>> searchVideos({
    required String query,
    String? city,
    String? language,
    String? cursor,
    int pageSize = _defaultPageSize,
  }) async {
    // For demo, filter mock videos by query
    final allVideos = _generateMockVideos(
      city: city ?? 'Hyderabad',
      state: 'Telangana',
      language: language ?? 'te',
      count: 50,
    );

    final filteredVideos = allVideos.where((video) {
      final searchLower = query.toLowerCase();
      return video.title.toLowerCase().contains(searchLower) ||
          video.description.toLowerCase().contains(searchLower) ||
          video.hashtags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();

    return _paginateVideos(filteredVideos, cursor, pageSize);
  }
}
