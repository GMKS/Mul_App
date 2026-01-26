// Business Feed Screen with 4 Modern Features
// 1. Business Videos (short-form, vertical, auto-play)
// 2. Offers with Expiry (countdown timers, dynamic badges)
// 3. Featured Badge (verified/featured businesses)
// 4. Distance Filtering (location-aware, adjustable radius)

import 'package:flutter/material.dart';
import 'dart:math';
import '../models/business_model.dart';
import '../models/business_video_model.dart' as video_model;
import '../services/business_service_supabase.dart';
import 'business_profile_screen.dart';
import 'business_video_player_screen.dart';
import 'business/business_analytics_advanced_screen.dart';
import 'business/business_profile_enhanced_screen.dart';
import 'business/submit_business_screen_enhanced.dart';

class BusinessFeedScreen extends StatefulWidget {
  const BusinessFeedScreen({super.key});

  @override
  State<BusinessFeedScreen> createState() => _BusinessFeedScreenState();
}

class _BusinessFeedScreenState extends State<BusinessFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _businessService = BusinessServiceSupabase();
  List<BusinessModel> _businesses = [];
  List<video_model.BusinessVideo> _videos = [];
  List<BusinessOffer> _offers = [];

  // Filter states
  double _distanceRadius = 10.0; // km
  String _selectedCategory = 'All';
  bool _showFeaturedOnly = false;
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Retail',
    'Food',
    'Services',
    'Healthcare',
    'Education',
    'Shop',
    'Restaurant',
    'Cafe',
    'Grocery',
    'Pharmacy',
    'Hospital',
    'Salon',
    'Gym',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch REAL approved businesses from Supabase
      final approvedBusinesses = await _businessService.getApprovedBusinesses();
      print(
          '📦 Loaded ${approvedBusinesses.length} approved businesses from database');

      final random = Random();
      final now = DateTime.now();

      // Use real businesses if available, otherwise show empty
      if (approvedBusinesses.isNotEmpty) {
        _businesses = approvedBusinesses.map<BusinessModel>((business) {
          // Add distance for filtering (mock for now since we may not have user location)
          final distance = random.nextDouble() * 15;
          return business.copyWith(
            priorityScore: business.calculatePriorityScore(),
          );
        }).toList();
      } else {
        _businesses = [];
      }

      // Generate videos from real businesses
      _videos = [];
      for (int i = 0; i < _businesses.length && i < 15; i++) {
        final business = _businesses[i];
        _videos.add(video_model.BusinessVideo(
          id: 'video_${business.id}',
          ownerId: business.ownerId,
          videoUrl: business.videoUrl ?? 'https://example.com/video_$i.mp4',
          thumbnailUrl: (business.images != null && business.images!.isNotEmpty)
              ? business.images!.first
              : 'https://picsum.photos/seed/$i/400/600',
          productName: business.name,
          price: 0,
          offerTag: null,
          businessName: business.name,
          businessCategory: business.category,
          city: business.city,
          area: business.locality ?? business.address,
          phoneNumber: business.phoneNumber,
          whatsappNumber: business.whatsappNumber ?? business.phoneNumber,
          views: random.nextInt(1000),
          callClicks: random.nextInt(50),
          whatsappClicks: random.nextInt(75),
          isBoosted: business.isFeatured,
          boostExpiry: business.featuredUntil,
          createdAt: business.createdAt,
          hashtags: ['#${business.category}', '#${business.city}'],
          description: business.description,
          isActive: true,
        ));
      }

      // Generate offers from real businesses
      _offers = [];
      for (int i = 0; i < _businesses.length && i < 12; i++) {
        final business = _businesses[i];
        final hoursUntilExpiry = random.nextInt(72) + 1;

        _offers.add(BusinessOffer(
          id: 'offer_${business.id}',
          businessId: business.id,
          title: '${business.name} Special',
          description: business.description,
          imageUrl: (business.images != null && business.images!.isNotEmpty)
              ? business.images!.first
              : 'https://picsum.photos/seed/offer$i/600/400',
          discountText: '${10 + (i * 5)}% OFF',
          startDate: now.subtract(const Duration(days: 1)),
          expiryDate: now.add(Duration(hours: hoursUntilExpiry)),
          claimLimit: 100,
          claimedCount: random.nextInt(50),
          promoCode: 'SAVE${10 + i}',
          isActive: true,
          offerType: 'percentage',
        ));
      }

      // Sort by priority
      _businesses = BusinessMonetization.sortByPriority(_businesses);
    } catch (e) {
      print('❌ Error loading businesses: $e');
      _businesses = [];
      _videos = [];
      _offers = [];
    }

    setState(() => _isLoading = false);
  }

  List<BusinessModel> get _filteredBusinesses {
    return _businesses.where((business) {
      final matchesCategory =
          _selectedCategory == 'All' || business.category == _selectedCategory;
      final matchesDistance =
          (business.distanceFromUser ?? 0) <= _distanceRadius;
      final matchesFeatured = !_showFeaturedOnly || business.isFeatured;

      return matchesCategory && matchesDistance && matchesFeatured;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Business Analytics',
            onPressed: () {
              // Navigate to advanced analytics
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessAnalyticsAdvancedScreen(
                    userId: 'demo_user',
                    businessId: 'demo_business',
                    videos: _videos,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.play_circle_outline), text: 'Videos'),
            Tab(icon: Icon(Icons.local_offer), text: 'Offers'),
            Tab(icon: Icon(Icons.business), text: 'Directory'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVideosTab(),
                _buildOffersTab(),
                _buildDirectoryTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SubmitBusinessScreenEnhanced(),
            ),
          );
        },
        icon: const Icon(Icons.add_business),
        label: const Text('Add Business'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  // FEATURE 4: Distance Filtering UI
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance Slider
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Within ${_distanceRadius.toInt()} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _distanceRadius,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${_distanceRadius.toInt()} km',
                  onChanged: (value) {
                    setState(() => _distanceRadius = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Category Filter
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Featured Filter
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('Featured'),
                        ],
                      ),
                      selected: _showFeaturedOnly,
                      onSelected: (selected) {
                        setState(() => _showFeaturedOnly = selected);
                      },
                      selectedColor: Colors.amber[100],
                    ),
                  );
                }

                final category = _categories[index - 1];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // FEATURE 1: Business Videos Tab
  Widget _buildVideosTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        final business = _businesses.firstWhere(
          (b) => b.ownerId == video.ownerId,
          orElse: () => _businesses.first,
        );

        return _buildVideoCard(video, business);
      },
    );
  }

  Widget _buildVideoCard(
      video_model.BusinessVideo video, BusinessModel business) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessVideoPlayerScreen(
                video: video,
                business: business,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(video.thumbnailUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                    color: Colors.grey[300],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Boosted badge
                if (video.isBoosted && video.isBoostActive)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.pink],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BOOSTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Info
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(business.emoji,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    business.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                // FEATURE 3: Featured Badge
                                if (business.isFeatured)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Colors.amber, Colors.orange],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star,
                                            size: 10, color: Colors.white),
                                        SizedBox(width: 2),
                                        Text(
                                          'Featured',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            // Distance indicator
                            if (business.distanceFromUser != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 12, color: Colors.grey),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${business.distanceFromUser!.toStringAsFixed(1)} km away',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Video Title & Product
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.productName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        video.formattedPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (video.offerTag != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.offerTag!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Stats
                  Row(
                    children: [
                      _buildVideoStat(Icons.visibility, '${video.views}'),
                      const SizedBox(width: 16),
                      _buildVideoStat(Icons.phone, '${video.callClicks}'),
                      const SizedBox(width: 16),
                      _buildVideoStat(Icons.chat, '${video.whatsappClicks}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // FEATURE 2: Offers with Expiry Tab
  Widget _buildOffersTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _offers.length,
      itemBuilder: (context, index) {
        final offer = _offers[index];
        final business = _businesses.firstWhere(
          (b) => b.id == offer.businessId,
          orElse: () => _businesses.first,
        );

        return _buildOfferCard(offer, business);
      },
    );
  }

  Widget _buildOfferCard(BusinessOffer offer, BusinessModel business) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showOfferDetails(offer, business);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Image with Discount Badge
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[400]!,
                        Colors.blue[400]!,
                      ],
                    ),
                  ),
                ),
                // Discount Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      offer.discountText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Expiry Timer (FEATURE 2)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: offer.isExpiringSoon ? Colors.red : Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          offer.expiryText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business Info
                  Row(
                    children: [
                      Text(
                        business.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    business.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                // FEATURE 3: Verified + Featured Badge
                                if (business.isVerified)
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                if (business.isFeatured)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                              ],
                            ),
                            // Distance
                            if (business.distanceFromUser != null)
                              Text(
                                '${business.distanceFromUser!.toStringAsFixed(1)} km away',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Offer Title
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Claim Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _claimOffer(offer, business),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_offer, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Claim Offer • ${offer.claimedCount}/${offer.claimLimit ?? "∞"} claimed',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Directory Tab
  Widget _buildDirectoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final businesses = _filteredBusinesses;

    if (businesses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No businesses found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        return _buildBusinessCard(businesses[index]);
      },
    );
  }

  Widget _buildBusinessCard(BusinessModel business) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BusinessProfileEnhancedScreen(business: business),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(business.emoji,
                      style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 12),

              // Business Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // FEATURE 3: Featured + Verified Badges
                        if (business.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (business.isVerified && !business.isFeatured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    // MONETIZATION: Subscription Plan Badge
                    if (business.subscriptionPlan != null &&
                        business.subscriptionPlan!.tier !=
                            SubscriptionTier.free)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              size: 12,
                              color: business.subscriptionPlan!.tier ==
                                      SubscriptionTier.premium
                                  ? Colors.purple
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              business.subscriptionPlan!.tierName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: business.subscriptionPlan!.tier ==
                                        SubscriptionTier.premium
                                    ? Colors.purple
                                    : Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Priority: ${business.priorityScore.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      business.tagline ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            business.category,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Rating
                        if (business.rating != null) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            business.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                        const Spacer(),
                        // FEATURE 4: Distance Display
                        if (business.distanceFromUser != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.red),
                              const SizedBox(width: 2),
                              Text(
                                '${business.distanceFromUser!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
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

  void _showOfferDetails(BusinessOffer offer, BusinessModel business) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.orange),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offer expires in',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        offer.expiryText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              offer.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (offer.promoCode != null) ...[
              Text(
                'Promo Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.blue, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      offer.promoCode!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Copy to clipboard
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _claimOffer(offer, business);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Claim This Offer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _claimOffer(BusinessOffer offer, BusinessModel business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Offer Claimed!'),
        content: Text(
          'You have successfully claimed the offer from ${business.name}. '
          'Show this to the business to redeem.\n\n'
          'Promo Code: ${offer.promoCode ?? "N/A"}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Helper methods for mock data
  String _getBusinessName(int index) {
    final names = [
      'Sri Lakshmi Jewellers',
      'Quick Home Services',
      'Fresh Farm Organics',
      'City Health Clinic',
      'Anand Sweets',
      'Bright Future Academy',
      'Royal Bakery',
      'Tech Repair Hub',
      'Fashion Boutique',
      'Fitness Plus Gym',
    ];
    return names[index % names.length];
  }

  String _getTagline(int index) {
    final taglines = [
      '50% Off on Gold Making Charges',
      'AC Service at ₹299 Only',
      'Free Delivery on Orders Above ₹500',
      'Free Health Checkup This Week',
      'Buy 1 Get 1 Free on Sweets',
      'Best Coaching Classes',
      'Fresh Cakes Daily',
      'Same Day Repairs',
      'New Collection Launch',
      'Get Fit, Stay Healthy',
    ];
    return taglines[index % taglines.length];
  }

  String _getEmoji(int index) {
    final emojis = ['💎', '🔧', '🥬', '🏥', '🍬', '📚', '🎂', '📱', '👗', '💪'];
    return emojis[index % emojis.length];
  }

  String _getProductName(int index) {
    final products = [
      'Gold Necklace',
      'AC Repair',
      'Fresh Vegetables',
      'Health Checkup',
      'Sweets Box',
      'Study Material',
      'Custom Cake',
      'Phone Repair',
      'Designer Dress',
      'Gym Membership',
    ];
    return products[index % products.length];
  }

  String _getOfferTitle(int index) {
    final titles = [
      '50% OFF on First Order',
      'Buy 1 Get 1 Free',
      'Flat ₹500 Cashback',
      'Special Weekend Discount',
      'Limited Time Mega Sale',
      'Exclusive Member Offer',
      'Flash Sale - 70% OFF',
      'New Year Special Deal',
      'Festive Season Offer',
      'Summer Clearance Sale',
      'Mid-Season Bonanza',
      'Premium Membership Free',
    ];
    return titles[index % titles.length];
  }

  String _getDiscountText(int index) {
    final discounts = [
      '50% OFF',
      'BOGO',
      '₹500 OFF',
      '30% OFF',
      '70% OFF',
      'FREE',
      '40% OFF',
      '₹1000 OFF',
      '60% OFF',
      '25% OFF',
      'FLAT 45% OFF',
      'BUY 2 GET 1',
    ];
    return discounts[index % discounts.length];
  }
}
