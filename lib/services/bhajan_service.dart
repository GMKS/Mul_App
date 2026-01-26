/// Bhajan Service
/// Service for Daily Bhajan feature with 2026+ capabilities
/// Supports streaming, AI recommendations, offline sync, live rooms

import 'dart:math';
import '../models/bhajan_model.dart';

class BhajanService {
  static final BhajanService _instance = BhajanService._internal();
  factory BhajanService() => _instance;
  BhajanService._internal();

  // Mock data stores
  final Set<String> _favoriteBhajans = {};
  final Map<String, Duration> _listeningProgress = {};
  final List<BhajanListeningHistory> _listeningHistory = [];

  // ==================== API METHODS ====================

  /// GET /bhajans - Get bhajans with filters
  /// Supports: category, mood, trending, language, deity, religion, festival
  Future<List<Bhajan>> getBhajans({
    BhajanCategory? category,
    BhajanMood? mood,
    BhajanType? type,
    String? language,
    String? deity,
    String? religion,
    String? festival,
    bool? trending,
    bool? featured,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var bhajans = _getMockBhajans();

    // Apply filters
    if (category != null) {
      bhajans = bhajans.where((b) => b.category == category).toList();
    }
    if (mood != null) {
      bhajans = bhajans.where((b) => b.mood == mood).toList();
    }
    if (type != null) {
      bhajans = bhajans.where((b) => b.type == type).toList();
    }
    if (language != null && language.isNotEmpty) {
      bhajans = bhajans
          .where((b) => b.language.toLowerCase() == language.toLowerCase())
          .toList();
    }
    if (deity != null && deity.isNotEmpty) {
      bhajans = bhajans
          .where((b) =>
              b.deity?.toLowerCase().contains(deity.toLowerCase()) ?? false)
          .toList();
    }
    if (religion != null && religion.isNotEmpty) {
      bhajans = bhajans
          .where((b) => b.religion?.toLowerCase() == religion.toLowerCase())
          .toList();
    }
    if (festival != null && festival.isNotEmpty) {
      bhajans = bhajans
          .where((b) =>
              b.festival?.toLowerCase().contains(festival.toLowerCase()) ??
              false)
          .toList();
    }
    if (trending == true) {
      bhajans = bhajans.where((b) => b.isTrending).toList();
    }
    if (featured == true) {
      bhajans = bhajans.where((b) => b.isFeatured).toList();
    }

    // Mark favorites
    bhajans = bhajans.map((b) {
      if (_favoriteBhajans.contains(b.id)) {
        return b.copyWith(isFavorite: true);
      }
      return b;
    }).toList();

    // Pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    if (startIndex >= bhajans.length) return [];
    return bhajans.sublist(
      startIndex,
      endIndex > bhajans.length ? bhajans.length : endIndex,
    );
  }

  /// GET /bhajans/{id} - Get bhajan by ID
  Future<Bhajan?> getBhajanById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final bhajans = _getMockBhajans();
    try {
      var bhajan = bhajans.firstWhere((b) => b.id == id);
      if (_favoriteBhajans.contains(bhajan.id)) {
        bhajan = bhajan.copyWith(isFavorite: true);
      }
      return bhajan;
    } catch (e) {
      return null;
    }
  }

  /// GET /bhajans/recommendations - AI-personalized recommendations
  Future<List<Bhajan>> getRecommendations({
    int limit = 10,
    String? basedOnBhajanId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final bhajans = _getMockBhajans();
    final random = Random();

    // Simulate AI recommendations based on listening history
    final recommended = bhajans.toList()..shuffle(random);
    return recommended.take(limit).map((b) {
      if (_favoriteBhajans.contains(b.id)) {
        return b.copyWith(isFavorite: true);
      }
      return b;
    }).toList();
  }

  /// GET /bhajans/today - Get today's divine picks (AI-curated)
  Future<List<Bhajan>> getTodaysDivinePicks() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    final bhajans = _getMockBhajans();

    // Morning: 4 AM - 12 PM
    // Evening: 5 PM - 9 PM
    // Default: General mix

    List<Bhajan> picks;
    if (now.hour >= 4 && now.hour < 12) {
      picks =
          bhajans.where((b) => b.category == BhajanCategory.morning).toList();
    } else if (now.hour >= 17 && now.hour < 21) {
      picks =
          bhajans.where((b) => b.category == BhajanCategory.evening).toList();
    } else {
      picks = bhajans.where((b) => b.isFeatured).toList();
    }

    if (picks.length < 5) {
      picks = bhajans.where((b) => b.isFeatured).take(10).toList();
    }

    return picks.map((b) {
      if (_favoriteBhajans.contains(b.id)) {
        return b.copyWith(isFavorite: true);
      }
      return b;
    }).toList();
  }

