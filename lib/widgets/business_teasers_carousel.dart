/// Business Teasers Carousel Widget
/// Sponsored business cards with clickable CTAs

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class BusinessTeaser {
  final String id;
  final String businessName;
  final String tagline;
  final String? description;
  final String emoji;
  final String? logoUrl;
  final String? ctaText;
  final String? ctaLink;
  final String? phoneNumber;
  final List<Color> gradientColors;
  final bool isVerified;
  final bool isSponsored;
  final double? rating;
  final int? reviewCount;

  BusinessTeaser({
    required this.id,
    required this.businessName,
    required this.tagline,
    this.description,
    required this.emoji,
    this.logoUrl,
    this.ctaText,
    this.ctaLink,
    this.phoneNumber,
    required this.gradientColors,
    this.isVerified = false,
    this.isSponsored = false,
    this.rating,
    this.reviewCount,
  });
}

class BusinessTeasersCarousel extends StatefulWidget {
  final VoidCallback? onViewAllTap;
  final Function(BusinessTeaser)? onBusinessTap;

  const BusinessTeasersCarousel({
    super.key,
    this.onViewAllTap,
    this.onBusinessTap,
  });

  @override
  State<BusinessTeasersCarousel> createState() =>
      _BusinessTeasersCarouselState();
}

class _BusinessTeasersCarouselState extends State<BusinessTeasersCarousel> {
  List<BusinessTeaser> _businesses = [];
  bool _isLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final random = Random();
    final mockBusinesses = [
      {
        'name': 'Sri Lakshmi Jewellers',
        'tagline': '50% Off on Gold Making Charges',
        'desc': 'Premium gold & diamond jewellery',
        'emoji': '💎',
        'cta': 'Visit Store',
        'colors': [const Color(0xFFFFD700), const Color(0xFFFFA500)],
        'verified': true,
        'sponsored': true,
        'rating': 4.8,
        'reviews': 234,
      },
      {
        'name': 'Quick Home Services',
        'tagline': 'AC Service at ₹299 Only',
        'desc': 'Trusted home repair & maintenance',
        'emoji': '🔧',
        'cta': 'Book Now',
        'colors': [const Color(0xFF2196F3), const Color(0xFF1976D2)],
        'verified': true,
        'sponsored': true,
        'rating': 4.5,
        'reviews': 567,
      },
      {
        'name': 'Fresh Farm Organics',
        'tagline': 'Free Delivery on Orders Above ₹500',
        'desc': 'Farm-fresh vegetables & fruits',
        'emoji': '🥬',
        'cta': 'Order Now',
        'colors': [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
        'verified': false,
        'sponsored': true,
        'rating': 4.7,
        'reviews': 189,
      },
      {
        'name': 'City Health Clinic',
        'tagline': 'Free Health Checkup This Week',
        'desc': 'Multi-specialty healthcare',
        'emoji': '🏥',
        'cta': 'Book Appointment',
        'colors': [const Color(0xFFE91E63), const Color(0xFFC2185B)],
        'verified': true,
        'sponsored': false,
        'rating': 4.9,
        'reviews': 412,
      },
      {
        'name': 'Anand Sweets',
        'tagline': 'Buy 1 Get 1 Free on Sweets',
        'desc': 'Traditional Indian sweets',
        'emoji': '🍬',
        'cta': 'View Menu',
        'colors': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
        'verified': true,
        'sponsored': true,
        'rating': 4.6,
        'reviews': 789,
      },
    ];

    setState(() {
      _businesses = mockBusinesses.map((b) {
        return BusinessTeaser(
          id: 'biz_${random.nextInt(10000)}',
          businessName: b['name'] as String,
          tagline: b['tagline'] as String,
          description: b['desc'] as String,
          emoji: b['emoji'] as String,
          ctaText: b['cta'] as String,
          gradientColors: b['colors'] as List<Color>,
          isVerified: b['verified'] as bool,
          isSponsored: b['sponsored'] as bool,
          rating: b['rating'] as double,
          reviewCount: b['reviews'] as int,
        );
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_businesses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '💼 ',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Text(
                    'Featured Businesses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: widget.onViewAllTap,
                child: const Text('Explore'),
              ),
            ],
          ),
        ),
        // Carousel
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _businesses.length,
            itemBuilder: (context, index) {
              return _buildBusinessCard(_businesses[index], index);
            },
          ),
        ),
        // Page Indicators
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_businesses.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? _businesses[index].gradientColors.first
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(BusinessTeaser business, int index) {
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: isActive ? 0 : 12,
      ),
      child: GestureDetector(
        onTap: () => widget.onBusinessTap?.call(business),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: business.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: business.gradientColors.first.withOpacity(0.4),
                blurRadius: isActive ? 15 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                top: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Logo/Emoji and Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              business.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (business.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (business.isSponsored) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Ad',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Business Name
                    Text(
                      business.businessName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Tagline
                    Text(
                      business.tagline,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Rating and CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating
                        if (business.rating != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${business.rating} (${business.reviewCount})',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        // CTA Button
                        if (business.ctaText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              business.ctaText!,
                              style: TextStyle(
                                color: business.gradientColors.first,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
