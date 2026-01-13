// BUSINESS FEATURE 12: Business Verification Service
// Implement OTP-based business verification

import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BusinessVerificationService {
  static const String _verificationsKey = 'business_verifications';
  static const String _pendingOtpKey = 'pending_otp';

  /// Send OTP to phone number (simulated)
  static Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Generate 6-digit OTP
      final otp = _generateOtp();
      final verificationId = 'ver_${DateTime.now().millisecondsSinceEpoch}';

      // Store OTP for verification (in real app, this would be handled by SMS service)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_pendingOtpKey}_$verificationId',
        json.encode({
          'otp': otp,
          'phoneNumber': phoneNumber,
          'createdAt': DateTime.now().toIso8601String(),
          'expiresAt':
              DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        }),
      );

      // In development, print OTP for testing
      print('📱 OTP for $phoneNumber: $otp');

      return {
        'success': true,
        'verificationId': verificationId,
        'message': 'OTP sent to +91$phoneNumber',
        'devOtp': otp, // For development only - remove in production
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP: $e',
      };
    }
  }

  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(
    String verificationId,
    String userOtp,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('${_pendingOtpKey}_$verificationId');

      if (data == null) {
        return {
          'success': false,
          'message': 'Verification session expired. Please request a new OTP.',
        };
      }

      final otpData = json.decode(data) as Map<String, dynamic>;
      final storedOtp = otpData['otp'] as String;
      final expiresAt = DateTime.parse(otpData['expiresAt']);

      // Check expiry
      if (DateTime.now().isAfter(expiresAt)) {
        await prefs.remove('${_pendingOtpKey}_$verificationId');
        return {
          'success': false,
          'message': 'OTP has expired. Please request a new one.',
        };
      }

      // Verify OTP
      if (userOtp != storedOtp) {
        return {
          'success': false,
          'message': 'Invalid OTP. Please try again.',
        };
      }

      // OTP verified - clean up
      await prefs.remove('${_pendingOtpKey}_$verificationId');

      return {
        'success': true,
        'message': 'Phone number verified successfully!',
        'phoneNumber': otpData['phoneNumber'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Verification failed: $e',
      };
    }
  }

  /// Request business verification (admin approval)
  static Future<Map<String, dynamic>> requestVerification({
    required String userId,
    required String businessName,
    required String phoneNumber,
    required String businessCategory,
    required String city,
    String? documentUrl, // Optional document for verification
  }) async {
    try {
      final request = VerificationRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        businessName: businessName,
        phoneNumber: phoneNumber,
        businessCategory: businessCategory,
        city: city,
        documentUrl: documentUrl,
        status: VerificationStatus.pending,
        requestedAt: DateTime.now(),
      );

      // Store verification request
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_verificationsKey);
      List<dynamic> requests = [];
      if (data != null) {
        requests = json.decode(data) as List;
      }
      requests.add(request.toJson());
      await prefs.setString(_verificationsKey, json.encode(requests));

      return {
        'success': true,
        'request': request,
        'message':
            'Verification request submitted. You will be notified once approved.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit verification request: $e',
      };
    }
  }

  /// Get verification status for a user
  static Future<VerificationRequest?> getVerificationStatus(
      String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_verificationsKey);

    if (data == null) return null;

    final requests = (json.decode(data) as List)
        .map((r) => VerificationRequest.fromJson(r))
        .where((r) => r.userId == userId)
        .toList();

    if (requests.isEmpty) return null;

    // Return the latest request
    requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return requests.first;
  }

  /// Admin: Approve verification
  static Future<bool> approveVerification(String requestId) async {
    return _updateVerificationStatus(requestId, VerificationStatus.approved);
  }

  /// Admin: Reject verification
  static Future<bool> rejectVerification(
      String requestId, String reason) async {
    return _updateVerificationStatus(
      requestId,
      VerificationStatus.rejected,
      rejectionReason: reason,
    );
  }

  /// Admin: Get all pending verifications
  static Future<List<VerificationRequest>> getPendingVerifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_verificationsKey);

    if (data == null) return [];

    return (json.decode(data) as List)
        .map((r) => VerificationRequest.fromJson(r))
        .where((r) => r.status == VerificationStatus.pending)
        .toList();
  }

  /// Private helper to update verification status
  static Future<bool> _updateVerificationStatus(
    String requestId,
    VerificationStatus status, {
    String? rejectionReason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_verificationsKey);

    if (data == null) return false;

    final requests = (json.decode(data) as List)
        .map((r) => VerificationRequest.fromJson(r))
        .toList();

    final index = requests.indexWhere((r) => r.id == requestId);
    if (index == -1) return false;

    requests[index] = requests[index].copyWith(
      status: status,
      reviewedAt: DateTime.now(),
      rejectionReason: rejectionReason,
    );

    await prefs.setString(
      _verificationsKey,
      json.encode(requests.map((r) => r.toJson()).toList()),
    );

    return true;
  }

  /// Generate 6-digit OTP
  static String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}

/// Verification status enum
enum VerificationStatus {
  pending,
  approved,
  rejected,
}

/// Verification request model
class VerificationRequest {
  final String id;
  final String userId;
  final String businessName;
  final String phoneNumber;
  final String businessCategory;
  final String city;
  final String? documentUrl;
  final VerificationStatus status;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;

  VerificationRequest({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.phoneNumber,
    required this.businessCategory,
    required this.city,
    this.documentUrl,
    required this.status,
    required this.requestedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      id: json['id'],
      userId: json['userId'],
      businessName: json['businessName'],
      phoneNumber: json['phoneNumber'],
      businessCategory: json['businessCategory'],
      city: json['city'],
      documentUrl: json['documentUrl'],
      status: VerificationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VerificationStatus.pending,
      ),
      requestedAt: DateTime.parse(json['requestedAt']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'phoneNumber': phoneNumber,
      'businessCategory': businessCategory,
      'city': city,
      'documentUrl': documentUrl,
      'status': status.name,
      'requestedAt': requestedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  VerificationRequest copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? phoneNumber,
    String? businessCategory,
    String? city,
    String? documentUrl,
    VerificationStatus? status,
    DateTime? requestedAt,
    DateTime? reviewedAt,
    String? rejectionReason,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      businessCategory: businessCategory ?? this.businessCategory,
      city: city ?? this.city,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
