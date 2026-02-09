/// Business Teasers Carousel Widget
/// Sponsored business cards with clickable CTAs
/// Integrated with Supabase for real-time data
/// Supports multilingual content (English, Telugu, Hindi)

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../models/business_model.dart';
import '../screens/business_profile_screen.dart';
import '../services/language_service.dart';

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
  final BusinessModel? fullBusinessModel; // Link to full model
  // Location fields
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;

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
    this.fullBusinessModel,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
  });

  // Convert to full BusinessModel for profile screen
  BusinessModel toBusinessModel() {
    if (fullBusinessModel != null) return fullBusinessModel!;

    return BusinessModel(
      id: id,
      name: businessName,
      tagline: tagline,
      description: description ?? 'No description available',
      category: 'General',
      emoji: emoji,
      logoUrl: logoUrl,
      address: address ?? 'Address not available',
      city: city ?? 'City',
      state: 'State',
      phoneNumber: phoneNumber ?? '0000000000',
      whatsappNumber: phoneNumber,
      isApproved: true,
      isVerified: isVerified,
      rating: rating,
      reviewCount: reviewCount,
      ownerId: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSponsored: isSponsored,
      ctaText: ctaText,
      ctaLink: ctaLink,
      latitude: latitude,
      longitude: longitude,
    );
  }
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
  String _currentLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguageAndBusinesses();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload businesses when dependencies change (e.g., language change)
    _checkLanguageChange();
  }

  Future<void> _checkLanguageChange() async {
    final newLanguage = await LanguageService.getPrimaryLanguage();
    if (newLanguage != _currentLanguage) {
      print('🔄 Language changed from $_currentLanguage to $newLanguage');
      _currentLanguage = newLanguage;
      setState(() {
        _isLoading = true;
      });
      await _loadBusinesses();
    }
  }

  Future<void> _loadLanguageAndBusinesses() async {
    // Get current language preference
    _currentLanguage = await LanguageService.getPrimaryLanguage();
    print('🌐 Initial language: $_currentLanguage');
    await _loadBusinesses();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    try {
      // Fetch featured businesses from Supabase with all translation columns
      final response = await Supabase.instance.client
          .from('businesses')
          .select(
              '*, name_te, name_hi, offer_te, offer_hi, tagline_te, tagline_hi, description_te, description_hi, cta_text_te, cta_text_hi')
          .eq('is_featured', true)
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .limit(20);

      print(
          '📥 Fetched ${(response as List).length} featured businesses from Supabase');
      print('🌐 Current language: $_currentLanguage');

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      if (data.isNotEmpty) {
        // Deduplicate based on ID only (not name)
        final seenIds = <String>{};
        final uniqueData = data.where((b) {
          final id = (b['id'] ?? '').toString();

          // Skip if we've already seen this ID or if ID is empty
          if (id.isEmpty) return false;
          if (seenIds.contains(id)) {
            print('🚫 Skipping duplicate business ID: $id');
            return false;
          }

          seenIds.add(id);
          return true;
        }).toList();

        print('✅ Processing ${uniqueData.length} unique businesses');

        setState(() {
          // Convert unique businesses to BusinessTeaser with localized content
          _businesses = uniqueData.map((b) {
            // Get localized content based on user's language
            // ALWAYS fallback to English if translation is not available
            final name = _getLocalizedText(b, 'name', _currentLanguage) ??
                b['name']?.toString() ??
                'Unnamed Business';

            final tagline = _getLocalizedText(b, 'offer', _currentLanguage) ??
                b['offer']?.toString() ??
                _getLocalizedText(b, 'tagline', _currentLanguage) ??
                b['tagline']?.toString() ??
                b['description']?.toString() ??
                'Visit us today!';

            final description =
                _getLocalizedText(b, 'description', _currentLanguage) ??
                    b['description']?.toString();

            final ctaText =
                _getLocalizedText(b, 'cta_text', _currentLanguage) ??
                    b['cta_text']?.toString() ??
                    _getDefaultCtaText();

            print(
                '📝 Business ID: ${b['id']} | Name: $name | Has ${_currentLanguage} translation: ${_getLocalizedText(b, 'name', _currentLanguage) != null}');

            final city = _getLocalizedText(b, 'city', _currentLanguage) ??
                b['city']?.toString() ??
                'City';

            return BusinessTeaser(
              id: b['id']?.toString() ?? 'biz_${Random().nextInt(10000)}',
              businessName: name,
              tagline: tagline,
              description: description,
              emoji: _getCategoryEmoji(b['category']),
              logoUrl: b['logo_url'] ?? b['image_url'],
              ctaText: ctaText,
              ctaLink: b['cta_url'],
              phoneNumber: b['phone'],
              gradientColors: _getGradientColors(b['category']),
              isVerified: b['is_verified'] ?? false,
              isSponsored: b['is_ad'] ?? false,
              rating: (b['rating'] as num?)?.toDouble(),
              reviewCount: b['review_count'] as int?,
              address: b['address'],
              city: city,
              latitude: (b['latitude'] as num?)?.toDouble(),
              longitude: (b['longitude'] as num?)?.toDouble(),
            );
          }).toList();

          print(
              '✅ Loaded ${_businesses.length} unique businesses in language: $_currentLanguage');
          _isLoading = false;
        });
      } else {
        // Fallback to mock data if no featured businesses in Supabase
        _loadMockBusinesses();
      }
    } catch (e) {
      print('❌ Error fetching businesses from Supabase: $e');
      // Fallback to mock data on error
      _loadMockBusinesses();
    }
  }

  /// Get localized text based on user's language
  /// Falls back to English if translation is not available
  String? _getLocalizedText(
      Map<String, dynamic> data, String fieldName, String langCode) {
    // Try to get the localized version first
    if (langCode != 'en') {
      final localizedField = '${fieldName}_$langCode';
      final localizedValue = data[localizedField];
      if (localizedValue != null && localizedValue.toString().isNotEmpty) {
        return localizedValue.toString();
      }
    }
    // Fallback to English (default field)
    return data[fieldName]?.toString();
  }

  /// Get localized header text for "Featured Businesses"
  String _getHeaderText() {
    switch (_currentLanguage) {
      case 'te':
        return 'ఫీచర్డ్ వ్యాపారాలు';
      case 'hi':
        return 'फीचर्ड बिजनेस';
      default:
        return 'Featured Businesses';
    }
  }

  /// Get localized "Explore" button text
  String _getExploreText() {
    switch (_currentLanguage) {
      case 'te':
        return 'అన్వేషించండి';
      case 'hi':
        return 'खोजें';
      default:
        return 'Explore';
    }
  }

  /// Get default CTA text based on language
  String _getDefaultCtaText() {
    switch (_currentLanguage) {
      case 'te':
        return 'స్టోర్ సందర్శించండి';
      case 'hi':
        return 'स्टोर पर जाएं';
      default:
        return 'Visit Store';
    }
  }

  /// Get localized 'Verified' badge text
  String _getVerifiedText() {
    switch (_currentLanguage) {
      case 'te':
        return 'ధృవీకరించబడింది';
      case 'hi':
        return 'सत्यापित';
      default:
        return 'Verified';
    }
  }

  /// Get localized 'Ad' badge text
  String _getAdText() {
    switch (_currentLanguage) {
      case 'te':
        return 'ప్రాయోజిత';
      case 'hi':
        return 'विज्ञापन';
      default:
        return 'Ad';
    }
  }

  /// Get localized 'Map' button text
  String _getMapText() {
    switch (_currentLanguage) {
      case 'te':
        return 'మ్యాప్';
      case 'hi':
        return 'मानचित्र';
      default:
        return 'Map';
    }
  }

  /// Get emoji based on business category
  String _getCategoryEmoji(String? category) {
    switch (category?.toLowerCase()) {
      case 'jewellery':
      case 'jewelry':
        return '💎';
      case 'restaurant':
      case 'food':
        return '🍽️';
      case 'cafe':
        return '☕';
      case 'grocery':
        return '🛒';
      case 'pharmacy':
        return '💊';
      case 'hospital':
      case 'healthcare':
        return '🏥';
      case 'salon':
        return '💇';
      case 'gym':
      case 'fitness':
        return '🏋️';
      case 'education':
        return '📚';
      case 'electronics':
        return '📱';
      case 'fashion':
        return '👗';
      case 'books':
        return '📖';
      case 'services':
        return '🔧';
      case 'home decor':
        return '🏠';
      case 'automobile':
        return '🚗';
      default:
        return '🏪';
    }
  }

  /// Get gradient colors based on business category
  List<Color> _getGradientColors(String? category) {
    switch (category?.toLowerCase()) {
      case 'jewellery':
      case 'jewelry':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 'restaurant':
      case 'food':
        return [const Color(0xFFFF5722), const Color(0xFFE64A19)];
      case 'cafe':
        return [const Color(0xFF795548), const Color(0xFF5D4037)];
      case 'grocery':
        return [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
      case 'pharmacy':
        return [const Color(0xFF2196F3), const Color(0xFF1976D2)];
      case 'hospital':
      case 'healthcare':
        return [const Color(0xFFE91E63), const Color(0xFFC2185B)];
      case 'salon':
        return [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)];
      case 'gym':
      case 'fitness':
        return [const Color(0xFFFF9800), const Color(0xFFF57C00)];
      case 'education':
        return [const Color(0xFF3F51B5), const Color(0xFF303F9F)];
      case 'electronics':
        return [const Color(0xFF607D8B), const Color(0xFF455A64)];
      case 'fashion':
        return [const Color(0xFFE91E63), const Color(0xFFAD1457)];
      case 'books':
        return [const Color(0xFF8D6E63), const Color(0xFF6D4C41)];
      case 'services':
        return [const Color(0xFF2196F3), const Color(0xFF1565C0)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
  }

  /// Load mock businesses as fallback
  void _loadMockBusinesses() {
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
        'city': 'Hyderabad',
        'address': '123 Main Street, Ameerpet',
        'lat': 17.4374,
        'lng': 78.4487,
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
        'city': 'Secunderabad',
        'address': '45 Service Road, Paradise',
        'lat': 17.4399,
        'lng': 78.4983,
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
        'city': 'Medchal',
        'address': '78 Farm Road, Kompally',
        'lat': 17.5449,
        'lng': 78.4836,
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
        'city': 'Kukatpally',
        'address': '12 Health Avenue, KPHB',
        'lat': 17.4947,
        'lng': 78.3996,
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
        'city': 'Banjara Hills',
        'address': '56 Sweet Lane, Road No. 12',
        'lat': 17.4156,
        'lng': 78.4347,
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
          city: b['city'] as String?,
          address: b['address'] as String?,
          latitude: b['lat'] as double?,
          longitude: b['lng'] as double?,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '💼 ',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            _getHeaderText(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Top picks in your city.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: widget.onViewAllTap,
                    child: Text(_getExploreText()),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Carousel
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _businesses.length,
            padEnds: false,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildBusinessCard(_businesses[index], index),
              );
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

  Future<void> _openMap(double lat, double lng) async {
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
        onTap: () {
          // Open full business profile screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessProfileScreen(
                business: business.toBusinessModel(),
              ),
            ),
          );
          widget.onBusinessTap?.call(business);
        },
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Logo/Emoji and Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              business.emoji,
                              style: const TextStyle(fontSize: 24),
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getVerifiedText(),
                                      style: const TextStyle(
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
                                child: Text(
                                  _getAdText(),
                                  style: const TextStyle(
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
                    const SizedBox(height: 10),
                    // Business Name
                    Flexible(
                      child: Text(
                        business.businessName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Tagline
                    Flexible(
                      child: Text(
                        business.tagline,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Location indicator
                    if (business.city != null && business.city!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.city!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (business.latitude != null &&
                              business.longitude != null)
                            GestureDetector(
                              onTap: () => _openMap(
                                  business.latitude!, business.longitude!),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.map,
                                        size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getMapText(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
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
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${business.rating} (${business.reviewCount})',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        // CTA Button
                        if (business.ctaText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              business.ctaText!,
                              style: TextStyle(
                                color: business.gradientColors.first,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
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
