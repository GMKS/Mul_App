/// Home Services Models
/// Comprehensive models for home service booking and management

import 'package:flutter/material.dart';

// Service categories
enum ServiceCategory {
  cleaning,
  plumbing,
  electrical,
  appliance,
  pestControl,
  painting,
  carpentry,
  acRepair,
  waterTank,
  roofing,
  gardening,
  moving,
  deepCleaning,
  homeRenovation,
  interiorDesign,
}

// Booking status
enum BookingStatus {
  pending,
  confirmed,
  providerAssigned,
  inProgress,
  completed,
  cancelled,
  refunded,
}

// Provider verification level
enum VerificationLevel {
  basic,
  verified,
  premium,
  certified,
}

// Payment methods
enum PaymentMethod {
  cash,
  upi,
  card,
  wallet,
  netBanking,
}

// Service type (one-time or subscription)
enum ServiceType {
  oneTime,
  subscription,
  emergency,
}

// Main service provider model
class ServiceProvider {
  final String id;
  final String name;
  final String photoUrl;
  final ServiceCategory category;
  final List<ServiceCategory> specializations;
  final double rating;
  final int totalReviews;
  final int completedJobs;
  final VerificationLevel verificationLevel;
  final bool isBackgroundChecked;
  final bool isCertified;
  final bool isEcoFriendly;
  final bool isFemale;
  final List<String> languages;
  final String experience;
  final double pricePerHour;
  final bool isAvailable;
  final String location;
  final double distanceKm;
  final List<String> availableSlots;
  final bool hasInsurance;
  final bool offersGuarantee;
  final int guaranteeDays;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.category,
    this.specializations = const [],
    required this.rating,
    required this.totalReviews,
    required this.completedJobs,
    this.verificationLevel = VerificationLevel.basic,
    this.isBackgroundChecked = false,
    this.isCertified = false,
    this.isEcoFriendly = false,
    this.isFemale = false,
    this.languages = const ['English'],
    this.experience = '0 years',
    required this.pricePerHour,
    this.isAvailable = true,
    required this.location,
    this.distanceKm = 0,
    this.availableSlots = const [],
    this.hasInsurance = false,
    this.offersGuarantee = false,
    this.guaranteeDays = 0,
  });

  IconData get verificationIcon {
    switch (verificationLevel) {
      case VerificationLevel.basic:
        return Icons.person;
      case VerificationLevel.verified:
        return Icons.verified;
      case VerificationLevel.premium:
        return Icons.workspace_premium;
      case VerificationLevel.certified:
        return Icons.military_tech;
    }
  }

  Color get verificationColor {
    switch (verificationLevel) {
      case VerificationLevel.basic:
        return Colors.grey;
      case VerificationLevel.verified:
        return Colors.blue;
      case VerificationLevel.premium:
        return Colors.purple;
      case VerificationLevel.certified:
        return Colors.amber;
    }
  }
}

// Service booking model
class ServiceBooking {
  final String id;
  final String userId;
  final String providerId;
  final ServiceProvider? provider;
  final ServiceCategory category;
  final ServiceType serviceType;
  final String title;
  final String description;
  final DateTime scheduledDate;
  final String timeSlot;
  final String address;
  final double latitude;
  final double longitude;
  final double estimatedCost;
  final double finalCost;
  final BookingStatus status;
  final PaymentMethod paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> mediaUrls;
  final String? specialInstructions;
  final bool isEmergency;
  final String? trackingUrl;
  final String? providerPhone;
  final double? providerLat;
  final double? providerLng;
  final String? otp;
  final List<String> tags;

  ServiceBooking({
    required this.id,
    required this.userId,
    required this.providerId,
    this.provider,
    required this.category,
    this.serviceType = ServiceType.oneTime,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.timeSlot,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.estimatedCost,
    this.finalCost = 0,
    this.status = BookingStatus.pending,
    this.paymentMethod = PaymentMethod.cash,
    this.isPaid = false,
    required this.createdAt,
    this.completedAt,
    this.mediaUrls = const [],
    this.specialInstructions,
    this.isEmergency = false,
    this.trackingUrl,
    this.providerPhone,
    this.providerLat,
    this.providerLng,
    this.otp,
    this.tags = const [],
  });

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.providerAssigned:
        return Colors.purple;
      case BookingStatus.inProgress:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.teal;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.refunded:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.providerAssigned:
        return 'Provider Assigned';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.refunded:
        return 'Refunded';
    }
  }
}

// Service review model
class ServiceReview {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String providerId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> mediaUrls;
  final bool isVerifiedBooking;
  final int helpfulCount;

  ServiceReview({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.mediaUrls = const [],
    this.isVerifiedBooking = false,
    this.helpfulCount = 0,
  });
}

// Service package model (for subscriptions)
class ServicePackage {
  final String id;
  final ServiceCategory category;
  final String title;
  final String description;
  final double monthlyPrice;
  final double annualPrice;
  final int servicesPerMonth;
  final List<String> features;
  final bool isPopular;
  final int discountPercent;

