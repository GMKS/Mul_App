/// Daily Bhajan Screen
/// Main screen for browsing and playing bhajans with 2026+ features
/// Includes: Categories, AI Playlists, Live Rooms, Trending, Search

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/bhajan_model.dart';
import '../../services/bhajan_service.dart';
import 'bhajan_player_screen.dart';
import 'bhajan_upload_screen.dart';
import 'bhajan_room_screen.dart';

class DailyBhajanScreen extends StatefulWidget {
  const DailyBhajanScreen({super.key});

  @override
  State<DailyBhajanScreen> createState() => _DailyBhajanScreenState();
}

class _DailyBhajanScreenState extends State<DailyBhajanScreen>
    with SingleTickerProviderStateMixin {
  final BhajanService _bhajanService = BhajanService();
  late TabController _tabController;

  bool _isLoading = true;
  List<Bhajan> _todaysPicks = [];
  List<Bhajan> _trendingBhajans = [];
  List<BhajanPlaylist> _playlists = [];
  List<BhajanRoom> _liveRooms = [];
  List<Bhajan> _allBhajans = [];

  String _searchQuery = '';
  BhajanCategory? _selectedCategory;
  String? _selectedMood;
  String? _selectedDeity;

  final List<String> _categories = [
    'All',
    'Morning',
    'Evening',
    'Aarti',
    'Chalisa',
    'Mantra',
    'Kirtan',
    'Festival',
  ];

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Peaceful', 'emoji': '🕊️', 'value': 'peaceful'},
    {'name': 'Energetic', 'emoji': '⚡', 'value': 'energetic'},
    {'name': 'Devotional', 'emoji': '🙏', 'value': 'devotional'},
    {'name': 'Meditative', 'emoji': '🧘', 'value': 'meditative'},
    {'name': 'Celebratory', 'emoji': '🎉', 'value': 'celebratory'},
    {'name': 'Soulful', 'emoji': '💫', 'value': 'soulful'},
  ];

  final List<Map<String, dynamic>> _deities = [
    {'name': 'Krishna', 'emoji': '🦚'},
    {'name': 'Shiva', 'emoji': '🔱'},
    {'name': 'Hanuman', 'emoji': '🐒'},
    {'name': 'Ganesha', 'emoji': '🐘'},
    {'name': 'Durga', 'emoji': '🦁'},
    {'name': 'Vishnu', 'emoji': '🪷'},
    {'name': 'Lakshmi', 'emoji': '💰'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _bhajanService.getTodaysDivinePicks(),
        _bhajanService.getTrendingBhajans(),
        _bhajanService.getPlaylists(),
        _bhajanService.getLiveBhajanRooms(),
        _bhajanService.getBhajans(),
      ]);

      if (mounted) {
        setState(() {
          _todaysPicks = results[0] as List<Bhajan>;
          _trendingBhajans = results[1] as List<Bhajan>;
          _playlists = results[2] as List<BhajanPlaylist>;
          _liveRooms = results[3] as List<BhajanRoom>;
          _allBhajans = results[4] as List<Bhajan>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bhajans: $e')),
        );
      }
    }
  }

  Future<void> _searchBhajans(String query) async {
    if (query.isEmpty) {
      _loadData();
      return;
    }

    setState(() => _isLoading = true);
    final results = await _bhajanService.searchBhajans(query);
    if (mounted) {
      setState(() {
        _allBhajans = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByCategory(BhajanCategory? category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });

    final results = await _bhajanService.getBhajans(category: category);
    if (mounted) {
      setState(() {
        _allBhajans = results;
        _isLoading = false;
      });
    }
  }

  void _playBhajan(Bhajan bhajan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BhajanPlayerScreen(bhajan: bhajan),
      ),
    );
  }

  void _joinRoom(BhajanRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BhajanRoomScreen(roomId: room.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: isDark ? Colors.grey[900] : Colors.orange[600],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Daily Bhajan 🎵',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [Colors.orange[900]!, Colors.deepOrange[900]!]
                          : [Colors.orange[400]!, Colors.deepOrange[400]!],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.upload_rounded, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BhajanUploadScreen(),
                      ),
                    );
                  },
                  tooltip: 'Upload Bhajan',
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: _showFavorites,
                  tooltip: 'Favorites',
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(
                      text: 'For You',
                      icon: Icon(Icons.auto_awesome, size: 18)),
                  Tab(
                      text: 'Browse',
                      icon: Icon(Icons.library_music, size: 18)),
                  Tab(text: 'Live', icon: Icon(Icons.sensors, size: 18)),
                  Tab(
                      text: 'Playlists',
                      icon: Icon(Icons.queue_music, size: 18)),
                ],
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildForYouTab(),
                  _buildBrowseTab(),
                  _buildLiveTab(),
                  _buildPlaylistsTab(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createBhajanRoom,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add),
        label: const Text('Start Room'),
      ),
    );
  }

  // ==================== FOR YOU TAB ====================

  Widget _buildForYouTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSearchBar(),
            ),
          ),

          // Live Rooms Preview
          if (_liveRooms.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                '🔴 Live Bhajan Rooms',
                onSeeAll: () => _tabController.animateTo(2),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _liveRooms.length,
                  itemBuilder: (context, index) {
                    return _buildLiveRoomCard(_liveRooms[index]);
                  },
                ),
              ),
            ),
          ],

          // Today's Divine Picks
          SliverToBoxAdapter(
            child: _buildSectionHeader("✨ Today's Divine Picks"),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _todaysPicks.length,
                itemBuilder: (context, index) {
                  return _buildFeaturedBhajanCard(_todaysPicks[index]);
                },
              ),
            ),
          ),

          // Trending Now
          SliverToBoxAdapter(
            child: _buildSectionHeader('🔥 Trending Now'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _trendingBhajans.length) return null;
                return _buildBhajanListTile(_trendingBhajans[index], index + 1);
              },
              childCount: _trendingBhajans.take(5).length,
            ),
          ),

          // Quick Mood Selection
          SliverToBoxAdapter(
            child: _buildSectionHeader('🎭 Browse by Mood'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  return _buildMoodChip(_moods[index]);
                },
              ),
            ),
          ),

          // Deity Selection
          SliverToBoxAdapter(
            child: _buildSectionHeader('🙏 Browse by Deity'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _deities.length,
                itemBuilder: (context, index) {
                  return _buildDeityChip(_deities[index]);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ==================== BROWSE TAB ====================

  Widget _buildBrowseTab() {
    return CustomScrollView(
      slivers: [
        // Category Filter Chips
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory?.name.toLowerCase() ==
                        category.toLowerCase() ||
                    (category == 'All' && _selectedCategory == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      if (category == 'All') {
                        _filterByCategory(null);
                      } else {
                        final cat = BhajanCategory.values.firstWhere(
                          (c) => c.name.toLowerCase() == category.toLowerCase(),
                          orElse: () => BhajanCategory.general,
                        );
                        _filterByCategory(cat);
                      }
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.orange[100],
                    checkmarkColor: Colors.orange,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Bhajan Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _allBhajans.length) return null;
                return _buildBhajanGridCard(_allBhajans[index]);
              },
              childCount: _allBhajans.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // ==================== LIVE TAB ====================

  Widget _buildLiveTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _liveRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No live rooms right now',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _createBhajanRoom,
                    icon: const Icon(Icons.add),
                    label: const Text('Start a Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _liveRooms.length,
              itemBuilder: (context, index) {
                return _buildLiveRoomDetailCard(_liveRooms[index]);
              },
            ),
    );
  }

  // ==================== PLAYLISTS TAB ====================

  Widget _buildPlaylistsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          return _buildPlaylistCard(_playlists[index]);
        },
      ),
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search bhajans, artists, deities...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _searchQuery = '');
                  _loadData();
                },
              )
            : IconButton(
                icon: const Icon(Icons.mic),
                onPressed: _voiceSearch,
                tooltip: 'Voice Search',
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value);
        if (value.length >= 2) {
          _searchBhajans(value);
        }
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBhajanCard(Bhajan bhajan) {
    return GestureDetector(
      onTap: () => _playBhajan(bhajan),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    bhajan.coverImageUrl ?? 'https://picsum.photos/160/120',
                    width: 160,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 160,
                      height: 120,
                      color: Colors.orange[100],
                      child: const Icon(Icons.music_note, size: 40),
                    ),
                  ),
                ),
                // Type Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: bhajan.type == BhajanType.video
                          ? Colors.red
                          : Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      bhajan.type == BhajanType.video ? '🎬 Video' : '🎵 Audio',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Play Button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              bhajan.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            // Stats
            Text(
              '${_formatNumber(bhajan.playCount)} plays',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBhajanListTile(Bhajan bhajan, int rank) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.orange : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              bhajan.coverImageUrl ?? 'https://picsum.photos/56/56',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.orange[100],
                child: const Icon(Icons.music_note),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        bhajan.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${bhajan.deity ?? bhajan.category.name} • ${_formatDuration(bhajan.duration)}',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              bhajan.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: bhajan.isFavorite ? Colors.red : null,
            ),
            onPressed: () => _toggleFavorite(bhajan),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_filled),
            color: Colors.orange,
            onPressed: () => _playBhajan(bhajan),
          ),
        ],
      ),
      onTap: () => _playBhajan(bhajan),
    );
  }

  Widget _buildBhajanGridCard(Bhajan bhajan) {
    return GestureDetector(
      onTap: () => _playBhajan(bhajan),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.network(
                    bhajan.coverImageUrl ?? 'https://picsum.photos/200/160',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.orange[100],
                      child: const Icon(Icons.music_note, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      bhajan.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: bhajan.isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(bhajan),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(bhajan.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (bhajan.isTrending)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '🔥 Trending',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bhajan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bhajan.deity ?? bhajan.category.name,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
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

  Widget _buildMoodChip(Map<String, dynamic> mood) {
    return GestureDetector(
      onTap: () async {
        final moodEnum = BhajanMood.values.firstWhere(
          (m) => m.name == mood['value'],
          orElse: () => BhajanMood.peaceful,
        );
        final results = await _bhajanService.getBhajans(mood: moodEnum);
        if (mounted) {
          setState(() {
            _allBhajans = results;
            _selectedMood = mood['value'];
          });
          _tabController.animateTo(1);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[300]!, Colors.deepOrange[300]!],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mood['emoji'], style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              mood['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeityChip(Map<String, dynamic> deity) {
    return GestureDetector(
      onTap: () async {
        final results = await _bhajanService.getBhajans(deity: deity['name']);
        if (mounted) {
          setState(() {
            _allBhajans = results;
            _selectedDeity = deity['name'];
          });
          _tabController.animateTo(1);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(deity['emoji'], style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              deity['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRoomCard(BhajanRoom room) {
    return GestureDetector(
      onTap: () => _joinRoom(room),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[400]!, Colors.red[600]!],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.people, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${room.participantCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              room.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'by ${room.hostName}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRoomDetailCard(BhajanRoom room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _joinRoom(room),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Host Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: room.hostAvatar != null
                        ? NetworkImage(room.hostAvatar!)
                        : null,
                    child: room.hostAvatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Room Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hosted by ${room.hostName}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${room.participantCount} listening',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (room.currentBhajan != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.music_note,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              room.currentBhajan!.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Join Button
              ElevatedButton(
                onPressed: () => _joinRoom(room),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(BhajanPlaylist playlist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openPlaylist(playlist),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  playlist.coverImageUrl ?? 'https://picsum.photos/80/80',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.orange[100],
                    child: const Icon(Icons.queue_music, size: 40),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            playlist.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (playlist.isAiCurated)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '✨ AI',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      playlist.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.music_note,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${playlist.bhajans.length} bhajans',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatNumber(playlist.followerCount)} followers',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Play Button
              IconButton(
                onPressed: () => _playPlaylist(playlist),
                icon: const Icon(Icons.play_circle_filled),
                iconSize: 48,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _toggleFavorite(Bhajan bhajan) async {
    if (bhajan.isFavorite) {
      await _bhajanService.removeFromFavorites(bhajan.id);
    } else {
      await _bhajanService.addToFavorites(bhajan.id);
    }
    _loadData();
  }

  void _showFavorites() async {
    final favorites = await _bhajanService.getFavorites();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'My Favorites',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${favorites.length} bhajans',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        return _buildBhajanListTile(
                            favorites[index], index + 1);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _voiceSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 Voice search: "Play my morning bhajan"'),
      ),
    );
  }

  void _createBhajanRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🎵 Create Bhajan Room',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Room Name',
                hintText: 'e.g., Morning Satsang',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What kind of bhajans will you play?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🎉 Bhajan Room Created!')),
                );
              },
              icon: const Icon(Icons.sensors),
              label: const Text('Go Live'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openPlaylist(BhajanPlaylist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  void _playPlaylist(BhajanPlaylist playlist) {
    if (playlist.bhajans.isNotEmpty) {
      _playBhajan(playlist.bhajans.first);
    }
  }

  // ==================== HELPERS ====================

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ==================== PLAYLIST DETAIL SCREEN ====================

class PlaylistDetailScreen extends StatelessWidget {
  final BhajanPlaylist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                playlist.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    playlist.coverImageUrl ?? 'https://picsum.photos/400/200',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Share.share(
                      'Check out this bhajan playlist: ${playlist.name}');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (playlist.bhajans.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BhajanPlayerScreen(
                                  bhajan: playlist.bhajans.first,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Shuffle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final bhajan = playlist.bhajans[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      bhajan.coverImageUrl ?? 'https://picsum.photos/56/56',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    bhajan.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(bhajan.deity ?? bhajan.category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.play_circle_filled),
                    color: Colors.orange,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BhajanPlayerScreen(bhajan: bhajan),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BhajanPlayerScreen(bhajan: bhajan),
                      ),
                    );
                  },
                );
              },
              childCount: playlist.bhajans.length,
            ),
          ),
        ],
      ),
    );
  }
}
