/// Video Controller Pool
/// Manages and reuses video controllers for optimal performance
/// Implements lazy loading and efficient memory management

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Pool of video controllers for efficient reuse
class VideoControllerPool {
  static final VideoControllerPool _instance = VideoControllerPool._internal();
  factory VideoControllerPool() => _instance;
  VideoControllerPool._internal();

  // Maximum number of controllers to keep in memory
  static const int _maxPoolSize = 5;

  // Active controllers
  final Map<String, _PooledController> _controllers = {};

  // Currently visible video index
  int _currentIndex = 0;

  // Preload range (how many videos to preload ahead/behind)
  static const int _preloadRange = 1;

  /// Sample video URLs for demo (mapped by hash for consistent results)
  static const List<String> _sampleVideos = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  ];

  /// Get actual video URL
  String _getActualVideoUrl(String providedUrl) {
    // If it's a local file (user uploaded), return as is
    if (providedUrl.startsWith('file://') || providedUrl.startsWith('/')) {
      return providedUrl;
    }

    // If it's already a valid URL (http/https), return as is
    if (providedUrl.startsWith('http://') ||
        providedUrl.startsWith('https://')) {
      return providedUrl;
    }

    // For demo purposes only - map unknown URLs to sample videos
    final index = providedUrl.hashCode.abs() % _sampleVideos.length;
    return _sampleVideos[index];
  }

  /// Get or create controller for a video
  Future<VideoPlayerController?> getController(
    String videoId,
    String videoUrl,
  ) async {
    // Check if controller already exists
    if (_controllers.containsKey(videoId)) {
      final pooled = _controllers[videoId]!;
      pooled.lastAccessed = DateTime.now();
      return pooled.controller;
    }

    // Create new controller
    try {
      final actualUrl = _getActualVideoUrl(videoUrl);

      // Create controller based on URL type
      final VideoPlayerController controller;
      if (actualUrl.startsWith('file://')) {
        // Local file - remove file:// prefix for VideoPlayerController.file
        final filePath = actualUrl.substring(7);
        controller = VideoPlayerController.file(
          File(Uri.parse(actualUrl).toFilePath()),
        );
      } else if (actualUrl.startsWith('/')) {
        // Absolute file path
        controller = VideoPlayerController.file(File(actualUrl));
      } else {
        // Network URL
        controller = VideoPlayerController.networkUrl(
          Uri.parse(actualUrl),
        );
      }

      await controller.initialize();
      controller.setLooping(true);

      // Add to pool
      _controllers[videoId] = _PooledController(
        controller: controller,
        videoId: videoId,
        lastAccessed: DateTime.now(),
      );

      // Clean up old controllers if needed
      _cleanupOldControllers();

      return controller;
    } catch (e) {
      debugPrint('Failed to create controller for $videoId: $e');
      return null;
    }
  }

  /// Preload controller (initialize but don't play)
  Future<void> preloadController(String videoId, String videoUrl) async {
    if (_controllers.containsKey(videoId)) return;

    try {
      final actualUrl = _getActualVideoUrl(videoUrl);
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(actualUrl),
      );

      await controller.initialize();
      controller.setLooping(true);

      _controllers[videoId] = _PooledController(
        controller: controller,
        videoId: videoId,
        lastAccessed: DateTime.now(),
        isPreloaded: true,
      );

      _cleanupOldControllers();
    } catch (e) {
      debugPrint('Failed to preload controller for $videoId: $e');
    }
  }

  /// Update current visible index and manage controllers
  void updateVisibleIndex(
    int index,
    List<String> videoIds,
    List<String> videoUrls,
  ) {
    _currentIndex = index;

    // Preload videos in range
    for (int i = index - _preloadRange; i <= index + _preloadRange; i++) {
      if (i >= 0 && i < videoIds.length && i != index) {
        preloadController(videoIds[i], videoUrls[i]);
      }
    }

    // Pause videos outside range
    _pauseOutOfRangeVideos(index, videoIds);
  }

  /// Pause videos that are outside the visible range
  void _pauseOutOfRangeVideos(int currentIndex, List<String> videoIds) {
    for (final entry in _controllers.entries) {
      final videoIndex = videoIds.indexOf(entry.key);
      if (videoIndex != -1) {
        final distance = (videoIndex - currentIndex).abs();
        if (distance > _preloadRange) {
          entry.value.controller.pause();
        }
      }
    }
  }

  /// Clean up old controllers to stay within pool size
  void _cleanupOldControllers() {
    if (_controllers.length <= _maxPoolSize) return;

    // Sort by last accessed time
    final entries = _controllers.entries.toList()
      ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));

    // Remove oldest controllers
    final toRemove = entries.take(_controllers.length - _maxPoolSize);
    for (final entry in toRemove) {
      entry.value.controller.dispose();
      _controllers.remove(entry.key);
    }
  }

  /// Play video at index
  void playVideo(String videoId) {
    final pooled = _controllers[videoId];
    if (pooled != null) {
      pooled.controller.play();
      pooled.lastAccessed = DateTime.now();
    }
  }

  /// Pause video
  void pauseVideo(String videoId) {
    _controllers[videoId]?.controller.pause();
  }

  /// Pause all videos
  void pauseAll() {
    for (final pooled in _controllers.values) {
      pooled.controller.pause();
    }
  }

  /// Resume video
  void resumeVideo(String videoId) {
    _controllers[videoId]?.controller.play();
  }

  /// Check if controller is initialized
  bool isInitialized(String videoId) {
    return _controllers[videoId]?.controller.value.isInitialized ?? false;
  }

  /// Check if video is playing
  bool isPlaying(String videoId) {
    return _controllers[videoId]?.controller.value.isPlaying ?? false;
  }

  /// Dispose specific controller
  void disposeController(String videoId) {
    final pooled = _controllers.remove(videoId);
    pooled?.controller.dispose();
  }

  /// Dispose all controllers
  void disposeAll() {
    for (final pooled in _controllers.values) {
      pooled.controller.dispose();
    }
    _controllers.clear();
  }

  /// Get controller directly (for external use)
  VideoPlayerController? getExistingController(String videoId) {
    return _controllers[videoId]?.controller;
  }

  /// Get pool stats for debugging
  Map<String, dynamic> getPoolStats() {
    return {
      'poolSize': _controllers.length,
      'maxPoolSize': _maxPoolSize,
      'currentIndex': _currentIndex,
      'controllers': _controllers.keys.toList(),
    };
  }
}

/// Internal class to track pooled controllers
class _PooledController {
  final VideoPlayerController controller;
  final String videoId;
  DateTime lastAccessed;
  bool isPreloaded;

  _PooledController({
    required this.controller,
    required this.videoId,
    required this.lastAccessed,
    this.isPreloaded = false,
  });
}
