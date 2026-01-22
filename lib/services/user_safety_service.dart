/// User Safety Service
/// Handles blocking users, muting keywords, and trust system

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_safety_model.dart';

class UserSafetyService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ===== BLOCK USER FEATURES =====

  /// Block a user
  static Future<void> blockUser({
    required String userId,
    required String blockedUserId,
    required String blockedUserName,
    String? blockedUserAvatar,
    String reason = 'User preference',
  }) async {
    final block = BlockedUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      blockedUserId: blockedUserId,
      blockedUserName: blockedUserName,
      blockedUserAvatar: blockedUserAvatar,
      reason: reason,
      blockedAt: DateTime.now(),
    );

    // TODO: Save to Supabase
    // await _supabase.from('blocked_users').insert(block.toJson());
  }

  /// Unblock a user
  static Future<void> unblockUser({
    required String userId,
    required String blockedUserId,
  }) async {
    // TODO: Update in Supabase
    // await _supabase.from('blocked_users')
    //   .update({'is_active': false})
    //   .eq('user_id', userId)
    //   .eq('blocked_user_id', blockedUserId);
  }

  /// Get all blocked users for a user
  static Future<List<BlockedUser>> getBlockedUsers(String userId) async {
    // TODO: Fetch from Supabase
    // final response = await _supabase.from('blocked_users')
    //   .select()
    //   .eq('user_id', userId)
    //   .eq('is_active', true)
    //   .order('blocked_at', ascending: false);
    // return (response as List).map((json) => BlockedUser.fromJson(json)).toList();

    // Mock data for now
    return _getMockBlockedUsers(userId);
  }

  /// Check if user is blocked
  static Future<bool> isUserBlocked({
    required String userId,
    required String checkUserId,
  }) async {
    final blockedUsers = await getBlockedUsers(userId);
    return blockedUsers.any((block) => block.blockedUserId == checkUserId);
  }

  // ===== MUTE KEYWORDS FEATURES =====

  /// Add muted keyword
  static Future<void> addMutedKeyword({
    required String userId,
    required String keyword,
  }) async {
    final mutedKeyword = MutedKeyword(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      keyword: keyword.toLowerCase().trim(),
      createdAt: DateTime.now(),
    );

    // TODO: Save to Supabase
    // await _supabase.from('muted_keywords').insert(mutedKeyword.toJson());
  }

  /// Remove muted keyword
  static Future<void> removeMutedKeyword({
    required String userId,
    required String keywordId,
  }) async {
    // TODO: Update in Supabase
    // await _supabase.from('muted_keywords')
    //   .update({'is_active': false})
    //   .eq('id', keywordId)
    //   .eq('user_id', userId);
  }

  /// Get all muted keywords for a user
  static Future<List<MutedKeyword>> getMutedKeywords(String userId) async {
    // TODO: Fetch from Supabase
    // final response = await _supabase.from('muted_keywords')
    //   .select()
    //   .eq('user_id', userId)
    //   .eq('is_active', true)
    //   .order('created_at', ascending: false);
    // return (response as List).map((json) => MutedKeyword.fromJson(json)).toList();

    // Mock data for now
    return _getMockMutedKeywords(userId);
  }

  /// Check if content should be hidden based on muted keywords
  static Future<bool> shouldHideContent({
    required String userId,
    required String contentText,
  }) async {
    final keywords = await getMutedKeywords(userId);
    final lowerContent = contentText.toLowerCase();

    for (final keyword in keywords) {
      if (lowerContent.contains(keyword.displayKeyword)) {
        return true;
      }
    }
    return false;
  }

  /// Filter content list based on blocks and mutes
  static Future<List<T>> filterContent<T>({
    required String userId,
    required List<T> content,
    required String Function(T) getContentOwnerId,
    required String Function(T) getContentText,
  }) async {
    final blockedUsers = await getBlockedUsers(userId);
    final mutedKeywords = await getMutedKeywords(userId);

    return content.where((item) {
      // Check if owner is blocked
      final ownerId = getContentOwnerId(item);
      if (blockedUsers.any((block) => block.blockedUserId == ownerId)) {
        return false;
      }

      // Check if content contains muted keywords
      final text = getContentText(item).toLowerCase();
      for (final keyword in mutedKeywords) {
        if (text.contains(keyword.displayKeyword)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ===== TRUST SYSTEM FEATURES =====

  /// Get user trust level
  static Future<UserTrustLevel> getUserTrustLevel(String userId) async {
    // TODO: Fetch from Supabase
    // final response = await _supabase.from('user_trust_levels')
    //   .select()
    //   .eq('user_id', userId)
    //   .single();
    // return UserTrustLevel.fromJson(response);

    // Mock data for now
    return UserTrustLevel(
      userId: userId,
      validReports: 8,
      invalidReports: 2,
      helpfulVotes: 15,
      trustBadge: TrustBadge.newUser,
    );
  }

  /// Update trust level after report resolution
  static Future<void> updateTrustLevel({
    required String userId,
    required bool reportWasValid,
  }) async {
    final currentLevel = await getUserTrustLevel(userId);

    final updatedLevel = UserTrustLevel(
      userId: userId,
      validReports: reportWasValid
          ? currentLevel.validReports + 1
          : currentLevel.validReports,
      invalidReports: !reportWasValid
          ? currentLevel.invalidReports + 1
          : currentLevel.invalidReports,
      helpfulVotes: currentLevel.helpfulVotes,
      trustBadge: _calculateTrustBadge(
        reportWasValid
            ? currentLevel.validReports + 1
            : currentLevel.validReports,
      ),
    );

    // TODO: Save to Supabase
    // await _supabase.from('user_trust_levels').upsert(updatedLevel.toJson());
  }

  static TrustBadge _calculateTrustBadge(int validReports) {
    if (validReports >= 200) return TrustBadge.communityMod;
    if (validReports >= 50) return TrustBadge.powerUser;
    if (validReports >= 10) return TrustBadge.trusted;
    return TrustBadge.newUser;
  }

  // ===== MOCK DATA =====

  static List<BlockedUser> _getMockBlockedUsers(String userId) {
    return [
      BlockedUser(
        id: '1',
        userId: userId,
        blockedUserId: 'user_spam_1',
        blockedUserName: 'SpamAccount123',
        reason: 'Spam content',
        blockedAt: DateTime.now().subtract(Duration(days: 5)),
      ),
      BlockedUser(
        id: '2',
        userId: userId,
        blockedUserId: 'user_troll_2',
        blockedUserName: 'TrollUser',
        reason: 'Harassment',
        blockedAt: DateTime.now().subtract(Duration(days: 12)),
      ),
    ];
  }

  static List<MutedKeyword> _getMockMutedKeywords(String userId) {
    return [
      MutedKeyword(
        id: '1',
        userId: userId,
        keyword: 'politics',
        createdAt: DateTime.now().subtract(Duration(days: 30)),
      ),
      MutedKeyword(
        id: '2',
        userId: userId,
        keyword: 'spam',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
      ),
    ];
  }
}