  /// GET /bhajans/trending - Get trending bhajans
  Future<List<Bhajan>> getTrendingBhajans({int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final bhajans = _getMockBhajans().where((b) => b.isTrending).toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));

    return bhajans.take(limit).map((b) {
      if (_favoriteBhajans.contains(b.id)) {
        return b.copyWith(isFavorite: true);
      }
      return b;
    }).toList();
  }

  /// GET /bhajans/search - Search bhajans
  Future<List<Bhajan>> searchBhajans(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final lowerQuery = query.toLowerCase();
    return _getMockBhajans().where((b) {
      return b.title.toLowerCase().contains(lowerQuery) ||
          (b.deity?.toLowerCase().contains(lowerQuery) ?? false) ||
          (b.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          b.tags.any((t) => t.toLowerCase().contains(lowerQuery));
    }).map((b) {
      if (_favoriteBhajans.contains(b.id)) {
        return b.copyWith(isFavorite: true);
      }
      return b;
    }).toList();
  }

  /// POST /bhajans - Upload bhajan (contributor)
  Future<BhajanUploadRequest> uploadBhajan({
    required String title,
    required String mediaUrl,
    required BhajanType type,
    required String language,
    required String uploadedBy,
    BhajanCategory category = BhajanCategory.general,
    List<String> tags = const [],
    String? deity,
    String? religion,
    String? description,
    String? lyricsText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Create upload request (goes through AI + human moderation)
    final request = BhajanUploadRequest(
      id: 'upload_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      mediaUrl: mediaUrl,
      type: type,
      language: language,
      uploadedBy: uploadedBy,
      category: category,
      tags: tags,
      deity: deity,
      religion: religion,
      description: description,
      lyricsText: lyricsText,
      status: UploadStatus.aiReview,
      submittedAt: DateTime.now(),
    );

    return request;
  }

  // ==================== FAVORITES & OFFLINE ====================

  /// Add to favorites
  Future<bool> addToFavorites(String bhajanId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favoriteBhajans.add(bhajanId);
    return true;
  }

  /// Remove from favorites
  Future<bool> removeFromFavorites(String bhajanId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favoriteBhajans.remove(bhajanId);
    return true;
  }

  /// Check if favorite
  bool isFavorite(String bhajanId) {
    return _favoriteBhajans.contains(bhajanId);
  }

  /// Get favorite bhajans
  Future<List<Bhajan>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _getMockBhajans()
        .where((b) => _favoriteBhajans.contains(b.id))
        .map((b) => b.copyWith(isFavorite: true))
        .toList();
  }

  /// Download for offline
  Future<bool> downloadForOffline(String bhajanId) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate download
    // In real app, download the file and store locally
    return true;
  }

  /// Get offline bhajans
  Future<List<Bhajan>> getOfflineBhajans() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In real app, return locally stored bhajans
    return [];
  }

  // ==================== PLAYLISTS ====================

  /// GET /playlists - Get AI-curated playlists
  Future<List<BhajanPlaylist>> getPlaylists() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockPlaylists();
  }

  /// GET /playlists/{id} - Get playlist by ID
  Future<BhajanPlaylist?> getPlaylistById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final playlists = _getMockPlaylists();
    try {
      return playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get morning ritual playlist
  Future<BhajanPlaylist> getMorningPlaylist() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final morningBhajans = _getMockBhajans()
        .where((b) => b.category == BhajanCategory.morning)
        .toList();

    return BhajanPlaylist(
      id: 'morning_ritual',
      name: 'Morning Divine Vibes 🌅',
      description: 'Start your day with divine blessings',
      coverImageUrl: 'https://picsum.photos/400/300?random=morning',
      bhajans: morningBhajans,
      playlistType: PlaylistType.morningRitual,
      isAiCurated: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get evening ritual playlist
  Future<BhajanPlaylist> getEveningPlaylist() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final eveningBhajans = _getMockBhajans()
        .where((b) => b.category == BhajanCategory.evening)
        .toList();

    return BhajanPlaylist(
      id: 'evening_ritual',
      name: 'Evening Aarti Collection 🪔',
      description: 'Sacred evening bhajans and aartis',
      coverImageUrl: 'https://picsum.photos/400/300?random=evening',
      bhajans: eveningBhajans,
      playlistType: PlaylistType.eveningRitual,
      isAiCurated: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ==================== LIVE BHAJAN ROOMS ====================

  /// GET /bhajans/live - Get live bhajan rooms
  Future<List<BhajanRoom>> getLiveBhajanRooms() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockLiveRooms();
  }

  /// Get room by ID
  Future<BhajanRoom?> getRoomById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final rooms = _getMockLiveRooms();
    try {
      return rooms.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a bhajan room
  Future<BhajanRoom> createRoom({
    required String name,
    required String description,
    required String hostId,
    required String hostName,
    String? hostAvatar,
    bool isPrivate = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return BhajanRoom(
      id: 'room_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      hostId: hostId,
      hostName: hostName,
      hostAvatar: hostAvatar,
      isLive: true,
      isPrivate: isPrivate,
      roomCode: isPrivate ? _generateRoomCode() : null,
      startedAt: DateTime.now(),
      participantCount: 1,
    );
  }

  /// Join a bhajan room
  Future<bool> joinRoom(String roomId, {String? roomCode}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  /// Leave a bhajan room
  Future<bool> leaveRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  String _generateRoomCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // ==================== LISTENING HISTORY ====================

  /// Record listening progress
  Future<void> recordListeningProgress(
      String bhajanId, Duration progress) async {
    _listeningProgress[bhajanId] = progress;
  }

  /// Get listening progress
  Duration? getListeningProgress(String bhajanId) {
    return _listeningProgress[bhajanId];
  }

  /// Get listening history
  Future<List<BhajanListeningHistory>> getListeningHistory({
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _listeningHistory.take(limit).toList();
  }

  /// Add to listening history
  Future<void> addToHistory(String bhajanId, Duration listenedDuration) async {
    final bhajan = await getBhajanById(bhajanId);
    _listeningHistory.insert(
      0,
      BhajanListeningHistory(
        id: 'history_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        bhajanId: bhajanId,
        bhajan: bhajan,
        listenedDuration: listenedDuration,
        listenedAt: DateTime.now(),
        completed: bhajan != null && listenedDuration >= bhajan.duration * 0.9,
      ),
    );
  }

  // ==================== COMMENTS ====================

  /// Get comments for a bhajan
  Future<List<BhajanComment>> getComments(String bhajanId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _getMockComments(bhajanId);
  }

  /// Add comment
  Future<BhajanComment> addComment({
    required String bhajanId,
    required String userId,
    required String userName,
    String? userAvatar,
    required String content,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return BhajanComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      bhajanId: bhajanId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  // ==================== MOCK DATA ====================

  List<Bhajan> _getMockBhajans() {
    final now = DateTime.now();
    final random = Random(42);

    return [
      // Morning Bhajans
      Bhajan(
        id: 'bhajan_1',
        title: 'Om Jai Jagdish Hare',
        mediaUrl: 'https://example.com/bhajan1.mp3',
        type: BhajanType.audio,
        language: 'hindi',
        uploadedBy: 'user_1',
        uploaderName: 'Divine Sounds',
        category: BhajanCategory.aarti,
        tags: ['aarti', 'vishnu', 'morning'],
        mood: BhajanMood.devotional,
        deity: 'Lord Vishnu',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan1',
        description: 'Traditional aarti sung in praise of Lord Vishnu',
        duration: const Duration(minutes: 5, seconds: 30),
        isTrending: true,
        isFeatured: true,
        playCount: random.nextInt(100000) + 50000,
        favoriteCount: random.nextInt(10000) + 5000,
        likeCount: random.nextInt(50000) + 20000,
        hasLyrics: true,
        hasSubtitles: true,
        availableQuality: StreamingQuality.hd,
        availableLanguages: ['hindi', 'english', 'telugu'],
        userRating: 4.8,
        ratingCount: 12500,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(days: 30)),
        approved: true,
      ),
      Bhajan(
        id: 'bhajan_2',
        title: 'Hanuman Chalisa',
        mediaUrl: 'https://example.com/bhajan2.mp4',
        type: BhajanType.video,
        language: 'hindi',
        uploadedBy: 'user_2',
        uploaderName: 'Bhakti Sangeet',
        category: BhajanCategory.chalisa,
        tags: ['chalisa', 'hanuman', 'morning', 'tuesday'],
        mood: BhajanMood.energetic,
        deity: 'Lord Hanuman',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan2',
        description:
            'Powerful Hanuman Chalisa with beautiful visuals and lyrics',
        duration: const Duration(minutes: 8, seconds: 45),
        isTrending: true,
        isFeatured: true,
        playCount: random.nextInt(500000) + 200000,
        favoriteCount: random.nextInt(50000) + 25000,
        likeCount: random.nextInt(100000) + 80000,
        hasLyrics: true,
        hasSubtitles: true,
        aiUpscaled: true,
        availableQuality: StreamingQuality.ultraHd,
        availableLanguages: ['hindi', 'english', 'tamil', 'telugu', 'kannada'],
        userRating: 4.9,
        ratingCount: 45000,
        createdAt: now.subtract(const Duration(days: 400)),
        updatedAt: now.subtract(const Duration(days: 7)),
        approved: true,
      ),
      Bhajan(
        id: 'bhajan_3',
        title: 'Suprabhatam - Morning Wake Up',
        mediaUrl: 'https://example.com/bhajan3.mp3',
        type: BhajanType.audio,
        language: 'sanskrit',
        uploadedBy: 'user_3',
        uploaderName: 'Temple Recordings',
        category: BhajanCategory.morning,
        tags: ['suprabhatam', 'morning', 'venkateshwara', 'tirupati'],
        mood: BhajanMood.peaceful,
        deity: 'Lord Venkateshwara',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan3',
        description:
            'Traditional Tirumala Suprabhatam to start your day with blessings',
        duration: const Duration(minutes: 12, seconds: 0),
        isTrending: false,
        isFeatured: true,
        playCount: random.nextInt(80000) + 30000,
        favoriteCount: random.nextInt(8000) + 4000,
        likeCount: random.nextInt(40000) + 15000,
        hasLyrics: true,
        hasSubtitles: true,
        availableQuality: StreamingQuality.spatialAudio,
        availableLanguages: ['sanskrit', 'telugu', 'hindi'],
        userRating: 4.7,
        ratingCount: 8500,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 15)),
        approved: true,
      ),
      // Evening Bhajans
      Bhajan(
        id: 'bhajan_4',
        title: 'Om Namah Shivaya - Evening Meditation',
        mediaUrl: 'https://example.com/bhajan4.mp3',
        type: BhajanType.audio,
        language: 'sanskrit',
        uploadedBy: 'user_4',
        uploaderName: 'Shiva Bhakti',
        category: BhajanCategory.mantra,
        tags: ['shiva', 'mantra', 'meditation', 'evening'],
        mood: BhajanMood.meditative,
        deity: 'Lord Shiva',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan4',
        description: '108 times Om Namah Shivaya for deep meditation',
        duration: const Duration(minutes: 25, seconds: 0),
        isTrending: true,
        isFeatured: false,
        playCount: random.nextInt(150000) + 70000,
        favoriteCount: random.nextInt(15000) + 8000,
        likeCount: random.nextInt(60000) + 30000,
        hasLyrics: true,
        availableQuality: StreamingQuality.spatialAudio,
        availableLanguages: ['sanskrit', 'hindi'],
        userRating: 4.9,
        ratingCount: 22000,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now.subtract(const Duration(days: 5)),
        approved: true,
      ),
      Bhajan(
        id: 'bhajan_5',
        title: 'Ganesh Aarti - Jai Ganesh Deva',
        mediaUrl: 'https://example.com/bhajan5.mp4',
        type: BhajanType.video,
        language: 'hindi',
        uploadedBy: 'user_5',
        uploaderName: 'Ganpati Bhakts',
        category: BhajanCategory.aarti,
        tags: ['ganesh', 'aarti', 'evening', 'wednesday'],
        mood: BhajanMood.celebratory,
        deity: 'Lord Ganesha',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan5',
        description: 'Joyful Ganesh Aarti with traditional visuals',
        duration: const Duration(minutes: 4, seconds: 15),
        isTrending: true,
        isFeatured: true,
        playCount: random.nextInt(200000) + 100000,
        favoriteCount: random.nextInt(20000) + 12000,
        likeCount: random.nextInt(80000) + 50000,
        hasLyrics: true,
        hasSubtitles: true,
        availableQuality: StreamingQuality.ultraHd,
        availableLanguages: ['hindi', 'marathi', 'gujarati'],
        userRating: 4.8,
        ratingCount: 35000,
        createdAt: now.subtract(const Duration(days: 100)),
        updatedAt: now.subtract(const Duration(days: 2)),
        approved: true,
      ),
      Bhajan(
        id: 'bhajan_6',
        title: 'Shri Krishna Govind Hare Murari',
        mediaUrl: 'https://example.com/bhajan6.mp3',
        type: BhajanType.audio,
        language: 'hindi',
        uploadedBy: 'user_6',
        uploaderName: 'Krishna Premi',
        category: BhajanCategory.evening,
        tags: ['krishna', 'bhajan', 'evening', 'soulful'],
        mood: BhajanMood.soulful,
        deity: 'Lord Krishna',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan6',
        description: 'Soulful Krishna bhajan for peaceful evenings',
        duration: const Duration(minutes: 6, seconds: 30),
        isTrending: false,
        isFeatured: true,
        playCount: random.nextInt(90000) + 40000,
        favoriteCount: random.nextInt(9000) + 5000,
        likeCount: random.nextInt(45000) + 20000,
        hasLyrics: true,
        availableQuality: StreamingQuality.hd,
        availableLanguages: ['hindi', 'gujarati'],
        userRating: 4.7,
        ratingCount: 12000,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now.subtract(const Duration(days: 20)),
        approved: true,
      ),
      // Festival Bhajans
      Bhajan(
        id: 'bhajan_7',
        title: 'Durga Chalisa - Navratri Special',
        mediaUrl: 'https://example.com/bhajan7.mp4',
        type: BhajanType.video,
        language: 'hindi',
        uploadedBy: 'user_7',
        uploaderName: 'Shakti Bhakti',
        category: BhajanCategory.chalisa,
        tags: ['durga', 'navratri', 'festival', 'chalisa'],
        mood: BhajanMood.energetic,
        festival: 'Navratri',
        deity: 'Maa Durga',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan7',
        description: 'Powerful Durga Chalisa for Navratri celebrations',
        duration: const Duration(minutes: 10, seconds: 0),
        isTrending: true,
        isFeatured: true,
        playCount: random.nextInt(180000) + 90000,
        favoriteCount: random.nextInt(18000) + 10000,
        likeCount: random.nextInt(70000) + 40000,
        hasLyrics: true,
        hasSubtitles: true,
        availableQuality: StreamingQuality.ultraHd,
        availableLanguages: ['hindi', 'bengali', 'gujarati'],
        userRating: 4.9,
        ratingCount: 28000,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 1)),
        approved: true,
      ),
      Bhajan(
        id: 'bhajan_8',
        title: 'Diwali Lakshmi Puja Mantra',
        mediaUrl: 'https://example.com/bhajan8.mp3',
        type: BhajanType.audio,
        language: 'sanskrit',
        uploadedBy: 'user_8',
        uploaderName: 'Vedic Chants',
        category: BhajanCategory.mantra,
        tags: ['lakshmi', 'diwali', 'festival', 'wealth'],
        mood: BhajanMood.peaceful,
        festival: 'Diwali',
        deity: 'Goddess Lakshmi',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan8',
        description: 'Auspicious Lakshmi mantras for Diwali prosperity',
        duration: const Duration(minutes: 15, seconds: 0),
        isTrending: false,
        isFeatured: true,
        playCount: random.nextInt(120000) + 60000,
        favoriteCount: random.nextInt(12000) + 7000,
        likeCount: random.nextInt(55000) + 30000,
        hasLyrics: true,
        availableQuality: StreamingQuality.spatialAudio,
        availableLanguages: ['sanskrit', 'hindi'],
        userRating: 4.8,
        ratingCount: 18000,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 10)),
        approved: true,
      ),
      // Kirtan & Bhakti
      Bhajan(
        id: 'bhajan_9',
        title: 'Hare Krishna Maha Mantra - ISKCON',
        mediaUrl: 'https://example.com/bhajan9.mp4',
        type: BhajanType.video,
        language: 'sanskrit',
        uploadedBy: 'user_9',
        uploaderName: 'ISKCON Bhakti',
        category: BhajanCategory.kirtan,
        tags: ['hare krishna', 'iskcon', 'kirtan', 'maha mantra'],
        mood: BhajanMood.uplifting,
        deity: 'Lord Krishna',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan9',
        description: 'Energetic Hare Krishna kirtan from ISKCON temple',
        duration: const Duration(minutes: 20, seconds: 0),
        isTrending: true,
        isFeatured: true,
        playCount: random.nextInt(250000) + 150000,
        favoriteCount: random.nextInt(25000) + 15000,
        likeCount: random.nextInt(100000) + 70000,
        hasLyrics: true,
        hasSubtitles: true,
        aiUpscaled: true,
        availableQuality: StreamingQuality.ultraHd,
        availableLanguages: ['sanskrit', 'english', 'hindi'],
        userRating: 4.9,
        ratingCount: 55000,
        createdAt: now.subtract(const Duration(days: 250)),
        updatedAt: now.subtract(const Duration(days: 3)),
        approved: true,
      ),
      Bhajan(
        id: 'bhajan_10',
        title: 'Gayatri Mantra - 108 Times',
        mediaUrl: 'https://example.com/bhajan10.mp3',
        type: BhajanType.audio,
        language: 'sanskrit',
        uploadedBy: 'user_10',
        uploaderName: 'Vedic Wisdom',
        category: BhajanCategory.mantra,
        tags: ['gayatri', 'mantra', 'morning', 'meditation'],
        mood: BhajanMood.meditative,
        deity: 'Gayatri Devi',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan10',
        description:
            'Sacred Gayatri Mantra chanted 108 times with proper rhythm',
        duration: const Duration(minutes: 30, seconds: 0),
        isTrending: true,
        isFeatured: true,
        playCount: random.nextInt(300000) + 180000,
        favoriteCount: random.nextInt(30000) + 20000,
        likeCount: random.nextInt(120000) + 90000,
        hasLyrics: true,
        hasSubtitles: true,
        availableQuality: StreamingQuality.spatialAudio,
        availableLanguages: ['sanskrit', 'hindi', 'english'],
        userRating: 5.0,
        ratingCount: 65000,
        createdAt: now.subtract(const Duration(days: 500)),
        updatedAt: now.subtract(const Duration(days: 1)),
        approved: true,
      ),
      // Morning category explicitly
      Bhajan(
        id: 'bhajan_11',
        title: 'Surya Namaskar Mantra',
        mediaUrl: 'https://example.com/bhajan11.mp4',
        type: BhajanType.video,
        language: 'sanskrit',
        uploadedBy: 'user_11',
        uploaderName: 'Yoga Bhakti',
        category: BhajanCategory.morning,
        tags: ['surya', 'morning', 'yoga', 'sun'],
        mood: BhajanMood.energetic,
        deity: 'Lord Surya',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan11',
        description: 'Sun Salutation mantras with guided yoga',
        duration: const Duration(minutes: 7, seconds: 0),
        isTrending: false,
        isFeatured: true,
        playCount: random.nextInt(60000) + 30000,
        favoriteCount: random.nextInt(6000) + 3000,
        likeCount: random.nextInt(30000) + 15000,
        hasLyrics: true,
        hasSubtitles: true,
        availableQuality: StreamingQuality.ultraHd,
        availableLanguages: ['sanskrit', 'hindi', 'english'],
        userRating: 4.7,
        ratingCount: 9000,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 8)),
        approved: true,
      ),
      Bhajan(
        id: 'bhajan_12',
        title: 'Vishnu Sahasranamam',
        mediaUrl: 'https://example.com/bhajan12.mp3',
        type: BhajanType.audio,
        language: 'sanskrit',
        uploadedBy: 'user_12',
        uploaderName: 'MS Subbulakshmi Tribute',
        category: BhajanCategory.stotram,
        tags: ['vishnu', 'sahasranamam', 'stotram', '1000 names'],
        mood: BhajanMood.devotional,
        deity: 'Lord Vishnu',
        religion: 'hinduism',
        coverImageUrl: 'https://picsum.photos/400/300?random=bhajan12',
        description: '1000 names of Lord Vishnu in traditional style',
        duration: const Duration(minutes: 35, seconds: 0),
        isTrending: false,
        isFeatured: true,
        playCount: random.nextInt(200000) + 100000,
        favoriteCount: random.nextInt(20000) + 12000,
        likeCount: random.nextInt(80000) + 50000,
        hasLyrics: true,
        hasSubtitles: true,
        aiUpscaled: true,
        availableQuality: StreamingQuality.hd,
        availableLanguages: ['sanskrit', 'tamil', 'telugu', 'kannada'],
        userRating: 4.9,
        ratingCount: 42000,
        createdAt: now.subtract(const Duration(days: 800)),
        updatedAt: now.subtract(const Duration(days: 14)),
        approved: true,
      ),
    ];
  }

  List<BhajanPlaylist> _getMockPlaylists() {
    final bhajans = _getMockBhajans();
    final now = DateTime.now();

    return [
      BhajanPlaylist(
        id: 'playlist_1',
        name: "Today's Divine Picks ✨",
        description: 'AI-curated bhajans based on your preferences',
        coverImageUrl: 'https://picsum.photos/400/300?random=playlist1',
        bhajans: bhajans.where((b) => b.isFeatured).take(8).toList(),
        playlistType: PlaylistType.aiCurated,
        isAiCurated: true,
        createdAt: now,
        updatedAt: now,
        followerCount: 25000,
      ),
      BhajanPlaylist(
        id: 'playlist_2',
        name: 'Morning Rituals 🌅',
        description: 'Start your day with divine blessings',
        coverImageUrl: 'https://picsum.photos/400/300?random=playlist2',
        bhajans:
            bhajans.where((b) => b.category == BhajanCategory.morning).toList(),
        playlistType: PlaylistType.morningRitual,
        isAiCurated: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        followerCount: 45000,
      ),
      BhajanPlaylist(
        id: 'playlist_3',
        name: 'Evening Sandhya 🪔',
        description: 'Sacred evening bhajans and aartis',
        coverImageUrl: 'https://picsum.photos/400/300?random=playlist3',
        bhajans: bhajans
            .where((b) =>
                b.category == BhajanCategory.evening ||
                b.category == BhajanCategory.aarti)
            .toList(),
        playlistType: PlaylistType.eveningRitual,
        isAiCurated: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
        followerCount: 38000,
      ),
      BhajanPlaylist(
        id: 'playlist_4',
        name: 'Trending Now 🔥',
        description: "What's popular this week",
        coverImageUrl: 'https://picsum.photos/400/300?random=playlist4',
        bhajans: bhajans.where((b) => b.isTrending).take(10).toList(),
        playlistType: PlaylistType.trending,
        isAiCurated: true,
        createdAt: now,
        updatedAt: now,
        followerCount: 62000,
      ),
      BhajanPlaylist(
        id: 'playlist_5',
        name: 'Deep Meditation 🧘',
        description: 'Mantras for peaceful meditation',
        coverImageUrl: 'https://picsum.photos/400/300?random=playlist5',
        bhajans: bhajans.where((b) => b.mood == BhajanMood.meditative).toList(),
        playlistType: PlaylistType.aiCurated,
        isAiCurated: true,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 5)),
        followerCount: 28000,
      ),
      BhajanPlaylist(
        id: 'playlist_6',
        name: 'Festival Specials 🎉',
        description: 'Bhajans for festivals and celebrations',
        coverImageUrl: 'https://picsum.photos/400/300?random=playlist6',
        bhajans: bhajans
            .where((b) =>
                b.category == BhajanCategory.festival || b.festival != null)
            .toList(),
        playlistType: PlaylistType.festivalSpecial,
        isAiCurated: true,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
        followerCount: 52000,
      ),
    ];
  }

  List<BhajanRoom> _getMockLiveRooms() {
    final bhajans = _getMockBhajans();
    final now = DateTime.now();
    final random = Random();

    return [
      BhajanRoom(
        id: 'room_1',
        name: 'Morning Bhajan Satsang',
        description: 'Daily morning bhajan session with devotees worldwide',
        hostId: 'host_1',
        hostName: 'Swami Ananda',
        hostAvatar: 'https://picsum.photos/100/100?random=host1',
        currentBhajan: bhajans.first,
        currentBhajanId: bhajans.first.id,
        participantCount: random.nextInt(200) + 50,
        isLive: true,
        startedAt: now.subtract(Duration(minutes: random.nextInt(60) + 15)),
      ),
      BhajanRoom(
        id: 'room_2',
        name: 'Krishna Kirtan Live',
        description: 'Join us for melodious Krishna bhajans',
        hostId: 'host_2',
        hostName: 'Radha Bhakti',
        hostAvatar: 'https://picsum.photos/100/100?random=host2',
        currentBhajan: bhajans[8], // Hare Krishna
        currentBhajanId: bhajans[8].id,
        participantCount: random.nextInt(300) + 100,
        isLive: true,
        startedAt: now.subtract(Duration(minutes: random.nextInt(45) + 10)),
      ),
      BhajanRoom(
        id: 'room_3',
        name: 'Shiva Bhajan Room',
        description: 'Mahadev devotees unite!',
        hostId: 'host_3',
        hostName: 'Om Namah Shivaya',
        hostAvatar: 'https://picsum.photos/100/100?random=host3',
        currentBhajan: bhajans[3], // Om Namah Shivaya
        currentBhajanId: bhajans[3].id,
        participantCount: random.nextInt(150) + 30,
        isLive: true,
        startedAt: now.subtract(Duration(minutes: random.nextInt(30) + 5)),
      ),
    ];
  }

  List<BhajanComment> _getMockComments(String bhajanId) {
    final now = DateTime.now();

    return [
      BhajanComment(
        id: 'comment_1',
        bhajanId: bhajanId,
        userId: 'user_1',
        userName: 'Devotee123',
        userAvatar: 'https://picsum.photos/50/50?random=user1',
        content: 'This bhajan brings so much peace to my soul. 🙏',
        likeCount: 156,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      BhajanComment(
        id: 'comment_2',
        bhajanId: bhajanId,
        userId: 'user_2',
        userName: 'SpiritualSeeker',
        content: 'I listen to this every morning. Beautiful rendition!',
        likeCount: 89,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      BhajanComment(
        id: 'comment_3',
        bhajanId: bhajanId,
        userId: 'user_3',
        userName: 'BhaktiYogi',
        userAvatar: 'https://picsum.photos/50/50?random=user3',
        content: 'Jai Ho! This is divine. 🙏🙏🙏',
        likeCount: 234,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
