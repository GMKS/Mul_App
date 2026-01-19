// business_model.dart
// Enhanced Model for business with all modern features

class BusinessModel {
  // 1. Shop Name & Branding
  final String id;
  final String name;
  final String? tagline;
  final String description;
  final String category;
  final String? logoUrl;
  final String? coverImageUrl;
  final String emoji;

  // 2. Location & Discovery
  final String address;
  final String city;
  final String state;
  final String? locality;
  final double? latitude;
  final double? longitude;
  final double? serviceRadius; // in km
  final String? mapLink;

  // 3. Contact & Engagement
  final String phoneNumber;
  final String? whatsappNumber;
  final String? email;
  final String? websiteUrl;
  final String? facebookUrl;
  final String? instagramUrl;
  final String? youtubeUrl;

  // 4. Approval & Trust
  final bool isApproved;
  final bool isVerified;
  final DateTime? verifiedDate;
  final double? rating;
  final int? reviewCount;
  final List<Review>? reviews;

  // 5. Modern Additions
  final String? qrCode; // QR code for sharing
  final List<Product>? digitalCatalog;
  final bool hasOnlineBooking;
  final String? bookingUrl;
  final bool canSendNotifications;
  final int? followers;
  final BusinessAnalytics? analytics;

  // 6. Security & Privacy
  final String ownerId;
  final bool isKYCVerified;
  final List<String>? documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional fields
  final bool isSponsored;
  final String? ctaText;
  final String? ctaLink;
  final List<String>? images;
  final String? videoUrl;
  final Map<String, dynamic>? metadata;

  // NEW FEATURES (2026 Trends)
  // Feature 1: Business Videos
  final List<BusinessVideo>? videos;

  // Feature 2: Offers with Expiry
  final List<BusinessOffer>? activeOffers;

  // Feature 3: Featured Badge
  final bool isFeatured;
  final DateTime? featuredUntil;
  final int? featuredRank; // Lower number = higher priority

  // Feature 4: Distance Filtering
  final double? distanceFromUser; // in km, calculated based on user location

  // MONETIZATION FEATURES (2026)
  // Feature 5: Subscription Plan
  final SubscriptionPlan? subscriptionPlan;
  final DateTime? subscriptionExpiryDate;
  final bool isSubscriptionActive;

  // Feature 6: Visibility Priority Score
  final double priorityScore; // Calculated based on plan, featured, engagement
  final int engagementScore; // Views, clicks, reviews combined

  // Feature 7: Featured Toggle Controls
  final bool canToggleFeatured; // Based on subscription plan
  final int featuredDaysRemaining;

  BusinessModel({
    required this.id,
    required this.name,
    this.tagline,
    required this.description,
    required this.category,
    this.logoUrl,
    this.coverImageUrl,
    this.emoji = '🏪',
    required this.address,
    required this.city,
    required this.state,
    this.locality,
    this.latitude,
    this.longitude,
    this.serviceRadius,
    this.mapLink,
    required this.phoneNumber,
    this.whatsappNumber,
    this.email,
    this.websiteUrl,
    this.facebookUrl,
    this.instagramUrl,
    this.youtubeUrl,
    this.isApproved = false,
    this.isVerified = false,
    this.verifiedDate,
    this.rating,
    this.reviewCount,
    this.reviews,
    this.qrCode,
    this.digitalCatalog,
    this.hasOnlineBooking = false,
    this.bookingUrl,
    this.canSendNotifications = false,
    this.followers,
    this.analytics,
    required this.ownerId,
    this.isKYCVerified = false,
    this.documents,
    required this.createdAt,
    required this.updatedAt,
    this.isSponsored = false,
    this.ctaText,
    this.ctaLink,
    this.images,
    this.videoUrl,
    this.metadata,
    // NEW FEATURES
    this.videos,
    this.activeOffers,
    this.isFeatured = false,
    this.featuredUntil,
    this.featuredRank,
    this.distanceFromUser,
    // MONETIZATION
    this.subscriptionPlan,
    this.subscriptionExpiryDate,
    this.isSubscriptionActive = false,
    this.priorityScore = 0.0,
    this.engagementScore = 0,
    this.canToggleFeatured = false,
    this.featuredDaysRemaining = 0,
  });

