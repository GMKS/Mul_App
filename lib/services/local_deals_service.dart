/// Local Deals Service with Supabase Integration
/// Handles fetching, creating, and managing local deals with real-time updates

import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/local_deal_model.dart';

class LocalDealsService {
  static final LocalDealsService _instance = LocalDealsService._internal();
  factory LocalDealsService() => _instance;
  LocalDealsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Table names
  static const String _dealsTable = 'local_deals';
  static const String _claimsTable = 'deal_claims';
  static const String _categoriesTable = 'deal_categories';
  static const String _activeDealsView = 'active_deals_view';

  // Real-time subscription
  RealtimeChannel? _dealsChannel;
  final StreamController<List<LocalDeal>> _dealsStreamController =
      StreamController<List<LocalDeal>>.broadcast();

  /// Stream of deals for real-time updates
  Stream<List<LocalDeal>> get dealsStream => _dealsStreamController.stream;

  /// Initialize real-time subscription for deals
  /// Call this when the app starts or when entering deals screen
  void initializeRealtimeSubscription({String? city}) {
    _dealsChannel?.unsubscribe();

    _dealsChannel = _supabase
        .channel('local_deals_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _dealsTable,
          callback: (payload) {
            print('📢 Deal update received: ${payload.eventType}');
            // Refresh deals when any change occurs
            getActiveDeals(city: city).then((deals) {
              _dealsStreamController.add(deals);
            });
          },
        )
        .subscribe();

    print('🔔 Real-time subscription initialized for local deals');
  }

  /// Dispose real-time subscription
  void disposeRealtimeSubscription() {
    _dealsChannel?.unsubscribe();
    _dealsChannel = null;
    print('🔕 Real-time subscription disposed');
  }

  /// Get all active deals (optionally filtered by city)
  Future<List<LocalDeal>> getActiveDeals({
    String? city,
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from(_dealsTable) // Changed from _activeDealsView to _dealsTable
          .select()
          .eq('is_active', true)
          .eq('approval_status', 'approved')
          .gt('expires_at', DateTime.now().toIso8601String());

      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query
          .order('is_featured', ascending: false)
          .order('is_sponsored', ascending: false)
          .order('priority_rank', ascending: false)
          .order('expires_at', ascending: true)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => LocalDeal.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching deals: $e');
      return [];
    }
  }

