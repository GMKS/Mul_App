/// Tutor Marketplace Screen
/// Find and connect with tutors, mentors, and subject experts
/// Features: Search, Filter, Book Sessions, Reviews, Real-time availability

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/education_model.dart';

class TutorMarketplaceScreen extends StatefulWidget {
  const TutorMarketplaceScreen({super.key});

  @override
  State<TutorMarketplaceScreen> createState() => _TutorMarketplaceScreenState();
}

class _TutorMarketplaceScreenState extends State<TutorMarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  SubjectCategory? _selectedSubject;
  EducationLevel? _selectedLevel;
  double _maxPrice = 2000;
  bool _verifiedOnly = false;
  bool _availableNow = false;
  String _sortBy = 'rating'; // rating, price, experience

  List<Tutor> _allTutors = [];
  List<Tutor> _filteredTutors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTutors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadTutors() {
    // Mock data - Replace with API call
    _allTutors = [
      const Tutor(
        id: '1',
        name: 'Dr. Rajesh Kumar',
        photoUrl: null,
        bio:
            'IIT graduate with 10+ years of teaching experience. Specialized in JEE/NEET preparation.',
        specializations: [SubjectCategory.mathematics, SubjectCategory.science],
        teachingLevels: [
          EducationLevel.highSchool,
          EducationLevel.undergraduate
        ],
        rating: 4.9,
        reviewCount: 145,
        studentsTeaching: 234,
        hourlyRate: 1500,
        experience: '10+ years',
        qualifications: ['B.Tech IIT Delhi', 'M.Tech IIT Bombay', 'PhD'],
        phoneNumber: '+91-9876543210',
        email: 'rajesh@example.com',
        isVerified: true,
        isAvailableNow: true,
        languages: ['Hindi', 'English'],
        city: 'Delhi',
        state: 'Delhi',
      ),
      const Tutor(
        id: '2',
        name: 'Prof. Priya Sharma',
        photoUrl: null,
        bio:
            'Experienced English teacher specializing in communication skills and literature.',
        specializations: [SubjectCategory.english, SubjectCategory.languages],
        teachingLevels: [
          EducationLevel.middleSchool,
          EducationLevel.highSchool
        ],
        rating: 4.8,
        reviewCount: 98,
        studentsTeaching: 156,
        hourlyRate: 800,
        experience: '7 years',
        qualifications: ['MA English', 'B.Ed', 'CELTA Certified'],
        phoneNumber: '+91-9876543211',
        email: 'priya@example.com',
        isVerified: true,
        isAvailableNow: false,
        languages: ['Hindi', 'English', 'French'],
        city: 'Mumbai',
        state: 'Maharashtra',
      ),
      const Tutor(
        id: '3',
        name: 'Suresh Reddy',
        photoUrl: null,
        bio:
            'Computer Science expert. Teach programming from basics to advanced.',
        specializations: [SubjectCategory.computer],
        teachingLevels: [
          EducationLevel.highSchool,
          EducationLevel.undergraduate,
          EducationLevel.postgraduate
        ],
        rating: 4.7,
        reviewCount: 76,
        studentsTeaching: 189,
        hourlyRate: 1200,
        experience: '5 years',
        qualifications: ['B.Tech CS', 'Software Engineer at Google'],
        phoneNumber: '+91-9876543212',
        email: 'suresh@example.com',
        isVerified: true,
        isAvailableNow: true,
        languages: ['Telugu', 'Hindi', 'English'],
        city: 'Hyderabad',
        state: 'Telangana',
      ),
    ];
    _filteredTutors = _allTutors;
    setState(() {});
  }

  void _applyFilters() {
    _filteredTutors = _allTutors.where((tutor) {
      // Subject filter
      if (_selectedSubject != null &&
          !tutor.specializations.contains(_selectedSubject)) {
        return false;
      }

      // Level filter
      if (_selectedLevel != null &&
          !tutor.teachingLevels.contains(_selectedLevel)) {
        return false;
      }

      // Price filter
      if (tutor.hourlyRate > _maxPrice) {
        return false;
      }

      // Verified filter
      if (_verifiedOnly && !tutor.isVerified) {
        return false;
      }

      // Available filter
      if (_availableNow && !tutor.isAvailableNow) {
        return false;
      }

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        return tutor.name.toLowerCase().contains(query) ||
            tutor.bio.toLowerCase().contains(query) ||
            tutor.city.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    // Sort
    _filteredTutors.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'price':
          return a.hourlyRate.compareTo(b.hourlyRate);
        case 'experience':
          return b.studentsTeaching.compareTo(a.studentsTeaching);
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
        title: const Text('Find Tutors'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All Tutors'),
            Tab(text: 'Online Now'),
            Tab(text: 'My Tutors'),
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
                _buildTutorList(_filteredTutors),
                _buildTutorList(
                    _filteredTutors.where((t) => t.isAvailableNow).toList()),
                _buildEmptyState('No saved tutors yet'),
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
          hintText: 'Search by name, subject, location...',
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
          _buildFilterChip(
            'Available Now',
            _availableNow,
            Icons.circle,
            () {
              setState(() => _availableNow = !_availableNow);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          _buildSortChip(),
        ],
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
      selectedColor: Colors.teal.shade700,
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
                  title: const Text('Price (Low to High)'),
                  trailing: _sortBy == 'price' ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _sortBy = 'price');
                    _applyFilters();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Most Experienced'),
                  trailing:
                      _sortBy == 'experience' ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _sortBy = 'experience');
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

  Widget _buildTutorList(List<Tutor> tutors) {
    if (tutors.isEmpty) {
      return _buildEmptyState('No tutors found matching your criteria');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tutors.length,
      itemBuilder: (context, index) => _buildTutorCard(tutors[index]),
    );
  }

  Widget _buildTutorCard(Tutor tutor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTutorDetails(tutor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          tutor.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (tutor.isAvailableNow)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Tutor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tutor.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (tutor.isVerified)
                              const Icon(Icons.verified,
                                  color: Colors.blue, size: 20),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tutor.city}, ${tutor.state}',
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${tutor.rating} (${tutor.reviewCount})',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.people,
                                color: Colors.grey[600], size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${tutor.studentsTeaching} students',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
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
              Text(
                tutor.bio,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tutor.specializations.take(3).map((subject) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Text(
                      subject.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '₹${tutor.hourlyRate}/hour',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _makeCall(tutor.phoneNumber),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call'),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () => _bookSession(tutor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Book'),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
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
                // Subject Dropdown
                DropdownButtonFormField<SubjectCategory>(
                  value: _selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Subjects'),
                    ),
                    ...SubjectCategory.values.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setModalState(() => _selectedSubject = value);
                  },
                ),
                const SizedBox(height: 16),
                // Level Dropdown
                DropdownButtonFormField<EducationLevel>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Education Level',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Levels'),
                    ),
                    ...EducationLevel.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setModalState(() => _selectedLevel = value);
                  },
                ),
                const SizedBox(height: 16),
                // Price Slider
                Text('Max Price: ₹${_maxPrice.toInt()}/hour'),
                Slider(
                  value: _maxPrice,
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  label: '₹${_maxPrice.toInt()}',
                  onChanged: (value) {
                    setModalState(() => _maxPrice = value);
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
                      backgroundColor: Colors.teal.shade700,
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

  void _showTutorDetails(Tutor tutor) {
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
                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        tutor.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                                  tutor.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (tutor.isVerified)
                                const Icon(Icons.verified,
                                    color: Colors.blue, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tutor.experience,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${tutor.rating} (${tutor.reviewCount} reviews)',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bio
                const Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(tutor.bio, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                // Specializations
                const Text(
                  'Specializations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tutor.specializations.map((subject) {
                    return Chip(
                      label: Text(subject.displayName),
                      backgroundColor: Colors.teal.shade50,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // Qualifications
                const Text(
                  'Qualifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...tutor.qualifications.map((qual) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(qual)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                // Languages
                const Text(
                  'Languages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(tutor.languages.join(', ')),
                const SizedBox(height: 20),
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Students', '${tutor.studentsTeaching}+'),
                    _buildStat('Reviews', '${tutor.reviewCount}'),
                    _buildStat('Rating', '${tutor.rating}⭐'),
                  ],
                ),
                const SizedBox(height: 20),
                // Price and Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hourly Rate',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '₹${tutor.hourlyRate}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _makeCall(tutor.phoneNumber),
                              icon: const Icon(Icons.call),
                              label: const Text('Call'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal.shade700,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _bookSession(tutor);
                              },
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('Book'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _makeCall(String? phoneNumber) async {
    if (phoneNumber == null) return;
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _bookSession(Tutor tutor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutor: ${tutor.name}'),
            const SizedBox(height: 8),
            Text('Rate: ₹${tutor.hourlyRate}/hour'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Preferred Date & Time',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Duration (hours)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Topic/Requirements',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
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
                  content: Text(
                      'Booking request sent! Tutor will contact you soon.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }
}
