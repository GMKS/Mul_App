// BUSINESS FEATURE 3: Business Video Model
// Video model for business content with product/service metadata

class BusinessVideo {
  final String id;
  final String ownerId;
  final String videoUrl;
  final String thumbnailUrl;
  final String productName;
  final double price;
  final String? offerTag; // e.g., "20% OFF", "Buy 1 Get 1"
  final String businessName;
  final String businessCategory;
  final String city;
  final String area;
  final String phoneNumber;
  final String whatsappNumber;
  final int views;
  final int callClicks;
  final int whatsappClicks;
  final bool isBoosted;
  final DateTime? boostExpiry;
  final DateTime createdAt;
  final List<String> hashtags;
  final String description;
  final bool isActive;

  BusinessVideo({
    required this.id,
    required this.ownerId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.productName,
    required this.price,
    this.offerTag,
    required this.businessName,
    required this.businessCategory,
    required this.city,
    required this.area,
    required this.phoneNumber,
    required this.whatsappNumber,
    this.views = 0,
    this.callClicks = 0,
    this.whatsappClicks = 0,
    this.isBoosted = false,
    this.boostExpiry,
    required this.createdAt,
    this.hashtags = const [],
    this.description = '',
    this.isActive = true,
  });

  /// Calculate engagement score for ranking
  double get engagementScore {
    return views * 0.1 + callClicks * 5 + whatsappClicks * 3;
  }

  /// Check if boost is active
  bool get isBoostActive {
    if (!isBoosted || boostExpiry == null) return false;
    return boostExpiry!.isAfter(DateTime.now());
  }

  /// Format price for display
  String get formattedPrice {
    if (price == 0) return 'Contact for price';
    return '₹${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';
  }

  factory BusinessVideo.fromJson(Map<String, dynamic> json) {
    return BusinessVideo(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      productName: json['productName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      offerTag: json['offerTag'],
      businessName: json['businessName'] ?? '',
      businessCategory: json['businessCategory'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
      views: json['views'] ?? 0,
      callClicks: json['callClicks'] ?? 0,
      whatsappClicks: json['whatsappClicks'] ?? 0,
      isBoosted: json['isBoosted'] ?? false,
      boostExpiry: json['boostExpiry'] != null
          ? DateTime.parse(json['boostExpiry'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      hashtags: List<String>.from(json['hashtags'] ?? []),
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'productName': productName,
      'price': price,
      'offerTag': offerTag,
      'businessName': businessName,
      'businessCategory': businessCategory,
      'city': city,
      'area': area,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'views': views,
      'callClicks': callClicks,
      'whatsappClicks': whatsappClicks,
      'isBoosted': isBoosted,
      'boostExpiry': boostExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'hashtags': hashtags,
      'description': description,
      'isActive': isActive,
    };
  }

  BusinessVideo copyWith({
    String? id,
    String? ownerId,
    String? videoUrl,
    String? thumbnailUrl,
    String? productName,
    double? price,
    String? offerTag,
    String? businessName,
    String? businessCategory,
    String? city,
    String? area,
    String? phoneNumber,
    String? whatsappNumber,
    int? views,
    int? callClicks,
    int? whatsappClicks,
    bool? isBoosted,
    DateTime? boostExpiry,
    DateTime? createdAt,
    List<String>? hashtags,
    String? description,
    bool? isActive,
  }) {
    return BusinessVideo(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      offerTag: offerTag ?? this.offerTag,
      businessName: businessName ?? this.businessName,
      businessCategory: businessCategory ?? this.businessCategory,
      city: city ?? this.city,
      area: area ?? this.area,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      views: views ?? this.views,
      callClicks: callClicks ?? this.callClicks,
      whatsappClicks: whatsappClicks ?? this.whatsappClicks,
      isBoosted: isBoosted ?? this.isBoosted,
      boostExpiry: boostExpiry ?? this.boostExpiry,
      createdAt: createdAt ?? this.createdAt,
      hashtags: hashtags ?? this.hashtags,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Offer tags for business videos
class OfferTag {
  static const List<String> commonTags = [
    '10% OFF',
    '20% OFF',
    '30% OFF',
    '50% OFF',
    'Buy 1 Get 1',
    'Free Delivery',
    'Limited Time',
    'Flash Sale',
    'New Arrival',
    'Best Seller',
    'Clearance',
    'Festival Special',
  ];
}