  /// Get featured deals
  Future<List<LocalDeal>> getFeaturedDeals(
      {String? city, int limit = 5}) async {
    try {
      var query = _supabase
          .from(_dealsTable)
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .eq('approval_status', 'approved')
          .gt('expires_at', DateTime.now().toIso8601String());

      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      final response =
          await query.order('priority_rank', ascending: false).limit(limit);

      return (response as List)
          .map((json) => LocalDeal.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching featured deals: $e');
      return [];
    }
  }

  /// Get sponsored deals
  Future<List<LocalDeal>> getSponsoredDeals(
      {String? city, int limit = 5}) async {
    try {
      var query = _supabase
          .from(_dealsTable)
          .select()
          .eq('is_active', true)
          .eq('is_sponsored', true)
          .eq('approval_status', 'approved')
          .gt('expires_at', DateTime.now().toIso8601String());

      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      final response =
          await query.order('priority_rank', ascending: false).limit(limit);

      return (response as List)
          .map((json) => LocalDeal.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching sponsored deals: $e');
      return [];
    }
  }

  /// Get expiring soon deals (within 24 hours)
  Future<List<LocalDeal>> getExpiringSoonDeals(
      {String? city, int limit = 10}) async {
    try {
      final now = DateTime.now();
      final in24Hours = now.add(const Duration(hours: 24));

      var query = _supabase
          .from(_dealsTable)
          .select()
          .eq('is_active', true)
          .gt('expires_at', now.toIso8601String())
          .lt('expires_at', in24Hours.toIso8601String());

      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      final response =
          await query.order('expires_at', ascending: true).limit(limit);

      return (response as List)
          .map((json) => LocalDeal.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching expiring deals: $e');
      return [];
    }
  }

  /// Get deals by category
  Future<List<LocalDeal>> getDealsByCategory(String category,
      {String? city}) async {
    try {
      var query = _supabase
          .from(_dealsTable)
          .select()
          .eq('is_active', true)
          .eq('category', category)
          .gt('expires_at', DateTime.now().toIso8601String());

      if (city != null && city.isNotEmpty) {
        query = query.eq('city', city);
      }

      final response = await query
          .order('is_featured', ascending: false)
          .order('priority_rank', ascending: false);

      return (response as List)
          .map((json) => LocalDeal.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching deals by category: $e');
      return [];
    }
  }

  /// Get deal by ID
  Future<LocalDeal?> getDealById(String dealId) async {
    try {
      final response =
          await _supabase.from(_dealsTable).select().eq('id', dealId).single();

      // Increment view count
      await incrementDealViews(dealId);

      return LocalDeal.fromJson(response);
    } catch (e) {
      print('❌ Error fetching deal: $e');
      return null;
    }
  }

  /// Increment deal view count
  Future<void> incrementDealViews(String dealId) async {
    try {
      await _supabase.rpc('increment_deal_views', params: {'deal_id': dealId});
    } catch (e) {
      print('❌ Error incrementing views: $e');
    }
  }

  /// Claim a deal
  Future<Map<String, dynamic>> claimDeal(String dealId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'message': 'Please login to claim deals'};
      }

      final result = await _supabase.rpc(
        'claim_deal',
        params: {'p_deal_id': dealId, 'p_user_id': userId},
      );

      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      print('❌ Error claiming deal: $e');
      return {'success': false, 'message': 'Failed to claim deal: $e'};
    }
  }

  /// Get user's claimed deals
  Future<List<DealClaim>> getUserClaims() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from(_claimsTable)
          .select()
          .eq('user_id', userId)
          .order('claimed_at', ascending: false);

      return (response as List)
          .map((json) => DealClaim.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching user claims: $e');
      return [];
    }
  }

  /// Check if user has claimed a deal
  Future<bool> hasUserClaimedDeal(String dealId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from(_claimsTable)
          .select('id')
          .eq('deal_id', dealId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error checking claim status: $e');
      return false;
    }
  }

  /// Mark a claimed deal as redeemed
  Future<bool> markDealAsRedeemed(String dealId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
          .from(_claimsTable)
          .update({
            'is_redeemed': true,
            'redeemed_at': DateTime.now().toIso8601String(),
          })
          .eq('deal_id', dealId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('❌ Error marking deal as redeemed: $e');
      return false;
    }
  }

  /// Get all deal categories
  Future<List<DealCategory>> getCategories() async {
    try {
      final response = await _supabase
          .from(_categoriesTable)
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => DealCategory.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return [];
    }
  }

