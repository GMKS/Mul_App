/// Local News Service
/// API methods for hyperlocal news with AI verification and community validation

import '../models/local_news_model.dart';

class LocalNewsService {
  // Mock data storage
  static final List<LocalNews> _mockNews = [];
  static final List<NewsComment> _mockComments = [];
  static final Set<String> _upvotedNews = {};
  static final Set<String> _flaggedNews = {};

  LocalNewsService() {
    if (_mockNews.isEmpty) {
      _initializeMockData();
    }
  }

  // ==================== GET NEWS ====================

  /// GET /news - Get hyperlocal news with filters
  Future<List<LocalNews>> getNews({
    double? latitude,
    double? longitude,
    double radiusKm = 5.0,
    NewsCategory? category,
    List<String>? tags,
    NewsStatus? status,
    bool trendingOnly = false,
    bool breakingOnly = false,
    String? language,
    int limit = 20,
    int offset = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = _mockNews.where((news) {
      // Filter by status (default: published only)
      if (status != null && news.status != status) return false;
      if (status == null && news.status != NewsStatus.published) return false;

      // Filter by location (if provided)
      if (latitude != null && longitude != null) {
        if (news.latitude == null || news.longitude == null) return false;
        final distance = _calculateDistance(
          latitude,
          longitude,
          news.latitude!,
          news.longitude!,
        );
        if (distance > radiusKm) return false;
      }

      // Filter by category
      if (category != null && news.category != category) return false;

      // Filter by tags
      if (tags != null && tags.isNotEmpty) {
        if (!tags.any((tag) => news.tags.contains(tag))) return false;
      }

      // Filter by trending
      if (trendingOnly && !news.isTrending) return false;

      // Filter by breaking
      if (breakingOnly && !news.isBreaking) return false;

      // Filter by language
      if (language != null && news.language != language) return false;

      return true;
    }).toList();

    // Sort by priority and date
    filtered.sort((a, b) {
      // Breaking news first
      if (a.isBreaking && !b.isBreaking) return -1;
      if (!a.isBreaking && b.isBreaking) return 1;

      // Then by trending score
      if (a.trendingScore != b.trendingScore) {
        return b.trendingScore.compareTo(a.trendingScore);
      }

      // Then by date
      return b.createdAt.compareTo(a.createdAt);
    });

    // Pagination
    final start = offset;
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  /// GET /news/:id - Get single news by ID
  Future<LocalNews?> getNewsById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockNews.firstWhere((news) => news.id == id);
    } catch (e) {
      return null;
    }
  }

  /// GET /news/trending - Get trending news
  Future<List<LocalNews>> getTrendingNews({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    int limit = 10,
  }) async {
    return getNews(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      trendingOnly: true,
      limit: limit,
    );
  }

  /// GET /news/breaking - Get breaking news
  Future<List<LocalNews>> getBreakingNews({
    double? latitude,
    double? longitude,
    double radiusKm = 20.0,
  }) async {
    return getNews(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      breakingOnly: true,
      limit: 5,
    );
  }

