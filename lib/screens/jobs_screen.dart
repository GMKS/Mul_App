// Jobs & Opportunities Screen
// Features: Job listing, filters (city/category), expiry logic, save/apply functionality

import 'package:flutter/material.dart';
import 'dart:math';
import '../models/job_model.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<JobModel> _allJobs = [];
  Set<String> _savedJobIds = {};

  // Filter states
  String _selectedCity = 'All Cities';
  JobCategory? _selectedCategory;
  EmploymentType? _selectedEmploymentType;
  ExperienceLevel? _selectedExperienceLevel;
  bool _showRemoteOnly = false;
  bool _showExpired = false;

  final List<String> _cities = [
    'All Cities',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Pune',
    'Hyderabad',
    'Chennai',
    'Kolkata',
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data generation
    final random = Random();
    final now = DateTime.now();

    _allJobs = List.generate(20, (index) {
      final category =
          JobCategory.values[random.nextInt(JobCategory.values.length)];
      final employmentType =
          EmploymentType.values[random.nextInt(EmploymentType.values.length)];
      final experienceLevel =
          ExperienceLevel.values[random.nextInt(ExperienceLevel.values.length)];
      final daysUntilExpiry = random.nextInt(30) + 1;
      final daysSincePosted = random.nextInt(10);

      return JobModel(
        id: 'job_$index',
        title: _getJobTitle(index, category),
        description: _getJobDescription(category),
        requirements: _getRequirements(experienceLevel),
        companyName: _getCompanyName(index),
        companyLogo:
            'https://ui-avatars.com/api/?name=${_getCompanyName(index)}&background=random',
        city: _cities[random.nextInt(_cities.length - 1) + 1],
        state: 'Maharashtra',
        isRemote: random.nextBool(),
        isHybrid: random.nextBool(),
        category: category,
        employmentType: employmentType,
        experienceLevel: experienceLevel,
        salaryRange: SalaryRange(
          min: 20000 + (random.nextInt(30) * 5000),
          max: 40000 + (random.nextInt(60) * 5000),
          period: employmentType == EmploymentType.internship
              ? SalaryPeriod.monthly
              : SalaryPeriod.monthly,
        ),
        numberOfOpenings: random.nextInt(5) + 1,
        skills: _getSkills(category),
        benefits: ['Health Insurance', 'Paid Leave', 'Performance Bonus'],
        postedDate: now.subtract(Duration(days: daysSincePosted)),
        expiryDate: now.add(Duration(days: daysUntilExpiry)),
        contactEmail:
            'hr@${_getCompanyName(index).toLowerCase().replaceAll(' ', '')}.com',
        contactPhone: '98765432${10 + index}',
        easyApply: random.nextBool(),
        status: JobStatus.active,
        isFeatured: index < 3,
        viewsCount: random.nextInt(500),
        applicationsCount: random.nextInt(50),
        savedCount: random.nextInt(100),
        isPremiumListing: index < 5,
      );
    });

    // Sort by priority
    _allJobs.sort((a, b) =>
        b.calculatePriorityScore().compareTo(a.calculatePriorityScore()));

    setState(() => _isLoading = false);
  }

  List<JobModel> get _filteredJobs {
    return _allJobs.where((job) {
      // City filter
      if (_selectedCity != 'All Cities' &&
          job.city != _selectedCity &&
          !job.isRemote) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null && job.category != _selectedCategory) {
        return false;
      }

      // Employment type filter
      if (_selectedEmploymentType != null &&
          job.employmentType != _selectedEmploymentType) {
        return false;
      }

      // Experience level filter
      if (_selectedExperienceLevel != null &&
          job.experienceLevel != _selectedExperienceLevel) {
        return false;
      }

      // Remote filter
      if (_showRemoteOnly && !job.isRemote) {
        return false;
      }

      // Expired filter
      if (!_showExpired && job.isExpired) {
        return false;
      }

      return true;
    }).toList();
  }

  List<JobModel> get _featuredJobs {
    return _filteredJobs
        .where((job) => job.isFeatured && !job.isExpired)
        .toList();
  }

  List<JobModel> get _recentJobs {
    final jobs = _filteredJobs.where((job) => !job.isExpired).toList();
    jobs.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return jobs;
  }

  List<JobModel> get _savedJobs {
    return _allJobs.where((job) => _savedJobIds.contains(job.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs & Opportunities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Featured'),
            Tab(icon: Icon(Icons.work_outline), text: 'All Jobs'),
            Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildQuickFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildJobList(
                          _featuredJobs, 'No featured jobs available'),
                      _buildJobList(_recentJobs, 'No jobs found'),
                      _buildJobList(_savedJobs, 'No saved jobs yet'),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: null, // Disabled until implemented
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // City filter
            _buildFilterChip(
              label: _selectedCity,
              icon: Icons.location_on,
              onTap: () => _showCityPicker(),
            ),
            const SizedBox(width: 8),

            // Category filter
            _buildFilterChip(
              label: _selectedCategory?.displayName ?? 'All Categories',
              icon: Icons.category,
              onTap: () => _showCategoryPicker(),
            ),
            const SizedBox(width: 8),

            // Remote toggle
            FilterChip(
              label: const Text('Remote'),
              avatar: Icon(
                Icons.home_work,
                size: 18,
                color: _showRemoteOnly ? Colors.white : Colors.grey[700],
              ),
              selected: _showRemoteOnly,
              onSelected: (value) {
                setState(() => _showRemoteOnly = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
        onDeleted: onTap,
      ),
    );
  }

  Widget _buildJobList(List<JobModel> jobs, String emptyMessage) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) => _buildJobCard(jobs[index]),
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    final isSaved = _savedJobIds.contains(job.id);
    final isExpired = job.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: job.isFeatured ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: job.isFeatured
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(job: job),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isExpired ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company logo
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                        image: job.companyLogo != null
                            ? DecorationImage(
                                image: NetworkImage(job.companyLogo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: job.companyLogo == null
                          ? const Icon(Icons.business, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Job title and company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.companyName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Save button
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isSaved) {
                            _savedJobIds.remove(job.id);
                          } else {
                            _savedJobIds.add(job.id);
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Badges row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (job.isFeatured)
                      _buildBadge('Featured', Colors.amber, Icons.star),
                    if (isExpired)
                      _buildBadge('Expired', Colors.red, Icons.event_busy)
                    else if (job.isExpiringSoon)
                      _buildBadge('Expiring Soon', Colors.orange, Icons.timer),
                    _buildBadge(job.employmentType.displayName, Colors.blue,
                        Icons.work),
                    _buildBadge(job.experienceLevel.displayName, Colors.green,
                        Icons.school),
                    if (job.isRemote)
                      _buildBadge('Remote', Colors.purple, Icons.home_work),
                  ],
                ),
                const SizedBox(height: 12),

                // Location and salary
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      job.locationText,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                    if (job.salaryRange != null) ...[
                      Icon(Icons.currency_rupee,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        job.salaryRange!.displayText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Skills
                if (job.skills.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.skills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Footer
                Row(
                  children: [
                    Text(
                      job.postedTimeAgo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    if (!isExpired) ...[
                      if (job.easyApply)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flash_on,
                                  size: 14, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                'Easy Apply',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        '${job.daysRemaining} days left',
                        style: TextStyle(
                          fontSize: 12,
                          color: job.isExpiringSoon
                              ? Colors.orange
                              : Colors.grey[600],
                          fontWeight: job.isExpiringSoon
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCity = 'All Cities';
                      _selectedCategory = null;
                      _selectedEmploymentType = null;
                      _selectedExperienceLevel = null;
                      _showRemoteOnly = false;
                      _showExpired = false;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  const Text('Employment Type',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: EmploymentType.values.map((type) {
                      return ChoiceChip(
                        label: Text(type.displayName),
                        selected: _selectedEmploymentType == type,
                        onSelected: (selected) {
                          setState(() {
                            _selectedEmploymentType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Experience Level',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ExperienceLevel.values.map((level) {
                      return ChoiceChip(
                        label: Text(level.displayName),
                        selected: _selectedExperienceLevel == level,
                        onSelected: (selected) {
                          setState(() {
                            _selectedExperienceLevel = selected ? level : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('Show Expired Jobs'),
                    value: _showExpired,
                    onChanged: (value) {
                      setState(() => _showExpired = value);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: _cities.map((city) {
          return ListTile(
            title: Text(city),
            trailing: _selectedCity == city
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              setState(() => _selectedCity = city);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('All Categories'),
            trailing: _selectedCategory == null
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              setState(() => _selectedCategory = null);
              Navigator.pop(context);
            },
          ),
          ...JobCategory.values.map((category) {
            return ListTile(
              title: Text(category.displayName),
              trailing: _selectedCategory == category
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() => _selectedCategory = category);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getJobTitle(int index, JobCategory category) {
    final titles = {
      JobCategory.it: [
        'Software Developer',
        'Full Stack Engineer',
        'DevOps Engineer',
        'QA Tester'
      ],
      JobCategory.retail: [
        'Store Manager',
        'Sales Associate',
        'Cashier',
        'Inventory Manager'
      ],
      JobCategory.healthcare: [
        'Nurse',
        'Medical Assistant',
        'Lab Technician',
        'Pharmacist'
      ],
      JobCategory.education: [
        'Teacher',
        'Tutor',
        'Academic Coordinator',
        'Principal'
      ],
      JobCategory.hospitality: [
        'Chef',
        'Waiter',
        'Hotel Manager',
        'Receptionist'
      ],
      JobCategory.finance: [
        'Accountant',
        'Financial Analyst',
        'Investment Banker',
        'Tax Consultant'
      ],
      JobCategory.marketing: [
        'Digital Marketer',
        'Content Writer',
        'SEO Specialist',
        'Brand Manager'
      ],
      JobCategory.sales: [
        'Sales Executive',
        'Business Development Manager',
        'Account Manager'
      ],
    };

    final list = titles[category] ??
        ['Professional', 'Specialist', 'Manager', 'Executive'];
    return list[index % list.length];
  }

  String _getJobDescription(JobCategory category) {
    return 'We are looking for a talented professional to join our growing team. '
        'This is an excellent opportunity to work with industry leaders.';
  }

  String _getRequirements(ExperienceLevel level) {
    return 'Strong communication skills, team player, ${level.displayName} experience required.';
  }

  String _getCompanyName(int index) {
    final names = [
      'Tech Solutions',
      'Retail Plus',
      'HealthCare Inc',
      'Edu World',
      'Hospitality Group',
      'Finance Pro',
      'Marketing Hub',
      'Sales Force'
    ];
    return names[index % names.length];
  }

  List<String> _getSkills(JobCategory category) {
    final skills = {
      JobCategory.it: ['Java', 'Python', 'React', 'Node.js', 'SQL'],
      JobCategory.retail: [
        'Customer Service',
        'POS Systems',
        'Inventory Management'
      ],
      JobCategory.healthcare: [
        'Patient Care',
        'Medical Records',
        'CPR Certified'
      ],
      JobCategory.marketing: [
        'SEO',
        'Social Media',
        'Content Creation',
        'Analytics'
      ],
    };

    return skills[category] ?? ['Communication', 'Teamwork', 'Problem Solving'];
  }
}
