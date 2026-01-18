/// Devotional Service
/// API service for fetching devotional videos with filters

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/devotional_video_model.dart';
import '../models/quote_model.dart';
import '../services/religion_service.dart';
import '../services/festival_service.dart';
import '../models/festival_model.dart';

class DevotionalService {
  static const String _quoteKey = 'cached_quote';
  static const String _quoteDateKey = 'quote_cached_date';
  static const String _quoteReligionKey = 'quote_religion';

  /// Fetch devotional videos with filters
  static Future<List<DevotionalVideo>> fetchDevotionalVideos({
    String? religion,
    String? distanceCategory,
    String? language,
    List<String>? festivalTags,
    double? userLat,
    double? userLng,
    int limit = 20,
    int offset = 0,
  }) async {
    // TODO: Replace with actual API call
    // For now, return mock data
    await Future.delayed(const Duration(milliseconds: 500));

    final currentFestival = FestivalService.getCurrentFestival();

    List<DevotionalVideo> videos = _getMockDevotionalVideos();

    // Filter by religion
    if (religion != null && religion.isNotEmpty) {
      videos = videos
          .where((v) => v.religion.toLowerCase() == religion.toLowerCase())
          .toList();
    }

    // Filter by distance category
    if (distanceCategory != null && distanceCategory.isNotEmpty) {
      videos = videos
          .where((v) =>
              v.distanceCategory.toLowerCase() ==
              distanceCategory.toLowerCase())
          .toList();
    }

    // Filter by language
    if (language != null && language.isNotEmpty) {
      videos = videos
          .where((v) => v.language.toLowerCase() == language.toLowerCase())
          .toList();
    }

    // Filter by festival tags
    if (festivalTags != null && festivalTags.isNotEmpty) {
      videos = videos.where((v) {
        return v.festivalTags.any((tag) => festivalTags.contains(tag));
      }).toList();
    }

    // Sort by festival relevance first, then by latest
    videos.sort((a, b) {
      // Festival-tagged videos first during active festivals
      if (currentFestival != null) {
        final aHasFestival = a.festivalTags
            .any((tag) => currentFestival.relatedHashtags.contains(tag));
        final bHasFestival = b.festivalTags
            .any((tag) => currentFestival.relatedHashtags.contains(tag));

        if (aHasFestival && !bHasFestival) return -1;
        if (bHasFestival && !aHasFestival) return 1;
      }

      // Then sort by date (latest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    // Apply pagination
    final startIndex = offset;
    final endIndex = (offset + limit).clamp(0, videos.length);

    if (startIndex >= videos.length) return [];

    return videos.sublist(startIndex, endIndex);
  }

  /// Get Quote of the Day
  static Future<DevotionalQuote?> getQuoteOfTheDay({
    String? religion,
    String? language,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we have a cached quote for today
    final cachedDateStr = prefs.getString(_quoteDateKey);
    final cachedReligion = prefs.getString(_quoteReligionKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    // If cached quote exists for today and same religion, return it
    if (cachedDateStr == todayStr &&
        cachedReligion == religion &&
        prefs.getString(_quoteKey) != null) {
      final cachedJson = prefs.getString(_quoteKey);
      if (cachedJson != null) {
        return DevotionalQuote.fromJson(jsonDecode(cachedJson));
      }
    }

    // Get religion from parameter or stored preference
    String? userReligion = religion;
    if (userReligion == null || userReligion.isEmpty) {
      userReligion = await ReligionService.getReligionString();
    }

    if (userReligion == null || userReligion.isEmpty) {
      return null;
    }

    // Get quotes for the religion
    final quotes = DevotionalQuote.getPredefinedQuotes(userReligion);
    if (quotes.isEmpty) return null;

    // Select quote based on day of year for consistency
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final quoteIndex = dayOfYear % quotes.length;
    final quote = quotes[quoteIndex];

    // Cache the quote
    await prefs.setString(_quoteKey, jsonEncode(quote.toJson()));
    await prefs.setString(_quoteDateKey, todayStr);
    await prefs.setString(_quoteReligionKey, userReligion);

    return quote;
  }

  /// Force refresh quote (for testing or manual refresh)
  static Future<void> clearCachedQuote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quoteKey);
    await prefs.remove(_quoteDateKey);
    await prefs.remove(_quoteReligionKey);
  }

  /// Get active festival content
  static Future<List<DevotionalVideo>> getFestivalContent() async {
    final currentFestival = FestivalService.getCurrentFestival();
    if (currentFestival == null) return [];

    return fetchDevotionalVideos(
      festivalTags: currentFestival.relatedHashtags,
    );
  }

  /// Get deities by religion
  static List<String> getDeitiesByReligion(String religion) {
    switch (religion.toLowerCase()) {
      case 'hinduism':
        return [
          'Ganesha',
          'Shiva',
          'Vishnu',
          'Krishna',
          'Rama',
          'Hanuman',
          'Durga',
          'Lakshmi',
          'Saraswati',
          'Kali',
        ];
      case 'islam':
        return ['Allah'];
      case 'christianity':
        return ['Jesus Christ', 'Mother Mary', 'Holy Spirit'];
      case 'sikhism':
        return ['Waheguru'];
      case 'buddhism':
        return ['Buddha', 'Avalokiteshvara', 'Tara'];
      default:
        return [];
    }
  }

  /// Mock devotional videos for development
  static List<DevotionalVideo> _getMockDevotionalVideos() {
    final now = DateTime.now();
    return [
      // Hinduism
      DevotionalVideo(
        id: 'dev_1',
        title: 'Morning Aarti at Varanasi Ghat',
        religion: 'hinduism',
        deity: 'Shiva',
        templeName: 'Kashi Vishwanath Temple',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=1',
        festivalTags: ['diwali', 'mahashivratri'],
        distanceCategory: 'national',
        language: 'hi',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        views: 15420,
        likes: 2341,
      ),
      DevotionalVideo(
        id: 'dev_2',
        title: 'Ganesh Chaturthi Celebration',
        religion: 'hinduism',
        deity: 'Ganesha',
        templeName: 'Siddhivinayak Temple',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=2',
        festivalTags: ['ganesh_chaturthi'],
        distanceCategory: 'regional',
        language: 'mr',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        views: 8932,
        likes: 1456,
      ),
      DevotionalVideo(
        id: 'dev_3',
        title: 'Krishna Janmashtami Bhajan',
        religion: 'hinduism',
        deity: 'Krishna',
        templeName: 'ISKCON Temple',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=3',
        festivalTags: ['janmashtami'],
        distanceCategory: 'nearby',
        language: 'hi',
        isVerified: false,
        createdAt: now.subtract(const Duration(hours: 8)),
        views: 5621,
        likes: 892,
      ),

      // Islam
      DevotionalVideo(
        id: 'dev_4',
        title: 'Beautiful Azaan from Jama Masjid',
        religion: 'islam',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=4',
        festivalTags: ['eid', 'ramadan'],
        distanceCategory: 'national',
        language: 'ur',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 3)),
        views: 12350,
        likes: 2100,
      ),
      DevotionalVideo(
        id: 'dev_5',
        title: 'Eid Prayer Gathering',
        religion: 'islam',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=5',
        festivalTags: ['eid'],
        distanceCategory: 'regional',
        language: 'ur',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 6)),
        views: 7845,
        likes: 1523,
      ),

