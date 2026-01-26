/// Community Help Models
/// Comprehensive models for community assistance, volunteering, and resource sharing

import 'package:flutter/material.dart';

// Help request categories
enum HelpCategory {
  medical,
  transport,
  food,
  shelter,
  education,
  lostAndFound,
  legal,
  technical,
  financial,
  emergency,
  bloodDonation,
  petCare,
  elderly,
  childcare,
  disaster,
  other,
}

// Request status
enum HelpRequestStatus {
  open,
  inProgress,
  resolved,
  cancelled,
  urgent,
}

// Request priority
enum HelpPriority {
  low,
  medium,
  high,
  critical,
}

// Volunteer verification level
enum VolunteerLevel {
  basic,
  verified,
  certified,
  hero,
}

// Resource type
enum ResourceType {
  food,
  clothes,
  books,
  medicines,
  money,
  equipment,
  other,
}

// Help request model
class HelpRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final HelpCategory category;
  final String title;
  final String description;
  final HelpRequestStatus status;
  final HelpPriority priority;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String location;
  final double latitude;
  final double longitude;
  final bool isAnonymous;
  final bool isEmergency;
  final List<String> mediaUrls;
  final List<String> tags;
  final int responseCount;
  final String? responderId;
  final String? responderName;
  final String? contactPhone;
  final String? contactEmail;

  HelpRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.category,
    required this.title,
    required this.description,
    this.status = HelpRequestStatus.open,
    this.priority = HelpPriority.medium,
    required this.createdAt,
    this.resolvedAt,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.isAnonymous = false,
    this.isEmergency = false,
    this.mediaUrls = const [],
    this.tags = const [],
    this.responseCount = 0,
    this.responderId,
    this.responderName,
    this.contactPhone,
    this.contactEmail,
  });

  Color get statusColor {
    switch (status) {
      case HelpRequestStatus.open:
        return Colors.blue;
      case HelpRequestStatus.inProgress:
        return Colors.orange;
      case HelpRequestStatus.resolved:
        return Colors.green;
      case HelpRequestStatus.cancelled:
        return Colors.grey;
      case HelpRequestStatus.urgent:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case HelpRequestStatus.open:
        return 'Open';
      case HelpRequestStatus.inProgress:
        return 'In Progress';
      case HelpRequestStatus.resolved:
        return 'Resolved';
      case HelpRequestStatus.cancelled:
        return 'Cancelled';
      case HelpRequestStatus.urgent:
        return 'Urgent';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case HelpPriority.low:
        return Colors.grey;
      case HelpPriority.medium:
        return Colors.blue;
      case HelpPriority.high:
        return Colors.orange;
      case HelpPriority.critical:
        return Colors.red;
    }
  }
}

// Community volunteer model
class CommunityVolunteer {
  final String id;
  final String name;
  final String photoUrl;
  final String bio;
  final List<HelpCategory> skills;
  final VolunteerLevel level;
  final double rating;
  final int totalHelps;
  final int points;
  final List<String> badges;
  final String location;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final bool isVerified;
  final List<String> languages;
  final String? phone;
  final String? email;
  final DateTime joinedAt;

  CommunityVolunteer({
    required this.id,
    required this.name,
    required this.photoUrl,
    this.bio = '',
    this.skills = const [],
    this.level = VolunteerLevel.basic,
    this.rating = 0,
    this.totalHelps = 0,
    this.points = 0,
    this.badges = const [],
    required this.location,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    this.isVerified = false,
    this.languages = const ['English'],
    this.phone,
    this.email,
    required this.joinedAt,
  });

  IconData get levelIcon {
    switch (level) {
      case VolunteerLevel.basic:
        return Icons.person;
      case VolunteerLevel.verified:
        return Icons.verified;
      case VolunteerLevel.certified:
        return Icons.workspace_premium;
      case VolunteerLevel.hero:
        return Icons.military_tech;
    }
  }

  Color get levelColor {
    switch (level) {
      case VolunteerLevel.basic:
        return Colors.grey;
      case VolunteerLevel.verified:
        return Colors.blue;
      case VolunteerLevel.certified:
        return Colors.purple;
      case VolunteerLevel.hero:
        return Colors.amber;
    }
  }
}

// Help response model
class HelpResponse {
  final String id;
  final String requestId;
  final String volunteerId;
  final String volunteerName;
  final String volunteerPhotoUrl;
  final String message;
  final DateTime createdAt;
  final bool isAccepted;

  HelpResponse({
    required this.id,
    required this.requestId,
    required this.volunteerId,
    required this.volunteerName,
    required this.volunteerPhotoUrl,
    required this.message,
    required this.createdAt,
    this.isAccepted = false,
  });
}

// Resource sharing model
class ResourceShare {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final ResourceType type;
  final String title;
  final String description;
  final int quantity;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final bool isAvailable;
  final String? claimedBy;

  ResourceShare({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.type,
    required this.title,
    required this.description,
    this.quantity = 1,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.mediaUrls = const [],
    required this.createdAt,
    this.isAvailable = true,
    this.claimedBy,
  });
}

// Community bulletin model
class CommunityBulletin {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<String> mediaUrls;
  final bool isPinned;
  final int viewCount;

