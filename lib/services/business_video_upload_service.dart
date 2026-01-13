// BUSINESS FEATURE 4: Business Video Upload Service
// Service for BUSINESS users to upload short videos with product metadata

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/business_video_model.dart';
import '../models/user_model.dart';

class BusinessVideoUploadService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick video from gallery or camera
  static Future<File?> pickVideo({bool fromCamera = false}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(seconds: 60), // Max 60 seconds
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  /// Pick thumbnail image
  static Future<File?> pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 1280,
        imageQuality: 80,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking thumbnail: $e');
      return null;
    }
  }

  /// Check if user can upload more videos based on plan
  static bool canUpload(UserProfile user, int currentMonthUploads) {
    if (!user.isBusinessUser) return false;

    final limit = user.uploadLimit;
    if (limit == -1) return true; // Unlimited for PRO

    return currentMonthUploads < limit;
  }

  /// Get remaining uploads for the month
  static int getRemainingUploads(UserProfile user, int currentMonthUploads) {
    if (!user.isBusinessUser) return 0;

    final limit = user.uploadLimit;
    if (limit == -1) return 999; // Unlimited

    return (limit - currentMonthUploads).clamp(0, limit);
  }

  /// Upload video with metadata (simulated)
  static Future<Map<String, dynamic>> uploadVideo({
    required File videoFile,
    File? thumbnailFile,
    required String productName,
    required double price,
    String? offerTag,
    required String description,
    required List<String> hashtags,
    required UserProfile businessUser,
  }) async {
    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      // In real implementation:
      // 1. Upload video to cloud storage (Firebase Storage, AWS S3, etc.)
      // 2. Upload thumbnail if provided
      // 3. Save metadata to database

      // Generate mock URLs
      final videoId = 'bv_${DateTime.now().millisecondsSinceEpoch}';
      final videoUrl = 'https://storage.example.com/videos/$videoId.mp4';
      final thumbnailUrl = thumbnailFile != null
          ? 'https://storage.example.com/thumbnails/$videoId.jpg'
          : 'https://picsum.photos/400/700?random=${videoId.hashCode}';

      final businessVideo = BusinessVideo(
        id: videoId,
        ownerId: businessUser.id,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        productName: productName,
        price: price,
        offerTag: offerTag,
        businessName: businessUser.businessName ?? '',
        businessCategory: businessUser.businessCategory ?? '',
        city: businessUser.city,
        area: businessUser.area ?? '',
        phoneNumber: businessUser.phoneNumber ?? '',
        whatsappNumber: businessUser.whatsappNumber ?? '',
        createdAt: DateTime.now(),
        hashtags: hashtags,
        description: description,
      );

      return {
        'success': true,
        'video': businessVideo,
        'message': 'Video uploaded successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload video: $e',
      };
    }
  }

  /// Validate video before upload
  static Map<String, dynamic> validateVideo(File videoFile) {
    final fileSizeInMB = videoFile.lengthSync() / (1024 * 1024);

    if (fileSizeInMB > 100) {
      return {
        'valid': false,
        'message': 'Video size must be less than 100MB',
      };
    }

    final extension = videoFile.path.split('.').last.toLowerCase();
    final validExtensions = ['mp4', 'mov', 'avi', 'mkv'];

    if (!validExtensions.contains(extension)) {
      return {
        'valid': false,
        'message': 'Invalid video format. Supported: MP4, MOV, AVI, MKV',
      };
    }

    return {'valid': true};
  }

  /// Get upload progress (for real implementation with streams)
  static Stream<double> getUploadProgress() {
    // Simulated progress stream
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (count) => (count + 1) / 20,
    ).take(20);
  }
}

/// Video upload status
enum UploadStatus {
  idle,
  picking,
  validating,
  uploading,
  processing,
  completed,
  failed,
}

/// Upload progress data
class UploadProgress {
  final UploadStatus status;
  final double progress;
  final String message;

  UploadProgress({
    required this.status,
    this.progress = 0.0,
    this.message = '',
  });
}
