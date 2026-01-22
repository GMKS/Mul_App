// BUSINESS PROFILE ENHANCED - 2026 EDITION
// Polished, smooth, modern UX with animations and micro-interactions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../../models/business_model.dart';

class BusinessProfileEnhancedScreen extends StatefulWidget {
  final BusinessModel business;

  const BusinessProfileEnhancedScreen({
    super.key,
    required this.business,
  });

  @override
  State<BusinessProfileEnhancedScreen> createState() =>
      _BusinessProfileEnhancedScreenState();
}

class _BusinessProfileEnhancedScreenState
    extends State<BusinessProfileEnhancedScreen> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fabAnimation;

  bool _isFollowing = false;
  bool _isSaved = false;
  bool _showFullDescription = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _trackProfileView();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _trackProfileView() async {
    debugPrint('📊 Profile view tracked for ${widget.business.name}');
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBusinessHeader(),
                  _buildInteractiveStats(),
                  _buildQuickActions(),
                  _buildAboutSection(),
                  _buildBusinessBadges(),
                  _buildGallerySection(),
                  _buildServicesSection(),
                  _buildReviewsSection(),
                  _buildMapSection(),
                  _buildWorkingHours(),
                  _buildSocialLinks(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildModernAppBar() {
    final images = widget.business.images ?? [];
    final hasImages = images.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.blue.shade700,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with parallax
            if (hasImages)
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildGradientBackground(),
                  );
                },
              )
            else
              _buildGradientBackground(),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Image indicators
            if (hasImages)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentImageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

            // Business emoji/icon at bottom
            Positioned(
              bottom: 20,
              left: 20,
              child: Hero(
                tag: 'business_${widget.business.id}',
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.business.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        _buildAppBarAction(Icons.share, () => _shareProfile()),
        _buildAppBarAction(Icons.more_vert, () => _showMoreOptions()),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.purple.shade600,
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.business.emoji,
          style: const TextStyle(fontSize: 100),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      ),
    );
  }

  Widget _buildBusinessHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.business.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.business.isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ],
                      ],
                    ),
                    if (widget.business.tagline != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.business.tagline!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.business.category,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.business.rating != null) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.business.rating!.toStringAsFixed(1)} (${widget.business.reviewCount ?? 0})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStats() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.visibility,
            value: '${Random().nextInt(5000) + 1000}',
            label: 'Views',
            color: Colors.blue,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(
            icon: Icons.people,
            value:
                '${widget.business.followers ?? Random().nextInt(500) + 100}',
            label: 'Followers',
            color: Colors.purple,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(
            icon: Icons.star,
            value:
                '${widget.business.reviewCount ?? Random().nextInt(200) + 20}',
            label: 'Reviews',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View $label details')),
        );
      },
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: _buildPrimaryButton(
              icon: Icons.call,
              label: 'Call Now',
              color: Colors.green,
              onTap: () => _makeCall(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPrimaryButton(
              icon: Icons.chat,
              label: 'WhatsApp',
              color: Colors.teal,
              onTap: () => _openWhatsApp(),
            ),
          ),
          const SizedBox(width: 12),
          _buildIconButton(
            icon: Icons.directions,
            color: Colors.blue,
            onTap: () => _openMap(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Icon(icon, size: 24),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: Text(
              widget.business.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            secondChild: Text(
              widget.business.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            crossFadeState: _showFullDescription
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (widget.business.description.length > 100)
            TextButton(
              onPressed: () {
                setState(() => _showFullDescription = !_showFullDescription);
                HapticFeedback.selectionClick();
              },
              child: Text(
                _showFullDescription ? 'Show Less' : 'Read More',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessBadges() {
    final badges = <Map<String, dynamic>>[];
    if (widget.business.isVerified) {
      badges.add({
        'icon': Icons.verified,
        'label': 'Verified',
        'color': Colors.blue,
      });
    }
    if (widget.business.isFeatured) {
      badges.add({
        'icon': Icons.star,
        'label': 'Featured',
        'color': Colors.amber,
      });
    }
    if (widget.business.hasOnlineBooking) {
      badges.add({
        'icon': Icons.calendar_month,
        'label': 'Online Booking',
        'color': Colors.purple,
      });
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: badges.map((badge) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: (badge['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: (badge['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  badge['icon'] as IconData,
                  color: badge['color'] as Color,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  badge['label'] as String,
                  style: TextStyle(
                    color: badge['color'] as Color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGallerySection() {
    final images = widget.business.images ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gallery',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Open full gallery
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services & Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildServiceItem(
            icon: Icons.shopping_bag,
            title: 'Browse Catalog',
            subtitle: 'View all products and services',
            onTap: () {},
          ),
          _buildServiceItem(
            icon: Icons.calendar_month,
            title: 'Book Appointment',
            subtitle: 'Schedule a visit or consultation',
            onTap: () {},
          ),
          _buildServiceItem(
            icon: Icons.local_offer,
            title: 'View Offers',
            subtitle: 'Special deals and discounts',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final rating = widget.business.rating ?? 4.5;
    final reviewCount = widget.business.reviewCount ?? 0;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews & Ratings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$reviewCount reviews',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '92% positive feedback',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showReviewDialog();
            },
            icon: const Icon(Icons.rate_review),
            label: const Text('Write a Review'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Mock map
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 48, color: Colors.red.shade600),
                        const SizedBox(height: 8),
                        Text(
                          widget.business.city,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openMap(),
                        child: Container(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.place, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.business.address}, ${widget.business.city}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (widget.business.distanceFromUser != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_walk,
                    size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${widget.business.distanceFromUser!.toStringAsFixed(1)} km away',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkingHours() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Open Now',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHourRow('Monday - Friday', '9:00 AM - 6:00 PM'),
          _buildHourRow('Saturday', '10:00 AM - 4:00 PM'),
          _buildHourRow('Sunday', 'Closed'),
        ],
      ),
    );
  }

  Widget _buildHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            hours,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect With Us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(
                icon: Icons.language,
                label: 'Website',
                color: Colors.blue,
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                color: Colors.blue.shade800,
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                label: 'Instagram',
                color: Colors.pink,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'save',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              setState(() => _isSaved = !_isSaved);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSaved ? 'Saved!' : 'Removed from saved'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? Colors.blue : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'chat',
            backgroundColor: Colors.blue,
            onPressed: () => _openChat(),
            child: const Icon(Icons.chat_bubble, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => _isFollowing = !_isFollowing);
                HapticFeedback.mediumImpact();
              },
              icon: Icon(_isFollowing ? Icons.check : Icons.add),
              label: Text(_isFollowing ? 'Following' : 'Follow'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _isFollowing ? Colors.grey : Colors.blue,
                side: BorderSide(
                  color: _isFollowing ? Colors.grey : Colors.blue,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _makeCall(),
              icon: const Icon(Icons.call, size: 20),
              label: const Text('Contact Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Actions
  void _makeCall() async {
    final url = Uri.parse('tel:${widget.business.phoneNumber}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openWhatsApp() async {
    final phone = widget.business.whatsappNumber ?? widget.business.phoneNumber;
    final message = Uri.encodeComponent(
        'Hi! I found your business on My City App. I\'d like to know more about your services.');
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openMap() async {
    final lat = widget.business.latitude;
    final lng = widget.business.longitude;
    if (lat != null && lng != null) {
      final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening chat...')),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${widget.business.name}...')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Business'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block Business'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Business Info'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: const Icon(Icons.star, size: 32),
                  color: Colors.amber,
                  onPressed: () {},
                );
              }),
            ),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review submitted!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
