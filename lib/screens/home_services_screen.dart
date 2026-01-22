/// Home Services Screen
/// Comprehensive home services booking platform with all modern features

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/home_service_model.dart';
import '../services/home_service_service.dart';
import '../l10n/app_localizations.dart';

class HomeServicesScreen extends StatefulWidget {
  const HomeServicesScreen({super.key});

  @override
  State<HomeServicesScreen> createState() => _HomeServicesScreenState();
}

class _HomeServicesScreenState extends State<HomeServicesScreen>
    with SingleTickerProviderStateMixin {
  final _homeService = HomeServiceService();
  late TabController _tabController;

  List<ServiceProvider> _allProviders = [];
  List<ServiceBooking> _myBookings = [];
  List<ServiceOffer> _offers = [];
  bool _isLoading = true;

  ServiceCategory? _selectedCategory;
  String _sortBy = 'rating';
  bool _showAvailableOnly = true;
  bool _showFemaleOnly = false;
  bool _showEcoFriendlyOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _homeService.initializeMockData();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final providers = await _homeService.fetchProviders(
      category: _selectedCategory,
      isAvailable: _showAvailableOnly,
      isFemale: _showFemaleOnly,
      isEcoFriendly: _showEcoFriendlyOnly,
      sortBy: _sortBy,
    );

    final bookings = await _homeService.fetchUserBookings('u1');
    final offers = await _homeService.fetchOffers();

    setState(() {
      _allProviders = providers;
      _myBookings = bookings;
      _offers = offers;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1419) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n?.homeServices ?? 'Home Services'),
        backgroundColor: isDark ? const Color(0xFF1C2938) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: 'Services'),
            Tab(icon: Icon(Icons.people), text: 'Providers'),
            Tab(icon: Icon(Icons.bookmark), text: 'Bookings'),
            Tab(icon: Icon(Icons.local_offer), text: 'Offers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildServicesTab(isDark),
          _buildProvidersTab(isDark),
          _buildBookingsTab(isDark),
          _buildOffersTab(isDark),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showEmergencyBookingDialog,
              icon: const Icon(Icons.emergency),
              label: const Text('Emergency'),
              backgroundColor: Colors.red,
            )
          : null,
    );
  }

  // Services Tab - Category Grid
  Widget _buildServicesTab(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedBanner(isDark),
            const SizedBox(height: 20),
            _buildQuickStats(isDark),
            const SizedBox(height: 20),
            Text(
              'All Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: ServiceCategory.values.length,
              itemBuilder: (context, index) {
                final category = ServiceCategory.values[index];
                return _buildCategoryCard(category, isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book trusted professionals for your home',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Find Provider'),
                ),
              ],
            ),
          ),
          const Icon(Icons.home_repair_service,
              size: 80, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.verified_user,
            label: 'Verified',
            value: '500+',
            color: Colors.blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            label: 'Avg Rating',
            value: '4.8',
            color: Colors.amber,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: 'Completed',
            value: '10K+',
            color: Colors.green,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2938) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category, bool isDark) {
    final name = ServiceCategoryHelper.getName(category);
    final icon = ServiceCategoryHelper.getIcon(category);
    final color = ServiceCategoryHelper.getColor(category);

    return InkWell(
      onTap: () {
        setState(() => _selectedCategory = category);
        _loadData();
        _tabController.animateTo(1);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C2938) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: _selectedCategory == category
              ? Border.all(color: color, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Providers Tab
  Widget _buildProvidersTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allProviders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No providers found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _showAvailableOnly = false;
                  _showFemaleOnly = false;
                  _showEcoFriendlyOnly = false;
                });
                _loadData();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allProviders.length,
        itemBuilder: (context, index) {
          return _buildProviderCard(_allProviders[index], isDark);
        },
      ),
    );
  }

  Widget _buildProviderCard(ServiceProvider provider, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1C2938) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showProviderDetails(provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(provider.photoUrl),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: provider.verificationColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            provider.verificationIcon,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (provider.isFemale)
                              const Icon(Icons.female,
                                  size: 18, color: Colors.pink),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ServiceCategoryHelper.getName(provider.category),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 16, color: Colors.amber.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.rating} (${provider.totalReviews})',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.check_circle,
                                size: 16, color: Colors.green.shade400),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.completedJobs} jobs',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (provider.isBackgroundChecked)
                    _buildBadge('Verified', Icons.verified_user, Colors.blue),
                  if (provider.isCertified)
                    _buildBadge(
                        'Certified', Icons.workspace_premium, Colors.purple),
                  if (provider.isEcoFriendly)
                    _buildBadge('Eco-Friendly', Icons.eco, Colors.green),
                  if (provider.hasInsurance)
                    _buildBadge('Insured', Icons.security, Colors.orange),
                  if (provider.offersGuarantee)
                    _buildBadge('${provider.guaranteeDays}D Guarantee',
                        Icons.verified, Colors.teal),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${provider.location} • ${provider.distanceKm} km away',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '₹${provider.pricePerHour}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const Text(' /hour', style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: provider.isAvailable
                        ? () => _showBookingDialog(provider)
                        : null,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label:
                        Text(provider.isAvailable ? 'Book Now' : 'Unavailable'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Bookings Tab
  Widget _buildBookingsTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Book a service to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myBookings.length,
        itemBuilder: (context, index) {
          return _buildBookingCard(_myBookings[index], isDark);
        },
      ),
    );
  }

  Widget _buildBookingCard(ServiceBooking booking, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1C2938) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ServiceCategoryHelper.getColor(booking.category)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    ServiceCategoryHelper.getIcon(booking.category),
                    color: ServiceCategoryHelper.getColor(booking.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ServiceCategoryHelper.getName(booking.category),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: booking.statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    booking.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: booking.statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (booking.provider != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(booking.provider!.photoUrl),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.provider!.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.blue.shade400),
                const SizedBox(width: 6),
                Text(
                  '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time,
                    size: 16, color: Colors.orange.shade400),
                const SizedBox(width: 6),
                Text(
                  booking.timeSlot,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '₹${booking.estimatedCost}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                if (booking.status == BookingStatus.pending)
                  TextButton(
                    onPressed: () => _cancelBooking(booking.id),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            if (booking.isEmergency) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Emergency Service',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Offers Tab
  Widget _buildOffersTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No offers available',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _offers.length,
      itemBuilder: (context, index) {
        return _buildOfferCard(_offers[index], isDark);
      },
    );
  }

  Widget _buildOfferCard(ServiceOffer offer, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1C2938) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400.withOpacity(0.1),
              Colors.pink.shade400.withOpacity(0.1),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${offer.discountPercent}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                if (offer.isFirstTimeUser)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'First User',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              offer.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              offer.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1419) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    offer.code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.copy,
                      size: 18, color: Theme.of(context).primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Valid till ${offer.validTill.day}/${offer.validTill.month}/${offer.validTill.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dialogs
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Providers'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter provider name or service...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) async {
            Navigator.pop(context);
            setState(() => _isLoading = true);
            final results = await _homeService.searchProviders(query);
            setState(() {
              _allProviders = results;
              _isLoading = false;
            });
            _tabController.animateTo(1);
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Providers'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Available Only'),
                value: _showAvailableOnly,
                onChanged: (value) =>
                    setDialogState(() => _showAvailableOnly = value),
              ),
              SwitchListTile(
                title: const Text('Female Providers'),
                value: _showFemaleOnly,
                onChanged: (value) =>
                    setDialogState(() => _showFemaleOnly = value),
              ),
              SwitchListTile(
                title: const Text('Eco-Friendly'),
                value: _showEcoFriendlyOnly,
                onChanged: (value) =>
                    setDialogState(() => _showEcoFriendlyOnly = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showProviderDetails(ServiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating: ${provider.rating} ⭐'),
            Text('Experience: ${provider.experience}'),
            Text('Jobs: ${provider.completedJobs}'),
            Text('Location: ${provider.location}'),
            Text('Languages: ${provider.languages.join(", ")}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showBookingDialog(provider);
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(ServiceProvider provider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${provider.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Service Title',
                hintText: 'e.g., Kitchen pipe repair',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the issue...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;

              await _homeService.createBooking(
                userId: 'u1',
                providerId: provider.id,
                category: provider.category,
                serviceType: ServiceType.oneTime,
                title: titleController.text,
                description: descController.text,
                scheduledDate: DateTime.now().add(const Duration(days: 1)),
                timeSlot: provider.availableSlots.first,
                address: 'User address here',
                latitude: 17.4948,
                longitude: 78.3985,
                estimatedCost: provider.pricePerHour * 2,
              );

              Navigator.pop(context);
              _loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking created successfully!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Booking'),
          ],
        ),
        content: const Text(
          'Emergency services are prioritized and typically arrive within 1-2 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Request Emergency'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _homeService.cancelBooking(bookingId, 'User cancelled');
              Navigator.pop(context);
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