  /// GET /news/category/:category - Get news by category
  Future<List<LocalNews>> getNewsByCategory(
    NewsCategory category, {
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    return getNews(
      latitude: latitude,
      longitude: longitude,
      category: category,
      limit: limit,
    );
  }

  /// GET /news/digest - Get personalized news digest
  Future<Map<String, List<LocalNews>>> getNewsDigest({
    double? latitude,
    double? longitude,
  }) async {
    final breaking = await getBreakingNews(
      latitude: latitude,
      longitude: longitude,
    );
    final trending = await getTrendingNews(
      latitude: latitude,
      longitude: longitude,
    );
    final recent = await getNews(
      latitude: latitude,
      longitude: longitude,
      limit: 10,
    );

    return {
      'breaking': breaking,
      'trending': trending,
      'recent': recent,
    };
  }

  // ==================== SUBMIT NEWS ====================

  /// POST /news - Submit news (user-generated)
  Future<LocalNews> submitNews(NewsSubmissionRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final news = LocalNews(
      id: 'news_${DateTime.now().millisecondsSinceEpoch}',
      title: request.title,
      content: request.content,
      tldr: request.tldr,
      imageUrls: request.imagePaths, // Would be uploaded URLs
      videoUrls: request.videoPaths,
      audioUrl: request.audioPath,
      latitude: request.latitude,
      longitude: request.longitude,
      locationName: request.locationName,
      category: request.category,
      tags: request.tags,
      priority: request.priority,
      language: request.language,
      reportedBy: 'current_user_id',
      reporterName: 'Current User',
      reporterAvatar: 'https://i.pravatar.cc/100?img=50',
      status: NewsStatus.aiReview,
      credibilityScore: 0.7, // Initial AI score
      aiVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockNews.add(news);
    return news;
  }

  // ==================== VALIDATION & MODERATION ====================

  /// POST /news/:id/upvote - Community upvote
  Future<bool> upvoteNews(String newsId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _upvotedNews.add(newsId);

    final index = _mockNews.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      _mockNews[index] = _mockNews[index].copyWith(
        upvotes: _mockNews[index].upvotes + 1,
      );
      return true;
    }
    return false;
  }

  /// POST /news/:id/downvote - Community downvote
  Future<bool> downvoteNews(String newsId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _mockNews.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      _mockNews[index] = _mockNews[index].copyWith(
        downvotes: _mockNews[index].downvotes + 1,
      );
      return true;
    }
    return false;
  }

