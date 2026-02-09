/// Local Shop Model
/// Model for hyperlocal marketplace businesses

import 'package:flutter/material.dart';

class LocalShop {
  final String id;
  final String name;
  final String description;
  final ShopCategory category;
  final String? logoUrl;
  final List<String> imageUrls;
  final String? address;
  final String? locality;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? whatsapp;
  final String? website;
  final String? offer;
  final double? rating;
  final int reviewCount;
  final bool isVerified;
  final bool isFeatured;
  final bool isOpen;
  final Map<String, String> workingHours;
  final List<String> tags;
  final DateTime createdAt;
  final double? distance;

  LocalShop({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.logoUrl,
    this.imageUrls = const [],
    this.address,
    this.locality,
    this.city,
    this.latitude,
    this.longitude,
    this.phone,
    this.whatsapp,
    this.website,
    this.offer,
    this.rating,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isFeatured = false,
    this.isOpen = true,
    this.workingHours = const {},
    this.tags = const [],
    required this.createdAt,
    this.distance,
  });

  factory LocalShop.fromJson(Map<String, dynamic> json) {
    return LocalShop(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: ShopCategory.fromString(json['category']),
      logoUrl: json['logo_url'],
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      address: json['address'],
      locality: json['locality'],
      city: json['city'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'],
      whatsapp: json['whatsapp'] ?? json['phone'],
      website: json['website'],
      offer: json['offer'],
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isVerified: json['is_verified'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      isOpen: json['is_open'] ?? true,
      workingHours: (json['working_hours'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.value,
      'logo_url': logoUrl,
      'image_urls': imageUrls,
      'address': address,
      'locality': locality,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'whatsapp': whatsapp,
      'website': website,
      'offer': offer,
      'rating': rating,
      'review_count': reviewCount,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'is_open': isOpen,
      'working_hours': workingHours,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Shop categories
enum ShopCategory {
  grocery('grocery', 'Grocery', '🛒', [0xFF4CAF50, 0xFF2E7D32]),
  bakery('bakery', 'Bakery', '🥐', [0xFFFF9800, 0xFFF57C00]),
  pharmacy('pharmacy', 'Pharmacy', '💊', [0xFF2196F3, 0xFF1976D2]),
  services('services', 'Services', '🔧', [0xFF9C27B0, 0xFF7B1FA2]),
  restaurant('restaurant', 'Restaurant', '🍽️', [0xFFE91E63, 0xFFC2185B]),
  electronics('electronics', 'Electronics', '📱', [0xFF607D8B, 0xFF455A64]),
  fashion('fashion', 'Fashion', '👗', [0xFFE91E63, 0xFFAD1457]),
  homeDecor('home_decor', 'Home & Decor', '🏠', [0xFF795548, 0xFF5D4037]),
  beauty('beauty', 'Beauty', '💄', [0xFFFF4081, 0xFFF50057]),
  sports('sports', 'Sports', '⚽', [0xFF00BCD4, 0xFF0097A7]),
  books('books', 'Books', '📚', [0xFF8D6E63, 0xFF6D4C41]),
  all('all', 'All', '🏪', [0xFF6366F1, 0xFF4F46E5]);

  final String value;
  final String label;
  final String emoji;
  final List<int> _gradientColorInts;

  const ShopCategory(
      this.value, this.label, this.emoji, this._gradientColorInts);

  /// Display name (alias for label)
  String get displayName => label;

  /// Get gradient colors as Color objects
  List<Color> get gradientColors =>
      _gradientColorInts.map((c) => Color(c)).toList();

  static ShopCategory fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'grocery':
        return ShopCategory.grocery;
      case 'bakery':
        return ShopCategory.bakery;
      case 'pharmacy':
        return ShopCategory.pharmacy;
      case 'services':
        return ShopCategory.services;
      case 'restaurant':
        return ShopCategory.restaurant;
      case 'electronics':
        return ShopCategory.electronics;
      case 'fashion':
        return ShopCategory.fashion;
      case 'home_decor':
        return ShopCategory.homeDecor;
      case 'beauty':
        return ShopCategory.beauty;
      case 'sports':
        return ShopCategory.sports;
      case 'books':
        return ShopCategory.books;
      default:
        return ShopCategory.all;
    }
  }
}
