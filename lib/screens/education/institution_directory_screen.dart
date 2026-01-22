/// Institution Directory Screen
/// Comprehensive directory of schools, colleges, universities, and coaching centers
/// Features: Search, Filter by type, Map view, Detailed profiles, Admission info

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/education_model.dart';

class InstitutionDirectoryScreen extends StatefulWidget {
  final String? userCity;

  const InstitutionDirectoryScreen({super.key, this.userCity});

  @override
  State<InstitutionDirectoryScreen> createState() =>
      _InstitutionDirectoryScreenState();
}

class _InstitutionDirectoryScreenState extends State<InstitutionDirectoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  InstitutionType? _selectedType;
  String _selectedCity = 'All Cities';
  bool _verifiedOnly = false;
  String _sortBy = 'rating'; // rating, name, established

  List<Institution> _allInstitutions = [];
  List<Institution> _filteredInstitutions = [];

  final List<String> _cities = [
    'All Cities',
    'Hyderabad',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Pune',
    'Chennai',
    'Kolkata',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    if (widget.userCity != null) {
      _selectedCity = widget.userCity!;
    }
    _loadInstitutions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInstitutions() {
    // Mock data - Replace with API call
    _allInstitutions = [
      const Institution(
        id: '1',
        name: 'Delhi Public School',
        type: InstitutionType.highSchool,
        logoUrl: null,
        coverImageUrl: null,
        description:
            'One of the premier schools in India with excellent academic record and world-class facilities.',
        address: 'Begumpet, Hyderabad',
        city: 'Hyderabad',
        state: 'Telangana',
        pincode: '500016',
        latitude: 17.4410,
        longitude: 78.4599,
        phoneNumber: '+91-40-27764543',
        email: 'info@dpshyderabad.com',
        website: 'www.dpshyderabad.com',
        facilities: [
          'Smart Classrooms',
          'Science Labs',
          'Sports Complex',
          'Library',
          'Computer Labs',
          'Auditorium'
        ],
        affiliations: ['CBSE', 'Cambridge International'],
        principalName: 'Dr. Rajesh Kumar',
        establishedYear: 1985,
        rating: 4.8,
        reviewCount: 245,
        isVerified: true,
        courses: ['Primary', 'Secondary', 'Senior Secondary'],
        admissionProcess:
            'Online application followed by entrance test and interview',
        feesRange: '₹1.5L - ₹2.5L per year',
      ),
      const Institution(
        id: '2',
        name: 'BITS Pilani',
        type: InstitutionType.college,
        logoUrl: null,
        coverImageUrl: null,
        description:
            'Premier engineering college known for excellence in technical education and research.',
        address: 'Pilani, Rajasthan',
        city: 'Pilani',
        state: 'Rajasthan',
        pincode: '333031',
        phoneNumber: '+91-1596-242210',
        email: 'admissions@bits-pilani.ac.in',
        website: 'www.bits-pilani.ac.in',
        facilities: [
          'Modern Labs',
          'Research Centers',
          'Hostels',
          'Sports Facilities',
          'Central Library',
          'Cafeteria'
        ],
        affiliations: ['Deemed University', 'NAAC A++'],
        establishedYear: 1964,
        rating: 4.9,
        reviewCount: 1250,
        isVerified: true,
        courses: ['B.E.', 'M.E.', 'M.Sc.', 'MBA', 'Ph.D.'],
        admissionProcess: 'BITSAT entrance exam',
        feesRange: '₹4L - ₹5L per year',
      ),
      const Institution(
        id: '3',
        name: 'Sri Chaitanya Educational Institutions',
        type: InstitutionType.coachingCenter,
        logoUrl: null,
        coverImageUrl: null,
        description:
            'Leading coaching institute for JEE, NEET, and board exam preparation.',
        address: 'Multiple locations across Hyderabad',
        city: 'Hyderabad',
        state: 'Telangana',
        phoneNumber: '+91-40-27654321',
        email: 'info@srichaitanya.net',
        website: 'www.srichaitanya.net',
        facilities: [
          'AC Classrooms',
          'Digital Content',
          'Test Series',
          'Doubt Clearing Sessions',
          'Study Material'
        ],
        affiliations: [],
        establishedYear: 1986,
        rating: 4.6,
        reviewCount: 890,
        isVerified: true,
        courses: ['JEE Preparation', 'NEET Preparation', 'EAMCET'],
        admissionProcess: 'Direct admission with scholarship test',
        feesRange: '₹80K - ₹1.5L per year',
      ),
    ];
    _filteredInstitutions = _allInstitutions;
    setState(() {});
  }

  void _applyFilters() {
    _filteredInstitutions = _allInstitutions.where((institution) {
      // Type filter
      if (_selectedType != null && institution.type != _selectedType) {
        return false;
      }

      // City filter
      if (_selectedCity != 'All Cities' && institution.city != _selectedCity) {
        return false;
      }

      // Verified filter
      if (_verifiedOnly && !institution.isVerified) {
        return false;
      }

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        return institution.name.toLowerCase().contains(query) ||
            institution.description.toLowerCase().contains(query) ||
            institution.city.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    // Sort
    _filteredInstitutions.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'name':
          return a.name.compareTo(b.name);
        case 'established':
          return (b.establishedYear ?? 0).compareTo(a.establishedYear ?? 0);
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
        title: const Text('Schools & Colleges'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Schools'),
            Tab(text: 'Colleges'),
            Tab(text: 'Coaching'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildQuickFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInstitutionList(_filteredInstitutions),
                _buildInstitutionList(_filteredInstitutions
                    .where((i) =>
                        i.type == InstitutionType.preschool ||
                        i.type == InstitutionType.primarySchool ||
                        i.type == InstitutionType.highSchool)
                    .toList()),
                _buildInstitutionList(_filteredInstitutions
                    .where((i) =>
                        i.type == InstitutionType.college ||
                        i.type == InstitutionType.university)
                    .toList()),
                _buildInstitutionList(_filteredInstitutions
                    .where((i) => i.type == InstitutionType.coachingCenter)
                    .toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Map view feature coming soon!')),
          );
        },
        icon: const Icon(Icons.map),
        label: const Text('Map View'),
        backgroundColor: Colors.indigo.shade700,
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
          hintText: 'Search schools, colleges, coaching...',
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
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCityDropdown(),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Verified Only',
            _verifiedOnly,
            Icons.verified,
            () {
              setState(() => _verifiedOnly = !_verifiedOnly);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          _buildSortChip(),
        ],
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCity = value);
              _applyFilters();
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      String label, bool selected, IconData icon, VoidCallback onTap) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.white : null),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.indigo.shade700,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildSortChip() {
    return ActionChip(
      avatar: const Icon(Icons.sort, size: 16),
      label: Text('Sort: ${_sortBy.toUpperCase()}'),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Rating (High to Low)'),
                  trailing:
                      _sortBy == 'rating' ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _sortBy = 'rating');
                    _applyFilters();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Name (A-Z)'),
                  trailing: _sortBy == 'name' ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _sortBy = 'name');
                    _applyFilters();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Established (Oldest First)'),
                  trailing:
                      _sortBy == 'established' ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _sortBy = 'established');
                    _applyFilters();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstitutionList(List<Institution> institutions) {
    if (institutions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No institutions found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: institutions.length,
      itemBuilder: (context, index) =>
          _buildInstitutionCard(institutions[index]),
    );
  }

  Widget _buildInstitutionCard(Institution institution) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showInstitutionDetails(institution),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.school,
                          size: 40, color: Colors.indigo.shade700),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        institution.type.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          institution.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (institution.isVerified)
                        const Icon(Icons.verified,
                            color: Colors.blue, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${institution.city}, ${institution.state}',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  if (institution.establishedYear != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Est. ${institution.establishedYear}',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    institution.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${institution.rating} (${institution.reviewCount})',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      if (institution.feesRange != null)
                        Text(
                          institution.feesRange!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: institution.facilities.take(3).map((facility) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          facility,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Institution Type
                DropdownButtonFormField<InstitutionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Institution Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...InstitutionType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setModalState(() => _selectedType = value);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInstitutionDetails(Institution institution) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Institution Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.school,
                          size: 40, color: Colors.indigo.shade700),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  institution.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (institution.isVerified)
                                const Icon(Icons.verified,
                                    color: Colors.blue, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            institution.type.displayName,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${institution.rating} (${institution.reviewCount} reviews)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Description
                const Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(institution.description,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                // Contact Info
                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, institution.address),
                _buildInfoRow(Icons.phone, institution.phoneNumber ?? 'N/A'),
                _buildInfoRow(Icons.email, institution.email ?? 'N/A'),
                _buildInfoRow(Icons.language, institution.website ?? 'N/A'),
                const SizedBox(height: 20),
                // Facilities
                const Text(
                  'Facilities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: institution.facilities.map((facility) {
                    return Chip(
                      label: Text(facility),
                      backgroundColor: Colors.indigo.shade50,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Courses
                const Text(
                  'Courses Offered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...institution.courses.map((course) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(course)),
                      ],
                    ),
                  );
                }),
                if (institution.affiliations.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Affiliations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(institution.affiliations.join(', ')),
                ],
                if (institution.feesRange != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Fee Structure',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    institution.feesRange!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (institution.admissionProcess != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Admission Process',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(institution.admissionProcess!),
                ],
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _makeCall(institution.phoneNumber),
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openWebsite(institution.website),
                        icon: const Icon(Icons.language),
                        label: const Text('Website'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inquiry form feature coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.contact_mail),
                    label: const Text('Send Inquiry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String? phoneNumber) async {
    if (phoneNumber == null) return;
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String? website) async {
    if (website == null) return;
    final uri =
        Uri.parse(website.startsWith('http') ? website : 'https://$website');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
