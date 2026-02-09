/// Community Post Service
/// Handles CRUD operations for community posts

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_post_model.dart';
import 'region_service.dart';
import 'dart:io';

class CommunityPostService {
  static final _supabase = Supabase.instance.client;

  /// Create a new post
  static Future<CommunityPost?> createPost({
    required String content,
    required PostCategory category,
    List<File>? images,
    File? video,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get user's locality
      final regionData = await RegionService.getStoredRegion();
      final locality = regionData['village'] ?? regionData['city'] ?? 'Unknown';
      final city = regionData['city'] ?? '';
      final state = regionData['state'] ?? '';

      // Upload images if any
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          final fileName =
              '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${images.indexOf(image)}.jpg';
          await _supabase.storage.from('post_images').upload(fileName, image);
          final url =
              _supabase.storage.from('post_images').getPublicUrl(fileName);
          imageUrls.add(url);
        }
      }

      // Upload video if any
      String? videoUrl;
      if (video != null) {
        final fileName =
            '${user.id}/${DateTime.now().millisecondsSinceEpoch}.mp4';
        await _supabase.storage.from('post_videos').upload(fileName, video);
        videoUrl = _supabase.storage.from('post_videos').getPublicUrl(fileName);
      }

      // Get user profile
      final profileResponse = await _supabase
          .from('profiles')
          .select('name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      // Insert post
      final response = await _supabase
          .from('community_posts')
          .insert({
            'user_id': user.id,
            'user_name': profileResponse?['name'] ?? 'Anonymous',
            'user_avatar': profileResponse?['avatar_url'],
            'content': content,
            'image_urls': imageUrls,
            'video_url': videoUrl,
            'category': category.value,
            'locality': locality,
            'city': city,
            'state': state,
            'is_approved': true,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return CommunityPost.fromJson(response);
    } catch (e) {
      print('❌ Error creating post: $e');
      return null;
    }
  }

  /// Get posts by locality
  static Future<List<CommunityPost>> getPostsByLocality({
    String? locality,
    String? city,
    PostCategory? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Get user's locality if not provided
      if (locality == null && city == null) {
        final regionData = await RegionService.getStoredRegion();
        locality = regionData['village'];
        city = regionData['city'];
      }

      var query =
          _supabase.from('community_posts').select().eq('is_approved', true);

      // Filter by locality or city
      if (locality != null && locality.isNotEmpty) {
        query = query.eq('locality', locality);
      } else if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      // Filter by category
      if (category != null && category != PostCategory.general) {
        query = query.eq('category', category.value);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => CommunityPost.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching posts: $e');
      return _getMockPosts();
    }
  }

  /// Like a post
  static Future<bool> likePost(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Check if already liked
      final existing = await _supabase
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) {
        // Unlike
        await _supabase
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);

        // Decrement count
        await _supabase.rpc('decrement_likes', params: {'p_id': postId});
        return false;
      } else {
        // Like
        await _supabase.from('post_likes').insert({
          'post_id': postId,
          'user_id': user.id,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Increment count
        await _supabase.rpc('increment_likes', params: {'p_id': postId});
        return true;
      }
    } catch (e) {
      print('❌ Error liking post: $e');
      return false;
    }
  }

  /// Add comment to post
  static Future<PostComment?> addComment(String postId, String content) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final profileResponse = await _supabase
          .from('profiles')
          .select('name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      final response = await _supabase
          .from('post_comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'user_name': profileResponse?['name'] ?? 'Anonymous',
            'user_avatar': profileResponse?['avatar_url'],
            'content': content,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Increment comment count
      await _supabase.rpc('increment_comments', params: {'p_id': postId});

      return PostComment.fromJson(response);
    } catch (e) {
      print('❌ Error adding comment: $e');
      return null;
    }
  }

  /// Get comments for a post
  static Future<List<PostComment>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('post_comments')
          .select()
          .eq('post_id', postId)
          .eq('is_flagged', false)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => PostComment.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching comments: $e');
      return [];
    }
  }

  /// Flag a post/comment for moderation
  static Future<bool> flagContent(
      String contentId, String contentType, String reason) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('content_flags').insert({
        'content_id': contentId,
        'content_type': contentType,
        'user_id': user.id,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('❌ Error flagging content: $e');
      return false;
    }
  }

  /// Get mock posts for testing
  static List<CommunityPost> _getMockPosts() {
    return [
      CommunityPost(
        id: 'post_1',
        userId: 'user_1',
        userName: 'Ramesh Kumar',
        content:
            'Road repair work started near main market. Traffic may be slow for the next few days. Please use alternate routes. 🚧',
        category: PostCategory.localIssues,
        locality: 'Ameerpet',
        city: 'Hyderabad',
        likesCount: 24,
        commentsCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: 'post_2',
        userId: 'user_2',
        userName: 'Sunita Devi',
        content:
            'Lost: Brown wallet near Bus Stand yesterday evening. Contains important documents. Please contact if found. Reward offered. 🙏',
        category: PostCategory.lostAndFound,
        locality: 'Kukatpally',
        city: 'Hyderabad',
        likesCount: 45,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: 'post_3',
        userId: 'user_3',
        userName: 'Community Welfare',
        userAvatar: '🏆',
        content:
            'Our locality won the Best Clean Area award! Thanks to everyone who participated in the cleanliness drive. Let\'s keep it up! 🎉',
        category: PostCategory.achievements,
        locality: 'Gachibowli',
        city: 'Hyderabad',
        likesCount: 156,
        commentsCount: 28,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CommunityPost(
        id: 'post_4',
        userId: 'user_4',
        userName: 'Anand Rao',
        content:
            'Free health checkup camp this Sunday at Community Hall from 9 AM to 2 PM. All residents are welcome. Bring your Aadhaar card.',
        category: PostCategory.events,
        locality: 'Madhapur',
        city: 'Hyderabad',
        likesCount: 89,
        commentsCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CommunityPost(
        id: 'post_5',
        userId: 'user_5',
        userName: 'Lakshmi',
        content:
            'Need volunteers for teaching underprivileged children every weekend. One hour of your time can change a life. Contact me if interested.',
        category: PostCategory.communityHelp,
        locality: 'Begumpet',
        city: 'Hyderabad',
        likesCount: 67,
        commentsCount: 22,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
