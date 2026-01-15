/// Regional Feed Screen
/// Main screen for browsing regional short videos with filters and tabs
/// Also includes regional services grid

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/app_state.dart';
import '../../../screens/cab_services_screen.dart';
import '../../../screens/local_alerts_screen.dart';
import '../../../services/auth_service.dart';
import '../../../screens/login_screen.dart';
import '../models/models.dart';
import '../state/regional_feed_state.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class RegionalFeedScreen extends StatefulWidget {
  const RegionalFeedScreen({super.key});

  @override
  State<RegionalFeedScreen> createState() => _RegionalFeedScreenState();
}

class _RegionalFeedScreenState extends State<RegionalFeedScreen>
    with TickerProviderStateMixin {
  late RegionalFeedState _feedState;
  late AnimationController _filterAnimationController;
  late TabController _mainTabController;
  bool _showFilters = true;

  // Regional Services data
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
    _feedState = RegionalFeedState();
    _mainTabController = TabController(length: 2, vsync: this);
    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _filterAnimationController.forward();

    // Initialize feed with user's location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFeed();
    });
  }

  void _initializeFeed() {
    final appState = context.read<AppState>();
    _feedState.initialize(
      city: appState.selectedCity ?? 'Hyderabad',
      state: appState.selectedState ?? 'Telangana',
      district: null,
      region: appState.selectedRegion,
    );
  }

  @override
  void dispose() {
    _feedState.dispose();
    _filterAnimationController.dispose();
    _mainTabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }

  Future<void> _showLanguageSelector() async {
    final language = await LanguageSelectionSheet.show(
      context,
      selectedLanguage: _feedState.filter.language,
    );

    if (language != null) {
      _feedState.setLanguage(language);
    }
  }

  Future<void> _showCitySelector() async {
    final result = await CitySelectionSheet.show(
      context,
      selectedCity: _feedState.filter.city,
      selectedState: _feedState.filter.state,
    );

    if (result != null) {
      _feedState.setCity(
        city: result['city']!,
        state: result['state']!,
        district: result['district'],
      );
    }
  }

  void _handleLike(RegionalVideo video) {
    // TODO: Implement like functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Liked ${video.title}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleComment(RegionalVideo video) {
    // TODO: Show comments bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _CommentsSheet(video: video),
    );
  }

  void _handleShare(RegionalVideo video) {
    // TODO: Implement share functionality
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ShareSheet(video: video),
    );
  }

  void _handleCreatorTap(RegionalVideo video) {
    // TODO: Navigate to creator profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View ${video.creatorName}\'s profile'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoonDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleServiceTap(Map<String, dynamic> service) {
    final title = service['title'] as String;
    if (title == 'Cab Services') {
      final appState = context.read<AppState>();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CabServicesScreen(
            userCity: appState.selectedCity,
          ),
        ),
      );
    } else if (title == 'Local Alerts') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LocalAlertsScreen(),
        ),
      );
    } else {
      _showComingSoonDialog(title);
    }
  }

  Future<void> _handleUploadVideo() async {
    // Show video source selection
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _VideoSourceSheet(),
    );

    if (source == null) return;

    final picker = ImagePicker();
    try {
      final video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 60),
      );

      if (video != null) {
        // Show input dialog for video details
        if (mounted) {
          final result = await _showVideoDetailsDialog(video.path);

          if (result != null) {
            // Save the video
            final appState = context.read<AppState>();
            final success = await VideoStorageService.savePostedVideo(
              videoPath: video.path,
              title: result['title']!,
              description: result['description']!,
              city: _feedState.filter.city ?? 'Hyderabad',
              state: _feedState.filter.state ?? 'Telangana',
              language: _feedState.filter.language ?? 'en',
              hashtags: _extractHashtags(result['description']!),
            );

            if (success && mounted) {
              // Refresh the feed to show the new video
              _feedState.refresh();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video posted successfully! 🎉'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Map<String, String>?> _showVideoDetailsDialog(String videoPath) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter video title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add description and hashtags (#tag)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 300,
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
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a title')),
                );
                return;
              }

              Navigator.pop(context, {
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
              });
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(0)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _feedState,
      child: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16213e),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Regional',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            controller: _mainTabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Videos', icon: Icon(Icons.play_circle_outline)),
              Tab(text: 'Services', icon: Icon(Icons.apps)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _mainTabController,
          children: [
            // Videos Tab
            _buildVideosTab(),
            // Services Tab
            _buildServicesTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _handleUploadVideo,
          backgroundColor: const Color(0xFF6C63FF),
          icon: const Icon(Icons.video_call),
          label: const Text('Post Video'),
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    return Stack(
      children: [
        // Main feed content
        Consumer<RegionalFeedState>(
          builder: (context, state, child) {
            return _buildFeedContent(state);
          },
        ),
        // Top overlay with video filters
        _buildVideoFiltersOverlay(),
      ],
    );
  }

  Widget _buildServicesTab() {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _regionalServices.length,
          itemBuilder: (context, index) {
            final service = _regionalServices[index];
            return _buildRegionalServiceCard(service);
          },
        ),
      ),
    );
  }

  Widget _buildRegionalServiceCard(Map<String, dynamic> service) {
    final gradient = service['gradient'] as List<Color>;
    return GestureDetector(
      onTap: () => _handleServiceTap(service),
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
            // Decorative circle
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
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    service['icon'] as IconData,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(RegionalFeedState state) {
    final currentFeed = state.currentFeed;

    // Error state
    if (currentFeed.hasError) {
      return ErrorFeedState(
        message: currentFeed.errorMessage,
        isNetworkError: currentFeed.errorMessage?.contains('network') ?? false,
        onRetry: () => state.refresh(),
      );
    }

    // Empty state
    if (currentFeed.isEmpty && !currentFeed.isLoading) {
      return EmptyFeedState(
        city: state.filter.city,
        language: state.filter.language,
        onChangeLocation: _showCitySelector,
        onChangeLanguage: _showLanguageSelector,
        onRefresh: () => state.refresh(),
      );
    }

    // Feed content
    return VerticalVideoFeed(
      videos: currentFeed.items,
      isLoading: currentFeed.isLoading,
      isLoadingMore: currentFeed.isLoadingMore,
      hasMore: currentFeed.cursor.hasMore,
      onLoadMore: () => state.loadMore(),
      onRefresh: () => state.refresh(),
      onLike: _handleLike,
      onComment: _handleComment,
      onShare: _handleShare,
      onCreatorTap: _handleCreatorTap,
      emptyWidget: EmptyFeedState(
        city: state.filter.city,
        language: state.filter.language,
        onChangeLocation: _showCitySelector,
        onChangeLanguage: _showLanguageSelector,
      ),
    );
  }

  Widget _buildVideoFiltersOverlay() {
    return SafeArea(
      child: Column(
        children: [
          // Header with Latest/Trending tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 48), // Space for alignment

                const Spacer(),

                // Latest/Trending Tab bar
                Consumer<RegionalFeedState>(
                  builder: (context, state, child) {
                    return FeedTabBarMinimal(
                      selectedTab: state.currentTab,
                      onTabChanged: (tab) => state.switchTab(tab),
                    );
                  },
                ),

                const Spacer(),

                // Filter toggle button
                IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFilters,
                ),
              ],
            ),
          ),

          // Filter chips
          AnimatedBuilder(
            animation: _filterAnimationController,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _filterAnimationController,
                child: child,
              );
            },
            child: Consumer<RegionalFeedState>(
              builder: (context, state, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // City filter
                      CityFilterChip(
                        city: state.filter.city,
                        state: state.filter.state,
                        onTap: _showCitySelector,
                      ),
                      const SizedBox(width: 8),

                      // Language filter
                      LanguageFilterChip(
                        selectedLanguage: state.filter.language,
                        onTap: _showLanguageSelector,
                      ),

                      const Spacer(),

                      // Refresh indicator
                      if (state.isRefreshing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Comments bottom sheet placeholder
class _CommentsSheet extends StatelessWidget {
  final RegionalVideo video;

  const _CommentsSheet({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${video.comments} Comments',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey),

          // Comments placeholder
          Expanded(
            child: Center(
              child: Text(
                'Comments coming soon...',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              top: 8,
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white70),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Share bottom sheet
class _ShareSheet extends StatelessWidget {
  final RegionalVideo video;

  const _ShareSheet({required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Share',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Share options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                  },
                ),
                _ShareOption(
                  icon: Icons.message,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Video source selection sheet for uploading videos
class _VideoSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Post a Regional Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Share local news, events, or content from your region with the community!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Source options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceOption(
                    icon: Icons.videocam,
                    label: 'Record',
                    sublabel: 'Camera',
                    color: const Color(0xFFFF6B6B),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _SourceOption(
                    icon: Icons.photo_library,
                    label: 'Choose',
                    sublabel: 'Gallery',
                    color: const Color(0xFF4CAF50),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Guidelines
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Guidelines:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _GuidelineItem(text: 'Max duration: 60 seconds'),
                  _GuidelineItem(text: 'Vertical format recommended (9:16)'),
                  _GuidelineItem(text: 'Max file size: 100MB'),
                  _GuidelineItem(
                      text: 'Content must be relevant to your region'),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final String text;

  const _GuidelineItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
