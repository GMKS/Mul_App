/// Devotional Feed Screen
/// Complete devotional content with religion-based videos, quotes, and festivals
/// Features: Nearby content, Festivals, Quotes, Temples tabs with distance filtering

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:video_player/video_player.dart';
import '../../models/devotional_video_model.dart';
import '../../models/festival_model.dart';
import '../../models/quote_model.dart';
import '../../models/temple_model.dart';
import '../../models/report_model.dart';
import '../../services/devotional_service.dart';
import '../../services/religion_service.dart';
import '../../services/festival_service.dart';
import '../../services/temple_service.dart';
import '../../services/devotional_notification_service.dart';
import '../../services/ai_moderation_service.dart';
import '../../services/user_safety_service.dart';
import '../../models/user_safety_model.dart';
import '../../widgets/quote_of_the_day_widget.dart';
import '../../widgets/festival_banner_widget.dart';
import '../../widgets/report_button_widget.dart';
import 'religion_selection_screen.dart';
import 'upload_devotional_video_screen.dart';
import '../moderation/safety_center_screen.dart';
import '../moderation/analytics_dashboard_screen.dart';

class DevotionalFeedScreen extends StatefulWidget {
  const DevotionalFeedScreen({super.key});

  @override
  State<DevotionalFeedScreen> createState() => _DevotionalFeedScreenState();
}