  /// Create a new deal (for business owners)
  Future<Map<String, dynamic>> createDeal(LocalDeal deal) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'success': false, 'message': 'Please login to create deals'};
      }

      final dealData = deal.toJson();
      dealData['created_by'] = userId;

      final response =
          await _supabase.from(_dealsTable).insert(dealData).select().single();

      return {
        'success': true,
        'message': 'Deal created successfully!',
        'deal': LocalDeal.fromJson(response),
      };
    } catch (e) {
      print('❌ Error creating deal: $e');
      return {'success': false, 'message': 'Failed to create deal: $e'};
    }
  }

  /// Update a deal
  Future<Map<String, dynamic>> updateDeal(
      String dealId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from(_dealsTable)
          .update(updates)
          .eq('id', dealId)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Deal updated successfully!',
        'deal': LocalDeal.fromJson(response),
      };
    } catch (e) {
      print('❌ Error updating deal: $e');
      return {'success': false, 'message': 'Failed to update deal: $e'};
    }
  }

  /// Delete a deal
  Future<bool> deleteDeal(String dealId) async {
    try {
      await _supabase.from(_dealsTable).delete().eq('id', dealId);
      return true;
    } catch (e) {
      print('❌ Error deleting deal: $e');
      return false;
    }
  }

  /// Get deals statistics (for admin dashboard)
  Future<Map<String, dynamic>> getDealsStatistics() async {
    try {
      final now = DateTime.now().toIso8601String();

      // Total active deals
      final activeResponse = await _supabase
          .from(_dealsTable)
          .select('id')
          .eq('is_active', true)
          .gt('expires_at', now);
      final activeCount = (activeResponse as List).length;

      // Total claims
      final claimsResponse = await _supabase.from(_claimsTable).select('id');
      final claimsCount = (claimsResponse as List).length;

      // Redeemed claims
      final redeemedResponse = await _supabase
          .from(_claimsTable)
          .select('id')
          .eq('is_redeemed', true);
      final redeemedCount = (redeemedResponse as List).length;

      // Sponsored deals
      final sponsoredResponse = await _supabase
          .from(_dealsTable)
          .select('id')
          .eq('is_active', true)
          .eq('is_sponsored', true)
          .gt('expires_at', now);
      final sponsoredCount = (sponsoredResponse as List).length;

      return {
        'active_deals': activeCount,
        'total_claims': claimsCount,
        'redeemed_claims': redeemedCount,
        'sponsored_deals': sponsoredCount,
        'redemption_rate': claimsCount > 0
            ? ((redeemedCount / claimsCount) * 100).toStringAsFixed(1)
            : '0',
      };
    } catch (e) {
      print('❌ Error fetching statistics: $e');
      return {};
    }
  }

  /// Search deals
  Future<List<LocalDeal>> searchDeals(String query, {String? city}) async {
    try {
      var searchQuery = _supabase
          .from(_dealsTable)
          .select()
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toIso8601String())
          .or('title.ilike.%$query%,description.ilike.%$query%,business_name.ilike.%$query%');

      if (city != null && city.isNotEmpty) {
        searchQuery = searchQuery.eq('city', city);
      }

      final response =
          await searchQuery.order('is_featured', ascending: false).limit(20);

      return (response as List)
          .map((json) => LocalDeal.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error searching deals: $e');
      return [];
    }
  }

  /// ADMIN: Get pending deals awaiting approval
  Future<List<LocalDeal>> getPendingDeals({int limit = 50}) async {
    try {
      final response = await _supabase
          .from(_dealsTable)
          .select()
          .eq('approval_status', 'pending')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => LocalDeal.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching pending deals: $e');
      return [];
    }
  }

  /// ADMIN: Approve a deal
  Future<Map<String, dynamic>> approveDeal(String dealId) async {
    try {
      await _supabase.from(_dealsTable).update({
        'approval_status': 'approved',
        'approved_at': DateTime.now().toIso8601String(),
      }).eq('id', dealId);

      return {
        'success': true,
        'message': 'Deal approved successfully!',
      };
    } catch (e) {
      print('❌ Error approving deal: $e');
      return {
        'success': false,
        'message': 'Failed to approve deal: $e',
      };
    }
  }

  /// ADMIN: Reject a deal
  Future<Map<String, dynamic>> rejectDeal(String dealId, String reason) async {
    try {
      await _supabase.from(_dealsTable).update({
        'approval_status': 'rejected',
        'rejection_reason': reason,
      }).eq('id', dealId);

      return {
        'success': true,
        'message': 'Deal rejected successfully!',
      };
    } catch (e) {
      print('❌ Error rejecting deal: $e');
      return {
        'success': false,
        'message': 'Failed to reject deal: $e',
      };
    }
  }

  /// Dispose resources
  void dispose() {
    disposeRealtimeSubscription();
    _dealsStreamController.close();
  }
}
