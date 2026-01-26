// Business Directory Screen
// Shows list of all businesses with search and filtering
// Each business card leads to full BusinessProfileScreen

import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../widgets/business_teasers_carousel.dart';
import 'business_profile_screen.dart';
import 'business/submit_business_screen_enhanced.dart';
import 'dart:math';

class BusinessDirectoryScreen extends StatefulWidget {
  const BusinessDirectoryScreen({super.key});

  @override
  State<BusinessDirectoryScreen> createState() =>
      _BusinessDirectoryScreenState();
}

class _BusinessDirectoryScreenState extends State<BusinessDirectoryScreen> {
  List<BusinessModel> _businesses = [];
  List<BusinessModel> _filteredBusinesses = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = true;

  final List<String> _categories = [
    'All',
    'Retail',
    'Food',
    'Services',
    'Healthcare',
    'Education',
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    print('🔵 BusinessDirectory: Starting to load businesses...');
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - replace with actual API call
    final random = Random();
    final mockBusinesses = [
      {
        'name': 'Sri Lakshmi Jewellers',
        'tagline': '50% Off on Gold Making Charges',
        'category': 'Retail',
        'emoji': '💎',
        'rating': 4.8,
        'reviews': 234,
        'address': '123 Main Street, Downtown',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543210',
        'verified': true,
      },
      {
        'name': 'Quick Home Services',
        'tagline': 'AC Service at ₹299 Only',
        'category': 'Services',
        'emoji': '🔧',
        'rating': 4.5,
        'reviews': 567,
        'address': '45 Service Road',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543211',
        'verified': true,
      },
      {
        'name': 'Fresh Farm Organics',
        'tagline': 'Free Delivery on Orders Above ₹500',
        'category': 'Food',
        'emoji': '🥬',
        'rating': 4.7,
        'reviews': 189,
        'address': '78 Green Valley',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543212',
        'verified': false,
      },
      {
        'name': 'City Health Clinic',
        'tagline': 'Free Health Checkup This Week',
        'category': 'Healthcare',
        'emoji': '🏥',
        'rating': 4.9,
        'reviews': 412,
        'address': '90 Hospital Road',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543213',
        'verified': true,
      },
      {
        'name': 'Anand Sweets',
        'tagline': 'Buy 1 Get 1 Free on Sweets',
        'category': 'Food',
        'emoji': '🍬',
        'rating': 4.6,
        'reviews': 789,
        'address': '12 Sweet Lane',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543214',
        'verified': true,
      },
      {
        'name': 'Bright Future Academy',
        'tagline': 'Best Coaching Classes',
        'category': 'Education',
        'emoji': '📚',
        'rating': 4.8,
        'reviews': 156,
        'address': '34 Education Street',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543215',
        'verified': true,
      },
      {
        'name': 'Royal Bakery',
        'tagline': 'Fresh Cakes Daily',
        'category': 'Food',
        'emoji': '🎂',
        'rating': 4.4,
        'reviews': 298,
        'address': '56 Baker Street',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543216',
        'verified': false,
      },
      {
        'name': 'Tech Repair Hub',
        'tagline': 'Same Day Repairs',
        'category': 'Services',
        'emoji': '📱',
        'rating': 4.3,
        'reviews': 445,
        'address': '89 Tech Park',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'phone': '9876543217',
        'verified': true,
      },
    ];

    setState(() {
      _businesses = mockBusinesses.map((b) {
        return BusinessModel(
          id: 'biz_${random.nextInt(10000)}',
          name: b['name'] as String,
          tagline: b['tagline'] as String,
          description: 'Quality ${b['category']} services in your area',
          category: b['category'] as String,
          emoji: b['emoji'] as String,
          address: b['address'] as String,
          city: b['city'] as String,
          state: b['state'] as String,
          latitude: 19.0760 + (random.nextDouble() * 0.1),
          longitude: 72.8777 + (random.nextDouble() * 0.1),
          phoneNumber: b['phone'] as String,
          whatsappNumber: b['phone'] as String,
          isApproved: true,
          isVerified: b['verified'] as bool,
          rating: b['rating'] as double,
          reviewCount: b['reviews'] as int,
          ownerId: 'owner_${random.nextInt(1000)}',
          createdAt:
              DateTime.now().subtract(Duration(days: random.nextInt(365))),
          updatedAt: DateTime.now(),
          qrCode: 'https://app.com/business/biz_${random.nextInt(10000)}',
          followers: random.nextInt(1000),
        );
      }).toList();
      _filteredBusinesses = _businesses;
      _isLoading = false;
      print('🟢 BusinessDirectory: Loaded ${_businesses.length} businesses');
      print(
          '🟢 BusinessDirectory: Filtered list has ${_filteredBusinesses.length} items');
    });
  }

  void _filterBusinesses() {
    setState(() {
      _filteredBusinesses = _businesses.where((business) {
        final matchesSearch =
            business.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                business.tagline!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' ||
            business.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        '🔷 BusinessDirectory: Building UI - isLoading: $_isLoading, businesses: ${_filteredBusinesses.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterBusinesses();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search businesses...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                              _filterBusinesses();
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
              ),

              // Category Filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                          _filterBusinesses();
                        },
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBusinesses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredBusinesses.length,
                  itemBuilder: (context, index) {
                    return _buildBusinessCard(_filteredBusinesses[index]);
                  },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No businesses found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BusinessModel business) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessProfileScreen(business: business),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo/Emoji
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        business.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // FEATURE 4: Verified Badge
                            if (business.isVerified)
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
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          business.tagline ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Category
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                business.category,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Rating
                            if (business.rating != null) ...[
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${business.rating} (${business.reviewCount ?? 0})',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // FEATURE 2: Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${business.city}, ${business.state}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // FEATURE 3: Quick Contact Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.call,
                      label: 'Call',
                      color: Colors.green,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BusinessProfileScreen(business: business),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.chat,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BusinessProfileScreen(business: business),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.directions,
                      label: 'Directions',
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BusinessProfileScreen(business: business),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionButton(
                      icon: Icons.info_outline,
                      label: 'View Profile',
                      color: Colors.orange,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BusinessProfileScreen(business: business),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
