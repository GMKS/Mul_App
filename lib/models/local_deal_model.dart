/// Local Deal Model
/// Represents a deal/offer from a local business

class LocalDeal {
  final String id;
  final String title;
  final String description;
  final String? businessId;
  final String businessName;
  final String? businessPhone;
  final String? businessAddress;
  final String category;
  final String emoji;
  final String? imageUrl;
  final double? originalPrice;
  final double? discountedPrice;
  final int? discountPercent;
  final double? discountAmount;
  final String discountType; // 'percentage' or 'flat'
  final String? promoCode;
  final String? termsConditions;
  final String? affiliateLink;
  final String city;
  final String state;
  final String? area;
  final double? latitude;
  final double? longitude;
  final int radiusKm;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool isActive;
  final bool isSponsored;
  final bool isFeatured;
  final int priorityRank;
  final String approvalStatus; // 'pending', 'approved', 'rejected'
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final int viewsCount;
  final int claimsCount;
  final int? maxClaims;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed properties
  final String? categoryColor;
  final String? categoryIcon;
  final String? urgencyStatus;
  final double? hoursRemaining;

  LocalDeal({
    required this.id,
    required this.title,
    required this.description,
    this.businessId,
    required this.businessName,
    this.businessPhone,
    this.businessAddress,
    required this.category,
    this.emoji = '🏷️',
    this.imageUrl,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercent,
    this.discountAmount,
    this.discountType = 'percentage',
    this.promoCode,
    this.termsConditions,
    this.affiliateLink,
    required this.city,
    this.state = 'Telangana',
    this.area,
    this.latitude,
    this.longitude,
    this.radiusKm = 10,
    required this.startsAt,
    required this.expiresAt,
    this.isActive = true,
    this.isSponsored = false,
    this.isFeatured = false,
    this.priorityRank = 0,
    this.approvalStatus = 'pending',
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.viewsCount = 0,
    this.claimsCount = 0,
    this.maxClaims,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.categoryColor,
    this.categoryIcon,
    this.urgencyStatus,
    this.hoursRemaining,
  });

