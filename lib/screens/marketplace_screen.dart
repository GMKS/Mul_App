import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketplaceAndClassifieds),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.shopping_bag), text: l10n.buySellRent),
            Tab(icon: const Icon(Icons.work), text: l10n.jobsAndGigs),
            Tab(icon: const Icon(Icons.handyman), text: l10n.servicesOffered),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBuySellRentTab(),
          _buildJobsTab(),
          _buildServicesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostDialog(),
        backgroundColor: Colors.orange.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Post Ad'),
      ),
    );
  }

  Widget _buildBuySellRentTab() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Category Filter
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(l10n.allCategories, Icons.grid_view),
              _buildCategoryChip(l10n.furniture, Icons.chair),
              _buildCategoryChip(l10n.electronics, Icons.devices),
              _buildCategoryChip(l10n.vehicles, Icons.directions_car),
              _buildCategoryChip(l10n.realEstate, Icons.home),
            ],
          ),
        ),
        const Divider(height: 1),
        // Listings
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMarketplaceItem(
                title: 'Sofa Set - 3+2 Seater',
                price: '₹15,000',
                category: 'Furniture',
                location: 'Jubilee Hills, 2.5 km',
                condition: 'Good',
                postedDate: '2 days ago',
                imageUrl: null,
                type: 'Sell',
              ),
              const SizedBox(height: 12),
              _buildMarketplaceItem(
                title: 'iPhone 13 Pro - 128GB',
                price: '₹45,000',
                category: 'Electronics',
                location: 'Banjara Hills, 3 km',
                condition: 'Like New',
                postedDate: '1 day ago',
                imageUrl: null,
                type: 'Sell',
              ),
              const SizedBox(height: 12),
              _buildMarketplaceItem(
                title: 'Honda Activa 2020',
                price: '₹42,000',
                category: 'Vehicles',
                location: 'Hitech City, 5 km',
                condition: 'Excellent',
                postedDate: '3 hours ago',
                imageUrl: null,
                type: 'Sell',
              ),
              const SizedBox(height: 12),
              _buildMarketplaceItem(
                title: '2BHK Apartment',
                price: '₹18,000/month',
                category: 'Real Estate',
                location: 'Gachibowli, 4 km',
                condition: 'Semi-Furnished',
                postedDate: '1 day ago',
                imageUrl: null,
                type: 'Rent',
              ),
              const SizedBox(height: 12),
              _buildMarketplaceItem(
                title: 'MacBook Pro M1',
                price: '₹75,000',
                category: 'Electronics',
                location: 'Madhapur, 6 km',
                condition: 'Excellent',
                postedDate: '5 hours ago',
                imageUrl: null,
                type: 'Sell',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildJobCard(
          title: 'Delivery Executive',
          company: 'SwiggyZomato',
          type: 'Full-time',
          salary: '₹15,000 - ₹20,000/month',
          location: 'Multiple locations',
          posted: '2 hours ago',
          description: 'Food delivery, Own vehicle required',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          title: 'Content Writer (Freelance)',
          company: 'Digital Marketing Agency',
          type: 'Freelance',
          salary: '₹500 - ₹1000/article',
          location: 'Work from home',
          posted: '1 day ago',
          description: 'SEO-friendly content writing',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          title: 'Part-time Sales Associate',
          company: 'Reliance Retail',
          type: 'Part-time',
          salary: '₹12,000/month',
          location: 'Hitech City, 3 km',
          posted: '3 days ago',
          description: 'Evening shift, 4-9 PM',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          title: 'Graphic Designer',
          company: 'Startup Hub',
          type: 'Gig Work',
          salary: '₹2,000 - ₹5,000/project',
          location: 'Remote',
          posted: '1 week ago',
          description: 'Logo design, social media posts',
        ),
        const SizedBox(height: 12),
        _buildJobCard(
          title: 'Tutor - Mathematics',
          company: 'Individual',
          type: 'Part-time',
          salary: '₹500/hour',
          location: 'Madhapur, 5 km',
          posted: '2 days ago',
          description: 'Class 10-12 students',
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildServiceCard(
          title: 'Plumber',
          provider: 'Ravi Kumar',
          rating: 4.8,
          reviewCount: 156,
          price: '₹300/hour',
          location: 'Covers 10 km radius',
          skills: ['Pipe Repair', 'Bathroom Fitting', 'Water Leakage'],
          available: true,
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          title: 'Electrician',
          provider: 'Suresh Electrical Services',
          rating: 4.9,
          reviewCount: 203,
          price: '₹400/hour',
          location: 'Covers 15 km radius',
          skills: ['Wiring', 'AC Repair', 'Switch Installation'],
          available: true,
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          title: 'Home Tutor - English',
          provider: 'Priya Sharma',
          rating: 4.7,
          reviewCount: 89,
          price: '₹500/hour',
          location: 'Jubilee Hills area',
          skills: ['Spoken English', 'Grammar', 'IELTS Prep'],
          available: false,
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          title: 'Carpenter',
          provider: 'Mohammed Woodworks',
          rating: 4.6,
          reviewCount: 124,
          price: '₹350/hour',
          location: 'Covers 12 km radius',
          skills: ['Furniture Repair', 'Door Installation', 'Custom Work'],
          available: true,
        ),
        const SizedBox(height: 12),
        _buildServiceCard(
          title: 'Painter',
          provider: 'City Painters',
          rating: 4.5,
          reviewCount: 98,
          price: '₹250/hour',
          location: 'Covers 20 km radius',
          skills: ['Interior Painting', 'Exterior Painting', 'Texture'],
          available: true,
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.orange.shade700),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = label);
        },
        selectedColor: Colors.orange.shade700,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMarketplaceItem({
    required String title,
    required String price,
    required String category,
    required String location,
    required String condition,
    required String postedDate,
    String? imageUrl,
    required String type,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () =>
            _showItemDetails(title, price, category, location, condition),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  size: 40,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: type == 'Rent'
                                ? Colors.blue.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: type == 'Rent'
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Condition: $condition',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• $postedDate',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
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
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required String company,
    required String type,
    required String salary,
    required String location,
    required String posted,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showJobDetails(title, company, salary, description),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(Icons.work, color: Colors.orange.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          company,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.currency_rupee,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    salary,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    posted,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _applyForJob(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String provider,
    required double rating,
    required int reviewCount,
    required String price,
    required String location,
    required List<String> skills,
    required bool available,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showServiceDetails(title, provider, price),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      provider[0],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          provider,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (available)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle,
                              size: 8, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Available',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$rating ($reviewCount reviews)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makeCall(''),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _bookService(title, provider),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Furniture':
        return Icons.chair;
      case 'Electronics':
        return Icons.devices;
      case 'Vehicles':
        return Icons.directions_car;
      case 'Real Estate':
        return Icons.home;
      case 'Books':
        return Icons.book;
      case 'Sports':
        return Icons.sports_soccer;
      default:
        return Icons.shopping_bag;
    }
  }

  void _showPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Advertisement'),
        content: const Text(
          'Choose what you want to post:\n\n'
          '• Sell or Rent items\n'
          '• Job posting\n'
          '• Offer services',
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
                const SnackBar(content: Text('Post ad feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(String title, String price, String category,
      String location, String condition) {
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
                    title,
                    style: const TextStyle(
                      fontSize: 20,
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
            Text(
              price,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Category', category),
            _buildDetailRow('Location', location),
            _buildDetailRow('Condition', condition),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makeCall(''),
                    icon: const Icon(Icons.call),
                    label: const Text('Call Seller'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showJobDetails(
      String title, String company, String salary, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                    title,
                    style: const TextStyle(
                      fontSize: 20,
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
            const SizedBox(height: 8),
            Text(
              company,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              salary,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _applyForJob(title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Now', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetails(String title, String provider, String price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              price,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makeCall(''),
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _bookService(title, provider),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling feature coming soon!')),
    );
  }

  void _applyForJob(String jobTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Job'),
        content:
            Text('Apply for: $jobTitle\n\nThis will open application form.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application submitted!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _bookService(String service, String provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Service'),
        content: Text(
            'Book: $service\nProvider: $provider\n\nChoose date and time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking confirmed!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
