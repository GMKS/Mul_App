/// Donation Model
/// Model for donations and donation history

import 'package:flutter/material.dart';

class Donation {
  final String id;
  final String userId;
  final String? userName;
  final String? donorName;
  final String? message;
  final double amount;
  final DonationCategory category;
  final String? purpose;
  final String? organizationName;
  final String? organizationId;
  final PaymentMethod paymentMethod;
  final PaymentStatus status;
  final String? transactionId;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime? completedAt;

  Donation({
    required this.id,
    required this.userId,
    this.userName,
    this.donorName,
    this.message,
    required this.amount,
    required this.category,
    this.purpose,
    this.organizationName,
    this.organizationId,
    required this.paymentMethod,
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.receiptUrl,
    required this.createdAt,
    this.completedAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'],
      donorName: json['donor_name'],
      message: json['message'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: DonationCategory.fromString(json['category']),
      purpose: json['purpose'],
      organizationName: json['organization_name'],
      organizationId: json['organization_id'],
      paymentMethod: PaymentMethod.fromString(json['payment_method']),
      status: PaymentStatus.fromString(json['status']),
      transactionId: json['transaction_id'],
      receiptUrl: json['receipt_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'donor_name': donorName,
      'message': message,
      'amount': amount,
      'category': category.value,
      'purpose': purpose,
      'organization_name': organizationName,
      'organization_id': organizationId,
      'payment_method': paymentMethod.value,
      'status': status.value,
      'transaction_id': transactionId,
      'receipt_url': receiptUrl,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

/// Donation categories
enum DonationCategory {
  religious(
      'religious', 'Religious', '🙏', 'Temples, Churches, Mosques', 0xFFFF9800),
  localCauses(
      'local_causes', 'Local Causes', '🏘️', 'Community projects', 0xFF4CAF50),
  emergencyHelp(
      'emergency_help', 'Emergency Help', '🚨', 'Urgent relief', 0xFFF44336),
  education('education', 'Education', '📚', 'Schools & students', 0xFF2196F3),
  healthcare('healthcare', 'Healthcare', '🏥', 'Medical aid', 0xFFE91E63),
  environment(
      'environment', 'Environment', '🌱', 'Green initiatives', 0xFF8BC34A);

  final String value;
  final String label;
  final String emoji;
  final String description;
  final int _colorValue;

  const DonationCategory(
      this.value, this.label, this.emoji, this.description, this._colorValue);

  /// Display name alias for label
  String get displayName => label;

  /// Get color
  Color get color => Color(_colorValue);

  static DonationCategory fromString(String? value) {
    switch (value) {
      case 'religious':
        return DonationCategory.religious;
      case 'local_causes':
        return DonationCategory.localCauses;
      case 'emergency_help':
        return DonationCategory.emergencyHelp;
      case 'education':
        return DonationCategory.education;
      case 'healthcare':
        return DonationCategory.healthcare;
      case 'environment':
        return DonationCategory.environment;
      default:
        return DonationCategory.localCauses;
    }
  }
}

/// Payment methods
enum PaymentMethod {
  upi('upi', 'UPI', '📱', Icons.qr_code, 'Pay using UPI apps', 0xFF9C27B0),
  card(
      'card', 'Card', '💳', Icons.credit_card, 'Credit/Debit card', 0xFF2196F3),
  netBanking('net_banking', 'Net Banking', '🏦', Icons.account_balance,
      'Internet banking', 0xFF4CAF50),
  wallet('wallet', 'Wallet', '👛', Icons.account_balance_wallet,
      'Digital wallets', 0xFFFF9800);

  final String value;
  final String label;
  final String emoji;
  final IconData _iconData;
  final String _desc;
  final int _colorValue;

  const PaymentMethod(this.value, this.label, this.emoji, this._iconData,
      this._desc, this._colorValue);

  /// Display name alias for label
  String get displayName => label;

  /// Get icon
  IconData get icon => _iconData;

  /// Get description
  String get description => _desc;

  /// Get color
  Color get color => Color(_colorValue);

  static PaymentMethod fromString(String? value) {
    switch (value) {
      case 'upi':
        return PaymentMethod.upi;
      case 'card':
        return PaymentMethod.card;
      case 'net_banking':
        return PaymentMethod.netBanking;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.upi;
    }
  }
}

/// Payment status
enum PaymentStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  refunded('refunded', 'Refunded');

  final String value;
  final String label;

  const PaymentStatus(this.value, this.label);

  /// Display name alias for label
  String get displayName => label;

  static PaymentStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

/// Donation Organization
class DonationOrganization {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final DonationCategory category;
  final String? imageUrl;
  final String? address;
  final bool isVerified;
  final double totalRaised;
  final int donorCount;
  final double? campaignGoal;

  DonationOrganization({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    this.imageUrl,
    this.address,
    this.isVerified = false,
    this.totalRaised = 0,
    this.donorCount = 0,
    this.campaignGoal,
  });

  /// Alias for donorCount
  int get totalDonors => donorCount;

  factory DonationOrganization.fromJson(Map<String, dynamic> json) {
    return DonationOrganization(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '🙏',
      category: DonationCategory.fromString(json['category']),
      imageUrl: json['image_url'],
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      totalRaised: (json['total_raised'] as num?)?.toDouble() ?? 0.0,
      donorCount: json['donor_count'] ?? 0,
      campaignGoal: (json['campaign_goal'] as num?)?.toDouble(),
    );
  }
}
