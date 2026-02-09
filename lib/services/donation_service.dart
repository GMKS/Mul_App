/// Donation Service
/// Handles donation operations

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/donation_model.dart';

class DonationService {
  static final _supabase = Supabase.instance.client;

  // ========== INSTANCE METHODS (call static versions) ==========

  /// Get donation organizations by category (instance)
  Future<List<DonationOrganization>> getOrganizations({
    DonationCategory? category,
  }) async {
    return DonationService.getOrganizationsStatic(category: category);
  }

  /// Create a donation (instance)
  Future<Donation?> createDonation({
    required double amount,
    required DonationCategory category,
    required PaymentMethod paymentMethod,
    String? organizationId,
    String? organizationName,
    String? purpose,
    String? donorName,
    String? message,
  }) async {
    return DonationService.createDonationStatic(
      amount: amount,
      category: category,
      paymentMethod: paymentMethod,
      organizationId: organizationId,
      organizationName: organizationName,
      purpose: purpose,
      donorName: donorName,
      message: message,
    );
  }

  /// Get user's donation history (instance)
  Future<List<Donation>> getDonationHistory({
    DonationCategory? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return DonationService.getDonationHistoryStatic(
      category: category,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  // ========== STATIC METHODS ==========

  /// Get donation organizations by category (static)
  static Future<List<DonationOrganization>> getOrganizationsStatic({
    DonationCategory? category,
  }) async {
    try {
      var query = _supabase.from('donation_organizations').select();

      if (category != null) {
        query = query.eq('category', category.value);
      }

      final response = await query.eq('is_active', true);

      return (response as List)
          .map((json) => DonationOrganization.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching organizations: $e');
      return _getMockOrganizations(category);
    }
  }

  /// Create a donation (static)
  static Future<Donation?> createDonationStatic({
    required double amount,
    required DonationCategory category,
    required PaymentMethod paymentMethod,
    String? organizationId,
    String? organizationName,
    String? purpose,
    String? donorName,
    String? message,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final response = await _supabase
          .from('donations')
          .insert({
            'user_id': user.id,
            'amount': amount,
            'category': category.value,
            'payment_method': paymentMethod.value,
            'organization_id': organizationId,
            'organization_name': organizationName,
            'purpose': purpose,
            'donor_name': donorName,
            'message': message,
            'status': PaymentStatus.pending.value,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Donation.fromJson(response);
    } catch (e) {
      print('❌ Error creating donation: $e');
      return null;
    }
  }

  /// Update donation status
  static Future<bool> updateDonationStatus({
    required String donationId,
    required PaymentStatus status,
    String? transactionId,
  }) async {
    try {
      await _supabase.from('donations').update({
        'status': status.value,
        'transaction_id': transactionId,
        if (status == PaymentStatus.completed)
          'completed_at': DateTime.now().toIso8601String(),
      }).eq('id', donationId);

      return true;
    } catch (e) {
      print('❌ Error updating donation: $e');
      return false;
    }
  }

  /// Get user's donation history (static)
  static Future<List<Donation>> getDonationHistoryStatic({
    DonationCategory? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      var query = _supabase.from('donations').select().eq('user_id', user.id);

      if (category != null) {
        query = query.eq('category', category.value);
      }

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List).map((json) => Donation.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching donation history: $e');
      return _getMockDonations();
    }
  }

  /// Get total donations by user
  static Future<double> getTotalDonations() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 0;

      final response = await _supabase
          .from('donations')
          .select('amount')
          .eq('user_id', user.id)
          .eq('status', PaymentStatus.completed.value);

      double total = 0;
      for (var item in response) {
        total += (item['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('❌ Error calculating total: $e');
      return 0;
    }
  }

  /// Get mock organizations
  static List<DonationOrganization> _getMockOrganizations(
      DonationCategory? category) {
    final allOrgs = [
      DonationOrganization(
        id: 'org_1',
        name: 'Sri Venkateswara Temple Trust',
        description: 'Support temple maintenance and community services',
        emoji: '🛕',
        category: DonationCategory.religious,
        isVerified: true,
        totalRaised: 250000,
        donorCount: 1250,
      ),
      DonationOrganization(
        id: 'org_2',
        name: 'Local Church Fund',
        description: 'Support church activities and charity work',
        emoji: '⛪',
        category: DonationCategory.religious,
        isVerified: true,
        totalRaised: 85000,
        donorCount: 420,
      ),
      DonationOrganization(
        id: 'org_3',
        name: 'Community Development Fund',
        description: 'Building better infrastructure for our locality',
        emoji: '🏘️',
        category: DonationCategory.localCauses,
        isVerified: true,
        totalRaised: 500000,
        donorCount: 890,
      ),
      DonationOrganization(
        id: 'org_4',
        name: 'Clean Streets Initiative',
        description: 'Keep our locality clean and green',
        emoji: '🧹',
        category: DonationCategory.localCauses,
        isVerified: true,
        totalRaised: 75000,
        donorCount: 340,
      ),
      DonationOrganization(
        id: 'org_5',
        name: 'Flood Relief Fund',
        description: 'Help families affected by recent floods',
        emoji: '🚨',
        category: DonationCategory.emergencyHelp,
        isVerified: true,
        totalRaised: 1200000,
        donorCount: 3500,
      ),
      DonationOrganization(
        id: 'org_6',
        name: 'Medical Emergency Support',
        description: 'Help poor patients with medical expenses',
        emoji: '🏥',
        category: DonationCategory.emergencyHelp,
        isVerified: true,
        totalRaised: 450000,
        donorCount: 780,
      ),
      DonationOrganization(
        id: 'org_7',
        name: 'Education for All',
        description: 'Sponsor education for underprivileged children',
        emoji: '📚',
        category: DonationCategory.education,
        isVerified: true,
        totalRaised: 850000,
        donorCount: 1200,
      ),
      DonationOrganization(
        id: 'org_8',
        name: 'Green Earth Initiative',
        description: 'Plant trees and protect environment',
        emoji: '🌱',
        category: DonationCategory.environment,
        isVerified: true,
        totalRaised: 120000,
        donorCount: 560,
      ),
    ];

    if (category != null) {
      return allOrgs.where((org) => org.category == category).toList();
    }
    return allOrgs;
  }

  /// Get mock donations for testing
  static List<Donation> _getMockDonations() {
    return [
      Donation(
        id: 'don_1',
        userId: 'user_1',
        amount: 500,
        category: DonationCategory.religious,
        organizationName: 'Sri Venkateswara Temple Trust',
        paymentMethod: PaymentMethod.upi,
        status: PaymentStatus.completed,
        transactionId: 'TXN12345678',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Donation(
        id: 'don_2',
        userId: 'user_1',
        amount: 1000,
        category: DonationCategory.emergencyHelp,
        organizationName: 'Flood Relief Fund',
        paymentMethod: PaymentMethod.card,
        status: PaymentStatus.completed,
        transactionId: 'TXN23456789',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Donation(
        id: 'don_3',
        userId: 'user_1',
        amount: 250,
        category: DonationCategory.education,
        organizationName: 'Education for All',
        paymentMethod: PaymentMethod.upi,
        status: PaymentStatus.completed,
        transactionId: 'TXN34567890',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        completedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
}
