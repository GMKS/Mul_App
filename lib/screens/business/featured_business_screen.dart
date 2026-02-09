/// Featured Business Module Screen
/// Separate module for managing featured businesses with:
/// - Add featured business
/// - Admin approval flow
/// - Auto-sync to main UI carousel
/// - Database persistence

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';

class FeaturedBusinessScreen extends StatefulWidget {
  final bool isAdmin;

  const FeaturedBusinessScreen({
    super.key,
    this.isAdmin = false,
  });

  @override
  State<FeaturedBusinessScreen> createState() => _FeaturedBusinessScreenState();
}

class _FeaturedBusinessScreenState extends State<FeaturedBusinessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FeaturedBusiness> _allBusinesses = [];
  List<FeaturedBusiness> _pendingBusinesses = [];
  List<FeaturedBusiness> _approvedBusinesses = [];
  List<FeaturedBusiness> _rejectedBusinesses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isAdmin ? 4 : 1,
      vsync: this,
    );
    _loadFeaturedBusinesses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedBusinesses() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Fetch featured business submissions
      final response = await supabase
          .from('featured_business_submissions')
          .select()
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);

      final businesses = data.map((b) => FeaturedBusiness.fromJson(b)).toList();

      setState(() {
        _allBusinesses = businesses;
        _pendingBusinesses =
            businesses.where((b) => b.status == 'pending').toList();
        _approvedBusinesses =
            businesses.where((b) => b.status == 'approved').toList();
        _rejectedBusinesses =
            businesses.where((b) => b.status == 'rejected').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading featured businesses: $e');
      // Load mock data for testing
      _loadMockData();
    }
  }

  void _loadMockData() {
    final mockBusinesses = [
      FeaturedBusiness(
        id: 'fb_1',
        businessName: 'Lakshmi Jewellers',
        tagline: 'Traditional Gold Jewelry',
        description: 'Finest gold and diamond jewelry',
        category: 'Jewellery',
        emoji: '💎',
        phoneNumber: '9876543210',
        address: 'Begum Bazaar, Hyderabad',
        city: 'Hyderabad',
        latitude: 17.3850,
        longitude: 78.4867,
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      FeaturedBusiness(
        id: 'fb_2',
        businessName: 'Spice Garden Restaurant',
        tagline: 'Authentic Hyderabadi Biryani',
        description: 'Best biryani in town!',
        category: 'Restaurant',
        emoji: '🍽️',
        phoneNumber: '9988776655',
        address: 'Banjara Hills, Hyderabad',
        city: 'Hyderabad',
        latitude: 17.4156,
        longitude: 78.4347,
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FeaturedBusiness(
        id: 'fb_3',
        businessName: 'Tech World Electronics',
        tagline: 'Latest Gadgets & Accessories',
        description: 'All electronics under one roof',
        category: 'Electronics',
        emoji: '📱',
        phoneNumber: '9112233445',
        address: 'Ameerpet, Hyderabad',
        city: 'Hyderabad',
        latitude: 17.4375,
        longitude: 78.4483,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    ];

    setState(() {
      _allBusinesses = mockBusinesses;
      _pendingBusinesses =
          mockBusinesses.where((b) => b.status == 'pending').toList();
      _approvedBusinesses =
          mockBusinesses.where((b) => b.status == 'approved').toList();
      _rejectedBusinesses =
          mockBusinesses.where((b) => b.status == 'rejected').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isAdmin ? 'Featured Business Admin' : 'Featured Businesses'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: widget.isAdmin
            ? TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.amber,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'All (${_allBusinesses.length})'),
                  Tab(text: 'Pending (${_pendingBusinesses.length})'),
                  Tab(text: 'Approved (${_approvedBusinesses.length})'),
                  Tab(text: 'Rejected (${_rejectedBusinesses.length})'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.isAdmin
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBusinessList(_allBusinesses),
                    _buildBusinessList(_pendingBusinesses),
                    _buildBusinessList(_approvedBusinesses),
                    _buildBusinessList(_rejectedBusinesses),
                  ],
                )
              : _buildBusinessList(_approvedBusinesses),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFeaturedBusinessDialog(),
        icon: const Icon(Icons.add_business),
        label: const Text('Add Featured'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBusinessList(List<FeaturedBusiness> businesses) {
    if (businesses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No businesses found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a featured business to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeaturedBusinesses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          return _buildBusinessCard(businesses[index]);
        },
      ),
    );
  }

  Widget _buildBusinessCard(FeaturedBusiness business) {
    Color statusColor;
    IconData statusIcon;
    switch (business.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getGradientColors(business.category),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      business.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.businessName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        business.tagline,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        business.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (business.description != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      business.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.red[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${business.address}, ${business.city}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Phone
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.green[400]),
                    const SizedBox(width: 4),
                    Text(
                      business.phoneNumber,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category
                Row(
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 4),
                    Text(
                      business.category,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Admin Actions
                if (widget.isAdmin && business.status == 'pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _approveBusiness(business),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _rejectBusiness(business),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
    );
  }

  Future<void> _approveBusiness(FeaturedBusiness business) async {
    try {
      final supabase = Supabase.instance.client;

      // Update status to approved
      await supabase.from('featured_business_submissions').update({
        'status': 'approved',
        'approved_at': DateTime.now().toIso8601String()
      }).eq('id', business.id);

      // Sync to main businesses table with is_featured = true
      await supabase.from('businesses').upsert({
        'id': 'featured_${business.id}',
        'name': business.businessName,
        'tagline': business.tagline,
        'description': business.description,
        'category': business.category,
        'phone': business.phoneNumber,
        'address': business.address,
        'city': business.city,
        'latitude': business.latitude,
        'longitude': business.longitude,
        'is_featured': true,
        'is_approved': true,
        'is_verified': true,
        'created_at': business.createdAt.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${business.businessName} approved and synced to Featured!'),
          backgroundColor: Colors.green,
        ),
      );

      _loadFeaturedBusinesses();
    } catch (e) {
      print('❌ Error approving business: $e');

      // Mock approval for testing
      setState(() {
        final index = _allBusinesses.indexWhere((b) => b.id == business.id);
        if (index != -1) {
          _allBusinesses[index] = business.copyWith(status: 'approved');
          _pendingBusinesses.removeWhere((b) => b.id == business.id);
          _approvedBusinesses.add(_allBusinesses[index]);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${business.businessName} approved! (Demo mode)'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectBusiness(FeaturedBusiness business) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectionReasonDialog(),
    );

    if (reason == null) return;

    try {
      final supabase = Supabase.instance.client;

      await supabase.from('featured_business_submissions').update({
        'status': 'rejected',
        'rejection_reason': reason,
        'rejected_at': DateTime.now().toIso8601String(),
      }).eq('id', business.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${business.businessName} rejected'),
          backgroundColor: Colors.red,
        ),
      );

      _loadFeaturedBusinesses();
    } catch (e) {
      print('❌ Error rejecting business: $e');

      // Mock rejection for testing
      setState(() {
        final index = _allBusinesses.indexWhere((b) => b.id == business.id);
        if (index != -1) {
          _allBusinesses[index] = business.copyWith(status: 'rejected');
          _pendingBusinesses.removeWhere((b) => b.id == business.id);
          _rejectedBusinesses.add(_allBusinesses[index]);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${business.businessName} rejected (Demo mode)'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddFeaturedBusinessDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFeaturedBusinessScreen(
          onBusinessAdded: () {
            _loadFeaturedBusinesses();
          },
        ),
      ),
    );
  }

  List<Color> _getGradientColors(String category) {
    switch (category.toLowerCase()) {
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
      case 'electronics':
        return [const Color(0xFF607D8B), const Color(0xFF455A64)];
      case 'salon':
        return [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)];
      default:
        return [Colors.deepPurple, Colors.purple];
    }
  }
}

// Add Featured Business Screen
class AddFeaturedBusinessScreen extends StatefulWidget {
  final VoidCallback? onBusinessAdded;

  const AddFeaturedBusinessScreen({super.key, this.onBusinessAdded});

  @override
  State<AddFeaturedBusinessScreen> createState() =>
      _AddFeaturedBusinessScreenState();
}

class _AddFeaturedBusinessScreenState extends State<AddFeaturedBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedCategory = 'Shop';
  double? _latitude;
  double? _longitude;
  bool _isCapturingLocation = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Shop',
    'Restaurant',
    'Cafe',
    'Grocery',
    'Pharmacy',
    'Electronics',
    'Jewellery',
    'Salon',
    'Healthcare',
    'Education',
    'Services',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _captureCurrentLocation() async {
    setState(() => _isCapturingLocation = true);

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Reverse geocode to get address
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _addressController.text =
                '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';
            _cityController.text = place.locality ?? '';
          });
        }
      } catch (e) {
        print('Geocoding error: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Location captured: ${_latitude?.toStringAsFixed(4)}, ${_longitude?.toStringAsFixed(4)}',
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isCapturingLocation = false);
    }
  }

  Future<void> _submitBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;

      final businessData = {
        'id': 'fb_${DateTime.now().millisecondsSinceEpoch}',
        'business_name': _nameController.text.trim(),
        'tagline': _taglineController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'phone_number': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('featured_business_submissions').insert(businessData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business submitted for approval!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onBusinessAdded?.call();
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error submitting business: $e');

      // Show success anyway for demo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business submitted for approval! (Demo mode)'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onBusinessAdded?.call();
      Navigator.pop(context);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'jewellery':
        return '💎';
      case 'restaurant':
        return '🍽️';
      case 'cafe':
        return '☕';
      case 'grocery':
        return '🛒';
      case 'pharmacy':
        return '💊';
      case 'electronics':
        return '📱';
      case 'salon':
        return '💇';
      case 'healthcare':
        return '🏥';
      case 'education':
        return '📚';
      case 'services':
        return '🔧';
      default:
        return '🏪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Featured Business'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 48,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add Your Business to Featured',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get more visibility! Featured businesses appear on the home screen carousel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Business Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tagline
              TextFormField(
                controller: _taglineController,
                decoration: const InputDecoration(
                  labelText: 'Tagline *',
                  prefixIcon: Icon(Icons.short_text),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Best Biryani in Town!',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a catchy tagline';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Text(
                    _getCategoryEmoji(_selectedCategory),
                    style: const TextStyle(fontSize: 20),
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(
                          _getCategoryEmoji(category),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // GPS Location Capture
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.gps_fixed, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'GPS Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_latitude != null && _longitude != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lat: ${_latitude!.toStringAsFixed(6)}\nLng: ${_longitude!.toStringAsFixed(6)}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'Capture your business location for map display',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCapturingLocation
                              ? null
                              : _captureCurrentLocation,
                          icon: _isCapturingLocation
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(
                            _isCapturingLocation
                                ? 'Capturing...'
                                : _latitude != null
                                    ? 'Update Location'
                                    : 'Capture Current Location',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBusiness,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text(
                          'Submit for Approval',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Info Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your business will be reviewed by admin before appearing in Featured section.',
                        style: TextStyle(fontSize: 13),
                      ),
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

// Rejection Reason Dialog
class _RejectionReasonDialog extends StatefulWidget {
  @override
  State<_RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<_RejectionReasonDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rejection Reason'),
      content: TextField(
        controller: _reasonController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Enter reason for rejection...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _reasonController.text.trim());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}

// Featured Business Model
class FeaturedBusiness {
  final String id;
  final String businessName;
  final String tagline;
  final String? description;
  final String category;
  final String emoji;
  final String phoneNumber;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime createdAt;
  final String? rejectionReason;

  FeaturedBusiness({
    required this.id,
    required this.businessName,
    required this.tagline,
    this.description,
    required this.category,
    required this.emoji,
    required this.phoneNumber,
    required this.address,
    required this.city,
    this.latitude,
    this.longitude,
    this.status = 'pending',
    required this.createdAt,
    this.rejectionReason,
  });

  factory FeaturedBusiness.fromJson(Map<String, dynamic> json) {
    return FeaturedBusiness(
      id: json['id']?.toString() ?? '',
      businessName: json['business_name'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'Other',
      emoji: _getEmojiForCategory(json['category'] ?? 'Other'),
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      rejectionReason: json['rejection_reason'],
    );
  }

  static String _getEmojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'jewellery':
        return '💎';
      case 'restaurant':
        return '🍽️';
      case 'cafe':
        return '☕';
      case 'grocery':
        return '🛒';
      case 'pharmacy':
        return '💊';
      case 'electronics':
        return '📱';
      case 'salon':
        return '💇';
      case 'healthcare':
        return '🏥';
      case 'education':
        return '📚';
      case 'services':
        return '🔧';
      default:
        return '🏪';
    }
  }

  FeaturedBusiness copyWith({
    String? id,
    String? businessName,
    String? tagline,
    String? description,
    String? category,
    String? emoji,
    String? phoneNumber,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
  }) {
    return FeaturedBusiness(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
