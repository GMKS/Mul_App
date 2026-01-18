import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/devotional_video_model.dart';

/// Service for uploading devotional videos to Supabase
/// Handles video upload, thumbnail upload, and database insertion
class DevotionalUploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  /// Upload a new devotional video
  /// Returns the created DevotionalVideo object
  Future<DevotionalVideo> uploadDevotionalVideo({
    required String title,
    required String deity,
    required String templeName,
    required File videoFile,
    required File thumbnailFile,
    required String language,
    required List<String> festivalTags,
    required double latitude,
    required double longitude,
    String distanceCategory = '0-100',
  }) async {
    try {
      // 1. Upload video file to Supabase Storage
      final videoFileName =
          'devotional_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final videoPath = await _uploadVideoFile(videoFile, videoFileName);

      // 2. Upload thumbnail to Supabase Storage
      final thumbnailFileName =
          'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final thumbnailPath =
          await _uploadThumbnail(thumbnailFile, thumbnailFileName);

      // 3. Generate video ID
      final videoId = 'dv_${DateTime.now().millisecondsSinceEpoch}';

      // 4. Insert video metadata into database
      final videoData = {
        'id': videoId,
        'title': title,
        'deity': deity,
        'temple_name': templeName,
        'video_url': videoPath,
        'thumbnail_url': thumbnailPath,
        'language': language,
        'festival_tags': festivalTags,
        'location': {'lat': latitude, 'lng': longitude},
        'distance_category': distanceCategory,
        'is_verified': false, // Admin needs to verify
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('devotional_videos').insert(videoData);

      // 5. Return the created video object
      return DevotionalVideo.fromJson(videoData);
    } catch (e) {
      throw Exception('Failed to upload devotional video: $e');
    }
  }

  /// Upload video file to Supabase Storage
  Future<String> _uploadVideoFile(File videoFile, String fileName) async {
    try {
      final bytes = await videoFile.readAsBytes();
      final path = 'devotional/videos/$fileName';

      await _supabase.storage.from('devotional-content').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'video/mp4',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl =
          _supabase.storage.from('devotional-content').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload video file: $e');
    }
  }

  /// Upload thumbnail to Supabase Storage
  Future<String> _uploadThumbnail(File thumbnailFile, String fileName) async {
    try {
      final bytes = await thumbnailFile.readAsBytes();
      final path = 'devotional/thumbnails/$fileName';

      await _supabase.storage.from('devotional-content').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl =
          _supabase.storage.from('devotional-content').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload thumbnail: $e');
    }
  }

  /// Pick video from device
  Future<File?> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10), // 10 min max
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick video: $e');
    }
  }

  /// Pick thumbnail image from device
  Future<File?> pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick thumbnail: $e');
    }
  }

  /// Record video using camera
  Future<File?> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to record video: $e');
    }
  }

  /// Get user's uploaded videos (pending verification)
  Future<List<DevotionalVideo>> getUserVideos(String userId) async {
    try {
      final response = await _supabase
          .from('devotional_videos')
          .select()
          .eq('uploaded_by', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DevotionalVideo.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user videos: $e');
    }
  }

  /// Delete a video (only if not verified)
  Future<void> deleteVideo(String videoId) async {
    try {
      await _supabase
          .from('devotional_videos')
          .delete()
          .eq('id', videoId)
          .eq('is_verified', false);
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }
}
