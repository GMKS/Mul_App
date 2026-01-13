// BUSINESS FEATURE 9: Subscription Plans Service
// Implement business subscription plans: FREE, BASIC, PRO

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class BusinessSubscriptionService {
  static const String _subscriptionKey = 'business_subscription';

  /// Subscription plan details
  static final Map<BusinessPlanType, SubscriptionPlan> plans = {
    BusinessPlanType.free: SubscriptionPlan(
      type: BusinessPlanType.free,
      name: 'Free',
      price: 0,
      uploadLimit: 3,
      features: [
        '3 video uploads per month',
        'Basic analytics',
        'Call & WhatsApp buttons',
        'Local visibility',
      ],
      restrictions: [
        'No video boosting',
        'Limited reach',
        'No priority support',
      ],
    ),
    BusinessPlanType.basic: SubscriptionPlan(
      type: BusinessPlanType.basic,
      name: 'Basic',
      price: 299,
      uploadLimit: 10,
      features: [
        '10 video uploads per month',
        'Advanced analytics',
        'Call & WhatsApp buttons',
        'City-wide visibility',
        '1 video boost per month',
        'Priority in local feed',
      ],
      restrictions: [
        'Limited boost duration',
      ],
    ),
    BusinessPlanType.pro: SubscriptionPlan(
      type: BusinessPlanType.pro,
      name: 'Pro',
      price: 999,
      uploadLimit: -1, // Unlimited
      features: [
        'Unlimited video uploads',
        'Full analytics dashboard',
        'Call & WhatsApp buttons',
        'State-wide visibility',
        '5 video boosts per month',
        'Priority support',
        'Verified badge',
        'Featured in explore',
      ],
      restrictions: [],
    ),
  };

  /// Get current subscription for a user
  static Future<UserSubscription?> getSubscription(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('${_subscriptionKey}_$userId');

    if (data == null) return null;

    return UserSubscription.fromJson(json.decode(data));
  }

  /// Subscribe to a plan
  static Future<Map<String, dynamic>> subscribe({
    required String userId,
    required BusinessPlanType planType,
    required String paymentId,
  }) async {
    try {
      // Simulate payment verification delay
      await Future.delayed(const Duration(seconds: 1));

      final plan = plans[planType]!;
      final subscription = UserSubscription(
        userId: userId,
        planType: planType,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
        paymentId: paymentId,
        uploadsUsedThisMonth: 0,
        boostsUsedThisMonth: 0,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_subscriptionKey}_$userId',
        json.encode(subscription.toJson()),
      );

      return {
        'success': true,
        'subscription': subscription,
        'message': 'Successfully subscribed to ${plan.name} plan!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Subscription failed: $e',
      };
    }
  }

  /// Cancel subscription
  static Future<bool> cancelSubscription(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscription = await getSubscription(userId);

    if (subscription == null) return false;

    final updated = subscription.copyWith(
      isActive: false,
      cancelledAt: DateTime.now(),
    );

    await prefs.setString(
      '${_subscriptionKey}_$userId',
      json.encode(updated.toJson()),
    );

    return true;
  }

  /// Check if user can upload based on subscription
  static Future<bool> canUpload(String userId) async {
    final subscription = await getSubscription(userId);

    if (subscription == null || !subscription.isActive) {
      // Free plan limits
      return true; // Allow with free limits
    }

    final plan = plans[subscription.planType]!;
    if (plan.uploadLimit == -1) return true; // Unlimited

    return subscription.uploadsUsedThisMonth < plan.uploadLimit;
  }

  /// Increment upload count
  static Future<void> incrementUploadCount(String userId) async {
    final subscription = await getSubscription(userId);
    if (subscription == null) return;

    final updated = subscription.copyWith(
      uploadsUsedThisMonth: subscription.uploadsUsedThisMonth + 1,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_subscriptionKey}_$userId',
      json.encode(updated.toJson()),
    );
  }

  /// Check if user can boost videos
  static Future<bool> canBoost(String userId) async {
    final subscription = await getSubscription(userId);

    if (subscription == null || !subscription.isActive) {
      return false; // Free plan can't boost
    }

    final boostLimit = subscription.planType == BusinessPlanType.basic ? 1 : 5;
    return subscription.boostsUsedThisMonth < boostLimit;
  }

  /// Get remaining boosts
  static Future<int> getRemainingBoosts(String userId) async {
    final subscription = await getSubscription(userId);

    if (subscription == null || !subscription.isActive) {
      return 0;
    }

    final boostLimit = subscription.planType == BusinessPlanType.basic ? 1 : 5;
    return boostLimit - subscription.boostsUsedThisMonth;
  }
}

/// Subscription plan details
class SubscriptionPlan {
  final BusinessPlanType type;
  final String name;
  final double price;
  final int uploadLimit; // -1 for unlimited
  final List<String> features;
  final List<String> restrictions;

  SubscriptionPlan({
    required this.type,
    required this.name,
    required this.price,
    required this.uploadLimit,
    required this.features,
    required this.restrictions,
  });

  String get priceDisplay {
    if (price == 0) return 'Free';
    return '₹${price.toInt()}/month';
  }
}

/// User subscription data
class UserSubscription {
  final String userId;
  final BusinessPlanType planType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String paymentId;
  final int uploadsUsedThisMonth;
  final int boostsUsedThisMonth;
  final DateTime? cancelledAt;

  UserSubscription({
    required this.userId,
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.paymentId,
    this.uploadsUsedThisMonth = 0,
    this.boostsUsedThisMonth = 0,
    this.cancelledAt,
  });

  bool get isExpired => endDate.isBefore(DateTime.now());
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      userId: json['userId'],
      planType: BusinessPlanType.values.firstWhere(
        (e) => e.name == json['planType'],
        orElse: () => BusinessPlanType.free,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
      paymentId: json['paymentId'] ?? '',
      uploadsUsedThisMonth: json['uploadsUsedThisMonth'] ?? 0,
      boostsUsedThisMonth: json['boostsUsedThisMonth'] ?? 0,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'planType': planType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'paymentId': paymentId,
      'uploadsUsedThisMonth': uploadsUsedThisMonth,
      'boostsUsedThisMonth': boostsUsedThisMonth,
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  UserSubscription copyWith({
    String? userId,
    BusinessPlanType? planType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? paymentId,
    int? uploadsUsedThisMonth,
    int? boostsUsedThisMonth,
    DateTime? cancelledAt,
  }) {
    return UserSubscription(
      userId: userId ?? this.userId,
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      paymentId: paymentId ?? this.paymentId,
      uploadsUsedThisMonth: uploadsUsedThisMonth ?? this.uploadsUsedThisMonth,
      boostsUsedThisMonth: boostsUsedThisMonth ?? this.boostsUsedThisMonth,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