class _DevotionalFeedScreenState extends State<DevotionalFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Religion? _selectedReligion;
  DistanceCategory _selectedDistanceCategory = DistanceCategory.nearby;
  bool _isLoading = true;
  List<DevotionalVideo> _videos = [];
  List<Temple> _temples = [];
  List<DevotionalQuote> _quotes = [];
  List<Festival> _upcomingFestivals = [];
  Festival? _activeFestival;
  bool _showFestivalBanner = true;

  // User location
  Position? _userLocation;
  bool _locationLoading = true;

  final PageController _pageController = PageController();
  int _currentVideoIndex = 0;

  // Distance buckets in km
  final List<DistanceCategory> _distanceCategories = [
    DistanceCategory.nearby, // 0-100 km
    DistanceCategory.medium, // 100-200 km
    DistanceCategory.far, // 200-500 km
    DistanceCategory.national, // 500+ km
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this); // 4 tabs: Nearby, Festivals, Quotes, Temples
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Check if religion is set
    final isReligionSet = await ReligionService.isReligionSet();
    if (!isReligionSet && mounted) {
      // Navigate to religion selection
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const ReligionSelectionScreen(isOnboarding: true),
        ),
      );
      if (result != null && result is Religion) {
        setState(() {
          _selectedReligion = result;
        });
      }
    } else {
      final religion = await ReligionService.getSelectedReligion();
      setState(() {
        _selectedReligion = religion;
      });
    }

    // Check for active festival
    _activeFestival = FestivalService.getCurrentFestival();

    // Get user location
    await _loadUserLocation();

    // Load all content
    await Future.wait([
      _loadVideos(),
      _loadTemples(),
      _loadQuotes(),
      _loadUpcomingFestivals(),
    ]);

    // Initialize notifications
    await DevotionalNotificationService.initialize();
  }

  Future<void> _loadUserLocation() async {
    setState(() {
      _locationLoading = true;
    });

    try {
      // Try to get current location
      _userLocation = await TempleService.getCurrentLocation();

      // If that fails, try cached location
      _userLocation ??= await TempleService.getCachedLocation();
    } catch (e) {
      debugPrint('Error loading location: $e');
    }

    setState(() {
      _locationLoading = false;
    });
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final videos = await DevotionalService.fetchDevotionalVideos(
        religion: _selectedReligion?.displayName.toLowerCase(),
        distanceCategory: _selectedDistanceCategory.name,
        userLat: _userLocation?.latitude,
        userLng: _userLocation?.longitude,
      );

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTemples() async {
    try {
      final temples = await TempleService.fetchTemples(
        religion: _selectedReligion?.displayName.toLowerCase(),
        distanceCategory: _selectedDistanceCategory,
        userLat: _userLocation?.latitude,
        userLng: _userLocation?.longitude,
      );

      setState(() {
        _temples = temples;
      });
    } catch (e) {
      debugPrint('Error loading temples: $e');
    }
  }

  Future<void> _loadQuotes() async {
    try {
      final religionStr =
          _selectedReligion?.displayName.toLowerCase() ?? 'hinduism';
      final allQuotes = DevotionalQuote.getPredefinedQuotes(religionStr);

      // Filter by religion if selected
      final filteredQuotes = allQuotes;

      setState(() {
        _quotes = filteredQuotes;
      });
    } catch (e) {
      debugPrint('Error loading quotes: $e');
    }
  }

  Future<void> _loadUpcomingFestivals() async {
    try {
      final now = DateTime.now();
      final allFestivals = Festival.getPredefinedFestivals(now.year);

      // Get upcoming festivals (next 30 days)
      final upcoming = allFestivals.where((f) {
        final isUpcoming = f.startDate.isAfter(now) &&
            f.startDate.isBefore(now.add(const Duration(days: 30)));
        final matchesReligion = _selectedReligion == null ||
            f.religion?.toLowerCase() ==
                _selectedReligion!.displayName.toLowerCase();
        return isUpcoming && matchesReligion;
      }).toList();

      upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));

      setState(() {
        _upcomingFestivals = upcoming;
      });
    } catch (e) {
      debugPrint('Error loading festivals: $e');
    }
  }

  void _onDistanceChanged(DistanceCategory? category) {
    if (category == null) return;
    setState(() {
      _selectedDistanceCategory = category;
    });
    _loadVideos();
    _loadTemples();
  }

  Future<void> _changeReligion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReligionSelectionScreen(),
      ),
    );
    if (result != null && result is Religion) {
      setState(() {
        _selectedReligion = result;
      });
      // Reload all content with new religion
      _loadVideos();
      _loadTemples();
      _loadQuotes();
      _loadUpcomingFestivals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            // Header with religion selector
            _buildHeader(),

            // Distance filter chips
            _buildDistanceFilter(),

            // Tabs
            _buildTabs(),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Nearby Tab - Videos filtered by distance
                  _buildNearbyTab(),
                  // Festivals Tab
                  _buildFestivalsTab(),
                  // Quotes Tab
                  _buildQuotesTab(),
                  // Temples Tab
                  _buildTemplesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to upload screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadDevotionalVideoScreen(),
            ),
          );

          if (result != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Video uploaded! Pending verification.'),
                backgroundColor: Colors.green,
              ),
            );
            // Reload videos to potentially show the new video (if already verified)
            _loadVideos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Upload Video'),
        backgroundColor: const Color(0xFF9B59B6),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // Title with religion
          Expanded(
            child: GestureDetector(
              onTap: _changeReligion,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.self_improvement,
                    color: Color(0xFF9B59B6),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Devotional',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedReligion != null)
                        Row(
                          children: [
                            Text(
                              _selectedReligion!.icon,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedReligion!.displayName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Safety & Moderation button - NEW FEATURE
          IconButton(
            onPressed: _showSafetyMenu,
            icon: const Icon(Icons.shield_outlined, color: Colors.white),
            tooltip: 'Safety & Moderation',
          ),

          // Filter button
          IconButton(
            onPressed: _showNotificationSettings,
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF16213e),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _distanceCategories.length,
        itemBuilder: (context, index) {
          final category = _distanceCategories[index];
          final isSelected = _selectedDistanceCategory == category;

          return GestureDetector(
            onTap: () => _onDistanceChanged(category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF9B59B6)
                    : const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white24,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getDistanceIcon(category),
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${category.minKm.toInt()}-${category.maxKm == double.infinity ? '∞' : category.maxKm.toInt()} km',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getDistanceIcon(DistanceCategory category) {
    switch (category) {
      case DistanceCategory.nearby:
        return Icons.near_me;
      case DistanceCategory.medium:
        return Icons.directions_car;
      case DistanceCategory.far:
        return Icons.train;
      case DistanceCategory.national:
        return Icons.flight;
    }
  }

  Widget _buildTabs() {
    return Container(
      color: const Color(0xFF16213e),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF9B59B6),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        isScrollable: false,
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(
            icon: Icon(Icons.location_on, size: 20),
            text: 'Nearby',
          ),
          Tab(
            icon: Icon(Icons.celebration, size: 20),
            text: 'Festivals',
          ),
          Tab(
            icon: Icon(Icons.format_quote, size: 20),
            text: 'Quotes',
          ),
          Tab(
            icon: Icon(Icons.temple_hindu, size: 20),
            text: 'Temples',
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
      );
    }

    if (_locationLoading) {
      return _buildLocationLoadingState();
    }

    if (_userLocation == null) {
      return _buildLocationPermissionState();
    }

    if (_videos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Current distance bucket indicator
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF16213e).withOpacity(0.5),
          child: Row(
            children: [
              Icon(
                _getDistanceIcon(_selectedDistanceCategory),
                color: const Color(0xFF9B59B6),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Showing content within ${_selectedDistanceCategory.minKm.toInt()}-${_selectedDistanceCategory.maxKm == double.infinity ? '500+' : _selectedDistanceCategory.maxKm.toInt()} km',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // Videos
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videos.length,
            onPageChanged: (index) {
              setState(() {
                _currentVideoIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return DevotionalVideoCard(
                video: _videos[index],
                isActive: index == _currentVideoIndex,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF9B59B6)),
          const SizedBox(height: 16),
          Text(
            'Getting your location...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Location Required',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable location to discover devotional content near you',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Enable Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B59B6),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Festival Banner
          if (_activeFestival != null && _showFestivalBanner)
            FestivalBannerWidget(
              festival: _activeFestival!,
              onTap: () => _filterByFestival(_activeFestival!),
              onClose: () {
                setState(() {
                  _showFestivalBanner = false;
                });
              },
            ),

          // Upcoming Festivals
          _buildSection(
            title: '🎉 Upcoming Festivals',
            subtitle: 'Next 30 days',
            child: _upcomingFestivals.isEmpty
                ? _buildEmptyFestivalsMessage()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _upcomingFestivals.length,
                    itemBuilder: (context, index) {
                      return _buildFestivalCard(_upcomingFestivals[index]);
                    },
                  ),
          ),

          // Festival-tagged Videos
          if (_activeFestival != null)
            _buildSection(
              title:
                  '${_activeFestival!.iconEmoji} ${_activeFestival!.name} Videos',
              subtitle: 'Special festival content',
              child: _buildVideoGrid(
                _videos
                    .where((v) => v.festivalTags.any((tag) =>
                        _activeFestival!.relatedHashtags.contains(tag)))
                    .take(4)
                    .toList(),
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyFestivalsMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.celebration_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No upcoming festivals',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalCard(Festival festival) {
    final daysUntil = festival.startDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: festival.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: festival.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              festival.iconEmoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          festival.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              festival.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: festival.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                daysUntil == 0
                    ? 'Today!'
                    : daysUntil == 1
                        ? 'Tomorrow'
                        : 'In $daysUntil days',
                style: TextStyle(
                  color: festival.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
          onPressed: () => _scheduleNotificationForFestival(festival),
        ),
        onTap: () => _filterByFestival(festival),
      ),
    );
  }

  Widget _buildQuotesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote of the Day - featured
          const QuoteOfTheDayWidget(),

          // All Quotes section
          _buildSection(
            title: '📜 Spiritual Wisdom',
            subtitle: 'Inspirational quotes',
            child: _quotes.isEmpty
                ? _buildEmptyQuotesMessage()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _quotes.take(10).length,
                    itemBuilder: (context, index) {
                      return _buildQuoteCard(_quotes[index]);
                    },
                  ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyQuotesMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.format_quote,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No quotes available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(DevotionalQuote quote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(
            color: Color(0xFF9B59B6),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getReligionIcon(quote.religion),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quote.author ?? quote.source ?? 'Unknown',
                  style: const TextStyle(
                    color: Color(0xFF9B59B6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${quote.text}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          if (quote.source != null) ...[
            const SizedBox(height: 8),
            Text(
              '- ${quote.source}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplesTab() {
    if (_locationLoading) {
      return _buildLocationLoadingState();
    }

    if (_userLocation == null) {
      return _buildLocationPermissionState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance indicator
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF16213e).withOpacity(0.5),
            child: Row(
              children: [
                const Icon(
                  Icons.temple_hindu,
                  color: Color(0xFF9B59B6),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Temples within ${_selectedDistanceCategory.minKm.toInt()}-${_selectedDistanceCategory.maxKm == double.infinity ? '500+' : _selectedDistanceCategory.maxKm.toInt()} km',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Temples list
          _buildSection(
            title: '🛕 Sacred Places',
            subtitle: 'Temples and religious sites near you',
            child: _temples.isEmpty
                ? _buildEmptyTemplesMessage()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _temples.length,
                    itemBuilder: (context, index) {
                      return _buildTempleCard(_temples[index]);
                    },
                  ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyTemplesMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.temple_hindu,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No temples found in this distance range',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try expanding your search range',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempleCard(Temple temple) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temple image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.network(
                  temple.imageUrl ?? 'https://via.placeholder.com/300x150',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: const Color(0xFF1a1a2e),
                      child: const Center(
                        child: Icon(
                          Icons.temple_hindu,
                          color: Colors.white30,
                          size: 60,
                        ),
                      ),
                    );
                  },
                ),

                // Verified badge
                if (temple.isVerified)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Distance badge
                if (temple.distanceKm != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            temple.formattedDistance,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Temple details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        temple.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (temple.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            temple.rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  temple.deity ?? 'Sacred Place',
                  style: const TextStyle(
                    color: Color(0xFF9B59B6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${temple.city}, ${temple.state}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                if (temple.timings != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withOpacity(0.5),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        temple.timings!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],

                // Festival tags
                if (temple.festivalTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: temple.festivalTags.take(3).map((tag) {
                      return FestivalTagWidget(festivalTag: tag);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildVideoGrid(List<DevotionalVideo> videos) {
    if (videos.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          'No videos available',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoThumbnail(video);
      },
    );
  }

  Widget _buildVideoThumbnail(DevotionalVideo video) {
    return GestureDetector(
      onTap: () {
        // Navigate to video in full screen
        final index = _videos.indexOf(video);
        if (index >= 0) {
          _tabController.animateTo(0);
          _pageController.jumpToPage(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(video.thumbnailUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Verified badge
            if (video.isVerified)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),

            // Festival tags
            if (video.festivalTags.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                child: FestivalTagWidget(festivalTag: video.festivalTags.first),
              ),

            // Title and info
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.white.withOpacity(0.7),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatViews(video.views),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No devotional videos found',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters or religion',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _changeReligion,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
            ),
            child: const Text('Change Religion'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<bool>>(
              future: Future.wait([
                DevotionalNotificationService.isQuoteNotificationsEnabled(),
                DevotionalNotificationService.isFestivalNotificationsEnabled(),
              ]),
              builder: (context, snapshot) {
                final quoteEnabled = snapshot.data?[0] ?? false;
                final festivalEnabled = snapshot.data?[1] ?? false;

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Icon(Icons.notifications,
                              color: Color(0xFF9B59B6)),
                          const SizedBox(width: 12),
                          const Text(
                            'Notification Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Daily Quote notification
                      _buildNotificationToggle(
                        title: 'Daily Quote',
                        subtitle:
                            'Receive a spiritual quote every morning at 7 AM',
                        icon: Icons.format_quote,
                        value: quoteEnabled,
                        onChanged: (value) async {
                          await DevotionalNotificationService
                              .setQuoteNotificationsEnabled(value);
                          setModalState(() {});
                          if (value) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Daily quote notification enabled! ✨'),
                                  backgroundColor: Color(0xFF9B59B6),
                                ),
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Festival notifications
                      _buildNotificationToggle(
                        title: 'Festival Alerts',
                        subtitle:
                            'Get notified about upcoming religious festivals',
                        icon: Icons.celebration,
                        value: festivalEnabled,
                        onChanged: (value) async {
                          await DevotionalNotificationService
                              .setFestivalNotificationsEnabled(value);
                          setModalState(() {});
                          if (value) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Festival notifications enabled! 🎉'),
                                  backgroundColor: Color(0xFF9B59B6),
                                ),
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF9B59B6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF9B59B6),
          ),
        ],
      ),
    );
  }

  // NEW FEATURE: Safety & Moderation Menu
  void _showSafetyMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<UserTrustLevel>(
          future: UserSafetyService.getUserTrustLevel('current_user_id'),
          builder: (context, snapshot) {
            final trustLevel = snapshot.data?.trustBadge ?? TrustBadge.newUser;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.shield, color: Color(0xFF9B59B6)),
                      const SizedBox(width: 12),
                      const Text(
                        'Safety & Moderation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Trust Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a2e),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF9B59B6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          snapshot.data?.badgeEmoji ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          snapshot.data?.badgeText ?? 'New User',
                          style: const TextStyle(
                            color: Color(0xFF9B59B6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Safety Center
                  _buildSafetyMenuItem(
                    icon: Icons.security,
                    title: 'Safety Center',
                    subtitle: 'Your safety hub with reports & guidelines',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SafetyCenterScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Community Guidelines
                  _buildSafetyMenuItem(
                    icon: Icons.gavel,
                    title: 'Community Guidelines',
                    subtitle: 'Learn about our content policies',
                    onTap: () {
                      Navigator.pop(context);
                      // Already accessible via Safety Center
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SafetyCenterScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Analytics (Admin/Moderator only)
                  if (trustLevel == TrustBadge.communityMod)
                    _buildSafetyMenuItem(
                      icon: Icons.analytics_outlined,
                      title: 'Moderation Analytics',
                      subtitle: 'View community health metrics',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ModerationAnalyticsScreen(),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 8),

                  // AI Protection Indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a2e),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Colors.green.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'AI Moderation Active - Content is automatically screened for safety',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSafetyMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF9B59B6)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleNotificationForFestival(Festival festival) async {
    await DevotionalNotificationService.showFestivalNotification(festival);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification set for ${festival.name}! 🔔'),
          backgroundColor: festival.color,
        ),
      );
    }
  }

  void _filterByFestival(Festival festival) {
    // Filter videos by festival tags
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing ${festival.name} content'),
        backgroundColor: festival.color,
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

  String _getReligionIcon(String religion) {
    switch (religion.toLowerCase()) {
      case 'hinduism':
        return '🕉️';
      case 'islam':
        return '☪️';
      case 'christianity':
        return '✝️';
      case 'sikhism':
        return '🙏';
      case 'buddhism':
        return '☸️';
      default:
        return '🙏';
    }
  }
}

/// Devotional Video Card Widget
class DevotionalVideoCard extends StatefulWidget {
  final DevotionalVideo video;
  final bool isActive;

  const DevotionalVideoCard({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<DevotionalVideoCard> createState() => _DevotionalVideoCardState();
}

class _DevotionalVideoCardState extends State<DevotionalVideoCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isMuted = true;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(DevotionalVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initializeVideo();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller?.pause();
    }
  }

  Future<void> _initializeVideo() async {
    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );

    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0.0); // Start muted
      if (mounted && widget.isActive) {
        _controller!.play();
      }
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleMute() {
    if (_controller != null) {
      setState(() {
        _isMuted = !_isMuted;
        _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      });
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        if (_isInitialized && _controller != null)
          GestureDetector(
            onTap: () {
              if (_controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
            },
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          )
        else
          // Thumbnail while loading
          Image.network(
            widget.video.thumbnailUrl,
            fit: BoxFit.cover,
          ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // AI Moderation Warning Overlay - NEW FEATURE
        FutureBuilder<ModerationResult>(
          future: AIModerationService().analyzeDevotionalVideo(
            title: widget.video.title,
            description: widget.video.deity ?? 'Devotional Content',
            deity: widget.video.deity ?? 'General',
            religion: widget.video.religion ?? 'Hindu',
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data!.safety != ContentSafety.safe) {
              final result = snapshot.data!;
              return Positioned(
                top: 60,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: result.safety == ContentSafety.needsReview
                        ? Colors.orange.withOpacity(0.9)
                        : Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        result.safety == ContentSafety.needsReview
                            ? Icons.warning_amber
                            : Icons.error,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.safety == ContentSafety.needsReview
                                  ? '⚠️ Content Under Review'
                                  : '🚫 ${result.reason ?? "Flagged Content"}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (result.reason != null &&
                                result.reason!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  result.reason!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
            return const SizedBox.shrink();
          },
        ),

        // Content
        Positioned(
          bottom: 100,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verified badge
              if (widget.video.isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),

              // Title
              Text(
                widget.video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Temple name
              if (widget.video.templeName != null)
                Row(
                  children: [
                    const Text('🛕', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.video.templeName!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),

              // Festival tags
              if (widget.video.festivalTags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.video.festivalTags.take(2).map((tag) {
                    return FestivalTagWidget(festivalTag: tag);
                  }).toList(),
                ),
            ],
          ),
        ),

        // Action buttons
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              // Mute/Unmute
              _buildActionButton(
                icon: _isMuted ? Icons.volume_off : Icons.volume_up,
                label: _isMuted ? 'Unmute' : 'Mute',
                onTap: _toggleMute,
                color: Colors.white,
              ),
              const SizedBox(height: 20),

              // Like
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatNumber(widget.video.likes),
                onTap: _toggleLike,
                color: _isLiked ? Colors.red : Colors.white,
              ),
              const SizedBox(height: 20),

              // Comment
              _buildActionButton(
                icon: Icons.comment,
                label: 'Comment',
                onTap: () {},
              ),
              const SizedBox(height: 20),

              // Share
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: () {},
              ),
              const SizedBox(height: 20),

              // Report Button - NEW MODERATION FEATURE
              ReportButton(
                contentId: widget.video.id,
                contentType: ReportedContentType.devotionalVideo,
                contentTitle: widget.video.title,
                contentOwnerId: widget.video.creatorId ?? 'unknown',
                contentOwnerName: widget.video.creatorName ??
                    widget.video.templeName ??
                    'Unknown',
                contentDescription: widget.video.deity,
                contentThumbnail: widget.video.thumbnailUrl,
                iconColor: Colors.white,
                showLabel: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
