/// Local Deals & Discounts Widget
/// Shows geo-targeted offers with affiliate links
/// Now powered by Supabase with real-time updates!

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../models/local_deal_model.dart';
import '../services/local_deals_service.dart';
import '../screens/deals/add_deal_screen.dart';

// Keep legacy DealItem for backward compatibility
class DealItem {
  final String id;
  final String title;
  final String description;
  final String businessName;
  final String? businessPhone;
  final String? businessAddress;
  final String? imageUrl;
  final String emoji;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercent;
  final String? affiliateLink;
  final String category;
  final String city;
  final String? area;
  final double? latitude;
  final double? longitude;
  final DateTime expiresAt;
  final bool isSponsored;
  final String? promoCode;

  DealItem({
    required this.id,
    required this.title,
    required this.description,
    required this.businessName,
    this.businessPhone,
    this.businessAddress,
    this.imageUrl,
    required this.emoji,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    this.affiliateLink,
    required this.category,
    required this.city,
    this.area,
    this.latitude,
    this.longitude,
    required this.expiresAt,
    this.isSponsored = false,
    this.promoCode,
  });

  /// Create from LocalDeal model
  factory DealItem.fromLocalDeal(LocalDeal deal) {
    return DealItem(
      id: deal.id,
      title: deal.title,
      description: deal.description,
      businessName: deal.businessName,
      businessPhone: deal.businessPhone,
      businessAddress: deal.businessAddress,
      imageUrl: deal.imageUrl,
      emoji: deal.emoji,
      originalPrice: deal.originalPrice ?? 0,
      discountedPrice: deal.discountedPrice ?? 0,
      discountPercent: deal.discountPercent ?? 0,
      affiliateLink: deal.affiliateLink,
      category: deal.category,
      city: deal.city,
      area: deal.area,
      latitude: deal.latitude,
      longitude: deal.longitude,
      expiresAt: deal.expiresAt,
      isSponsored: deal.isSponsored,
      promoCode: deal.promoCode,
    );
  }
}

class LocalDealsWidget extends StatefulWidget {
  final String? category;
  final bool showAsCarousel;
  final String? city; // Filter by city

  const LocalDealsWidget({
    super.key,
    this.category,
    this.showAsCarousel = true,
    this.city,
  });

  @override
  State<LocalDealsWidget> createState() => _LocalDealsWidgetState();
}

class _LocalDealsWidgetState extends State<LocalDealsWidget> {
  final LocalDealsService _dealsService = LocalDealsService();
  List<DealItem> _deals = [];
  bool _isLoading = true;
  bool _hasError = false;
  StreamSubscription? _realtimeSubscription;