  CommunityBulletin({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.title,
    required this.description,
    this.category = 'General',
    required this.createdAt,
    this.expiresAt,
    this.mediaUrls = const [],
    this.isPinned = false,
    this.viewCount = 0,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

// Community group model
class CommunityGroup {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final String adminName;
  final int memberCount;
  final String location;
  final List<String> tags;
  final DateTime createdAt;
  final bool isPublic;

  CommunityGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.adminName,
    this.memberCount = 0,
    required this.location,
    this.tags = const [],
    required this.createdAt,
    this.isPublic = true,
  });
}

// Help review model
class HelpReview {
  final String id;
  final String requestId;
  final String volunteerId;
  final String reviewerId;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  HelpReview({
    required this.id,
    required this.requestId,
    required this.volunteerId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

// Emergency alert model
class EmergencyAlert {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final bool isActive;
  final int notifiedVolunteers;

  EmergencyAlert({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.isActive = true,
    this.notifiedVolunteers = 0,
  });
}

// Category helper
class HelpCategoryHelper {
  static String getName(HelpCategory category) {
    switch (category) {
      case HelpCategory.medical:
        return 'Medical';
      case HelpCategory.transport:
        return 'Transport';
      case HelpCategory.food:
        return 'Food';
      case HelpCategory.shelter:
        return 'Shelter';
      case HelpCategory.education:
        return 'Education';
      case HelpCategory.lostAndFound:
        return 'Lost & Found';
      case HelpCategory.legal:
        return 'Legal';
      case HelpCategory.technical:
        return 'Technical';
      case HelpCategory.financial:
        return 'Financial';
      case HelpCategory.emergency:
        return 'Emergency';
      case HelpCategory.bloodDonation:
        return 'Blood Donation';
      case HelpCategory.petCare:
        return 'Pet Care';
      case HelpCategory.elderly:
        return 'Elderly Care';
      case HelpCategory.childcare:
        return 'Childcare';
      case HelpCategory.disaster:
        return 'Disaster Relief';
      case HelpCategory.other:
        return 'Other';
    }
  }

  static IconData getIcon(HelpCategory category) {
    switch (category) {
      case HelpCategory.medical:
        return Icons.medical_services;
      case HelpCategory.transport:
        return Icons.directions_car;
      case HelpCategory.food:
        return Icons.restaurant;
      case HelpCategory.shelter:
        return Icons.home;
      case HelpCategory.education:
        return Icons.school;
      case HelpCategory.lostAndFound:
        return Icons.search;
      case HelpCategory.legal:
        return Icons.gavel;
      case HelpCategory.technical:
        return Icons.computer;
      case HelpCategory.financial:
        return Icons.account_balance;
      case HelpCategory.emergency:
        return Icons.emergency;
      case HelpCategory.bloodDonation:
        return Icons.bloodtype;
      case HelpCategory.petCare:
        return Icons.pets;
      case HelpCategory.elderly:
        return Icons.elderly;
      case HelpCategory.childcare:
        return Icons.child_care;
      case HelpCategory.disaster:
        return Icons.warning;
      case HelpCategory.other:
        return Icons.help;
    }
  }

  static Color getColor(HelpCategory category) {
    switch (category) {
      case HelpCategory.medical:
        return Colors.red;
      case HelpCategory.transport:
        return Colors.blue;
      case HelpCategory.food:
        return Colors.orange;
      case HelpCategory.shelter:
        return Colors.purple;
      case HelpCategory.education:
        return Colors.green;
      case HelpCategory.lostAndFound:
        return Colors.brown;
      case HelpCategory.legal:
        return Colors.indigo;
      case HelpCategory.technical:
        return Colors.cyan;
      case HelpCategory.financial:
        return Colors.teal;
      case HelpCategory.emergency:
        return Colors.red.shade900;
      case HelpCategory.bloodDonation:
        return Colors.red.shade700;
      case HelpCategory.petCare:
        return Colors.amber;
      case HelpCategory.elderly:
        return Colors.deepPurple;
      case HelpCategory.childcare:
        return Colors.pink;
      case HelpCategory.disaster:
        return Colors.deepOrange;
      case HelpCategory.other:
        return Colors.grey;
    }
  }
}

// Resource type helper
class ResourceTypeHelper {
  static String getName(ResourceType type) {
    switch (type) {
      case ResourceType.food:
        return 'Food';
      case ResourceType.clothes:
        return 'Clothes';
      case ResourceType.books:
        return 'Books';
      case ResourceType.medicines:
        return 'Medicines';
      case ResourceType.money:
        return 'Money';
      case ResourceType.equipment:
        return 'Equipment';
      case ResourceType.other:
        return 'Other';
    }
  }

  static IconData getIcon(ResourceType type) {
    switch (type) {
      case ResourceType.food:
        return Icons.restaurant;
      case ResourceType.clothes:
        return Icons.checkroom;
      case ResourceType.books:
        return Icons.book;
      case ResourceType.medicines:
        return Icons.medication;
      case ResourceType.money:
        return Icons.payments;
      case ResourceType.equipment:
        return Icons.build;
      case ResourceType.other:
        return Icons.category;
    }
  }
}
