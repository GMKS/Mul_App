// Services Directory Screen
// Comprehensive service provider directory with all modern features
// Features: Search, Filter, Map, Ratings, Booking, Chat, etc.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../models/service_model.dart';
import '../theme/app_theme.dart';
import 'service_details_screen.dart';

class ServicesDirectoryScreen extends StatefulWidget {
  final String? userCity;
  final String? userState;

  const ServicesDirectoryScreen({
    super.key,
    this.userCity,
    this.userState,
  });

  @override
  State<ServicesDirectoryScreen> createState() =>
      _ServicesDirectoryScreenState();
}

class _ServicesDirectoryScreenState extends State<ServicesDirectoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<ServiceProvider> _allServices = [];
  List<ServiceProvider> _filteredServices = [];
  Set<String> _favoriteIds = {};

  ServiceCategory? _selectedCategory;
  String _selectedCity = 'All Cities';
  bool _showVerifiedOnly = false;
  bool _showEmergencyOnly = false;
  PriceRange? _selectedPriceRange;
  String _sortBy = 'rating'; // rating, distance, reviews

  bool _isLoading = true;
  bool _showMap = false;

  final List<String> _cities = [
    'All Cities',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Pune',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Ahmedabad',
    'Jaipur',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.userCity != null) {
      _selectedCity = widget.userCity!;
    }
    _loadServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data - replace with API call
    final random = Random();
    _allServices = List.generate(30, (index) {
      final category =
          ServiceCategory.values[random.nextInt(ServiceCategory.values.length)];
      return ServiceProvider(
        id: 'service_$index',
        name: _getProviderName(index, category),
        businessName: _getBusinessName(index, category),
        category: category,
        subServices: _getSubServices(category),
        description: _getDescription(category),
        phoneNumber: '98765432${10 + index}',
        whatsappNumber: random.nextBool() ? '98765432${10 + index}' : null,
        email:
            'contact@${_getBusinessName(index, category).toLowerCase().replaceAll(' ', '')}.com',
        city: _cities[random.nextInt(_cities.length - 1) + 1],
        state: widget.userState ?? 'Maharashtra',
        area: _getArea(random),
        address: '${random.nextInt(100) + 1}, ${_getArea(random)}, City Center',
        latitude: 18.5 + random.nextDouble(),
        longitude: 73.8 + random.nextDouble(),
        imageUrl:
            'https://ui-avatars.com/api/?name=${_getBusinessName(index, category)}&background=random',
        isVerified: random.nextBool(),
        isEmergency24x7:
            category == ServiceCategory.emergency || random.nextInt(10) > 7,
        status:
            ServiceStatus.values[random.nextInt(ServiceStatus.values.length)],
        priceRange: PriceRange.values[random.nextInt(PriceRange.values.length)],
        rating: 3.5 + random.nextDouble() * 1.5,
        reviewCount: random.nextInt(200),
        totalBookings: random.nextInt(500),
        joinedDate:
            DateTime.now().subtract(Duration(days: random.nextInt(730))),
        workingDays: [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday'
        ],
        workingHours: '9:00 AM - 7:00 PM',
        specializations: _getSpecializations(category),
        certifications: random.nextBool() ? ['ISO Certified', 'Licensed'] : [],
        yearsOfExperience: random.nextInt(20) + 1,
        instantBooking: random.nextBool(),
        chatAvailable: random.nextBool(),
        favoriteCount: random.nextInt(100),
        callCount: random.nextInt(300),
        whatsappClickCount: random.nextInt(250),
      );
    });

    _filteredServices = _allServices;
    _applyFilters();
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    _filteredServices = _allServices.where((service) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!service.businessName.toLowerCase().contains(query) &&
            !service.name.toLowerCase().contains(query) &&
            !service.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // City filter
      if (_selectedCity != 'All Cities' && service.city != _selectedCity) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null && service.category != _selectedCategory) {
        return false;
      }

      // Verified filter
      if (_showVerifiedOnly && !service.isVerified) {
        return false;
      }

      // Emergency filter
      if (_showEmergencyOnly && !service.isEmergency24x7) {
        return false;
      }

      // Price range filter
      if (_selectedPriceRange != null &&
          service.priceRange != _selectedPriceRange) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    _filteredServices.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'reviews':
          return b.reviewCount.compareTo(a.reviewCount);
        case 'experience':
          return b.yearsOfExperience.compareTo(a.yearsOfExperience);
        default:
          return 0;
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Services Directory',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map, color: Colors.white),
            onPressed: () {
              setState(() => _showMap = !_showMap);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Top Rated'),
            Tab(icon: Icon(Icons.list), text: 'All Services'),
            Tab(icon: Icon(Icons.bookmark), text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildQuickFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showMap
                    ? _buildMapView()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildServiceList(_topRatedServices),
                          _buildServiceList(_filteredServices),
                          _buildServiceList(_favoriteServices),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search services...',
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: _selectedCity,
            icon: Icons.location_on,
            onTap: _showCityPicker,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: _selectedCategory?.displayName ?? 'All Categories',
            icon: Icons.category,
            onTap: _showCategoryPicker,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Verified'),
            avatar: const Icon(Icons.verified, size: 18),
            selected: _showVerifiedOnly,
            onSelected: (value) {
              setState(() => _showVerifiedOnly = value);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('24/7'),
            avatar: const Icon(Icons.access_time, size: 18),
            selected: _showEmergencyOnly,
            onSelected: (value) {
              setState(() => _showEmergencyOnly = value);
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onPressed: onTap,
    );
  }

  Widget _buildServiceList(List<ServiceProvider> services) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCity = 'All Cities';
                  _selectedCategory = null;
                  _showVerifiedOnly = false;
                  _showEmergencyOnly = false;
                  _selectedPriceRange = null;
                });
                _applyFilters();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(services[index]);
      },
    );
  }

  Widget _buildServiceCard(ServiceProvider service) {
    final isFavorite = _favoriteIds.contains(service.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceDetailsScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: service.imageUrl != null
                        ? Image.network(
                            service.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                  const SizedBox(width: 12),
                  // Service Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.businessName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (service.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${service.rating.toStringAsFixed(1)} (${service.reviewCount})',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(service.category.icon,
                                      size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      service.category.displayName,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${service.area ?? service.city}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: service.statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                service.statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: service.statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Favorite Button
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isFavorite) {
                          _favoriteIds.remove(service.id);
                        } else {
                          _favoriteIds.add(service.id);
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makeCall(service.phoneNumber),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  if (service.whatsappNumber != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openWhatsApp(service.whatsappNumber!),
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('WhatsApp',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF25D366),
                          side: const BorderSide(color: Color(0xFF25D366)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                  if (service.instantBooking) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showBookingDialog(service),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label:
                            const Text('Book', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // Badges
              if (service.isEmergency24x7 || service.certifications.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (service.isEmergency24x7)
                        _buildBadge('24/7 Emergency', Colors.red),
                      if (service.certifications.isNotEmpty)
                        _buildBadge(service.certifications.first, Colors.blue),
                      _buildBadge(service.priceRangeText, Colors.orange),
                      _buildBadge('${service.yearsOfExperience}+ Yrs Exp',
                          Colors.purple),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.business, size: 40, color: Colors.grey),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Map View',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredServices.length} services found',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Open in Google Maps
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening map with service locations...'),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in Maps'),
          ),
        ],
      ),
    );
  }

  List<ServiceProvider> get _topRatedServices {
    return List.from(_filteredServices)
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  List<ServiceProvider> get _favoriteServices {
    return _filteredServices
        .where((service) => _favoriteIds.contains(service.id))
        .toList();
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select City',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _cities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_cities[index]),
                      trailing: _selectedCity == _cities[index]
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() => _selectedCity = _cities[index]);
                        _applyFilters();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400,
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.all_inclusive),
                      title: const Text('All Categories'),
                      trailing: _selectedCategory == null
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() => _selectedCategory = null);
                        _applyFilters();
                        Navigator.pop(context);
                      },
                    ),
                    ...ServiceCategory.values.map((category) {
                      return ListTile(
                        leading: Icon(category.icon),
                        title: Text(category.displayName),
                        trailing: _selectedCategory == category
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          setState(() => _selectedCategory = category);
                          _applyFilters();
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _showVerifiedOnly = false;
                            _showEmergencyOnly = false;
                            _selectedPriceRange = null;
                            _sortBy = 'rating';
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Sort By
                  const Text(
                    'Sort By',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Rating'),
                        selected: _sortBy == 'rating',
                        onSelected: (selected) {
                          setModalState(() => _sortBy = 'rating');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Reviews'),
                        selected: _sortBy == 'reviews',
                        onSelected: (selected) {
                          setModalState(() => _sortBy = 'reviews');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Experience'),
                        selected: _sortBy == 'experience',
                        onSelected: (selected) {
                          setModalState(() => _sortBy = 'experience');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Price Range
                  const Text(
                    'Price Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Budget'),
                        selected: _selectedPriceRange == PriceRange.budget,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedPriceRange =
                                selected ? PriceRange.budget : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Moderate'),
                        selected: _selectedPriceRange == PriceRange.moderate,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedPriceRange =
                                selected ? PriceRange.moderate : null;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Premium'),
                        selected: _selectedPriceRange == PriceRange.premium,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedPriceRange =
                                selected ? PriceRange.premium : null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Additional Filters
                  const Text(
                    'Additional Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  CheckboxListTile(
                    title: const Text('Verified Providers Only'),
                    value: _showVerifiedOnly,
                    onChanged: (value) {
                      setModalState(() => _showVerifiedOnly = value ?? false);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('24/7 Emergency Services'),
                    value: _showEmergencyOnly,
                    onChanged: (value) {
                      setModalState(() => _showEmergencyOnly = value ?? false);
                    },
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingDialog(ServiceProvider service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${service.businessName}'),
            const SizedBox(height: 8),
            Text('Contact: ${service.phoneNumber}'),
            const SizedBox(height: 16),
            const Text(
                'Select your preferred date and time to book this service.'),
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
                const SnackBar(
                  content: Text('Booking feature - Coming soon!'),
                ),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make call')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/91$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  // Helper methods for mock data
  String _getProviderName(int index, ServiceCategory category) {
    final names = [
      'Rajesh Kumar',
      'Priya Sharma',
      'Amit Patel',
      'Sunita Reddy',
      'Vikram Singh'
    ];
    return names[index % names.length];
  }

  String _getBusinessName(int index, ServiceCategory category) {
    switch (category) {
      case ServiceCategory.home:
        return [
          'QuickFix Solutions',
          'HomeCare Pro',
          'Repair Masters',
          'Elite Services'
        ][index % 4];
      case ServiceCategory.health:
        return [
          'WellCare Clinic',
          'HealthFirst',
          'CureWell',
          'MedPlus'
        ][index % 4];
      case ServiceCategory.beauty:
        return [
          'Glamour Salon',
          'Beauty Hub',
          'Sparkle',
          'Style Studio'
        ][index % 4];
      case ServiceCategory.automotive:
        return [
          'AutoCare',
          'Car Clinic',
          'Garage Pro',
          'Quick Service'
        ][index % 4];
      default:
        return '${category.displayName} Services $index';
    }
  }

  List<String> _getSubServices(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.home:
        return ['Plumbing', 'Electrical', 'Carpentry', 'Painting'];
      case ServiceCategory.health:
        return ['General Checkup', 'Dental', 'Physiotherapy'];
      case ServiceCategory.beauty:
        return ['Haircut', 'Facial', 'Makeup', 'Spa'];
      case ServiceCategory.automotive:
        return ['Car Wash', 'Repair', 'Maintenance'];
      default:
        return [];
    }
  }

  String _getDescription(ServiceCategory category) {
    return 'Professional ${category.displayName.toLowerCase()} with years of experience. Quality service guaranteed.';
  }

  String _getArea(Random random) {
    final areas = [
      'Koregaon Park',
      'Baner',
      'Hinjewadi',
      'Viman Nagar',
      'Kothrud',
      'Aundh'
    ];
    return areas[random.nextInt(areas.length)];
  }

  List<String> _getSpecializations(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.home:
        return ['Residential', 'Commercial', 'Emergency'];
      case ServiceCategory.health:
        return ['Family Medicine', 'Pediatrics'];
      case ServiceCategory.beauty:
        return ['Bridal', 'Party Makeup'];
      default:
        return [];
    }
  }
}
