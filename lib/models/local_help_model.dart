/// Local Help Model
/// Comprehensive community support system

import 'package:flutter/material.dart';

/// Help Category enum
enum HelpCategory {
  elderFamily,
  studentYouth,
  dailyHousehold,
  medicalHealth,
  mentalSupport,
  communitySocial,
  safetyEmergency,
  animalEnvironment,
  governmentCivic,
}

/// Help Request Status
enum HelpStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
  expired,
}

/// Help Urgency Level
enum HelpUrgency {
  low,
  medium,
  high,
  critical,
}

/// Help Category Data with icon, color, and subcategories
class HelpCategoryData {
  final HelpCategory category;
  final String name;
  final String emoji;
  final IconData icon;
  final Color color;
  final List<String> subcategories;
  final String description;

  const HelpCategoryData({
    required this.category,
    required this.name,
    required this.emoji,
    required this.icon,
    required this.color,
    required this.subcategories,
    required this.description,
  });

  static List<HelpCategoryData> getAllCategories() {
    return [
      HelpCategoryData(
        category: HelpCategory.elderFamily,
        name: 'Elder & Family Support',
        emoji: '👴',
        icon: Icons.elderly,
        color: const Color(0xFF9C27B0),
        description: 'Support for seniors and family care',
        subcategories: [
          'Companion walk support (temple/park/hospital)',
          'Home paperwork assistance',
          'Phone setup & digital help',
          'Elder check-in requests',
          'Emergency contact relay',
          'Local volunteer visit',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.studentYouth,
        name: 'Student & Youth Help',
        emoji: '🎓',
        icon: Icons.school,
        color: const Color(0xFF2196F3),
        description: 'Career guidance and student support',
        subcategories: [
          'Career guidance (local mentors)',
          'Internship/part-time referrals',
          'Exam form assistance',
          'Laptop/device borrowing',
          'Resume review help',
          'Peer group learning',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.dailyHousehold,
        name: 'Daily Life & Household',
        emoji: '🏠',
        icon: Icons.home,
        color: const Color(0xFFFF9800),
        description: 'Everyday household assistance',
        subcategories: [
          'Emergency locksmith',
          'Water/gas refill help',
          'Power outage assistance',
          'Furniture moving help',
          'Home cleaning (urgent)',
          'Babysitting/child pickup',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.medicalHealth,
        name: 'Medical & Health Help',
        emoji: '🚑',
        icon: Icons.local_hospital,
        color: const Color(0xFFF44336),
        description: 'Non-emergency medical support',
        subcategories: [
          'Medicine availability check',
          'Home sample pickup help',
          'Wheelchair/stretcher support',
          'Hospital navigation help',
          'Medical document guidance',
          'Hospital accompaniment',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.mentalSupport,
        name: 'Mental & Emotional Support',
        emoji: '🧠',
        icon: Icons.psychology,
        color: const Color(0xFF00BCD4),
        description: 'Community-driven emotional support',
        subcategories: [
          'Talk to someone locally',
          'Stress/anxiety support',
          'Exam stress support',
          'Grief/loss support',
          'Parenting stress help',
          'Elder loneliness support',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.communitySocial,
        name: 'Community & Social Help',
        emoji: '🧍',
        icon: Icons.groups,
        color: const Color(0xFF4CAF50),
        description: 'Social events and community coordination',
        subcategories: [
          'Event volunteer requests',
          'Food distribution coordination',
          'Local donation drives',
          'Community cleanup calls',
          'Temple/festival support',
          'Blood camp coordination',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.safetyEmergency,
        name: 'Safety & Emergency',
        emoji: '🚨',
        icon: Icons.emergency,
        color: const Color(0xFFE91E63),
        description: 'Urgent safety and emergency help',
        subcategories: [
          'SOS to nearby helpers',
          'Night travel assistance',
          'Stranded vehicle help',
          'Safe escort request',
          'Emergency translation',
          'Disaster evacuation guidance',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.animalEnvironment,
        name: 'Animal & Environment',
        emoji: '🐾',
        icon: Icons.pets,
        color: const Color(0xFF795548),
        description: 'Animal rescue and environmental alerts',
        subcategories: [
          'Injured animal rescue',
          'Lost/found animals',
          'Stray feeding coordination',
          'Tree fall reporting',
          'Fire hazard alerts',
          'Flood/waterlogging alerts',
        ],
      ),
      HelpCategoryData(
        category: HelpCategory.governmentCivic,
        name: 'Government & Civic Help',
        emoji: '🧾',
        icon: Icons.account_balance,
        color: const Color(0xFF607D8B),
        description: 'Government forms and civic assistance',
        subcategories: [
          'Form filling help',
          'Ration/pension guidance',
          'Property tax help',
          'Voter ID/Aadhaar help',
          'Complaint follow-ups',
          'Office navigation',
        ],
      ),
    ];
  }
}

/// Help Request Model
class HelpRequest {
  final String id;
  final String userId;
  final String userName;
  final HelpCategory category;
  final String subcategory;
  final String description;
  final HelpUrgency urgency;
  final HelpStatus status;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? helperId;
  final String? helperName;
  final bool isAnonymous;
  final List<String> attachments;

  HelpRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.urgency,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.createdAt,
    this.expiresAt,
    this.helperId,
    this.helperName,
    this.isAnonymous = false,
    this.attachments = const [],
  });

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    return HelpRequest(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      category: HelpCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HelpCategory.dailyHousehold,
      ),
      subcategory: json['subcategory'] ?? '',
      description: json['description'] ?? '',
      urgency: HelpUrgency.values.firstWhere(
        (e) => e.name == json['urgency'],
        orElse: () => HelpUrgency.medium,
      ),
      status: HelpStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => HelpStatus.pending,
      ),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      helperId: json['helper_id'],
      helperName: json['helper_name'],
      isAnonymous: json['is_anonymous'] ?? false,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'category': category.name,
      'subcategory': subcategory,
      'description': description,
      'urgency': urgency.name,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'helper_id': helperId,
      'helper_name': helperName,
      'is_anonymous': isAnonymous,
      'attachments': attachments,
    };
  }
}

/// Helper Profile Model
class HelperProfile {
  final String id;
  final String name;
  final String avatar;
  final int helpCount;
  final double rating;
  final List<String> badges;
  final int trustScore;
  final bool isVerified;
  final List<HelpCategory> specializations;

  HelperProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.helpCount,
    required this.rating,
    required this.badges,
    required this.trustScore,
    required this.isVerified,
    required this.specializations,
  });
}
