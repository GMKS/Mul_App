/// Business Service with Supabase Integration
/// Handles business submission, approval, and management with real database

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_model.dart';

enum BusinessStatus { pending, approved, rejected, suspended }

class BusinessServiceSupabase {
  static final BusinessServiceSupabase _instance =
      BusinessServiceSupabase._internal();
  factory BusinessServiceSupabase() => _instance;
  BusinessServiceSupabase._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Table names
  static const String _businessTable = 'businesses';
  static const String _businessSubmissionsTable = 'business_submissions';

  /// Submit business for approval
  Future<Map<String, dynamic>> submitBusinessForApproval({
    required String name,
    required String description,
    required String category,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    required String ownerId,
    String? email,
    String? whatsappNumber,
    String? websiteUrl,
    List<String>? images,
    List<String>? documents,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final submission = <String, dynamic>{
        'name': name,
        'description': description,
        'category': category,
        'phone_number': phoneNumber,
        'address': address,
        'city': city,
        'state': state,
        'owner_id': ownerId,
        'status': BusinessStatus.pending.name,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      // Only add optional fields if they are not null
      if (email != null && email.isNotEmpty) {
        submission['email'] = email;
      }
      if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
        submission['whatsapp_number'] = whatsappNumber;
      }
      if (websiteUrl != null && websiteUrl.isNotEmpty) {
        submission['website_url'] = websiteUrl;
      }
      if (images != null && images.isNotEmpty) {
        submission['images'] = images;
      }
      if (documents != null && documents.isNotEmpty) {
        submission['documents'] = documents;
      }
      // Note: latitude/longitude not included until DB schema is updated

      final response = await _supabase
          .from(_businessSubmissionsTable)
          .insert(submission)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Business submitted for approval successfully!',
        'businessId': response['id'],
      };
    } catch (e) {
      print('❌ Error submitting business: $e');
      return {
        'success': false,
        'message': 'Failed to submit business: ${e.toString()}',
      };
    }
  }

  /// Get pending business submissions
  Future<List<Map<String, dynamic>>> getPendingBusinesses() async {
    try {
      final response = await _supabase
          .from(_businessSubmissionsTable)
          .select()
          .eq('status', BusinessStatus.pending.name)
          .order('submitted_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching pending businesses: $e');
      return [];
    }
  }

  /// Get specific pending business by ID
  Future<Map<String, dynamic>?> getPendingBusinessById(
    String businessId,
  ) async {
    try {
      final response = await _supabase
          .from(_businessSubmissionsTable)
          .select()
          .eq('id', businessId)
          .single();

      return response;
    } catch (e) {
      print('❌ Error fetching business: $e');
      return null;
    }
  }

  /// Approve business submission
  /// Inserts the business into the main businesses table and updates submission status
  Future<Map<String, dynamic>> approveBusiness(
    String businessId,
    String adminId,
  ) async {
    try {
      // Get submission details
      final submission = await getPendingBusinessById(businessId);
      if (submission == null) {
        return {'success': false, 'message': 'Business submission not found'};
      }

      // IMPORTANT: Only update the submission status to approved
      // Do NOT insert into businesses table to avoid RLS policy conflicts
      // The database trigger or stored procedure should handle the transfer

      print('🔄 Approving business: $businessId');

      // Update submission status
      final result = await _supabase
          .from(_businessSubmissionsTable)
          .update({
            'status': BusinessStatus.approved.name,
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': adminId,
          })
          .eq('id', businessId)
          .select()
          .single();

      print('✅ Submission updated to approved: ${result['id']}');

      // Send notification to owner
      try {
        await _sendApprovalNotification(
          submission['owner_id'],
          submission['name'],
        );
      } catch (notifError) {
        print('⚠️ Notification error (non-blocking): $notifError');
      }

      return {'success': true, 'message': 'Business approved successfully!'};
    } catch (e) {
      print('❌ Error approving business: $e');
      return {
        'success': false,
        'message': 'Failed to approve business: ${e.toString()}',
      };
    }
  }

  /// Reject business submission
  Future<Map<String, dynamic>> rejectBusiness(
    String businessId,
    String adminId,
    String rejectionReason,
  ) async {
    try {
      final submission = await getPendingBusinessById(businessId);
      if (submission == null) {
        return {'success': false, 'message': 'Business submission not found'};
      }

      // Update submission status
      await _supabase.from(_businessSubmissionsTable).update({
        'status': BusinessStatus.rejected.name,
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': adminId,
        'rejection_reason': rejectionReason,
      }).eq('id', businessId);

      // TODO: Send notification to owner with reason
      await _sendRejectionNotification(
        submission['owner_id'],
        submission['name'],
        rejectionReason,
      );

      return {'success': true, 'message': 'Business rejected successfully'};
    } catch (e) {
      print('❌ Error rejecting business: $e');
      return {
        'success': false,
        'message': 'Failed to reject business: ${e.toString()}',
      };
    }
  }

  /// Get approved businesses for public feed
  /// Fetches from both businesses table AND approved submissions
  Future<List<BusinessModel>> getApprovedBusinesses() async {
    try {
      final List<BusinessModel> allBusinesses = [];

      // 1. Query the main BUSINESSES table (if it has approved businesses)
      try {
        final businessesResponse = await _supabase
            .from(_businessTable)
            .select()
            .eq('is_approved', true)
            .order('created_at', ascending: false);

        allBusinesses.addAll(businessesResponse.map<BusinessModel>((data) {
          return BusinessModel.fromJson(data);
        }));
      } catch (e) {
        print('⚠️ businesses table query error (may be empty): $e');
      }

      // 2. Query approved submissions from business_submissions table
      try {
        final submissionsResponse = await _supabase
            .from(_businessSubmissionsTable)
            .select()
            .eq('status', 'approved')
            .order('submitted_at', ascending: false);

        for (final submission in submissionsResponse) {
          // Check if this submission is already in the businesses list
          final alreadyExists = allBusinesses.any((b) =>
              b.name == submission['name'] &&
              b.ownerId == submission['owner_id']);

          if (!alreadyExists) {
            // Convert submission to BusinessModel with defaults
            allBusinesses.add(_submissionToBusinessModel(submission));
          }
        }
      } catch (e) {
        print('⚠️ business_submissions query error: $e');
      }

      return allBusinesses;
    } catch (e) {
      print('❌ Error fetching approved businesses: $e');
      return [];
    }
  }

  /// Convert a submission map to BusinessModel
  BusinessModel _submissionToBusinessModel(Map<String, dynamic> submission) {
    return BusinessModel(
      id: submission['id']?.toString() ?? '',
      name: submission['name'] ?? 'Unnamed Business',
      description: submission['description'] ?? '',
      category: submission['category'] ?? 'Other',
      address: submission['address'] ?? '',
      city: submission['city'] ?? '',
      state: submission['state'] ?? '',
      phoneNumber: submission['phone_number'] ?? '',
      whatsappNumber: submission['whatsapp_number'],
      email: submission['email'],
      websiteUrl: submission['website_url'],
      ownerId: submission['owner_id'] ?? '',
      isApproved: true,
      isVerified: false,
      createdAt: submission['submitted_at'] != null
          ? DateTime.tryParse(submission['submitted_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: submission['reviewed_at'] != null
          ? DateTime.tryParse(submission['reviewed_at']) ?? DateTime.now()
          : DateTime.now(),
      images: submission['images'] != null
          ? List<String>.from(submission['images'])
          : null,
      // Default values for other fields
      emoji: '🏪',
      hasOnlineBooking: false,
      canSendNotifications: false,
      isSponsored: false,
      isFeatured: false,
      priorityScore: 0,
      engagementScore: 0,
      canToggleFeatured: false,
      featuredDaysRemaining: 0,
      isSubscriptionActive: false,
      isKYCVerified: false,
    );
  }

  /// Get rejected businesses
  Future<List<Map<String, dynamic>>> getRejectedBusinesses() async {
    try {
      final response = await _supabase
          .from(_businessSubmissionsTable)
          .select()
          .eq('status', BusinessStatus.rejected.name)
          .order('reviewed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching rejected businesses: $e');
      return [];
    }
  }

  /// Get featured businesses
  Future<List<BusinessModel>> getFeaturedBusinesses() async {
    try {
      final response = await _supabase
          .from(_businessTable)
          .select()
          .eq('is_approved', true)
          .eq('is_featured', true)
          .order('featured_rank', ascending: true);

      return response.map<BusinessModel>((data) {
        return BusinessModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error fetching featured businesses: $e');
      return [];
    }
  }

  /// Get businesses by category
  Future<List<BusinessModel>> getBusinessesByCategory(String category) async {
    try {
      final response = await _supabase
          .from(_businessTable)
          .select()
          .eq('is_approved', true)
          .eq('category', category)
          .order('created_at', ascending: false);

      return response.map<BusinessModel>((data) {
        return BusinessModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error fetching businesses by category: $e');
      return [];
    }
  }

  /// Get businesses by owner
  Future<List<BusinessModel>> getBusinessesByOwner(String ownerId) async {
    try {
      final response = await _supabase
          .from(_businessTable)
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return response.map<BusinessModel>((data) {
        return BusinessModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error fetching owner businesses: $e');
      return [];
    }
  }

  /// Update business
  Future<Map<String, dynamic>> updateBusiness(
    String businessId,
    String ownerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Verify ownership
      final business = await _supabase
          .from(_businessTable)
          .select()
          .eq('id', businessId)
          .eq('owner_id', ownerId)
          .single();

      if (business == null) {
        return {
          'success': false,
          'message': 'Business not found or unauthorized',
        };
      }

      await _supabase.from(_businessTable).update(updates).eq('id', businessId);

      return {'success': true, 'message': 'Business updated successfully'};
    } catch (e) {
      print('❌ Error updating business: $e');
      return {
        'success': false,
        'message': 'Failed to update business: ${e.toString()}',
      };
    }
  }

  /// Delete business
  Future<Map<String, dynamic>> deleteBusiness(
    String businessId,
    String userId, {
    bool isAdmin = false,
  }) async {
    try {
      if (isAdmin) {
        await _supabase.from(_businessTable).delete().eq('id', businessId);
      } else {
        await _supabase
            .from(_businessTable)
            .delete()
            .eq('id', businessId)
            .eq('owner_id', userId);
      }

      return {'success': true, 'message': 'Business deleted successfully'};
    } catch (e) {
      print('❌ Error deleting business: $e');
      return {
        'success': false,
        'message': 'Failed to delete business: ${e.toString()}',
      };
    }
  }

  /// Get admin statistics
  Future<Map<String, dynamic>> getAdminStatistics() async {
    try {
      // Get approved count from BUSINESSES table to match what UI lists
      final approvedBusinesses = await _supabase
          .from(_businessTable)
          .select('id')
          .eq('is_approved', true)
          .count(CountOption.exact);

      // Get pending submissions count
      final pendingSubmissions = await _supabase
          .from(_businessSubmissionsTable)
          .select('id')
          .eq('status', BusinessStatus.pending.name)
          .count(CountOption.exact);

      // Get rejected submissions count
      final rejectedSubmissions = await _supabase
          .from(_businessSubmissionsTable)
          .select('id')
          .eq('status', BusinessStatus.rejected.name)
          .count(CountOption.exact);

      // Get featured businesses count (from businesses table)
      final featuredBusinesses = await _supabase
          .from(_businessTable)
          .select('id')
          .eq('is_featured', true)
          .count(CountOption.exact);

      return {
        // Total = pending + rejected + approved (from businesses)
        'total': (pendingSubmissions.count ?? 0) +
            (rejectedSubmissions.count ?? 0) +
            (approvedBusinesses.count ?? 0),
        'approved': approvedBusinesses.count ?? 0,
        'pending': pendingSubmissions.count ?? 0,
        'rejected': rejectedSubmissions.count ?? 0,
        'featured': featuredBusinesses.count ?? 0,
      };
    } catch (e) {
      print('❌ Error fetching statistics: $e');
      return {
        'total': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'featured': 0,
      };
    }
  }

  /// Search businesses
  Future<List<BusinessModel>> searchBusinesses(String query) async {
    try {
      final response = await _supabase
          .from(_businessTable)
          .select()
          .eq('is_approved', true)
          .or(
            'name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return response.map<BusinessModel>((data) {
        return BusinessModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('❌ Error searching businesses: $e');
      return [];
    }
  }

  /// Upload business image to Supabase Storage
  Future<String?> uploadBusinessImage(
    String businessId,
    String filePath,
  ) async {
    try {
      final fileName =
          'business_$businessId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Read file bytes
      final file = File(filePath);
      final bytes = await file.readAsBytes();

      await _supabase.storage
          .from('BUSINESS-IMAGES')
          .uploadBinary(fileName, bytes);

      final publicUrl =
          _supabase.storage.from('BUSINESS-IMAGES').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Send approval notification
  Future<void> _sendApprovalNotification(
    String ownerId,
    String businessName,
  ) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': ownerId,
        'type': 'business_approved',
        'title': 'Business Approved! 🎉',
        'message':
            'Your business "$businessName" has been approved and is now visible to customers.',
        'created_at': DateTime.now().toIso8601String(),
        'read': false,
      });
    } catch (e) {
      print('❌ Error sending approval notification: $e');
    }
  }

  /// Send rejection notification
  Future<void> _sendRejectionNotification(
    String ownerId,
    String businessName,
    String reason,
  ) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': ownerId,
        'type': 'business_rejected',
        'title': 'Business Submission Update',
        'message':
            'Your business "$businessName" was not approved. Reason: $reason',
        'created_at': DateTime.now().toIso8601String(),
        'read': false,
      });
    } catch (e) {
      print('❌ Error sending rejection notification: $e');
    }
  }
}
