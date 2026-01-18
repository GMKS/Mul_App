import 'dart:async';
import 'package:flutter/material.dart';
import '../models/devotional_video_model.dart';
import '../repositories/devotional_repository.dart';

/// Controller for managing devotional videos with real-time updates
class DevotionalController extends ChangeNotifier {
  final DevotionalRepository _repository = DevotionalRepository();

  List<DevotionalVideo> videos = [];
  bool isLoading = false;
  String? error;

  StreamSubscription? _videoStreamSubscription;

  // Filters
  String? selectedDeity;
  String? selectedLanguage;
  String? selectedFestivalTag;

  /// Load videos (one-time fetch)
  Future<void> loadVideos({
    String? deity,
    String? language,
    String? festivalTag,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      videos = await _repository.fetchDevotionalVideos(
        deity: deity,
        language: language,
        festivalTag: festivalTag,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Start real-time streaming of videos
  /// Automatically updates when new videos are uploaded
  void startRealtimeStream({
    String? deity,
    String? language,
    String? festivalTag,
  }) {
    selectedDeity = deity;
    selectedLanguage = language;
    selectedFestivalTag = festivalTag;

    isLoading = true;
    error = null;
    notifyListeners();

    // Cancel existing subscription
    _videoStreamSubscription?.cancel();

    // Start new stream
    _videoStreamSubscription = _repository
        .streamDevotionalVideos(
      deity: deity,
      language: language,
      festivalTag: festivalTag,
    )
        .listen(
      (updatedVideos) {
        videos = updatedVideos;
        isLoading = false;
        error = null;
        notifyListeners();
        debugPrint('📺 Real-time update: ${videos.length} videos received');
      },
      onError: (e) {
        error = e.toString();
        isLoading = false;
        notifyListeners();
        debugPrint('❌ Stream error: $e');
      },
    );
  }

  /// Stop real-time streaming
  void stopRealtimeStream() {
    _videoStreamSubscription?.cancel();
    _videoStreamSubscription = null;
  }

  /// Refresh videos manually
  Future<void> refresh() async {
    await loadVideos(
      deity: selectedDeity,
      language: selectedLanguage,
      festivalTag: selectedFestivalTag,
    );
  }

  /// Filter videos by deity
  void filterByDeity(String? deity) {
    selectedDeity = deity;
    startRealtimeStream(
      deity: deity,
      language: selectedLanguage,
      festivalTag: selectedFestivalTag,
    );
  }

  /// Filter videos by language
  void filterByLanguage(String? language) {
    selectedLanguage = language;
    startRealtimeStream(
      deity: selectedDeity,
      language: language,
      festivalTag: selectedFestivalTag,
    );
  }

  /// Filter videos by festival tag
  void filterByFestivalTag(String? tag) {
    selectedFestivalTag = tag;
    startRealtimeStream(
      deity: selectedDeity,
      language: selectedLanguage,
      festivalTag: tag,
    );
  }

  /// Clear all filters
  void clearFilters() {
    selectedDeity = null;
    selectedLanguage = null;
    selectedFestivalTag = null;
    startRealtimeStream();
  }

  @override
  void dispose() {
    _videoStreamSubscription?.cancel();
    super.dispose();
  }
}
