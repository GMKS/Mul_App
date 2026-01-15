import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/video_model.dart';
import '../models/user_model.dart';
import '../services/feed_service.dart';
import '../services/language_service.dart';
import '../services/region_service.dart';
import '../services/notification_service.dart';
import '../widgets/social_interactions.dart';
import '../widgets/creator_badge.dart';
import '../widgets/report_dialog.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/comments_bottom_sheet.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/voice_comment_sheet.dart';
import '../widgets/floating_category_card.dart';
import 'language_selection_screen.dart';
import 'region_selection_screen.dart';
import 'cab_services_screen.dart';
import 'local_alerts_screen.dart';
import 'settings_screen.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_cards.dart';
import '../core/route_manager.dart';
import 'devotional/devotional_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Future<void> _logout() async {
    await AuthService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  // Send test notification for development
  Future<void> _sendTestNotification() async {
    try {
      await NotificationService().showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent! 🔔'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _selectedCategoryIndex = -1; // Start with no category selected
  String? _selectedHashtag;
  late TabController _tabController;

  // Mock user data
  UserProfile? _currentUser;
  List<Video> _videos = [];

  // Track liked videos and engagement
  final Set<String> _likedVideos = {};
  final Map<String, int> _videoLikes = {};
  final Map<String, int> _videoComments = {};
  final Map<String, int> _videoShares = {};

  final List<CategoryItem> _categories = [
    CategoryItem(
      title: 'Regional',
      icon: Icons.location_on,
      color: const Color(0xFFFF6B6B),
      gradient: [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)],
    ),
    CategoryItem(
      title: 'Business',
      icon: Icons.business_center,
      color: const Color(0xFF6C63FF),
      gradient: [const Color(0xFF6C63FF), const Color(0xFF5A52E0)],
    ),
    CategoryItem(
      title: 'Devotional',
      icon: Icons.self_improvement,
      color: const Color(0xFF9B59B6),
      gradient: [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
    ),
  ];

  // --- Regional Services Cards ---
  final List<Map<String, dynamic>> _regionalServices = [
    {
      'title': 'Cab Services',
      'icon': Icons.local_taxi,
      'color': const Color(0xFFFF6B6B),
      'gradient': [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)]
    },
    {
      'title': 'Local Alerts',
      'icon': Icons.notifications_active,
      'color': const Color(0xFFFF6347),
      'gradient': [const Color(0xFFFF6347), const Color(0xFFFF4500)]
    },
    {
      'title': 'Events & Festivals',
      'icon': Icons.celebration,
      'color': const Color(0xFF9B59B6),
      'gradient': [const Color(0xFF9B59B6), const Color(0xFF8E44AD)]
    },
    {
      'title': 'Emergency Services',
      'icon': Icons.local_hospital,
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFC2185B)]
    },
    {
      'title': 'Jobs & Opportunities',
      'icon': Icons.work,
      'color': const Color(0xFF3498DB),
      'gradient': [const Color(0xFF3498DB), const Color(0xFF2980B9)]
    },
    {
      'title': 'Education Corner',
      'icon': Icons.school,
      'color': const Color(0xFF1ABC9C),
      'gradient': [const Color(0xFF1ABC9C), const Color(0xFF16A085)]
    },
    {
      'title': 'Market Prices',
      'icon': Icons.trending_up,
      'color': const Color(0xFFF39C12),
      'gradient': [const Color(0xFFF39C12), const Color(0xFFE67E22)]
    },
    {
      'title': 'Community Help',
      'icon': Icons.people,
      'color': const Color(0xFF16A085),
      'gradient': [const Color(0xFF16A085), const Color(0xFF1ABC9C)]
    },
    {
      'title': 'Services Directory',
      'icon': Icons.home_repair_service,
      'color': const Color(0xFF2196F3),
      'gradient': [const Color(0xFF2196F3), const Color(0xFF1976D2)]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
    _loadMockVideos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final primaryLang = await LanguageService.getPrimaryLanguage();
    final secondaryLang = await LanguageService.getSecondaryLanguage();
    final regionData = await RegionService.getStoredRegion();

    print('🔍 DEBUG HomeScreen _loadUserData:');
    print('  Region data: $regionData');
    print('  City: ${regionData['city']}');
    print('  State: ${regionData['state']}');
    print('  Region: ${regionData['region']}');

    setState(() {
      _currentUser = UserProfile(
        id: 'user_1',
        name: 'User',
        email: 'user@example.com',
        primaryLanguage: primaryLang,
        secondaryLanguage: secondaryLang ?? '',
        region: regionData['region'] ?? '',
        state: regionData['state'] ?? '',
        city: regionData['city'] ?? '',
        isFirstLogin: false,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      print('  Current user city set to: ${_currentUser?.city}');
    });
  }

  void _loadMockVideos() {
    // Generate mock videos for demo - create videos for each category
    _videos = [];

    final categories = ['Regional', 'Business', 'Devotional'];
    final languages = ['en', 'hi', 'te', 'ta', 'kn'];

    // Category-specific data
    final categoryTitles = {
      'Regional': [
        'Local Festival Celebration',
        'Street Food Tour',
        'Traditional Dance',
        'Village Life',
        'Regional Music',
        'Local News Update',
        'Cultural Event',
      ],
      'Business': [
        'Startup Tips',
        'Investment Strategies',
        'Market Analysis',
        'Entrepreneurship Guide',
        'Financial Planning',
        'Business Growth Hacks',
        'Success Stories',
      ],
      'Devotional': [
        'Morning Prayer',
        'Temple Visit',
        'Bhajan Collection',
        'Spiritual Wisdom',
        'Meditation Guide',
        'Religious Festival',
        'Sacred Mantras',
      ],
    };

    final categoryHashtags = {
      'Regional': ['#regional', '#local', '#desi', '#culture', '#tradition'],
      'Business': [
        '#business',
        '#startup',
        '#money',
        '#entrepreneur',
        '#finance'
      ],
      'Devotional': [
        '#devotional',
        '#spiritual',
        '#prayer',
        '#bhajan',
        '#temple'
      ],
    };

    // Location data for region-based filtering
    final locations = [
      {'region': 'South', 'state': 'Karnataka', 'city': 'Bangalore'},
      {'region': 'South', 'state': 'Karnataka', 'city': 'Mysore'},
      {'region': 'South', 'state': 'Tamil Nadu', 'city': 'Chennai'},
      {'region': 'South', 'state': 'Tamil Nadu', 'city': 'Coimbatore'},
      {'region': 'South', 'state': 'Telangana', 'city': 'Hyderabad'},
      {'region': 'South', 'state': 'Kerala', 'city': 'Kochi'},
      {'region': 'West', 'state': 'Maharashtra', 'city': 'Mumbai'},
      {'region': 'West', 'state': 'Maharashtra', 'city': 'Pune'},
      {'region': 'West', 'state': 'Gujarat', 'city': 'Ahmedabad'},
      {'region': 'North', 'state': 'Delhi', 'city': 'New Delhi'},
      {'region': 'North', 'state': 'Uttar Pradesh', 'city': 'Lucknow'},
      {'region': 'East', 'state': 'West Bengal', 'city': 'Kolkata'},
    ];

    int videoIndex = 0;
    for (final category in categories) {
      // Generate 12 videos per category (one for each location)
      for (int i = 0; i < 12; i++) {
        final titles = categoryTitles[category]!;
        final hashtags = categoryHashtags[category]!;
        final location = locations[i % locations.length];

        _videos.add(Video(
          id: 'video_$videoIndex',
          videoUrl: 'https://example.com/video_$videoIndex.mp4',
          thumbnailUrl: 'https://picsum.photos/400/700?random=$videoIndex',
          title: '${titles[i % titles.length]} - ${location['city']}',
          description:
              'Check out this amazing $category content from ${location['city']}!',
          language: languages[videoIndex % languages.length],
          category: category,
          region: location['region']!,
          state: location['state']!,
          city: location['city']!,
          creatorId: 'creator_${videoIndex % 5}',
          creatorName: 'Creator ${videoIndex % 5}',
          creatorAvatar: 'https://i.pravatar.cc/150?img=${videoIndex % 10}',
          likes: (videoIndex + 1) * 1000,
          comments: (videoIndex + 1) * 100,
          shares: (videoIndex + 1) * 50,
          views: (videoIndex + 1) * 5000,
          watchTime: (videoIndex + 1) * 10.0,
          replays: (videoIndex + 1) * 200,
          createdAt: DateTime.now().subtract(Duration(hours: videoIndex)),
          hashtags: [
            hashtags[i % hashtags.length],
            '#${location['city']?.toLowerCase().replaceAll(' ', '')}',
            '#shorts',
          ],
          isFestivalContent: videoIndex % 5 == 0,
          isBoosted: videoIndex % 7 == 0,
        ));
        videoIndex++;
      }
    }

    setState(() {});
  }

  List<Video> _getFilteredVideos() {
    var filteredVideos = _videos;

    // Filter by category FIRST - this is the primary filter
    final category = _categories[_selectedCategoryIndex].title;
    filteredVideos = FeedService.filterByCategory(filteredVideos, category);

    // For Regional category, filter by user's selected region/state/city
    if (category == 'Regional' && _currentUser != null) {
      filteredVideos = filteredVideos.where((video) {
        // Match by city first, then state, then region
        if (_currentUser!.city.isNotEmpty && video.city == _currentUser!.city) {
          return true;
        }
        if (_currentUser!.state.isNotEmpty &&
            video.state == _currentUser!.state) {
          return true;
        }
        if (_currentUser!.region.isNotEmpty &&
            video.region == _currentUser!.region) {
          return true;
        }
        return false;
      }).toList();
    }

    // Filter by hashtag if selected
    if (_selectedHashtag != null) {
      filteredVideos =
          FeedService.filterByHashtag(filteredVideos, _selectedHashtag!);
    }

    // Sort by latest (removed trending)
    filteredVideos = FeedService.getLatestFeed(filteredVideos);

    return filteredVideos;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting = 'Hi';
    if (hour < 12)
      greeting = 'Good Morning';
    else if (hour < 17)
      greeting = 'Good Afternoon';
    else
      greeting = 'Good Evening';

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My City App',
          style: TextStyle(
            color: Color(0xFF4A90E2),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF4A90E2)),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF4A90E2)),
            tooltip: 'Test Notification',
            onPressed: _sendTestNotification,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF4A90E2)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFE74C3C)),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildCategoryContent(),
    );
  }

  Widget _buildOriginalHomeLayout() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4A90E2),
            Color(0xFF50C9C3),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Location Selector with Change button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentUser?.city ?? 'Medchal-Malkajgiri',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_currentUser?.state != null) ...[
                    Text(
                      ', ${_currentUser?.state}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegionSelectionScreen(),
                        ),
                      );
                      // Reload user data after region change
                      _loadUserData();
                    },
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: Color(0xFF64DFDF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Category Cards Row (Regional, Business, Devotional)
            _buildCategoryCardsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCardsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          CategoryCard(
            label: 'Regional',
            color: AppColors.category1,
            icon: Icons.location_on,
            onTap: () {
              print('🔵 Regional card tapped');
              // Navigate to the new Regional Feed Screen
              Navigator.pushNamed(context, RouteManager.regionalFeed);
            },
          ),
          const SizedBox(height: 12),
          CategoryCard(
            label: 'Business',
            color: AppColors.category2,
            icon: Icons.business_center,
            onTap: () {
              print('🟠 Business card tapped');
              setState(() {
                _selectedCategoryIndex = 1;
              });
              // Show a snackbar to confirm tap is working
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Business videos...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          CategoryCard(
            label: 'Devotional',
            color: AppColors.category3,
            icon: Icons.self_improvement,
            onTap: () {
              print('🔵 Devotional card tapped');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DevotionalFeedScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Three dots indicator
                Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionalServicesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 9, // Show 9 items as in the screenshot
        itemBuilder: (context, index) {
          if (index < _regionalServices.length) {
            final service = _regionalServices[index];
            return _buildRegionalServiceCard(
              title: service['title'] as String,
              subtitle: 'Services',
              icon: service['icon'] as IconData,
              gradient: service['gradient'] as List<Color>,
              onTap: () {
                if (service['title'] == 'Cab Services') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CabServicesScreen(
                        userCity: _currentUser?.city,
                      ),
                    ),
                  );
                } else if (service['title'] == 'Local Alerts') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocalAlertsScreen(),
                    ),
                  );
                } else {
                  _showComingSoonDialog(service['title'] as String);
                }
              },
            );
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildRegionalServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Three dots indicator
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Icon
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    // Show main screen with category cards if no category selected
    if (_selectedCategoryIndex == -1) {
      return _buildOriginalHomeLayout();
    }

    // Show content for selected category with back button
    if (_selectedCategoryIndex == 0) {
      // Regional category: show regional services grid
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A4D68),
              Color(0xFF088395),
              Color(0xFF05BFDB),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with back button and Regional title
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedCategoryIndex = -1;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Regional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Grid of regional service cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    if (index < _regionalServices.length) {
                      final service = _regionalServices[index];
                      return _buildRegionalServiceCard(
                        title: service['title'] as String,
                        subtitle: 'Services',
                        icon: service['icon'] as IconData,
                        gradient: service['gradient'] as List<Color>,
                        onTap: () {
                          if (service['title'] == 'Cab Services') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CabServicesScreen(
                                  userCity: _currentUser?.city,
                                ),
                              ),
                            );
                          } else if (service['title'] == 'Local Alerts') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LocalAlertsScreen(),
                              ),
                            );
                          } else {
                            _showComingSoonDialog(service['title'] as String);
                          }
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show content for other categories (Business, Devotional) - coming soon message
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 197, 59, 156),
            Color.fromARGB(255, 124, 156, 34),
            Color.fromARGB(255, 180, 66, 66),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header with back button
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedCategoryIndex = -1;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  _categories[_selectedCategoryIndex].title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Category content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _categories[_selectedCategoryIndex].icon,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _categories[_selectedCategoryIndex].title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Content Coming Soon',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllServicesGrid() {
    // Show main category cards (Regional, Business, Devotional)
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F4F8),
            Color(0xFFE8EEF4),
            Color(0xFFF5F5F5),
          ],
        ),
      ),
      child: Column(
        children: [
          // Welcome Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Categories',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a category to browse content',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Main Category Cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildMainCategoryCard(
                    title: category.title,
                    icon: category.icon,
                    gradient: category.gradient,
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: -10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Services',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
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

  Widget _buildMainCategoryCard({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Explore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(String serviceName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Coming Soon'),
        content: Text('$serviceName will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFeed() {
    final filteredVideos = _getFilteredVideos();

    if (filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No videos found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different category or hashtag',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(Video video) {
    final isLiked = _likedVideos.contains(video.id);
    final currentLikes = _videoLikes[video.id] ?? video.likes;
    final currentComments = _videoComments[video.id] ?? video.comments;
    final currentShares = _videoShares[video.id] ?? video.shares;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player widget with tap/double-tap interactions
          VideoPlayerWidget(
            videoUrl: video.videoUrl,
            thumbnailUrl: video.thumbnailUrl,
            autoPlay: true,
            showControls: true,
            onTap: () {
              // Play/pause handled internally
            },
            onDoubleTap: () {
              // Double tap to like
              if (!isLiked) {
                _handleLike(video);
              }
            },
          ),

          // Gradient overlay
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),

          // Video info
          Positioned(
            left: 16,
            right: 80,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Creator info
                GestureDetector(
                  onTap: () => _showCreatorProfile(video),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(video.creatorAvatar),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  video.creatorName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const VerifiedBadge(size: 14),
                              ],
                            ),
                            Text(
                              '${video.state} • ${_formatViews(video.views)} views',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),

                // Hashtags
                Wrap(
                  spacing: 6,
                  children: video.hashtags.map((tag) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedHashtag = tag),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: Colors.blue.shade300,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Social interactions
          Positioned(
            right: 8,
            bottom: 80,
            child: SocialInteractions(
              likes: currentLikes,
              comments: currentComments,
              shares: currentShares,
              isLiked: isLiked,
              onLike: () => _handleLike(video),
              onComment: () => _showComments(video),
              onShare: () => _showShareOptions(video),
              onVoiceComment: () => _showVoiceComment(video),
              onEmojiReaction: (emoji) => _handleEmojiReaction(video, emoji),
            ),
          ),

          // More options
          Positioned(
            right: 8,
            top: 16,
            child: ReportButton(
              contentId: video.id,
              contentType: 'video',
              reporterId: _currentUser?.id ?? 'anonymous',
            ),
          ),
        ],
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  // ============ ACTION HANDLERS ============

  void _handleLike(Video video) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_likedVideos.contains(video.id)) {
        _likedVideos.remove(video.id);
        _videoLikes[video.id] = (_videoLikes[video.id] ?? video.likes) - 1;
      } else {
        _likedVideos.add(video.id);
        _videoLikes[video.id] = (_videoLikes[video.id] ?? video.likes) + 1;
      }
    });
  }

  void _showComments(Video video) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        videoId: video.id,
        commentCount: _videoComments[video.id] ?? video.comments,
        onAddComment: (comment) {
          setState(() {
            _videoComments[video.id] =
                (_videoComments[video.id] ?? video.comments) + 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Comment added successfully!'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showShareOptions(Video video) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareBottomSheet(
        videoId: video.id,
        videoTitle: video.title,
        creatorName: video.creatorName,
        onShare: (platform) {
          setState(() {
            _videoShares[video.id] =
                (_videoShares[video.id] ?? video.shares) + 1;
          });
        },
      ),
    );
  }

  void _showVoiceComment(Video video) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceCommentSheet(
        videoId: video.id,
        onRecordComplete: (recordingId) {
          setState(() {
            _videoComments[video.id] =
                (_videoComments[video.id] ?? video.comments) + 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.mic, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Voice comment sent!'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _handleEmojiReaction(Video video, String emoji) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Text('Reaction sent!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showCreatorProfile(Video video) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Creator avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(video.creatorAvatar),
            ),
            const SizedBox(height: 16),

            // Creator name with verified badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  video.creatorName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const VerifiedBadge(size: 18),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Text(
              '${video.city}, ${video.state}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Followers', '${(video.views / 100).toInt()}K'),
                _buildStatItem('Videos', '${(video.views / 1000).toInt()}'),
                _buildStatItem('Likes', '${(video.likes / 100).toInt()}K'),
              ],
            ),
            const SizedBox(height: 24),

            // Follow button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Following ${video.creatorName}!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
