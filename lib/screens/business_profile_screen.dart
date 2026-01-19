// Business Profile Screen with All 6 Modern Features
// Showcases complete business information with interactive elements

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/business_model.dart';
import 'business_dashboard_screen.dart';

class BusinessProfileScreen extends StatefulWidget {
  final BusinessModel business;

  const BusinessProfileScreen({
    super.key,
    required this.business,
  });

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _trackProfileView();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _trackProfileView() async {
    // Track analytics
    debugPrint('📊 Profile view tracked for ${widget.business.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cover Image & Logo
          _buildSliverAppBar(),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SHOP NAME & BRANDING
                _buildBusinessHeader(),

                const Divider(height: 1),

                // 3. CONTACT & ENGAGEMENT BUTTONS
                _buildContactButtons(),

                const Divider(height: 1),

                // 2. LOCATION & DISCOVERY
                _buildLocationSection(),

                const Divider(height: 1),

                // Tabs for more content
                _buildTabBar(),
              ],
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildCatalogTab(),
                _buildReviewsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // FEATURE 1: Shop Name & Branding
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Image
            if (widget.business.coverImageUrl != null)
              Image.network(
                widget.business.coverImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.business.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Logo at bottom
            Positioned(
              left: 20,
              bottom: 20,
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: widget.business.logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.network(
                              widget.business.logoUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              widget.business.emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // FEATURE 4: Approval & Trust Badge
                  if (widget.business.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // MONETIZATION: Dashboard button for business owners
        IconButton(
          icon: const Icon(Icons.dashboard_outlined),
          tooltip: 'Business Dashboard',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BusinessDashboardScreen(business: widget.business),
              ),
            );
          },
        ),
        // Share button
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareProfile,
        ),
        // Report button
        IconButton(
          icon: const Icon(Icons.flag_outlined),
          onPressed: _reportBusiness,
        ),
      ],
    );
  }

  Widget _buildBusinessHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Name
                    Text(
                      widget.business.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.business.tagline != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.business.tagline!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Follow button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isFollowing = !_isFollowing;
                  });
                },
                icon: Icon(_isFollowing ? Icons.check : Icons.add),
                label: Text(_isFollowing ? 'Following' : 'Follow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category & Rating
          Row(
            children: [
              // Category
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.business.category,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),

              // Rating
              if (widget.business.rating != null) ...[
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${widget.business.rating} (${widget.business.reviewCount ?? 0} reviews)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          if (widget.business.followers != null) ...[
            const SizedBox(height: 8),
            Text(
              '${widget.business.followers} followers',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // FEATURE 3: Contact & Engagement
  Widget _buildContactButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Call Button
          Expanded(
            child: _buildContactButton(
              icon: Icons.call,
              label: 'Call',
              color: Colors.green,
              onPressed: () => _makeCall(widget.business.phoneNumber),
            ),
          ),
          const SizedBox(width: 8),

          // WhatsApp Button
          Expanded(
            child: _buildContactButton(
              icon: Icons.chat,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onPressed: () => _openWhatsApp(
                widget.business.whatsappNumber ?? widget.business.phoneNumber,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Email Button
          if (widget.business.email != null)
            Expanded(
              child: _buildContactButton(
                icon: Icons.email,
                label: 'Email',
                color: Colors.red,
                onPressed: () => _sendEmail(widget.business.email!),
              ),
            ),
          if (widget.business.email != null) const SizedBox(width: 8),

          // Website Button
          if (widget.business.websiteUrl != null)
            Expanded(
              child: _buildContactButton(
                icon: Icons.language,
                label: 'Website',
                color: Colors.blue,
                onPressed: () => _openWebsite(widget.business.websiteUrl!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  // FEATURE 2: Location & Discovery
  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.business.address,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${widget.business.city}, ${widget.business.state}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Directions Button
          ElevatedButton.icon(
            onPressed: _openDirections,
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          if (widget.business.serviceRadius != null) ...[
            const SizedBox(height: 8),
            Text(
              'Service area: ${widget.business.serviceRadius} km radius',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey[100],
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Catalog'),
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }

  // About Tab
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.business.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),

          // FEATURE 5: QR Code
          if (widget.business.qrCode != null) ...[
            const Text(
              'Share Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: widget.business.qrCode!,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan to view profile',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Social Media Links
          if (widget.business.facebookUrl != null ||
              widget.business.instagramUrl != null ||
              widget.business.youtubeUrl != null) ...[
            const Text(
              'Follow Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.business.facebookUrl != null)
                  _buildSocialButton(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onPressed: () => _openUrl(widget.business.facebookUrl!),
                  ),
                if (widget.business.instagramUrl != null)
                  _buildSocialButton(
                    icon: Icons.camera_alt,
                    color: const Color(0xFFE4405F),
                    onPressed: () => _openUrl(widget.business.instagramUrl!),
                  ),
                if (widget.business.youtubeUrl != null)
                  _buildSocialButton(
                    icon: Icons.play_circle_filled,
                    color: const Color(0xFFFF0000),
                    onPressed: () => _openUrl(widget.business.youtubeUrl!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // FEATURE 5: Digital Catalog Tab
  Widget _buildCatalogTab() {
    if (widget.business.digitalCatalog == null ||
        widget.business.digitalCatalog!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No products available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.business.digitalCatalog!.length,
      itemBuilder: (context, index) {
        final product = widget.business.digitalCatalog![index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (!product.isAvailable)
                  Text(
                    'Out of Stock',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FEATURE 4: Reviews Tab
  Widget _buildReviewsTab() {
    if (widget.business.reviews == null || widget.business.reviews!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _writeReview,
              child: const Text('Write First Review'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.business.reviews!.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final review = widget.business.reviews![index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: review.userAvatar != null
                  ? NetworkImage(review.userAvatar!)
                  : null,
              child:
                  review.userAvatar == null ? Text(review.userName[0]) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(review.createdAt),
                        style: TextStyle(
                          fontSize: 12,
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
        Text(review.comment),
        if (review.images != null && review.images!.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: review.images!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      review.images![index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: color,
        iconSize: 32,
      ),
    );
  }

  // Bottom Bar with CTA
  Widget _buildBottomBar() {
    if (widget.business.hasOnlineBooking &&
        widget.business.bookingUrl != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _openUrl(widget.business.bookingUrl!),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Book Appointment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Actions
  Future<void> _makeCall(String phoneNumber) async {
    HapticFeedback.mediumImpact();
    final Uri phoneUri = Uri(scheme: 'tel', path: '+91$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('Error making call: $e');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    HapticFeedback.mediumImpact();
    final message = Uri.encodeComponent(
        'Hi! I saw ${widget.business.name} on Regional Shorts. I\'m interested in your products/services.');
    final Uri whatsappUri =
        Uri.parse('https://wa.me/91$phoneNumber?text=$message');
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
    }
  }

  Future<void> _sendEmail(String email) async {
    HapticFeedback.mediumImpact();
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Inquiry about ${widget.business.name}',
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('Error sending email: $e');
    }
  }

  Future<void> _openWebsite(String url) async {
    HapticFeedback.mediumImpact();
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening website: $e');
    }
  }

  Future<void> _openDirections() async {
    HapticFeedback.mediumImpact();
    if (widget.business.latitude != null && widget.business.longitude != null) {
      final Uri mapsUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${widget.business.latitude},${widget.business.longitude}');
      try {
        if (await canLaunchUrl(mapsUri)) {
          await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('Error opening maps: $e');
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening URL: $e');
    }
  }

  void _shareProfile() {
    // Share business profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${widget.business.name} profile...')),
    );
  }

  void _reportBusiness() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Business'),
        content: const Text('Why are you reporting this business?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _writeReview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening review form...')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
