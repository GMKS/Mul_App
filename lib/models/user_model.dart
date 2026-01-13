import 'package:flutter/material.dart';

// User model with language, region preferences and account types
// STEP 1 & STEP 2: Language Selection and Region Detection
// BUSINESS FEATURE 1: Business Account Type

/// User account types
enum UserType { user, business, admin }

/// Business subscription plan types
enum BusinessPlanType { free, basic, pro }

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String primaryLanguage;
  final String secondaryLanguage;
  final String region;
  final String state;
  final String city;
  final List<String> preferredCategories;
  final List<String> followedCreators;
  final List<String> likedVideos;
  final List<String> watchHistory;
  final Map<String, double> categoryWatchTime; // Track watch time per category
  final bool isFirstLogin;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  
  // Account type fields
  final UserType userType;
  
  // Business-specific fields (only for BUSINESS users)
  final String? businessName;
  final String? businessCategory;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? area;
  final BusinessPlanType? planType;
  final bool isVerified;
  final DateTime? verifiedAt;
  final int totalViews;
  final int totalCalls;
  final int totalWhatsappClicks;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.primaryLanguage = 'en',
    this.secondaryLanguage = '',
    this.region = '',
    this.state = '',
    this.city = '',
    this.preferredCategories = const [],
    this.followedCreators = const [],
    this.likedVideos = const [],
    this.watchHistory = const [],
    this.categoryWatchTime = const {},
    this.isFirstLogin = true,
    required this.createdAt,
    required this.lastActiveAt,
    this.userType = UserType.user,
    this.businessName,
    this.businessCategory,
    this.phoneNumber,
    this.whatsappNumber,
    this.area,
    this.planType,
    this.isVerified = false,
    this.verifiedAt,
    this.totalViews = 0,
    this.totalCalls = 0,
    this.totalWhatsappClicks = 0,
  });

  bool get isBusinessUser => userType == UserType.business;
  bool get isAdmin => userType == UserType.admin;
  
  /// Get upload limit based on plan
  int get uploadLimit {
    switch (planType) {
      case BusinessPlanType.free:
        return 3; // 3 videos per month
      case BusinessPlanType.basic:
        return 10; // 10 videos per month
      case BusinessPlanType.pro:
        return -1; // Unlimited
      default:
        return 0;
    }
  }

  /// Check if business can boost videos
  bool get canBoostVideos {
    return planType == BusinessPlanType.basic || planType == BusinessPlanType.pro;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      primaryLanguage: json['primaryLanguage'] ?? 'en',
      secondaryLanguage: json['secondaryLanguage'] ?? '',
      region: json['region'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      preferredCategories: List<String>.from(json['preferredCategories'] ?? []),
      followedCreators: List<String>.from(json['followedCreators'] ?? []),
      likedVideos: List<String>.from(json['likedVideos'] ?? []),
      watchHistory: List<String>.from(json['watchHistory'] ?? []),
      categoryWatchTime:
          Map<String, double>.from(json['categoryWatchTime'] ?? {}),
      isFirstLogin: json['isFirstLogin'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'])
          : DateTime.now(),
      userType: UserType.values.firstWhere(
        (e) => e.name == json['userType'],
        orElse: () => UserType.user,
      ),
      businessName: json['businessName'],
      businessCategory: json['businessCategory'],
      phoneNumber: json['phoneNumber'],
      whatsappNumber: json['whatsappNumber'],
      area: json['area'],
      planType: json['planType'] != null
          ? BusinessPlanType.values.firstWhere(
              (e) => e.name == json['planType'],
              orElse: () => BusinessPlanType.free,
            )
          : null,
      isVerified: json['isVerified'] ?? false,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      totalViews: json['totalViews'] ?? 0,
      totalCalls: json['totalCalls'] ?? 0,
      totalWhatsappClicks: json['totalWhatsappClicks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'primaryLanguage': primaryLanguage,
      'secondaryLanguage': secondaryLanguage,
      'region': region,
      'state': state,
      'city': city,
      'preferredCategories': preferredCategories,
      'followedCreators': followedCreators,
      'likedVideos': likedVideos,
      'watchHistory': watchHistory,
      'categoryWatchTime': categoryWatchTime,
      'isFirstLogin': isFirstLogin,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'userType': userType.name,
      'businessName': businessName,
      'businessCategory': businessCategory,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'area': area,
      'planType': planType?.name,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'totalViews': totalViews,
      'totalCalls': totalCalls,
      'totalWhatsappClicks': totalWhatsappClicks,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? primaryLanguage,
    String? secondaryLanguage,
    String? region,
    String? state,
    String? city,
    List<String>? preferredCategories,
    List<String>? followedCreators,
    List<String>? likedVideos,
    List<String>? watchHistory,
    Map<String, double>? categoryWatchTime,
    bool? isFirstLogin,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    UserType? userType,
    String? businessName,
    String? businessCategory,
    String? phoneNumber,
    String? whatsappNumber,
    String? area,
    BusinessPlanType? planType,
    bool? isVerified,
    DateTime? verifiedAt,
    int? totalViews,
    int? totalCalls,
    int? totalWhatsappClicks,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      secondaryLanguage: secondaryLanguage ?? this.secondaryLanguage,
      region: region ?? this.region,
      state: state ?? this.state,
      city: city ?? this.city,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      followedCreators: followedCreators ?? this.followedCreators,
      likedVideos: likedVideos ?? this.likedVideos,
      watchHistory: watchHistory ?? this.watchHistory,
      categoryWatchTime: categoryWatchTime ?? this.categoryWatchTime,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      userType: userType ?? this.userType,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      area: area ?? this.area,
      planType: planType ?? this.planType,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      totalViews: totalViews ?? this.totalViews,
      totalCalls: totalCalls ?? this.totalCalls,
      totalWhatsappClicks: totalWhatsappClicks ?? this.totalWhatsappClicks,
    );
  }
}

/// Business categories for business profiles
class BusinessCategory {
  final String id;
  final String name;
  final IconData icon;

  const BusinessCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  static const List<BusinessCategory> categories = [
    BusinessCategory(id: 'retail', name: 'Retail Shop', icon: Icons.store),
    BusinessCategory(id: 'restaurant', name: 'Restaurant', icon: Icons.restaurant),
    BusinessCategory(id: 'salon', name: 'Salon & Spa', icon: Icons.spa),
    BusinessCategory(id: 'gym', name: 'Gym & Fitness', icon: Icons.fitness_center),
    BusinessCategory(id: 'electronics', name: 'Electronics', icon: Icons.devices),
    BusinessCategory(id: 'clothing', name: 'Clothing & Fashion', icon: Icons.checkroom),
    BusinessCategory(id: 'grocery', name: 'Grocery', icon: Icons.shopping_basket),
    BusinessCategory(id: 'pharmacy', name: 'Pharmacy', icon: Icons.local_pharmacy),
    BusinessCategory(id: 'automobile', name: 'Automobile', icon: Icons.directions_car),
    BusinessCategory(id: 'real_estate', name: 'Real Estate', icon: Icons.home),
    BusinessCategory(id: 'education', name: 'Education', icon: Icons.school),
    BusinessCategory(id: 'healthcare', name: 'Healthcare', icon: Icons.local_hospital),
    BusinessCategory(id: 'services', name: 'Services', icon: Icons.handyman),
    BusinessCategory(id: 'other', name: 'Other', icon: Icons.category),
  ];
}

// Available languages for the app
class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
        code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    AppLanguage(
        code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flag: '🇮🇳'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇮🇳'),
    AppLanguage(
        code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    AppLanguage(
        code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
    AppLanguage(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ', flag: '🇮🇳'),
  ];

  static AppLanguage? getByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
}
