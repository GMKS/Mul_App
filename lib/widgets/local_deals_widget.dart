/// Local Deals & Discounts Widget
/// Shows geo-targeted offers with affiliate links

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class DealItem {
  final String id;
  final String title;
  final String description;
  final String businessName;
  final String? imageUrl;
  final String emoji;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final String? affiliateLink;
  final String category;
  final DateTime expiresAt;
  final bool isSponsored;

  DealItem({
    required this.id,
    required this.title,
    required this.description,
    required this.businessName,
    this.imageUrl,
    required this.emoji,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    this.affiliateLink,
    required this.category,
    required this.expiresAt,
    this.isSponsored = false,
  });
}

class LocalDealsWidget extends StatefulWidget {
  final String? category;
  final bool showAsCarousel;

  const LocalDealsWidget({
    super.key,
    this.category,
    this.showAsCarousel = true,
  });

  @override
  State<LocalDealsWidget> createState() => _LocalDealsWidgetState();
}

class _LocalDealsWidgetState extends State<LocalDealsWidget> {
  List<DealItem> _deals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final random = Random();
    final mockDeals = [
      {
        'title': '50% Off on First Order',
        'desc': 'Fresh vegetables delivered to your door',
        'business': 'Local Fresh Market',
        'emoji': '🥬',
        'original': 500.0,
        'discount': 50,
        'category': 'Grocery',
        'sponsored': true,
      },
      {
        'title': 'Free Health Checkup',
        'desc': 'Complete body checkup worth ₹999',
        'business': 'City Health Clinic',
        'emoji': '🏥',
        'original': 999.0,
        'discount': 100,
        'category': 'Health',
        'sponsored': false,
      },
      {
        'title': '30% Off Pooja Items',
        'desc': 'All pooja essentials & flowers',
        'business': 'Sri Lakshmi Stores',
        'emoji': '🪷',
        'original': 300.0,
        'discount': 30,
        'category': 'Devotional',
        'sponsored': false,
      },
      {
        'title': 'AC Service at ₹299',
        'desc': 'Complete AC cleaning & gas refill',
        'business': 'Quick Home Services',
        'emoji': '❄️',
        'original': 799.0,
        'discount': 63,
        'category': 'Services',
        'sponsored': true,
      },
      {
        'title': 'Buy 1 Get 1 Free',
        'desc': 'On all traditional sweets',
        'business': 'Anand Sweets',
        'emoji': '🍬',
        'original': 200.0,
        'discount': 50,
        'category': 'Food',
        'sponsored': false,
      },
    ];

    setState(() {
      _deals = mockDeals.map((deal) {
        final original = deal['original'] as double;
        final discount = deal['discount'] as int;
        return DealItem(
          id: 'deal_${random.nextInt(10000)}',
          title: deal['title'] as String,
          description: deal['desc'] as String,
          businessName: deal['business'] as String,
          emoji: deal['emoji'] as String,
          originalPrice: original,
          discountedPrice: original * (1 - discount / 100),
          discountPercent: discount,
          category: deal['category'] as String,
          expiresAt: DateTime.now().add(Duration(days: random.nextInt(7) + 1)),
          isSponsored: deal['sponsored'] as bool,
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

    if (_deals.isEmpty) {
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
                    '🏷️ ',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Text(
                    'Local Deals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_deals.length} offers',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all deals screen
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        // Deals Carousel
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _deals.length,
            itemBuilder: (context, index) {
              return _buildDealCard(_deals[index]);
            },
          ),
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
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 260,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDealCard(DealItem deal) {
    return GestureDetector(
      onTap: () => _onDealTap(deal),
      child: Container(
        width: 260,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Emoji and Discount Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              _getCategoryColor(deal.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            deal.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${deal.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    deal.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    deal.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Business Name
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deal.businessName,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price and CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${deal.originalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            '₹${deal.discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(deal.category),
                              _getCategoryColor(deal.category).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Grab Now',
                          style: TextStyle(
                            color: Colors.white,
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
            // Sponsored Badge
            if (deal.isSponsored)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sponsored',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            // Expiry Timer
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 10,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _getExpiryText(deal.expiresAt),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDealTap(DealItem deal) async {
    if (deal.affiliateLink != null) {
      final uri = Uri.parse(deal.affiliateLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      // Show deal details dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(deal.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deal.description),
              const SizedBox(height: 8),
              Text('Business: ${deal.businessName}'),
              Text('Original: ₹${deal.originalPrice}'),
              Text('Discounted: ₹${deal.discountedPrice}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Claim Offer'),
            ),
          ],
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'grocery':
        return const Color(0xFF4CAF50);
      case 'health':
        return const Color(0xFFE91E63);
      case 'devotional':
        return const Color(0xFF9C27B0);
      case 'services':
        return const Color(0xFF2196F3);
      case 'food':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _getExpiryText(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return 'Expiring soon';
  }
}
