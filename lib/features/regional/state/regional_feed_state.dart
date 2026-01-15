/// Regional Feed State Management
/// Centralized state for the regional video feed with filters and pagination

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../services/regional_feed_service.dart';

/// Regional feed state notifier
class RegionalFeedState extends ChangeNotifier {
  // Services
  final RegionalFeedService _feedService = RegionalFeedService();

  // Feed states for each tab
  FeedState<RegionalVideo> _latestFeed = FeedState.initial();
  FeedState<RegionalVideo> _trendingFeed = FeedState.initial();

  // Current filter
  RegionalFeedFilter _filter = const RegionalFeedFilter();

  // Current tab
  RegionalFeedTab _currentTab = RegionalFeedTab.latest;

  // Available languages cache
  List<LanguageOption> _availableLanguages = LanguageOption.indianLanguages;

  // Cached results for performance
  final Map<String, PaginatedResponse<RegionalVideo>> _cache = {};

  // Refresh indicators
  bool _isRefreshing = false;

  // Getters
  FeedState<RegionalVideo> get latestFeed => _latestFeed;
  FeedState<RegionalVideo> get trendingFeed => _trendingFeed;
  RegionalFeedFilter get filter => _filter;
  RegionalFeedTab get currentTab => _currentTab;
  List<LanguageOption> get availableLanguages => _availableLanguages;
  bool get isRefreshing => _isRefreshing;

  /// Get current feed based on selected tab
  FeedState<RegionalVideo> get currentFeed {
    return _currentTab == RegionalFeedTab.latest ? _latestFeed : _trendingFeed;
  }

  /// Initialize state with user preferences
  Future<void> initialize({
    required String city,
    required String state,
    String? district,
    String? region,
  }) async {
    // Load persisted language preference
    final language = await _loadPersistedLanguage(state);

    _filter = RegionalFeedFilter.fromLocation(
      city: city,
      state: state,
      district: district,
      region: region,
      language: language,
      tab: _currentTab,
    );

    notifyListeners();

    // Load initial data
    await loadFeed(refresh: true);
  }

