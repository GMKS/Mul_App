// Service Model for Services Directory
// Comprehensive model with all modern features

import 'package:flutter/material.dart';

enum ServiceCategory {
  home,
  health,
  education,
  beauty,
  automotive,
  professional,
  food,
  emergency,
  events,
  technology,
  other;

  String get displayName {
    switch (this) {
      case ServiceCategory.home:
        return 'Home Services';
      case ServiceCategory.health:
        return 'Health & Wellness';
      case ServiceCategory.education:
        return 'Education';
      case ServiceCategory.beauty:
        return 'Beauty & Salon';
      case ServiceCategory.automotive:
        return 'Automotive';
      case ServiceCategory.professional:
        return 'Professional Services';
      case ServiceCategory.food:
        return 'Food & Catering';
      case ServiceCategory.emergency:
        return 'Emergency Services';
      case ServiceCategory.events:
        return 'Events & Entertainment';
      case ServiceCategory.technology:
        return 'Tech Support';
      case ServiceCategory.other:
        return 'Other Services';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceCategory.home:
        return Icons.home_repair_service;
      case ServiceCategory.health:
        return Icons.medical_services;
      case ServiceCategory.education:
        return Icons.school;
      case ServiceCategory.beauty:
        return Icons.spa;
      case ServiceCategory.automotive:
        return Icons.car_repair;
      case ServiceCategory.professional:
        return Icons.business_center;
      case ServiceCategory.food:
        return Icons.restaurant;
      case ServiceCategory.emergency:
        return Icons.emergency;
      case ServiceCategory.events:
        return Icons.celebration;
      case ServiceCategory.technology:
        return Icons.computer;
      case ServiceCategory.other:
        return Icons.more_horiz;
    }
  }
}

enum ServiceStatus { active, inactive, busy }

enum PriceRange { budget, moderate, premium }