  // Calculate Priority Score based on multiple factors
  double calculatePriorityScore() {
    double score = 0.0;

    // 1. Subscription Plan Tier (0-40 points)
    if (subscriptionPlan != null) {
      switch (subscriptionPlan!.tier) {
        case SubscriptionTier.free:
          score += 0;
          break;
        case SubscriptionTier.basic:
          score += 20;
          break;
        case SubscriptionTier.premium:
          score += 40;
          break;
      }
    }

    // 2. Featured Status (0-30 points)
    if (isFeatured &&
        featuredUntil != null &&
        DateTime.now().isBefore(featuredUntil!)) {
      score += 30;
      // Bonus for higher featured rank
      if (featuredRank != null && featuredRank! <= 3) {
        score += 5;
      }
    }

    // 3. Engagement Metrics (0-20 points)
    if (engagementScore > 0) {
      // Normalize engagement score (assuming max 10000)
      score += (engagementScore / 10000 * 20).clamp(0, 20);
    }

    // 4. Verification Status (0-5 points)
    if (isVerified) score += 5;

    // 5. Rating (0-5 points)
    if (rating != null && rating! >= 4.0) {
      score += rating!;
    }

    return score.clamp(0, 100);
  }

  // Check if business can toggle featured status
  bool get canSetFeatured {
    if (subscriptionPlan == null || !isSubscriptionActive) return false;
    return subscriptionPlan!.features.allowFeaturedListing;
  }

  // Check if subscription is active
  bool get hasActiveSubscription {
    if (subscriptionPlan == null || subscriptionExpiryDate == null)
      return false;
    return isSubscriptionActive &&
        DateTime.now().isBefore(subscriptionExpiryDate!);
  }

