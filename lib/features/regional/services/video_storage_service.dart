/// Video Storage Service
/// Handles local storage of user-posted videos for demo purposes
/// In production, this would integrate with Supabase Storage

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class VideoStorageService {
  static const String _videosKey = 'user_posted_videos';

  /// Save a posted video to local storage
  static Future<bool> savePostedVideo({
    required String videoPath,
    required String title,
    required String description,
    required String city,
    required String state,
    required String language,
    String? creatorName,
    String? creatorAvatar,
    List<String>? hashtags,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing videos
      final videosJson = prefs.getString(_videosKey);
      final List<Map<String, dynamic>> videos = videosJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(videosJson))
          : [];

      // Create new video entry
      final newVideo = {
        'id': 'user_video_${DateTime.now().millisecondsSinceEpoch}',
        'videoUrl': 'file://$videoPath', // Use file:// protocol for local files
        'thumbnailUrl':
            'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/700',
        'title': title,
        'description': description,
        'language': language,
        'category': 'Regional',
        'region': _getRegionForState(state),
        'state': state,
        'city': city,
        'creatorId': 'current_user',
        'creatorName': creatorName ?? 'You',
        'creatorAvatar': creatorAvatar ?? 'https://i.pravatar.cc/150?img=99',
        'isVerifiedCreator': false,
        'likes': 0,
        'comments': 0,
        'shares': 0,
        'views': 0,
        'watchTime': 0.0,
        'replays': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'hashtags': hashtags ?? [],
        'isBoosted': false,
      };

      // Add to list
      videos.insert(0, newVideo); // Add at beginning

      // Save back to storage
      await prefs.setString(_videosKey, jsonEncode(videos));

      return true;
    } catch (e) {
      print('Error saving video: $e');
      return false;
    }
  }

  /// Get all user-posted videos
  static Future<List<RegionalVideo>> getPostedVideos({
    String? city,
    String? state,
    String? language,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videosJson = prefs.getString(_videosKey);

      if (videosJson == null) return [];

      final List<dynamic> videosData = jsonDecode(videosJson);
      final videos = videosData
          .map((json) => RegionalVideo.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter by location and language if provided
      return videos.where((video) {
        if (city != null && video.city != city) return false;
        if (state != null && video.state != state) return false;
        if (language != null && video.language != language) return false;
        return true;
      }).toList();
    } catch (e) {
      print('Error loading videos: $e');
      return [];
    }
  }

  /// Delete a posted video
  static Future<bool> deleteVideo(String videoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final videosJson = prefs.getString(_videosKey);

      if (videosJson == null) return false;

      final List<dynamic> videosData = jsonDecode(videosJson);
      videosData.removeWhere((json) => json['id'] == videoId);

      await prefs.setString(_videosKey, jsonEncode(videosData));
      return true;
    } catch (e) {
      print('Error deleting video: $e');
      return false;
    }
  }

  /// Clear all posted videos
  static Future<bool> clearAllVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_videosKey);
      return true;
    } catch (e) {
      print('Error clearing videos: $e');
      return false;
    }
  }

  static String _getRegionForState(String state) {
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
}