  /// Load persisted language or get default for state
  Future<String> _loadPersistedLanguage(String state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('regional_feed_language');

      if (savedLanguage != null) {
        return savedLanguage;
      }

      // Default to state language
      return LanguageOption.getDefaultLanguageForState(state);
    } catch (e) {
      return 'hi'; // Default to Hindi
    }
  }

  /// Persist language preference
  Future<void> _persistLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('regional_feed_language', language);
    } catch (e) {
      debugPrint('Failed to persist language: $e');
    }
  }

  /// Generate cache key for current filter
  String _getCacheKey(RegionalFeedTab tab, String? cursor) {
    return '${tab.name}_${_filter.city}_${_filter.language}_$cursor';
  }

  /// Load feed data
  Future<void> loadFeed({bool refresh = false}) async {
    if (_currentTab == RegionalFeedTab.latest) {
      await _loadLatestFeed(refresh: refresh);
    } else {
      await _loadTrendingFeed(refresh: refresh);
    }
  }

  /// Load latest videos
  Future<void> _loadLatestFeed({bool refresh = false}) async {
    if (_latestFeed.isLoading || _latestFeed.isLoadingMore) return;

    if (refresh) {
      _latestFeed =
          _latestFeed.copyWith(loadingState: FeedLoadingState.loading);
      notifyListeners();
    } else if (!_latestFeed.canLoadMore) {
      return;
    } else {
      _latestFeed = _latestFeed.startLoading();
      notifyListeners();
    }

    try {
      final cursor = refresh ? null : _latestFeed.cursor.cursor;
      final cacheKey = _getCacheKey(RegionalFeedTab.latest, cursor);

      // Check cache first
      PaginatedResponse<RegionalVideo>? response;
      if (!refresh && _cache.containsKey(cacheKey)) {
        response = _cache[cacheKey];
      } else {
        response = await _feedService.getLatestVideos(
          city: _filter.city,
          district: _filter.district,
          state: _filter.state,
          language: _filter.language,
          cursor: cursor,
        );

        // Cache response
        _cache[cacheKey] = response;
      }

      if (response != null) {
        if (refresh) {
          _latestFeed = _latestFeed.replaceItems(
            response.items,
            (v) => v.id,
            response.nextCursor,
            response.hasMore,
          );
        } else {
          _latestFeed = _latestFeed.addItems(
            response.items,
            (v) => v.id,
            response.nextCursor,
            response.hasMore,
          );
        }
      }
    } catch (e) {
      _latestFeed = _latestFeed.setError('Failed to load videos: $e');
    }

    notifyListeners();
  }

  /// Load trending videos
  Future<void> _loadTrendingFeed({bool refresh = false}) async {
    if (_trendingFeed.isLoading || _trendingFeed.isLoadingMore) return;

    if (refresh) {
      _trendingFeed =
          _trendingFeed.copyWith(loadingState: FeedLoadingState.loading);
      notifyListeners();
    } else if (!_trendingFeed.canLoadMore) {
      return;
    } else {
      _trendingFeed = _trendingFeed.startLoading();
      notifyListeners();
    }

    try {
      final cursor = refresh ? null : _trendingFeed.cursor.cursor;
      final cacheKey = _getCacheKey(RegionalFeedTab.trending, cursor);

      // Check cache first
      PaginatedResponse<RegionalVideo>? response;
      if (!refresh && _cache.containsKey(cacheKey)) {
        response = _cache[cacheKey];
      } else {
        response = await _feedService.getTrendingVideos(
          city: _filter.city,
          district: _filter.district,
          state: _filter.state,
          language: _filter.language,
          cursor: cursor,
        );

        // Cache response
        _cache[cacheKey] = response;
      }

      if (response != null) {
        if (refresh) {
          _trendingFeed = _trendingFeed.replaceItems(
            response.items,
            (v) => v.id,
            response.nextCursor,
            response.hasMore,
          );
        } else {
          _trendingFeed = _trendingFeed.addItems(
            response.items,
            (v) => v.id,
            response.nextCursor,
            response.hasMore,
          );
        }
      }
    } catch (e) {
      _trendingFeed =
          _trendingFeed.setError('Failed to load trending videos: $e');
    }

    notifyListeners();
  }

  /// Load more videos (pagination)
  Future<void> loadMore() async {
    await loadFeed(refresh: false);
  }

  /// Refresh feed (pull-to-refresh)
  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();

    // Clear cache for current filter
    _clearFilterCache();

    await loadFeed(refresh: true);

    _isRefreshing = false;
    notifyListeners();
  }

  /// Clear cache for current filter
  void _clearFilterCache() {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith('${_currentTab.name}_${_filter.city}'))
        .toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// Switch between Latest and Trending tabs
  Future<void> switchTab(RegionalFeedTab tab) async {
    if (_currentTab == tab) return;

    _currentTab = tab;
    _filter = _filter.copyWith(tab: tab);
    notifyListeners();

    // Load data for new tab if not already loaded
    if (currentFeed.loadingState == FeedLoadingState.initial) {
      await loadFeed(refresh: true);
    }
  }

  /// Update language filter
  Future<void> setLanguage(String language) async {
    if (_filter.language == language) return;

    _filter = _filter.copyWith(language: language);
    await _persistLanguage(language);

    // Reset both feeds
    _latestFeed = FeedState.initial();
    _trendingFeed = FeedState.initial();
    _clearFilterCache();

    notifyListeners();

    // Reload current feed
    await loadFeed(refresh: true);
  }

  /// Update city filter
  Future<void> setCity({
    required String city,
    required String state,
    String? district,
    String? region,
  }) async {
    if (_filter.city == city && _filter.district == district) return;

    _filter = _filter.copyWith(
      city: city,
      state: state,
      district: district,
      region: region,
    );

    // Reset both feeds
    _latestFeed = FeedState.initial();
    _trendingFeed = FeedState.initial();
    _cache.clear(); // Clear all cache on city change

    notifyListeners();

    // Reload current feed
    await loadFeed(refresh: true);
  }

  /// Update full filter
  Future<void> setFilter(RegionalFeedFilter newFilter) async {
    if (_filter == newFilter) return;

    final languageChanged = _filter.language != newFilter.language;
    final locationChanged = _filter.city != newFilter.city ||
        _filter.district != newFilter.district;

    _filter = newFilter;

    if (languageChanged && newFilter.language != null) {
      await _persistLanguage(newFilter.language!);
    }

    if (languageChanged || locationChanged) {
      // Reset feeds on filter change
      _latestFeed = FeedState.initial();
      _trendingFeed = FeedState.initial();
      _cache.clear();
    }

    notifyListeners();

    // Reload feed
    await loadFeed(refresh: true);
  }

  /// Clear all data
  void clearAll() {
    _latestFeed = FeedState.initial();
    _trendingFeed = FeedState.initial();
    _cache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _cache.clear();
    super.dispose();
  }
}