      // Christianity
      DevotionalVideo(
        id: 'dev_6',
        title: 'Christmas Carol Service',
        religion: 'christianity',
        deity: 'Jesus Christ',
        templeName: 'St. Patrick\'s Cathedral',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=6',
        festivalTags: ['christmas', 'easter'],
        distanceCategory: 'national',
        language: 'en',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 4)),
        views: 9876,
        likes: 1789,
      ),
      DevotionalVideo(
        id: 'dev_7',
        title: 'Good Friday Mass',
        religion: 'christianity',
        deity: 'Jesus Christ',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=7',
        festivalTags: ['easter'],
        distanceCategory: 'regional',
        language: 'en',
        isVerified: false,
        createdAt: now.subtract(const Duration(hours: 10)),
        views: 4532,
        likes: 678,
      ),

      // Sikhism
      DevotionalVideo(
        id: 'dev_8',
        title: 'Kirtan at Golden Temple',
        religion: 'sikhism',
        deity: 'Waheguru',
        templeName: 'Golden Temple',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=8',
        festivalTags: ['vaisakhi', 'gurpurab'],
        distanceCategory: 'national',
        language: 'pa',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 1)),
        views: 18234,
        likes: 3456,
      ),
      DevotionalVideo(
        id: 'dev_9',
        title: 'Langar Seva at Gurudwara',
        religion: 'sikhism',
        templeName: 'Bangla Sahib',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=9',
        festivalTags: ['gurpurab'],
        distanceCategory: 'regional',
        language: 'pa',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 7)),
        views: 6234,
        likes: 1023,
      ),

      // Buddhism
      DevotionalVideo(
        id: 'dev_10',
        title: 'Meditation at Bodh Gaya',
        religion: 'buddhism',
        deity: 'Buddha',
        templeName: 'Mahabodhi Temple',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=10',
        festivalTags: ['buddha_purnima', 'vesak'],
        distanceCategory: 'national',
        language: 'en',
        isVerified: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        views: 11234,
        likes: 2134,
      ),
      DevotionalVideo(
        id: 'dev_11',
        title: 'Buddhist Chanting Ceremony',
        religion: 'buddhism',
        deity: 'Buddha',
        videoUrl:
            'https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
        thumbnailUrl: 'https://picsum.photos/400/600?random=11',
        festivalTags: ['vesak'],
        distanceCategory: 'regional',
        language: 'en',
        isVerified: false,
        createdAt: now.subtract(const Duration(hours: 9)),
        views: 3456,
        likes: 567,
      ),
    ];
  }
}