  // Get days until subscription expires
  int get subscriptionDaysRemaining {
    if (subscriptionExpiryDate == null || !isSubscriptionActive) return 0;
    final remaining = subscriptionExpiryDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // Create a copy with updated fields
  BusinessModel copyWith({
    bool? isFeatured,
    DateTime? featuredUntil,
    int? featuredRank,
    double? priorityScore,
    int? engagementScore,
    SubscriptionPlan? subscriptionPlan,
    DateTime? subscriptionExpiryDate,
    bool? isSubscriptionActive,
  }) {
    return BusinessModel(
      id: id,
      name: name,
      tagline: tagline,
      description: description,
      category: category,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      emoji: emoji,
      address: address,
      city: city,
      state: state,
      locality: locality,
      latitude: latitude,
      longitude: longitude,
      serviceRadius: serviceRadius,
      mapLink: mapLink,
      phoneNumber: phoneNumber,
      whatsappNumber: whatsappNumber,
      email: email,
      websiteUrl: websiteUrl,
      facebookUrl: facebookUrl,
      instagramUrl: instagramUrl,
      youtubeUrl: youtubeUrl,
      isApproved: isApproved,
      isVerified: isVerified,
      verifiedDate: verifiedDate,
      rating: rating,
      reviewCount: reviewCount,
      reviews: reviews,
      qrCode: qrCode,
      digitalCatalog: digitalCatalog,
      hasOnlineBooking: hasOnlineBooking,
      bookingUrl: bookingUrl,
      canSendNotifications: canSendNotifications,
      followers: followers,
      analytics: analytics,
      ownerId: ownerId,
      isKYCVerified: isKYCVerified,
      documents: documents,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSponsored: isSponsored,
      ctaText: ctaText,
      ctaLink: ctaLink,
      images: images,
      videoUrl: videoUrl,
      metadata: metadata,
      videos: videos,
      activeOffers: activeOffers,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      featuredRank: featuredRank ?? this.featuredRank,
      distanceFromUser: distanceFromUser,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionExpiryDate:
          subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      priorityScore: priorityScore ?? this.priorityScore,
      engagementScore: engagementScore ?? this.engagementScore,
      canToggleFeatured: canToggleFeatured,
      featuredDaysRemaining: featuredDaysRemaining,
    );
  }

  // JSON serialization
  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String?,
      description: json['description'] as String,
      category: json['category'] as String,
      logoUrl: json['logoUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      emoji: json['emoji'] as String? ?? '🏪',
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      locality: json['locality'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      serviceRadius: json['serviceRadius'] as double?,
      mapLink: json['mapLink'] as String?,
      phoneNumber: json['phoneNumber'] as String,
      whatsappNumber: json['whatsappNumber'] as String?,
      email: json['email'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      instagramUrl: json['instagramUrl'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      isApproved: json['isApproved'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      verifiedDate: json['verifiedDate'] != null
          ? DateTime.parse(json['verifiedDate'] as String)
          : null,
      rating: json['rating'] as double?,
      reviewCount: json['reviewCount'] as int?,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList()
          : null,
      qrCode: json['qrCode'] as String?,
      digitalCatalog: json['digitalCatalog'] != null
          ? (json['digitalCatalog'] as List)
              .map((p) => Product.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
      hasOnlineBooking: json['hasOnlineBooking'] as bool? ?? false,
      bookingUrl: json['bookingUrl'] as String?,
      canSendNotifications: json['canSendNotifications'] as bool? ?? false,
      followers: json['followers'] as int?,
      analytics: json['analytics'] != null
          ? BusinessAnalytics.fromJson(
              json['analytics'] as Map<String, dynamic>)
          : null,
      ownerId: json['ownerId'] as String,
      isKYCVerified: json['isKYCVerified'] as bool? ?? false,
      documents: json['documents'] != null
          ? List<String>.from(json['documents'] as List)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSponsored: json['isSponsored'] as bool? ?? false,
      ctaText: json['ctaText'] as String?,
      ctaLink: json['ctaLink'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      videoUrl: json['videoUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'category': category,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'emoji': emoji,
      'address': address,
      'city': city,
      'state': state,
      'locality': locality,
      'latitude': latitude,
      'longitude': longitude,
      'serviceRadius': serviceRadius,
      'mapLink': mapLink,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'websiteUrl': websiteUrl,
      'facebookUrl': facebookUrl,
      'instagramUrl': instagramUrl,
      'youtubeUrl': youtubeUrl,
      'isApproved': isApproved,
      'isVerified': isVerified,
      'verifiedDate': verifiedDate?.toIso8601String(),
      'rating': rating,
      'reviewCount': reviewCount,
      'reviews': reviews?.map((r) => r.toJson()).toList(),
      'qrCode': qrCode,
      'digitalCatalog': digitalCatalog?.map((p) => p.toJson()).toList(),
      'hasOnlineBooking': hasOnlineBooking,
      'bookingUrl': bookingUrl,
      'canSendNotifications': canSendNotifications,
      'followers': followers,
      'analytics': analytics?.toJson(),
      'ownerId': ownerId,
      'isKYCVerified': isKYCVerified,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSponsored': isSponsored,
      'ctaText': ctaText,
      'ctaLink': ctaLink,
      'images': images,
      'videoUrl': videoUrl,
      'metadata': metadata,
    };
  }
}

// Review Model
class Review {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? images;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      rating: json['rating'] as double,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
    };
  }
}

// Product Model for Digital Catalog
class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String? category;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: json['price'] as double,
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'category': category,
    };
  }
}

// Business Analytics Model
class BusinessAnalytics {
  final int profileViews;
  final int callClicks;
  final int whatsappClicks;
  final int directionsClicks;
  final int websiteClicks;
  final Map<String, int>? dailyViews;

  BusinessAnalytics({
    required this.profileViews,
    required this.callClicks,
    required this.whatsappClicks,
    required this.directionsClicks,
    required this.websiteClicks,
    this.dailyViews,
  });

  factory BusinessAnalytics.fromJson(Map<String, dynamic> json) {
    return BusinessAnalytics(
      profileViews: json['profileViews'] as int,
      callClicks: json['callClicks'] as int,
      whatsappClicks: json['whatsappClicks'] as int,
      directionsClicks: json['directionsClicks'] as int,
      websiteClicks: json['websiteClicks'] as int,
      dailyViews: json['dailyViews'] != null
          ? Map<String, int>.from(json['dailyViews'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileViews': profileViews,
      'callClicks': callClicks,
      'whatsappClicks': whatsappClicks,
      'directionsClicks': directionsClicks,
      'websiteClicks': websiteClicks,
      'dailyViews': dailyViews,
    };
  }
}

// Business Video Model (NEW FEATURE 1: Business Videos)
class BusinessVideo {
  final String id;
  final String businessId;
  final String videoUrl;
  final String? thumbnailUrl;
  final String title;
  final String? description;
  final int duration; // in seconds
  final int views;
  final int likes;
  final int shares;
  final List<String>? productTags; // Shoppable tags
  final DateTime createdAt;
  final bool isActive;

  BusinessVideo({
    required this.id,
    required this.businessId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.title,
    this.description,
    required this.duration,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.productTags,
    required this.createdAt,
    this.isActive = true,
  });

  factory BusinessVideo.fromJson(Map<String, dynamic> json) {
    return BusinessVideo(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      duration: json['duration'] as int,
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      productTags: json['productTags'] != null
          ? List<String>.from(json['productTags'] as List)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'description': description,
      'duration': duration,
      'views': views,
      'likes': likes,
      'shares': shares,
      'productTags': productTags,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

// Business Offer Model (NEW FEATURE 2: Offers with Expiry)
class BusinessOffer {
  final String id;
  final String businessId;
  final String title;
  final String description;
  final String? imageUrl;
  final String discountText; // e.g., "50% OFF", "Buy 1 Get 1"
  final DateTime startDate;
  final DateTime expiryDate;
  final int? claimLimit;
  final int claimedCount;
  final String? promoCode;
  final String? termsConditions;
  final bool isActive;
  final String offerType; // "percentage", "fixed", "bogo", "custom"

  BusinessOffer({
    required this.id,
    required this.businessId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.discountText,
    required this.startDate,
    required this.expiryDate,
    this.claimLimit,
    this.claimedCount = 0,
    this.promoCode,
    this.termsConditions,
    this.isActive = true,
    this.offerType = 'percentage',
  });

  // Calculate time remaining
  Duration get timeRemaining => expiryDate.difference(DateTime.now());

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isExpiringSoon => timeRemaining.inHours < 24 && !isExpired;

  String get expiryText {
    if (isExpired) return 'Expired';
    final duration = timeRemaining;
    if (duration.inDays > 0) return '${duration.inDays}d left';
    if (duration.inHours > 0) return '${duration.inHours}h left';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m left';
    return 'Expiring soon';
  }

  factory BusinessOffer.fromJson(Map<String, dynamic> json) {
    return BusinessOffer(
      id: json['id'] as String,
      businessId: json['businessId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      discountText: json['discountText'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      claimLimit: json['claimLimit'] as int?,
      claimedCount: json['claimedCount'] as int? ?? 0,
      promoCode: json['promoCode'] as String?,
      termsConditions: json['termsConditions'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      offerType: json['offerType'] as String? ?? 'percentage',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'discountText': discountText,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'claimLimit': claimLimit,
      'claimedCount': claimedCount,
      'promoCode': promoCode,
      'termsConditions': termsConditions,
      'isActive': isActive,
      'offerType': offerType,
    };
  }
}

// ================ MONETIZATION MODELS ================

// Subscription Tier Enum
enum SubscriptionTier {
  free,
  basic,
  premium,
}

// Subscription Plan Model
class SubscriptionPlan {
  final String id;
  final String name;
  final SubscriptionTier tier;
  final double price; // Monthly price
  final String currency;
  final String description;
  final SubscriptionFeatures features;
  final List<String> highlights; // Key benefits to display
  final bool isPopular;
  final double? annualPrice; // Optional annual pricing
  final String? badgeText; // e.g., "MOST POPULAR", "BEST VALUE"

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    this.currency = 'INR',
    required this.description,
    required this.features,
    required this.highlights,
    this.isPopular = false,
    this.annualPrice,
    this.badgeText,
  });

  // Get human-readable tier name
  String get tierName {
    switch (tier) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.basic:
        return 'Basic';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  // Get annual savings percentage
  double? get annualSavingsPercent {
    if (annualPrice == null) return null;
    final monthlyTotal = price * 12;
    return ((monthlyTotal - annualPrice!) / monthlyTotal * 100);
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == 'SubscriptionTier.${json['tier']}',
        orElse: () => SubscriptionTier.free,
      ),
      price: json['price'] as double,
      currency: json['currency'] as String? ?? 'INR',
      description: json['description'] as String,
      features: SubscriptionFeatures.fromJson(
          json['features'] as Map<String, dynamic>),
      highlights: List<String>.from(json['highlights'] as List),
      isPopular: json['isPopular'] as bool? ?? false,
      annualPrice: json['annualPrice'] as double?,
      badgeText: json['badgeText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier.toString().split('.').last,
      'price': price,
      'currency': currency,
      'description': description,
      'features': features.toJson(),
      'highlights': highlights,
      'isPopular': isPopular,
      'annualPrice': annualPrice,
      'badgeText': badgeText,
    };
  }

  // Static factory methods for predefined plans
  static SubscriptionPlan get freePlan => SubscriptionPlan(
        id: 'free',
        name: 'Free',
        tier: SubscriptionTier.free,
        price: 0,
        description: 'Basic listing for small businesses',
        features: SubscriptionFeatures.freeTierFeatures(),
        highlights: [
          'Basic business profile',
          'Limited visibility',
          'Standard support',
        ],
      );

  static SubscriptionPlan get basicPlan => SubscriptionPlan(
        id: 'basic',
        name: 'Basic',
        tier: SubscriptionTier.basic,
        price: 499,
        description: 'Enhanced features for growing businesses',
        features: SubscriptionFeatures.basicTierFeatures(),
        highlights: [
          'Enhanced visibility',
          'Basic analytics',
          'Featured listing (3 days/month)',
          'Priority support',
        ],
        isPopular: true,
        badgeText: 'MOST POPULAR',
        annualPrice: 4990,
      );

  static SubscriptionPlan get premiumPlan => SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        tier: SubscriptionTier.premium,
        price: 1499,
        description: 'Complete solution for established businesses',
        features: SubscriptionFeatures.premiumTierFeatures(),
        highlights: [
          'Maximum visibility',
          'Advanced analytics',
          'Featured listing (unlimited)',
          'Priority ranking',
          'Video marketing',
          'Premium support',
        ],
        badgeText: 'BEST VALUE',
        annualPrice: 14990,
      );
}

// Subscription Features Model
class SubscriptionFeatures {
  final bool allowFeaturedListing;
  final int featuredDaysPerMonth; // 0 = unlimited, -1 = not allowed
  final bool priorityRanking;
  final bool advancedAnalytics;
  final bool videoMarketing;
  final int maxVideos; // -1 = unlimited
  final int maxOffers; // -1 = unlimited
  final bool customBranding;
  final bool removeAds;
  final bool prioritySupport;
  final bool socialMediaIntegration;
  final int maxPhotos; // -1 = unlimited
  final bool customerInsights;
  final bool promotionalTools;

  SubscriptionFeatures({
    this.allowFeaturedListing = false,
    this.featuredDaysPerMonth = -1,
    this.priorityRanking = false,
    this.advancedAnalytics = false,
    this.videoMarketing = false,
    this.maxVideos = 0,
    this.maxOffers = 0,
    this.customBranding = false,
    this.removeAds = false,
    this.prioritySupport = false,
    this.socialMediaIntegration = false,
    this.maxPhotos = 5,
    this.customerInsights = false,
    this.promotionalTools = false,
  });

  factory SubscriptionFeatures.fromJson(Map<String, dynamic> json) {
    return SubscriptionFeatures(
      allowFeaturedListing: json['allowFeaturedListing'] as bool? ?? false,
      featuredDaysPerMonth: json['featuredDaysPerMonth'] as int? ?? -1,
      priorityRanking: json['priorityRanking'] as bool? ?? false,
      advancedAnalytics: json['advancedAnalytics'] as bool? ?? false,
      videoMarketing: json['videoMarketing'] as bool? ?? false,
      maxVideos: json['maxVideos'] as int? ?? 0,
      maxOffers: json['maxOffers'] as int? ?? 0,
      customBranding: json['customBranding'] as bool? ?? false,
      removeAds: json['removeAds'] as bool? ?? false,
      prioritySupport: json['prioritySupport'] as bool? ?? false,
      socialMediaIntegration: json['socialMediaIntegration'] as bool? ?? false,
      maxPhotos: json['maxPhotos'] as int? ?? 5,
      customerInsights: json['customerInsights'] as bool? ?? false,
      promotionalTools: json['promotionalTools'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowFeaturedListing': allowFeaturedListing,
      'featuredDaysPerMonth': featuredDaysPerMonth,
      'priorityRanking': priorityRanking,
      'advancedAnalytics': advancedAnalytics,
      'videoMarketing': videoMarketing,
      'maxVideos': maxVideos,
      'maxOffers': maxOffers,
      'customBranding': customBranding,
      'removeAds': removeAds,
      'prioritySupport': prioritySupport,
      'socialMediaIntegration': socialMediaIntegration,
      'maxPhotos': maxPhotos,
      'customerInsights': customerInsights,
      'promotionalTools': promotionalTools,
    };
  }

  // Factory methods for each tier
  static SubscriptionFeatures freeTierFeatures() {
    return SubscriptionFeatures(
      allowFeaturedListing: false,
      featuredDaysPerMonth: -1,
      priorityRanking: false,
      advancedAnalytics: false,
      videoMarketing: false,
      maxVideos: 0,
      maxOffers: 1,
      customBranding: false,
      removeAds: false,
      prioritySupport: false,
      socialMediaIntegration: false,
      maxPhotos: 5,
      customerInsights: false,
      promotionalTools: false,
    );
  }

  static SubscriptionFeatures basicTierFeatures() {
    return SubscriptionFeatures(
      allowFeaturedListing: true,
      featuredDaysPerMonth: 3,
      priorityRanking: true,
      advancedAnalytics: false,
      videoMarketing: false,
      maxVideos: 3,
      maxOffers: 5,
      customBranding: false,
      removeAds: false,
      prioritySupport: true,
      socialMediaIntegration: true,
      maxPhotos: 15,
      customerInsights: false,
      promotionalTools: true,
    );
  }

  static SubscriptionFeatures premiumTierFeatures() {
    return SubscriptionFeatures(
      allowFeaturedListing: true,
      featuredDaysPerMonth: 0, // 0 = unlimited
      priorityRanking: true,
      advancedAnalytics: true,
      videoMarketing: true,
      maxVideos: -1, // -1 = unlimited
      maxOffers: -1, // -1 = unlimited
      customBranding: true,
      removeAds: true,
      prioritySupport: true,
      socialMediaIntegration: true,
      maxPhotos: -1, // -1 = unlimited
      customerInsights: true,
      promotionalTools: true,
    );
  }
}

// Business Monetization Helper Class
class BusinessMonetization {
  // Calculate priority score for sorting businesses
  static double calculatePriorityScore(BusinessModel business) {
    return business.calculatePriorityScore();
  }

  // Sort businesses by priority score
  static List<BusinessModel> sortByPriority(List<BusinessModel> businesses) {
    final sorted = List<BusinessModel>.from(businesses);
    sorted.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return sorted;
  }

  // Check if business can toggle featured status
  static bool canToggleFeatured(BusinessModel business) {
    return business.canSetFeatured;
  }

  // Toggle featured status with validation
  static BusinessModel? toggleFeaturedStatus(
      BusinessModel business, bool newStatus) {
    if (!canToggleFeatured(business)) return null;

    // Check if business has remaining featured days
    if (newStatus) {
      final features = business.subscriptionPlan!.features;
      if (features.featuredDaysPerMonth == -1) return null; // Not allowed
      if (features.featuredDaysPerMonth > 0 &&
          business.featuredDaysRemaining <= 0) {
        return null; // No days remaining
      }
    }

    return business.copyWith(
      isFeatured: newStatus,
      featuredUntil:
          newStatus ? DateTime.now().add(const Duration(days: 30)) : null,
    );
  }

  // Get subscription upgrade recommendation
  static SubscriptionPlan? getUpgradeRecommendation(BusinessModel business) {
    if (business.subscriptionPlan == null) {
      return SubscriptionPlan.basicPlan;
    }

    switch (business.subscriptionPlan!.tier) {
      case SubscriptionTier.free:
        return SubscriptionPlan.basicPlan;
      case SubscriptionTier.basic:
        return SubscriptionPlan.premiumPlan;
      case SubscriptionTier.premium:
        return null; // Already at highest tier
    }
  }

  // Check if feature is unlocked for business
  static bool isFeatureUnlocked(BusinessModel business, String featureName) {
    if (!business.hasActiveSubscription) {
      return _isFreeFeature(featureName);
    }

    final features = business.subscriptionPlan!.features;
    switch (featureName) {
      case 'featured_listing':
        return features.allowFeaturedListing;
      case 'priority_ranking':
        return features.priorityRanking;
      case 'advanced_analytics':
        return features.advancedAnalytics;
      case 'video_marketing':
        return features.videoMarketing;
      case 'custom_branding':
        return features.customBranding;
      case 'remove_ads':
        return features.removeAds;
      case 'priority_support':
        return features.prioritySupport;
      case 'customer_insights':
        return features.customerInsights;
      default:
        return false;
    }
  }

  static bool _isFreeFeature(String featureName) {
    // Features available in free tier
    const freeFeatures = [
      'basic_profile',
      'standard_support',
    ];
    return freeFeatures.contains(featureName);
  }

  // Get feature limit text
  static String getFeatureLimitText(
      BusinessModel business, String featureType) {
    if (!business.hasActiveSubscription) {
      return 'Upgrade to unlock';
    }

    final features = business.subscriptionPlan!.features;
    switch (featureType) {
      case 'videos':
        if (features.maxVideos == -1) return 'Unlimited';
        if (features.maxVideos == 0) return 'Upgrade to unlock';
        return '${features.maxVideos} videos';
      case 'offers':
        if (features.maxOffers == -1) return 'Unlimited';
        if (features.maxOffers == 0) return 'Upgrade to unlock';
        return '${features.maxOffers} offers';
      case 'photos':
        if (features.maxPhotos == -1) return 'Unlimited';
        return '${features.maxPhotos} photos';
      case 'featured_days':
        if (features.featuredDaysPerMonth == 0) return 'Unlimited';
        if (features.featuredDaysPerMonth == -1) return 'Not available';
        return '${features.featuredDaysPerMonth} days/month';
      default:
        return '';
    }
  }
}
