/// Devotional Feed Screen
/// Complete devotional content with religion-based videos, quotes, and festivals

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/devotional_video_model.dart';
import '../../models/festival_model.dart';
import '../../services/devotional_service.dart';
import '../../services/religion_service.dart';
import '../../services/festival_service.dart';
import '../../widgets/quote_of_the_day_widget.dart';
import '../../widgets/festival_banner_widget.dart';
import 'religion_selection_screen.dart';

class DevotionalFeedScreen extends StatefulWidget {
  const DevotionalFeedScreen({super.key});

  @override
  State<DevotionalFeedScreen> createState() => _DevotionalFeedScreenState();
}

class _DevotionalFeedScreenState extends State<DevotionalFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Religion? _selectedReligion;
  String? _selectedDistance;
  bool _isLoading = true;
  List<DevotionalVideo> _videos = [];
  Festival? _activeFestival;
  bool _showFestivalBanner = true;

  final PageController _pageController = PageController();
  int _currentVideoIndex = 0;

  final List<String> _distanceCategories = [
    'all',
    'nearby',
    'regional',
    'national'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    // Load videos
    await _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final videos = await DevotionalService.fetchDevotionalVideos(
        religion: _selectedReligion?.displayName.toLowerCase(),
        distanceCategory: _selectedDistance == 'all' ? null : _selectedDistance,
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

  void _onDistanceChanged(String? distance) {
    setState(() {
      _selectedDistance = distance;
    });
    _loadVideos();
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
      _loadVideos();
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

            // Tabs
            _buildTabs(),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Videos Tab
                  _buildVideosTab(),
                  // Explore Tab
                  _buildExploreTab(),
                ],
              ),
            ),
          ],
        ),
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

          // Filter button
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
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
        tabs: const [
          Tab(
            icon: Icon(Icons.play_circle_fill),
            text: 'Videos',
          ),
          Tab(
            icon: Icon(Icons.explore),
            text: 'Explore',
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9B59B6)),
      );
    }

    if (_videos.isEmpty) {
      return _buildEmptyState();
    }

    return PageView.builder(
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
    );
  }

  Widget _buildExploreTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Festival Banner
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

          // Quote of the Day
          const QuoteOfTheDayWidget(),

          // Section: Trending
          _buildSection(
            title: '🔥 Trending',
            subtitle: 'Popular devotional content',
            child: _buildVideoGrid(_videos.take(4).toList()),
          ),

          // Section: By Temple
          _buildSection(
            title: '🛕 Sacred Places',
            subtitle: 'Videos from famous temples',
            child: _buildTempleChips(),
          ),

          // Section: By Deity
          if (_selectedReligion != null)
            _buildSection(
              title: '🙏 By Deity',
              subtitle: 'Explore by deity',
              child: _buildDeityChips(),
            ),

          // Section: Festival Content
          if (_activeFestival != null)
            _buildSection(
              title:
                  '${_activeFestival!.iconEmoji} ${_activeFestival!.name} Special',
              subtitle: 'Festival content',
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

  Widget _buildTempleChips() {
    final temples = _videos
        .where((v) => v.templeName != null && v.templeName!.isNotEmpty)
        .map((v) => v.templeName!)
        .toSet()
        .take(6)
        .toList();

    if (temples.isEmpty) {
      return Text(
        'No temples available',
        style: TextStyle(color: Colors.white.withOpacity(0.5)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: temples.map((temple) {
        return GestureDetector(
          onTap: () => _filterByTemple(temple),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFF9B59B6).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🛕', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  temple,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeityChips() {
    final deities = DevotionalService.getDeitiesByReligion(
      _selectedReligion?.displayName ?? '',
    );

    if (deities.isEmpty) {
      return Text(
        'No deities available',
        style: TextStyle(color: Colors.white.withOpacity(0.5)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: deities.take(8).map((deity) {
        return GestureDetector(
          onTap: () => _filterByDeity(deity),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFFFF6B00).withOpacity(0.5)),
            ),
            child: Text(
              deity,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.tune, color: Color(0xFF9B59B6)),
                      const SizedBox(width: 12),
                      const Text(
                        'Filter Videos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedDistance = null;
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Color(0xFF9B59B6)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Distance filter
                  const Text(
                    'Distance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _distanceCategories.map((distance) {
                      final isSelected = _selectedDistance == distance;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedDistance = distance;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF9B59B6)
                                : const Color(0xFF1a1a2e),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.white24,
                            ),
                          ),
                          child: Text(
                            distance == 'all'
                                ? 'All'
                                : distance[0].toUpperCase() +
                                    distance.substring(1),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _onDistanceChanged(_selectedDistance);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B59B6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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

  void _filterByFestival(Festival festival) {
    // Filter videos by festival tags
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing ${festival.name} content'),
        backgroundColor: festival.color,
      ),
    );
  }

  void _filterByTemple(String temple) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing videos from $temple'),
        backgroundColor: const Color(0xFF9B59B6),
      ),
    );
  }

  void _filterByDeity(String deity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing $deity videos'),
        backgroundColor: const Color(0xFFFF6B00),
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
