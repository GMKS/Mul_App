import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessService {
  final supabase = Supabase.instance.client;

  // Get pending businesses
  Future<List<Map<String, dynamic>>> getPendingBusinesses() async {
    try {
      final response = await supabase
          .from('business_submissions')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      debugPrint('✅ Pending businesses fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching pending businesses: $e');
      return [];
    }
  }

  // Get approved businesses from businesses table
  Future<List<Map<String, dynamic>>> getApprovedBusinesses() async {
    try {
      final response = await supabase
          .from('businesses')
          .select('*')
          .eq('is_approved', true)
          .order('created_at', ascending: false);

      debugPrint('✅ Approved businesses raw response: $response');
      debugPrint('✅ Approved businesses count: ${response.length}');

      // Map to include status field
      final businesses = List<Map<String, dynamic>>.from(response.map((item) {
        return {
          ...item,
          'status': 'approved',
        };
      }));

      debugPrint('✅ Approved businesses mapped: ${businesses.length}');
      return businesses;
    } catch (e) {
      debugPrint('❌ Error fetching approved businesses: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      if (e is PostgrestException) {
        debugPrint('❌ Postgrest error code: ${e.code}');
        debugPrint('❌ Postgrest error message: ${e.message}');
        debugPrint('❌ Postgrest error details: ${e.details}');
      }
      return [];
    }
  }

  // Get rejected businesses
  Future<List<Map<String, dynamic>>> getRejectedBusinesses() async {
    try {
      final response = await supabase
          .from('business_submissions')
          .select()
          .eq('status', 'rejected')
          .order('created_at', ascending: false);

      debugPrint('✅ Rejected businesses fetched: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching rejected businesses: $e');
      return [];
    }
  }

  // Get admin statistics
  Future<Map<String, dynamic>?> getAdminStatistics() async {
    try {
      debugPrint('📊 Fetching statistics...');

      // Get submissions stats
      final submissions =
          await supabase.from('business_submissions').select('status');

      debugPrint('📊 Submissions data: ${submissions.length} records');

      // Get approved from businesses table
      final approved = await supabase
          .from('businesses')
          .select('id')
          .eq('is_approved', true);

      debugPrint('📊 Approved businesses: ${approved.length} records');

      final pending = submissions.where((s) => s['status'] == 'pending').length;
      final rejected =
          submissions.where((s) => s['status'] == 'rejected').length;
      final approvedCount = approved.length;

      final stats = {
        'total': approvedCount + pending + rejected,
        'approved': approvedCount,
        'pending': pending,
        'rejected': rejected,
      };

      debugPrint('📊 Final statistics: $stats');
      return stats;
    } catch (e) {
      debugPrint('❌ Error fetching statistics: $e');
      return null;
    }
  }

  // Approve a business
  Future<void> approveBusiness(String businessId) async {
    try {
      final user = supabase.auth.currentUser;

      await supabase.from('business_submissions').update({
        'status': 'approved',
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': user?.id,
      }).eq('id', businessId);

      debugPrint('✅ Business $businessId approved');
    } catch (e) {
      debugPrint('❌ Error approving business: $e');
      rethrow;
    }
  }

  // Reject a business
  Future<void> rejectBusiness(String businessId, String? reason) async {
    try {
      final user = supabase.auth.currentUser;

      final updateData = {
        'status': 'rejected',
        'reviewed_at': DateTime.now().toIso8601String(),
        'reviewed_by': user?.id,
      };

      if (reason != null && reason.isNotEmpty) {
        updateData['rejection_reason'] = reason;
      }

      await supabase
          .from('business_submissions')
          .update(updateData)
          .eq('id', businessId);

      debugPrint('✅ Business $businessId rejected');
    } catch (e) {
      debugPrint('❌ Error rejecting business: $e');
      rethrow;
    }
  }

  // Submit a new business
  Future<void> submitBusiness(Map<String, dynamic> businessData) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final submissionData = {
        ...businessData,
        'owner_id': user.id,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('business_submissions').insert(submissionData);

      debugPrint('✅ Business submitted successfully');
    } catch (e) {
      debugPrint('❌ Error submitting business: $e');
      rethrow;
    }
  }

  // Get user's submitted businesses
  Future<List<Map<String, dynamic>>> getUserSubmissions() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await supabase
          .from('business_submissions')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching user submissions: $e');
      return [];
    }
  }

  // Get all businesses (for public view)
  Future<List<Map<String, dynamic>>> getAllBusinesses() async {
    try {
      final response = await supabase
          .from('businesses')
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching all businesses: $e');
      return [];
    }
  }

  // Search businesses
  Future<List<Map<String, dynamic>>> searchBusinesses(String query) async {
    try {
      final response = await supabase
          .from('businesses')
          .select()
          .eq('is_approved', true)
          .or('name.ilike.%$query%,category.ilike.%$query%,city.ilike.%$query%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error searching businesses: $e');
      return [];
    }
  }

  // Get businesses by category
  Future<List<Map<String, dynamic>>> getBusinessesByCategory(
      String category) async {
    try {
      final response = await supabase
          .from('businesses')
          .select()
          .eq('is_approved', true)
          .eq('category', category)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('❌ Error fetching businesses by category: $e');
      return [];
    }
  }

  // Get business by ID
  Future<Map<String, dynamic>?> getBusinessById(String businessId) async {
    try {
      final response = await supabase
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();

      return response;
    } catch (e) {
      debugPrint('❌ Error fetching business by ID: $e');
      return null;
    }
  }

  // Upload business image
  Future<String?> uploadBusinessImage(String filePath, String fileName) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${user.id}/$timestamp-$fileName';

      await supabase.storage.from('business-images').upload(path, filePath);

      final imageUrl =
          supabase.storage.from('business-images').getPublicUrl(path);

      return imageUrl;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      return null;
    }
  }
}