class ServiceProvider {
  final String id;
  final String name;
  final String businessName;
  final ServiceCategory category;
  final List<String> subServices;
  final String description;
  final String phoneNumber;
  final String? whatsappNumber;
  final String? email;
  final String city;
  final String state;
  final String? area;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> images;
  final bool isVerified;
  final bool isEmergency24x7;
  final ServiceStatus status;
  final PriceRange priceRange;
  final double rating;
  final int reviewCount;
  final int totalBookings;
  final DateTime joinedDate;
  final List<String> workingDays;
  final String workingHours;
  final List<String> specializations;
  final List<String> certifications;
  final int yearsOfExperience;
  final String? licenseNumber;
  final bool instantBooking;
  final bool chatAvailable;
  final String? websiteUrl;
  final Map<String, double>? distanceKm;
  final List<ServiceOffer>? offers;
  final List<Review>? reviews;
  final int favoriteCount;
  final int callCount;
  final int whatsappClickCount;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.businessName,
    required this.category,
    this.subServices = const [],
    required this.description,
    required this.phoneNumber,
    this.whatsappNumber,
    this.email,
    required this.city,
    required this.state,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.images = const [],
    this.isVerified = false,
    this.isEmergency24x7 = false,
    this.status = ServiceStatus.active,
    this.priceRange = PriceRange.moderate,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.totalBookings = 0,
    required this.joinedDate,
    this.workingDays = const [],
    this.workingHours = '9:00 AM - 6:00 PM',
    this.specializations = const [],
    this.certifications = const [],
    this.yearsOfExperience = 0,
    this.licenseNumber,
    this.instantBooking = false,
    this.chatAvailable = false,
    this.websiteUrl,
    this.distanceKm,
    this.offers,
    this.reviews,
    this.favoriteCount = 0,
    this.callCount = 0,
    this.whatsappClickCount = 0,
  });

  String get priceRangeText {
    switch (priceRange) {
      case PriceRange.budget:
        return '₹ Budget Friendly';
      case PriceRange.moderate:
        return '₹₹ Moderate';
      case PriceRange.premium:
        return '₹₹₹ Premium';
    }
  }

  String get statusText {
    switch (status) {
      case ServiceStatus.active:
        return 'Available';
      case ServiceStatus.inactive:
        return 'Unavailable';
      case ServiceStatus.busy:
        return 'Busy';
    }
  }

  Color get statusColor {
    switch (status) {
      case ServiceStatus.active:
        return Colors.green;
      case ServiceStatus.inactive:
        return Colors.grey;
      case ServiceStatus.busy:
        return Colors.orange;
    }
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      businessName: json['business_name'] ?? json['businessName'] ?? '',
      category: ServiceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ServiceCategory.other,
      ),
      subServices:
          List<String>.from(json['sub_services'] ?? json['subServices'] ?? []),
      description: json['description'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? json['whatsappNumber'],
      email: json['email'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      area: json['area'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['image_url'] ?? json['imageUrl'],
      images: List<String>.from(json['images'] ?? []),
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      isEmergency24x7:
          json['is_emergency_24x7'] ?? json['isEmergency24x7'] ?? false,
      status: ServiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ServiceStatus.active,
      ),
      priceRange: PriceRange.values.firstWhere(
        (e) => e.name == json['price_range'] ?? json['priceRange'],
        orElse: () => PriceRange.moderate,
      ),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      totalBookings: json['total_bookings'] ?? json['totalBookings'] ?? 0,
      joinedDate: json['joined_date'] != null
          ? DateTime.parse(json['joined_date'])
          : DateTime.now(),
      workingDays:
          List<String>.from(json['working_days'] ?? json['workingDays'] ?? []),
      workingHours:
          json['working_hours'] ?? json['workingHours'] ?? '9:00 AM - 6:00 PM',
      specializations: List<String>.from(json['specializations'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      yearsOfExperience:
          json['years_of_experience'] ?? json['yearsOfExperience'] ?? 0,
      licenseNumber: json['license_number'] ?? json['licenseNumber'],
      instantBooking:
          json['instant_booking'] ?? json['instantBooking'] ?? false,
      chatAvailable: json['chat_available'] ?? json['chatAvailable'] ?? false,
      websiteUrl: json['website_url'] ?? json['websiteUrl'],
      favoriteCount: json['favorite_count'] ?? json['favoriteCount'] ?? 0,
      callCount: json['call_count'] ?? json['callCount'] ?? 0,
      whatsappClickCount:
          json['whatsapp_click_count'] ?? json['whatsappClickCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'category': category.name,
      'sub_services': subServices,
      'description': description,
      'phone_number': phoneNumber,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'city': city,
      'state': state,
      'area': area,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'images': images,
      'is_verified': isVerified,
      'is_emergency_24x7': isEmergency24x7,
      'status': status.name,
      'price_range': priceRange.name,
      'rating': rating,
      'review_count': reviewCount,
      'total_bookings': totalBookings,
      'joined_date': joinedDate.toIso8601String(),
      'working_days': workingDays,
      'working_hours': workingHours,
      'specializations': specializations,
      'certifications': certifications,
      'years_of_experience': yearsOfExperience,
      'license_number': licenseNumber,
      'instant_booking': instantBooking,
      'chat_available': chatAvailable,
      'website_url': websiteUrl,
      'favorite_count': favoriteCount,
      'call_count': callCount,
      'whatsapp_click_count': whatsappClickCount,
    };
  }
}

class ServiceOffer {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final String? promoCode;
  final DateTime expiryDate;
  final bool isActive;

  ServiceOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    this.promoCode,
    required this.expiryDate,
    this.isActive = true,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
}

class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;
  final String? serviceType;
  final bool isVerified;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
    this.serviceType,
    this.isVerified = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      userAvatar: json['user_avatar'] ?? json['userAvatar'],
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      serviceType: json['service_type'] ?? json['serviceType'],
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
    );
  }
}

class ServiceBooking {
  final String id;
  final String serviceProviderId;
  final String userId;
  final String userName;
  final String userPhone;
  final DateTime bookingDate;
  final String timeSlot;
  final String serviceType;
  final String? specialRequests;
  final BookingStatus status;
  final DateTime createdAt;
  final String? cancellationReason;

  ServiceBooking({
    required this.id,
    required this.serviceProviderId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.bookingDate,
    required this.timeSlot,
    required this.serviceType,
    this.specialRequests,
    this.status = BookingStatus.pending,
    required this.createdAt,
    this.cancellationReason,
  });
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}