  /// Create from Supabase JSON response
  factory LocalDeal.fromJson(Map<String, dynamic> json) {
    return LocalDeal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      businessId: json['business_id'] as String?,
      businessName: json['business_name'] as String,
      businessPhone: json['business_phone'] as String?,
      businessAddress: json['business_address'] as String?,
      category: json['category'] as String,
      emoji: json['emoji'] as String? ?? '🏷️',
      imageUrl: json['image_url'] as String?,
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      discountPercent: json['discount_percent'] as int?,
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount'] as num).toDouble()
          : null,
      discountType: json['discount_type'] as String? ?? 'percentage',
      promoCode: json['promo_code'] as String?,
      termsConditions: json['terms_conditions'] as String?,
      affiliateLink: json['affiliate_link'] as String?,
      city: json['city'] as String,
      state: json['state'] as String? ?? 'Telangana',
      area: json['area'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      radiusKm: json['radius_km'] as int? ?? 10,
      startsAt: DateTime.parse(json['starts_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      isSponsored: json['is_sponsored'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      priorityRank: json['priority_rank'] as int? ?? 0,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      claimsCount: json['claims_count'] as int? ?? 0,
      maxClaims: json['max_claims'] as int?,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryColor: json['category_color'] as String?,
      categoryIcon: json['category_icon'] as String?,
      urgencyStatus: json['urgency_status'] as String?,
      hoursRemaining: json['hours_remaining'] != null
          ? (json['hours_remaining'] as num).toDouble()
          : null,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'business_id': businessId,
      'business_name': businessName,
      'business_phone': businessPhone,
      'business_address': businessAddress,
      'category': category,
      'emoji': emoji,
      'image_url': imageUrl,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'discount_type': discountType,
      'promo_code': promoCode,
      'terms_conditions': termsConditions,
      'affiliate_link': affiliateLink,
      'city': city,
      'state': state,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'radius_km': radiusKm,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
      'is_sponsored': isSponsored,
      'is_featured': isFeatured,
      'priority_rank': priorityRank,
      'approval_status': approvalStatus,
      'max_claims': maxClaims,
      'created_by': createdBy,
    };
  }

  /// Check if deal is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if deal is expiring soon (within 24 hours)
  bool get isExpiringSoon {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.inHours <= 24 && remaining.inHours > 0;
  }

  /// Get remaining time as formatted string
  String get remainingTimeText {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return 'Expiring soon';
  }

  /// Get savings amount
  double get savingsAmount => (originalPrice ?? 0) - (discountedPrice ?? 0);

  /// Check if deal has promo code
  bool get hasPromoCode => promoCode != null && promoCode!.isNotEmpty;

  /// Check if max claims reached
  bool get isClaimLimitReached =>
      maxClaims != null && claimsCount >= maxClaims!;

  /// Check if deal can be claimed
  bool get canBeClaimed => isActive && !isExpired && !isClaimLimitReached;

  /// Copy with method for updates
  LocalDeal copyWith({
    String? id,
    String? title,
    String? description,
    String? businessId,
    String? businessName,
    String? businessPhone,
    String? businessAddress,
    String? category,
    String? emoji,
    String? imageUrl,
    double? originalPrice,
    double? discountedPrice,
    int? discountPercent,
    String? promoCode,
    String? termsConditions,
    String? affiliateLink,
    String? city,
    String? state,
    String? area,
    double? latitude,
    double? longitude,
    int? radiusKm,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool? isActive,
    bool? isSponsored,
    bool? isFeatured,
    int? priorityRank,
    int? viewsCount,
    int? claimsCount,
    int? maxClaims,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryColor,
    String? categoryIcon,
    String? urgencyStatus,
    double? hoursRemaining,
  }) {
    return LocalDeal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      businessPhone: businessPhone ?? this.businessPhone,
      businessAddress: businessAddress ?? this.businessAddress,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      imageUrl: imageUrl ?? this.imageUrl,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      promoCode: promoCode ?? this.promoCode,
      termsConditions: termsConditions ?? this.termsConditions,
      affiliateLink: affiliateLink ?? this.affiliateLink,
      city: city ?? this.city,
      state: state ?? this.state,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      isSponsored: isSponsored ?? this.isSponsored,
      isFeatured: isFeatured ?? this.isFeatured,
      priorityRank: priorityRank ?? this.priorityRank,
      viewsCount: viewsCount ?? this.viewsCount,
      claimsCount: claimsCount ?? this.claimsCount,
      maxClaims: maxClaims ?? this.maxClaims,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      urgencyStatus: urgencyStatus ?? this.urgencyStatus,
      hoursRemaining: hoursRemaining ?? this.hoursRemaining,
    );
  }

  @override
  String toString() {
    return 'LocalDeal(id: $id, title: $title, business: $businessName, discount: $discountPercent%)';
  }
}

/// Deal Category model
class DealCategory {
  final String id;
  final String name;
  final String emoji;
  final String color;
  final String? iconName;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;

  DealCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.iconName,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory DealCategory.fromJson(Map<String, dynamic> json) {
    return DealCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      color: json['color'] as String,
      iconName: json['icon_name'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emoji': emoji,
      'color': color,
      'icon_name': iconName,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}

/// Deal Claim model
class DealClaim {
  final String id;
  final String dealId;
  final String userId;
  final DateTime claimedAt;
  final DateTime? redeemedAt;
  final bool isRedeemed;

  DealClaim({
    required this.id,
    required this.dealId,
    required this.userId,
    required this.claimedAt,
    this.redeemedAt,
    this.isRedeemed = false,
  });

  factory DealClaim.fromJson(Map<String, dynamic> json) {
    return DealClaim(
      id: json['id'] as String,
      dealId: json['deal_id'] as String,
      userId: json['user_id'] as String,
      claimedAt: DateTime.parse(json['claimed_at'] as String),
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.parse(json['redeemed_at'] as String)
          : null,
      isRedeemed: json['is_redeemed'] as bool? ?? false,
    );
  }
}