  ServicePackage({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.servicesPerMonth,
    required this.features,
    this.isPopular = false,
    this.discountPercent = 0,
  });

  double get annualSavings => (monthlyPrice * 12) - annualPrice;
}

// Offer/Coupon model
class ServiceOffer {
  final String id;
  final String title;
  final String description;
  final String code;
  final int discountPercent;
  final double maxDiscount;
  final double minOrderValue;
  final DateTime validTill;
  final List<ServiceCategory> applicableCategories;
  final bool isFirstTimeUser;

  ServiceOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.discountPercent,
    this.maxDiscount = 0,
    this.minOrderValue = 0,
    required this.validTill,
    this.applicableCategories = const [],
    this.isFirstTimeUser = false,
  });

  bool get isExpired => DateTime.now().isAfter(validTill);
  bool isApplicableFor(ServiceCategory category, double orderValue) {
    if (isExpired) return false;
    if (orderValue < minOrderValue) return false;
    if (applicableCategories.isEmpty) return true;
    return applicableCategories.contains(category);
  }
}

// Loyalty points model
class LoyaltyPoints {
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final List<PointsTransaction> transactions;

  LoyaltyPoints({
    required this.userId,
    this.totalPoints = 0,
    this.availablePoints = 0,
    this.usedPoints = 0,
    this.transactions = const [],
  });
}

class PointsTransaction {
  final String id;
  final int points;
  final String reason;
  final DateTime createdAt;
  final bool isCredit;

  PointsTransaction({
    required this.id,
    required this.points,
    required this.reason,
    required this.createdAt,
    this.isCredit = true,
  });
}

// Service category helper
class ServiceCategoryHelper {
  static String getName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return 'Cleaning';
      case ServiceCategory.plumbing:
        return 'Plumbing';
      case ServiceCategory.electrical:
        return 'Electrical';
      case ServiceCategory.appliance:
        return 'Appliance Repair';
      case ServiceCategory.pestControl:
        return 'Pest Control';
      case ServiceCategory.painting:
        return 'Painting';
      case ServiceCategory.carpentry:
        return 'Carpentry';
      case ServiceCategory.acRepair:
        return 'AC Repair';
      case ServiceCategory.waterTank:
        return 'Water Tank Cleaning';
      case ServiceCategory.roofing:
        return 'Roofing';
      case ServiceCategory.gardening:
        return 'Gardening';
      case ServiceCategory.moving:
        return 'Moving & Packing';
      case ServiceCategory.deepCleaning:
        return 'Deep Cleaning';
      case ServiceCategory.homeRenovation:
        return 'Home Renovation';
      case ServiceCategory.interiorDesign:
        return 'Interior Design';
    }
  }

  static IconData getIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return Icons.cleaning_services;
      case ServiceCategory.plumbing:
        return Icons.plumbing;
      case ServiceCategory.electrical:
        return Icons.electrical_services;
      case ServiceCategory.appliance:
        return Icons.kitchen;
      case ServiceCategory.pestControl:
        return Icons.pest_control;
      case ServiceCategory.painting:
        return Icons.format_paint;
      case ServiceCategory.carpentry:
        return Icons.carpenter;
      case ServiceCategory.acRepair:
        return Icons.ac_unit;
      case ServiceCategory.waterTank:
        return Icons.water_drop;
      case ServiceCategory.roofing:
        return Icons.roofing;
      case ServiceCategory.gardening:
        return Icons.yard;
      case ServiceCategory.moving:
        return Icons.local_shipping;
      case ServiceCategory.deepCleaning:
        return Icons.auto_awesome;
      case ServiceCategory.homeRenovation:
        return Icons.home_repair_service;
      case ServiceCategory.interiorDesign:
        return Icons.design_services;
    }
  }

  static Color getColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cleaning:
        return Colors.blue;
      case ServiceCategory.plumbing:
        return Colors.cyan;
      case ServiceCategory.electrical:
        return Colors.amber;
      case ServiceCategory.appliance:
        return Colors.purple;
      case ServiceCategory.pestControl:
        return Colors.green;
      case ServiceCategory.painting:
        return Colors.pink;
      case ServiceCategory.carpentry:
        return Colors.brown;
      case ServiceCategory.acRepair:
        return Colors.lightBlue;
      case ServiceCategory.waterTank:
        return Colors.teal;
      case ServiceCategory.roofing:
        return Colors.deepOrange;
      case ServiceCategory.gardening:
        return Colors.lightGreen;
      case ServiceCategory.moving:
        return Colors.indigo;
      case ServiceCategory.deepCleaning:
        return Colors.deepPurple;
      case ServiceCategory.homeRenovation:
        return Colors.orange;
      case ServiceCategory.interiorDesign:
        return Colors.pinkAccent;
    }
  }
}