  /// POST /news/:id/flag - Flag fake/inappropriate news
  Future<bool> flagNews(String newsId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _flaggedNews.add(newsId);

    final index = _mockNews.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      _mockNews[index] = _mockNews[index].copyWith();
      return true;
    }
    return false;
  }

  /// POST /news/:id/react - Add reaction
  Future<bool> addReaction(String newsId, ReactionType reaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Would update reactions map
    return true;
  }

  /// Check if user upvoted
  bool hasUpvoted(String newsId) {
    return _upvotedNews.contains(newsId);
  }

  /// Check if user flagged
  bool hasFlagged(String newsId) {
    return _flaggedNews.contains(newsId);
  }

  // ==================== COMMENTS ====================

  /// GET /news/:id/comments - Get comments
  Future<List<NewsComment>> getComments(String newsId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockComments.where((c) => c.newsId == newsId).toList();
  }

  /// POST /news/:id/comment - Add comment
  Future<NewsComment> addComment({
    required String newsId,
    required String content,
    List<String>? imagePaths,
    String? voiceNotePath,
    String? parentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final comment = NewsComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      newsId: newsId,
      userId: 'current_user_id',
      userName: 'Current User',
      userAvatar: 'https://i.pravatar.cc/100?img=50',
      content: content,
      imageUrls: imagePaths ?? [],
      voiceNoteUrl: voiceNotePath,
      parentId: parentId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _mockComments.add(comment);
    return comment;
  }

  // ==================== STATISTICS ====================

  /// POST /news/:id/view - Record view
  Future<void> recordView(String newsId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _mockNews.indexWhere((n) => n.id == newsId);
    if (index != -1) {
      _mockNews[index] = _mockNews[index].copyWith(
        viewCount: _mockNews[index].viewCount + 1,
      );
    }
  }

  /// POST /news/:id/share - Record share
  Future<void> recordShare(String newsId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Would increment share count
  }

  // ==================== SEARCH ====================

  /// GET /news/search - Search news
  Future<List<LocalNews>> searchNews(
    String query, {
    double? latitude,
    double? longitude,
    NewsCategory? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final lowerQuery = query.toLowerCase();
    return _mockNews.where((news) {
      if (news.status != NewsStatus.published) return false;

      final matchesTitle = news.title.toLowerCase().contains(lowerQuery);
      final matchesContent = news.content.toLowerCase().contains(lowerQuery);
      final matchesTags =
          news.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));

      final matchesSearch = matchesTitle || matchesContent || matchesTags;

      if (category != null && news.category != category) return false;

      return matchesSearch;
    }).toList();
  }

  // ==================== HELPER METHODS ====================

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula for distance calculation
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (dLat / 2).abs() * (dLat / 2).abs() +
        (lat1.abs() * lat2.abs()) * (dLon / 2).abs() * (dLon / 2).abs();

    final c = 2 * (a.abs());
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // ==================== MOCK DATA ====================

  void _initializeMockData() {
    final now = DateTime.now();

    _mockNews.addAll([
      LocalNews(
        id: '1',
        title: '🚨 Traffic Alert: Heavy Congestion on Jubilee Hills Road',
        content:
            'Severe traffic jam reported on Road No. 36, Jubilee Hills due to a water pipeline repair work. Commuters are advised to take alternate routes via Road No. 45. Expected clearance time: 2 hours.',
        tldr: 'Heavy traffic on Jubilee Hills Road No. 36 due to pipeline work',
        imageUrls: [
          'https://images.unsplash.com/photo-1583221773939-9c86c5bc303d?w=800',
        ],
        latitude: 17.4326,
        longitude: 78.4071,
        locationName: 'Jubilee Hills, Hyderabad',
        category: NewsCategory.traffic,
        tags: ['traffic', 'jubilee hills', 'road closure'],
        priority: NewsPriority.high,
        reportedBy: 'user_1',
        reporterName: 'Rajesh Kumar',
        reporterAvatar: 'https://i.pravatar.cc/100?img=10',
        isVerifiedReporter: true,
        status: NewsStatus.published,
        credibilityScore: 0.95,
        aiVerified: true,
        communityVerified: true,
        adminVerified: true,
        viewCount: 1250,
        upvotes: 89,
        downvotes: 2,
        reactions: {'like': 45, 'support': 30, 'sad': 14},
        commentsCount: 23,
        isTrending: true,
        isBreaking: true,
        trendingScore: 8.5,
        createdAt: now.subtract(const Duration(hours: 2)),
        publishedAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      LocalNews(
        id: '2',
        title: 'New Community Park Opens in Banjara Hills',
        content:
            'A brand new community park with walking tracks, kids play area, and fitness equipment has been inaugurated at Banjara Hills Road No. 12. The park is open from 5 AM to 10 PM daily.',
        tldr: 'New park with modern amenities opens in Banjara Hills',
        imageUrls: [
          'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=800',
          'https://images.unsplash.com/photo-1587845119261-385ca14b6716?w=800',
        ],
        latitude: 17.4239,
        longitude: 78.4738,
        locationName: 'Banjara Hills, Hyderabad',
        category: NewsCategory.community,
        tags: ['park', 'banjara hills', 'community', 'development'],
        priority: NewsPriority.normal,
        reportedBy: 'user_2',
        reporterName: 'Priya Sharma',
        reporterAvatar: 'https://i.pravatar.cc/100?img=5',
        isVerifiedReporter: true,
        status: NewsStatus.published,
        credibilityScore: 0.92,
        aiVerified: true,
        adminVerified: true,
        viewCount: 850,
        upvotes: 156,
        downvotes: 3,
        reactions: {'like': 98, 'love': 45, 'wow': 13},
        commentsCount: 42,
        isTrending: true,
        trendingScore: 7.2,
        createdAt: now.subtract(const Duration(hours: 5)),
        publishedAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      LocalNews(
        id: '3',
        title: '⚠️ Power Outage in Madhapur Area',
        content:
            'Unscheduled power cut reported in Madhapur, Ayyappa Society, and surrounding areas since 3 PM. TS Transco officials are working on restoring power. Expected restoration: 6 PM.',
        tldr: 'Power outage in Madhapur since 3 PM, restoration by 6 PM',
        imageUrls: [],
        latitude: 17.4484,
        longitude: 78.3908,
        locationName: 'Madhapur, Hyderabad',
        category: NewsCategory.announcement,
        tags: ['power', 'outage', 'madhapur', 'electricity'],
        priority: NewsPriority.urgent,
        reportedBy: 'user_3',
        reporterName: 'Amit Patel',
        reporterAvatar: 'https://i.pravatar.cc/100?img=12',
        isVerifiedReporter: false,
        status: NewsStatus.published,
        credibilityScore: 0.85,
        aiVerified: true,
        communityVerified: true,
        viewCount: 2100,
        upvotes: 234,
        downvotes: 12,
        reactions: {'angry': 89, 'sad': 67, 'support': 34},
        commentsCount: 78,
        isBreaking: true,
        trendingScore: 9.1,
        createdAt: now.subtract(const Duration(hours: 1)),
        publishedAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      LocalNews(
        id: '4',
        title: 'Free Health Check-up Camp at Gachibowli Stadium',
        content:
            'The local health department is organizing a free health check-up camp tomorrow (Jan 27) from 9 AM to 5 PM at Gachibowli Indoor Stadium. Services include BP, sugar, eye check-up, and dental consultation.',
        tldr: 'Free health camp tomorrow at Gachibowli Stadium, 9 AM - 5 PM',
        imageUrls: [
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
        ],
        latitude: 17.4399,
        longitude: 78.3487,
        locationName: 'Gachibowli, Hyderabad',
        category: NewsCategory.health,
        tags: ['health', 'free camp', 'gachibowli', 'medical'],
        priority: NewsPriority.normal,
        reportedBy: 'user_4',
        reporterName: 'Dr. Sunita Reddy',
        reporterAvatar: 'https://i.pravatar.cc/100?img=7',
        isVerifiedReporter: true,
        status: NewsStatus.published,
        credibilityScore: 0.98,
        aiVerified: true,
        adminVerified: true,
        viewCount: 560,
        upvotes: 98,
        downvotes: 1,
        reactions: {'like': 67, 'love': 23, 'support': 8},
        commentsCount: 15,
        isFeatured: true,
        trendingScore: 6.5,
        createdAt: now.subtract(const Duration(hours: 8)),
        publishedAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 7)),
      ),
      LocalNews(
        id: '5',
        title: 'Road Accident Near Kukatpally Metro Station',
        content:
            'A minor road accident involving two cars occurred near Kukatpally Metro Station around 4 PM. No major injuries reported. Traffic police are on site managing the situation. Expect minor delays.',
        tldr: 'Minor accident near Kukatpally Metro, no major injuries',
        imageUrls: [],
        latitude: 17.4849,
        longitude: 78.4138,
        locationName: 'Kukatpally, Hyderabad',
        category: NewsCategory.accident,
        tags: ['accident', 'kukatpally', 'traffic', 'metro'],
        priority: NewsPriority.high,
        reportedBy: 'user_5',
        reporterName: 'Vikram Singh',
        reporterAvatar: 'https://i.pravatar.cc/100?img=15',
        isVerifiedReporter: false,
        status: NewsStatus.published,
        credibilityScore: 0.78,
        aiVerified: true,
        communityVerified: true,
        viewCount: 1450,
        upvotes: 67,
        downvotes: 8,
        reactions: {'sad': 34, 'pray': 21, 'support': 12},
        commentsCount: 31,
        trendingScore: 5.8,
        createdAt: now.subtract(const Duration(minutes: 45)),
        publishedAt: now.subtract(const Duration(minutes: 40)),
        updatedAt: now.subtract(const Duration(minutes: 20)),
      ),
      LocalNews(
        id: '6',
        title: '🌧️ Heavy Rain Alert for Next 2 Days',
        content:
            'IMD has issued a heavy rainfall alert for Hyderabad and surrounding areas for the next 48 hours. Citizens are advised to avoid low-lying areas and stay updated with weather forecasts.',
        tldr: 'Heavy rain expected for next 2 days, stay cautious',
        imageUrls: [
          'https://images.unsplash.com/photo-1519692933481-e162a57d6721?w=800',
        ],
        latitude: 17.3850,
        longitude: 78.4867,
        locationName: 'Hyderabad',
        category: NewsCategory.weather,
        tags: ['weather', 'rain', 'alert', 'imd'],
        priority: NewsPriority.urgent,
        reportedBy: 'user_6',
        reporterName: 'Weather Desk',
        reporterAvatar: 'https://i.pravatar.cc/100?img=20',
        isVerifiedReporter: true,
        status: NewsStatus.published,
        credibilityScore: 0.99,
        aiVerified: true,
        adminVerified: true,
        viewCount: 3200,
        upvotes: 345,
        downvotes: 5,
        reactions: {'support': 123, 'pray': 89, 'sad': 45},
        commentsCount: 156,
        isBreaking: true,
        isFeatured: true,
        isPinned: true,
        trendingScore: 9.8,
        createdAt: now.subtract(const Duration(hours: 3)),
        publishedAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      LocalNews(
        id: '7',
        title: 'Local School Wins State-Level Science Competition',
        content:
            'Students from Delhi Public School, Kompally won first prize in the State-Level Science Exhibition with their innovative water purification project. Principal and parents congratulated the team.',
        tldr: 'DPS Kompally wins state science competition',
        imageUrls: [
          'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800',
        ],
        latitude: 17.5434,
        longitude: 78.4847,
        locationName: 'Kompally, Hyderabad',
        category: NewsCategory.education,
        tags: ['education', 'school', 'award', 'science'],
        priority: NewsPriority.normal,
        reportedBy: 'user_7',
        reporterName: 'Anitha Reddy',
        reporterAvatar: 'https://i.pravatar.cc/100?img=8',
        isVerifiedReporter: false,
        status: NewsStatus.published,
        credibilityScore: 0.88,
        aiVerified: true,
        viewCount: 450,
        upvotes: 123,
        downvotes: 2,
        reactions: {'like': 78, 'love': 34, 'wow': 11},
        commentsCount: 28,
        trendingScore: 4.5,
        createdAt: now.subtract(const Duration(hours: 12)),
        publishedAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 11)),
      ),
      LocalNews(
        id: '8',
        title: 'Street Food Festival This Weekend at Necklace Road',
        content:
            'A grand street food festival featuring 50+ stalls from across India will be held at Necklace Road this Saturday and Sunday (5 PM - 11 PM). Entry is free!',
        tldr: 'Street food festival at Necklace Road this weekend, free entry',
        imageUrls: [
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
        ],
        latitude: 17.4239,
        longitude: 78.4738,
        locationName: 'Necklace Road, Hyderabad',
        category: NewsCategory.event,
        tags: ['event', 'food', 'festival', 'weekend'],
        priority: NewsPriority.normal,
        reportedBy: 'user_8',
        reporterName: 'Foodie Club Hyd',
        reporterAvatar: 'https://i.pravatar.cc/100?img=25',
        isVerifiedReporter: true,
        status: NewsStatus.published,
        credibilityScore: 0.94,
        aiVerified: true,
        adminVerified: true,
        viewCount: 1850,
        upvotes: 289,
        downvotes: 4,
        reactions: {'love': 145, 'wow': 78, 'like': 66},
        commentsCount: 92,
        isTrending: true,
        isFeatured: true,
        trendingScore: 8.2,
        createdAt: now.subtract(const Duration(hours: 6)),
        publishedAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
    ]);

    // Mock comments
    _mockComments.addAll([
      NewsComment(
        id: 'c1',
        newsId: '1',
        userId: 'u1',
        userName: 'Sneha M.',
        userAvatar: 'https://i.pravatar.cc/100?img=1',
        content:
            'Thanks for the update! Took the alternate route and saved 30 mins.',
        likeCount: 12,
        createdAt: now.subtract(const Duration(minutes: 90)),
        updatedAt: now.subtract(const Duration(minutes: 90)),
      ),
      NewsComment(
        id: 'c2',
        newsId: '1',
        userId: 'u2',
        userName: 'Karthik B.',
        userAvatar: 'https://i.pravatar.cc/100?img=2',
        content: 'Still stuck here. When will this be cleared? 😤',
        likeCount: 8,
        createdAt: now.subtract(const Duration(minutes: 60)),
        updatedAt: now.subtract(const Duration(minutes: 60)),
      ),
      NewsComment(
        id: 'c3',
        newsId: '2',
        userId: 'u3',
        userName: 'Lakshmi P.',
        userAvatar: 'https://i.pravatar.cc/100?img=3',
        content: 'Finally! We needed this. The kids will love it! 🙌',
        likeCount: 23,
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
    ]);
  }
}
