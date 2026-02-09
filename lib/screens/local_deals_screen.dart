/// Local Deals Screen
/// Full-screen view for browsing all local deals with categories and filters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/local_deal_model.dart';
import '../services/local_deals_service.dart';
import 'deals/add_deal_screen.dart';

class LocalDealsScreen extends StatefulWidget {
  final String? city;
  final String? initialCategory;

  const LocalDealsScreen({
    super.key,
    this.city,
    this.initialCategory,
  });

  @override
  State<LocalDealsScreen> createState() => _LocalDealsScreenState();
}

class _LocalDealsScreenState extends State<LocalDealsScreen>
    with SingleTickerProviderStateMixin {
  final LocalDealsService _dealsService = LocalDealsService();
  late TabController _tabController;

  List<LocalDeal> _allDeals = [];
  List<LocalDeal> _filteredDeals = [];
  List<DealCategory> _categories = [];
  String? _selectedCategory;
  bool _isLoading = true;
  bool _showExpiringSoon = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedCategory = widget.initialCategory;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final deals = await _dealsService.getActiveDeals(city: widget.city);
      final categories = await _dealsService.getCategories();

      if (mounted) {
        setState(() {
          _allDeals = deals;
          _filteredDeals = deals;
          _categories = categories;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      print('Error loading deals: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    List<LocalDeal> filtered = List.from(_allDeals);

    // Category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered =
          filtered.where((d) => d.category == _selectedCategory).toList();
    }

    // Expiring soon filter
    if (_showExpiringSoon) {
      filtered = filtered.where((d) => d.isExpiringSoon).toList();
    }

    // Search filter
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((d) {
        return d.title.toLowerCase().contains(query) ||
            d.description.toLowerCase().contains(query) ||
            d.businessName.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredDeals = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(innerBoxIsScrolled),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategoryFilter()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'All Deals'),
                    Tab(text: '🔥 Featured'),
                    Tab(text: '⏰ Expiring'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildDealsList(_filteredDeals),
                  _buildDealsList(
                      _filteredDeals.where((d) => d.isFeatured).toList()),
                  _buildDealsList(
                      _filteredDeals.where((d) => d.isExpiringSoon).toList()),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      forceElevated: innerBoxIsScrolled,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          '🏷️ Local Deals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepOrange[400]!,
                Colors.orange[300]!,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Badge(
            isLabelVisible: _showExpiringSoon,
            child: const Icon(Icons.filter_list),
          ),
          onPressed: _showFilterSheet,
        ),
        IconButton(
          icon: const Icon(Icons.add_business),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddDealScreen(),
              ),
            );
            if (result == true) {
              _loadData();
            }
          },
          tooltip: 'Add Deal',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _applyFilters(),
        decoration: InputDecoration(
          hintText: 'Search deals, businesses...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildCategoryChip(null, 'All', '🏷️'),
          ..._categories
              .map((cat) => _buildCategoryChip(cat.name, cat.name, cat.emoji)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label, String emoji) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          _applyFilters();
        },
        selectedColor: Colors.orange[100],
        checkmarkColor: Colors.deepOrange,
      ),
    );
  }

  Widget _buildDealsList(List<LocalDeal> deals) {
    if (deals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No deals found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new offers!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          return _buildDealCard(deals[index]);
        },
      ),
    );
  }

  Widget _buildDealCard(LocalDeal deal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDealDetails(deal),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with discount badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCategoryColor(deal.category),
                    _getCategoryColor(deal.category).withOpacity(0.7),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(deal.emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deal.businessName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${deal.discountPercent}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Original price
                      Text(
                        '₹${deal.originalPrice?.toStringAsFixed(0) ?? '0'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Discounted price
                      Text(
                        '₹${deal.discountedPrice?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Spacer(),
                      // Expiry
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: deal.isExpiringSoon
                              ? Colors.red[50]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 14,
                              color: deal.isExpiringSoon
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deal.remainingTimeText,
                              style: TextStyle(
                                fontSize: 12,
                                color: deal.isExpiringSoon
                                    ? Colors.red
                                    : Colors.grey[600],
                                fontWeight: deal.isExpiringSoon
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Badges
                  Row(
                    children: [
                      if (deal.isSponsored)
                        _buildBadge(
                            'Sponsored', Colors.amber[100]!, Colors.orange),
                      if (deal.isFeatured)
                        _buildBadge(
                            'Featured', Colors.purple[100]!, Colors.purple),
                      if (deal.area != null)
                        _buildBadge(
                            '📍 ${deal.area}', Colors.blue[50]!, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons Row
                  Row(
                    children: [
                      // Directions Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openMaps(context, deal),
                          icon: Icon(Icons.directions,
                              size: 18, color: Colors.blue[700]),
                          label: const Text('Directions'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue[700],
                            side: BorderSide(color: Colors.blue[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Call Button
                      if (deal.businessPhone != null &&
                          deal.businessPhone!.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _makeCall(context, deal),
                            icon: Icon(Icons.phone,
                                size: 18, color: Colors.green[700]),
                            label: const Text('Call'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              side: BorderSide(color: Colors.green[300]!),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      if (deal.businessPhone != null &&
                          deal.businessPhone!.isNotEmpty)
                        const SizedBox(width: 8),
                      // Share Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareDeal(context, deal),
                          icon: Icon(Icons.share,
                              size: 18, color: Colors.orange[700]),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange[700],
                            side: BorderSide(color: Colors.orange[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show only expiring soon'),
              subtitle: const Text('Deals ending in 24 hours'),
              value: _showExpiringSoon,
              onChanged: (value) {
                setState(() => _showExpiringSoon = value);
                _applyFilters();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _showExpiringSoon = false;
                    _searchController.clear();
                  });
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: const Text('Clear All Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDealDetails(LocalDeal deal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DealDetailsSheet(
        deal: deal,
        onClaim: () => _claimDeal(deal),
        categoryColor: _getCategoryColor(deal.category),
      ),
    );
  }

  Future<void> _claimDeal(LocalDeal deal) async {
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
  Future<void> _openMaps(BuildContext context, LocalDeal deal) async {
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open maps. Please install Google Maps.'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
        );
      }
    }
  }

  // Make a phone call to the business
  Future<void> _makeCall(BuildContext context, LocalDeal deal) async {
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not make call')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error making call: $e')),
        );
      }
    }
  }

  // Share the deal
  Future<void> _shareDeal(BuildContext context, LocalDeal deal) async {
    final text = '''🎉 ${deal.title}

${deal.description}

💰 ${deal.discountPercent}% OFF at ${deal.businessName}
Original: ₹${deal.originalPrice?.toStringAsFixed(0) ?? '0'}
Now: ₹${deal.discountedPrice?.toStringAsFixed(0) ?? '0'}${deal.promoCode != null && deal.promoCode!.isNotEmpty ? '\n\n🏷️ Code: ${deal.promoCode}' : ''}

Location: ${deal.area ?? deal.city}
⏰ Valid until ${deal.expiresAt.day}/${deal.expiresAt.month}/${deal.expiresAt.year}''';

    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deal details copied! Share it with your friends.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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
}

/// Tab bar delegate for persistent header
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

/// Deal Details Bottom Sheet
class DealDetailsSheet extends StatelessWidget {
  final LocalDeal deal;
  final VoidCallback onClaim;
  final Color categoryColor;

  const DealDetailsSheet({
    super.key,
    required this.deal,
    required this.onClaim,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
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
                // Header
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
                            '₹${deal.originalPrice?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Column(
                        children: [
                          const Text('You Pay',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            '₹${deal.discountedPrice?.toStringAsFixed(0) ?? '0'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      Column(
                        children: [
                          const Text('You Save',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            '₹${deal.savingsAmount.toStringAsFixed(0)}',
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

                // Expiry and location info
                if (deal.isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
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
                          'Expiring soon! ${deal.remainingTimeText}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (deal.area != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${deal.area}, ${deal.city}',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),

                // Promo code if available
                if (deal.hasPromoCode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
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

                const SizedBox(height: 16),

                // Action Buttons Row (Directions, Call, Share)
                Row(
                  children: [
                    // Directions Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close bottom sheet first
                          _LocalDealsScreenState? state =
                              context.findAncestorStateOfType<
                                  _LocalDealsScreenState>();
                          state?._openMaps(context, deal);
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
                            _LocalDealsScreenState? state =
                                context.findAncestorStateOfType<
                                    _LocalDealsScreenState>();
                            state?._makeCall(context, deal);
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
                          _LocalDealsScreenState? state =
                              context.findAncestorStateOfType<
                                  _LocalDealsScreenState>();
                          state?._shareDeal(context, deal);
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
                    onPressed: deal.canBeClaimed ? onClaim : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.card_giftcard, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          deal.canBeClaimed
                              ? 'Claim This Deal'
                              : 'Deal Unavailable',
                          style: const TextStyle(
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
}