  @override
  void initState() {
    super.initState();
    _loadDeals();
    _initializeRealtime();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  /// Initialize real-time subscription for live updates
  void _initializeRealtime() {
    _dealsService.initializeRealtimeSubscription(city: widget.city);
    _realtimeSubscription = _dealsService.dealsStream.listen((deals) {
      if (mounted) {
        setState(() {
          _deals = deals.map((d) => DealItem.fromLocalDeal(d)).toList();
        });
      }
    });
  }

  Future<void> _loadDeals() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Try to load from Supabase first
      final supabaseDeals = await _dealsService.getActiveDeals(
        city: widget.city,
        category: widget.category,
        limit: 10,
      );

      if (supabaseDeals.isNotEmpty) {
        setState(() {
          _deals = supabaseDeals.map((d) => DealItem.fromLocalDeal(d)).toList();
          _isLoading = false;
        });
        return;
      }

      // Fallback to mock data if Supabase returns empty
      await _loadMockDeals();
    } catch (e) {
      print('❌ Error loading deals: $e');
      // Fallback to mock data on error
      await _loadMockDeals();
    }
  }

  /// Load mock deals as fallback
  Future<void> _loadMockDeals() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final mockDeals = [
      DealItem(
        id: 'deal_1',
        title: '50% Off on First Order',
        description: 'Fresh vegetables delivered to your door',
        businessName: 'Local Fresh Market',
        emoji: '🥬',
        originalPrice: 500.0,
        discountedPrice: 250.0,
        discountPercent: 50,
        category: 'Grocery',
        city: 'Hyderabad',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        isSponsored: true,
      ),
      DealItem(
        id: 'deal_2',
        title: 'Free Health Checkup',
        description: 'Complete body checkup worth ₹999',
        businessName: 'City Health Clinic',
        emoji: '🏥',
        originalPrice: 999.0,
        discountedPrice: 0.0,
        discountPercent: 100,
        category: 'Health',
        city: 'Hyderabad',
        expiresAt: DateTime.now().add(const Duration(days: 15)),
        isSponsored: false,
      ),
      DealItem(
        id: 'deal_3',
        title: '30% Off Pooja Items',
        description: 'All pooja essentials & flowers',
        businessName: 'Sri Lakshmi Stores',
        emoji: '🪷',
        originalPrice: 300.0,
        discountedPrice: 210.0,
        discountPercent: 30,
        category: 'Devotional',
        city: 'Hyderabad',
        expiresAt: DateTime.now().add(const Duration(days: 10)),
        isSponsored: false,
      ),
      DealItem(
        id: 'deal_4',
        title: 'AC Service at ₹299',
        description: 'Complete AC cleaning & gas refill',
        businessName: 'Quick Home Services',
        emoji: '❄️',
        originalPrice: 799.0,
        discountedPrice: 299.0,
        discountPercent: 63,
        category: 'Services',
        city: 'Hyderabad',
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        isSponsored: true,
      ),
      DealItem(
        id: 'deal_5',
        title: 'Buy 1 Get 1 Free',
        description: 'On all traditional sweets',
        businessName: 'Anand Sweets',
        emoji: '🍬',
        originalPrice: 200.0,
        discountedPrice: 100.0,
        discountPercent: 50,
        category: 'Food',
        city: 'Hyderabad',
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        isSponsored: false,
      ),
    ];

    if (mounted) {
      setState(() {
        _deals = mockDeals;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 2),
                    Text(
                      'Best offers from local businesses.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  // Add Deal Button
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.orange[600]),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddDealScreen(),
                        ),
                      );
                      if (result == true) {
                        // Show success message
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✓ Deal submitted! It will appear here after admin approval.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                        // Reload deals after adding new one
                        _loadDeals();
                      }
                    },
                    tooltip: 'Add Deal',
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all deals screen
                      Navigator.pushNamed(
                        context,
                        '/local-deals',
                        arguments: {
                          'city': widget.city,
                          'category': widget.category
                        },
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Deals Carousel or Empty State
        if (_deals.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'No deals available right now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to add a deal! Tap the + button above.\n\nYour submitted deals will appear here after admin approval.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
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
      // Show enhanced deal details dialog
      _showDealDetailsDialog(deal);
    }
  }

  void _showDealDetailsDialog(DealItem deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DealDetailsSheet(
        deal: deal,
        onClaim: () => _claimDeal(deal),
        categoryColor: _getCategoryColor(deal.category),
      ),
    );
  }

  Future<void> _claimDeal(DealItem deal) async {
    final result = await _dealsService.claimDeal(deal.id);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              result['success'] == true ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(result['message'] ?? 'Unknown error')),
          ],
        ),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Show promo code if available
    if (result['success'] == true && result['promo_code'] != null) {
      _showPromoCodeDialog(result['promo_code']);
    }
  }

  void _showPromoCodeDialog(String promoCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.green),
            SizedBox(width: 8),
            Text('Deal Claimed! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your promo code:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    promoCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: promoCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Show this code at the business to redeem your deal',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // Open Google Maps with directions and show business name
  Future<void> _openMaps(DealItem deal) async {
    Uri uri;

    // Use geo: URI with coordinates + business name only as label
    if (deal.latitude != null && deal.longitude != null) {
      final label = Uri.encodeComponent(deal.businessName);
      uri = Uri.parse(
        'geo:${deal.latitude},${deal.longitude}?q=${deal.latitude},${deal.longitude}($label)',
      );
    } else if (deal.businessAddress != null &&
        deal.businessAddress!.isNotEmpty) {
      final searchQuery = Uri.encodeComponent(
          '${deal.businessName}, ${deal.businessAddress}, ${deal.city}');
      uri = Uri.parse('geo:0,0?q=$searchQuery');
    } else {
      final searchQuery =
          Uri.encodeComponent('${deal.businessName}, ${deal.city}');
      uri = Uri.parse('geo:0,0?q=$searchQuery');
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps. Please install Google Maps.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
        );
      }
    }
  }

  // Make a phone call to the business
  Future<void> _makeCall(DealItem deal) async {
    if (deal.businessPhone == null || deal.businessPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final phoneUrl = 'tel:${deal.businessPhone}';
    final uri = Uri.parse(phoneUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not make call')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error making call: $e')),
        );
      }
    }
  }

  // Share the deal
  Future<void> _shareDeal(DealItem deal) async {
    final text = '''🎉 ${deal.title}

${deal.description}

💰 ${deal.discountPercent}% OFF at ${deal.businessName}
Original: ₹${deal.originalPrice.toStringAsFixed(0)}
Now: ₹${deal.discountedPrice.toStringAsFixed(0)}${deal.promoCode != null && deal.promoCode!.isNotEmpty ? '\n\n🏷️ Code: ${deal.promoCode}' : ''}

Location: ${deal.area ?? deal.city}
⏰ Valid until ${deal.expiresAt.day}/${deal.expiresAt.month}/${deal.expiresAt.year}''';

    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deal details copied! Share it with your friends.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
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
      case 'electronics':
        return const Color(0xFF00BCD4);
      case 'fashion':
        return const Color(0xFFFF5722);
      case 'beauty':
        return const Color(0xFFF06292);
      case 'education':
        return const Color(0xFF795548);
      case 'travel':
        return const Color(0xFF3F51B5);
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

/// Enhanced Deal Details Bottom Sheet
class _DealDetailsSheet extends StatelessWidget {
  final DealItem deal;
  final VoidCallback onClaim;
  final Color categoryColor;

  const _DealDetailsSheet({
    required this.deal,
    required this.onClaim,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon =
        deal.expiresAt.difference(DateTime.now()).inHours <= 24;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with emoji and discount
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(deal.emoji,
                            style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deal.businessName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${deal.discountPercent}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Description
                Text(
                  deal.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Price info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Original',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            '₹${deal.originalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Column(
                        children: [
                          const Text('You Pay',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            '₹${deal.discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Column(
                        children: [
                          const Text('You Save',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            '₹${(deal.originalPrice - deal.discountedPrice).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Expiry warning if soon
                if (isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Expiring soon! ${_getDetailedExpiry(deal.expiresAt)}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Promo code if available
                if (deal.promoCode != null && deal.promoCode!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_offer,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        const Text('Promo Code: '),
                        Text(
                          deal.promoCode!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: deal.promoCode!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons Row (Directions, Call, Share)
                Row(
                  children: [
                    // Directions Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet first
                          _LocalDealsWidgetState? state =
                              context.findAncestorStateOfType<
                                  _LocalDealsWidgetState>();
                          state?._openMaps(deal);
                        },
                        icon: const Icon(Icons.directions, size: 20),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Call Button
                    if (deal.businessPhone != null &&
                        deal.businessPhone!.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Close bottom sheet first
                            _LocalDealsWidgetState? state =
                                context.findAncestorStateOfType<
                                    _LocalDealsWidgetState>();
                            state?._makeCall(deal);
                          },
                          icon: const Icon(Icons.phone, size: 20),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    if (deal.businessPhone != null &&
                        deal.businessPhone!.isNotEmpty)
                      const SizedBox(width: 8),
                    // Share Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet first
                          _LocalDealsWidgetState? state =
                              context.findAncestorStateOfType<
                                  _LocalDealsWidgetState>();
                          state?._shareDeal(deal);
                        },
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Claim button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_giftcard, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Claim This Deal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDetailedExpiry(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays} days left';
    if (diff.inHours > 0) return '${diff.inHours} hours left';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes left';
    return 'Expiring soon';
  }
}
