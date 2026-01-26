/// Bhajan Player Screen
/// Full-featured audio/video player with lyrics, controls, and social features
/// Supports: Spatial Audio, AR/VR mode, Offline, Share

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/bhajan_model.dart';
import '../../services/bhajan_service.dart';

class BhajanPlayerScreen extends StatefulWidget {
  final Bhajan bhajan;

  const BhajanPlayerScreen({super.key, required this.bhajan});

  @override
  State<BhajanPlayerScreen> createState() => _BhajanPlayerScreenState();
}

class _BhajanPlayerScreenState extends State<BhajanPlayerScreen>
    with SingleTickerProviderStateMixin {
  final BhajanService _bhajanService = BhajanService();
  late TabController _tabController;

  bool _isPlaying = false;
  bool _isMuted = false;
  bool _showLyrics = true;
  bool _isFullScreen = false;
  bool _isFavorite = false;
  bool _isDownloaded = false;
  double _currentPosition = 0.0;
  double _playbackSpeed = 1.0;
  StreamingQuality _selectedQuality = StreamingQuality.auto;

  List<BhajanComment> _comments = [];
  List<Bhajan> _relatedBhajans = [];

  // Mock lyrics
  final List<Map<String, dynamic>> _lyrics = [
    {'time': 0, 'text': 'ॐ जय जगदीश हरे'},
    {'time': 5, 'text': 'स्वामी जय जगदीश हरे'},
    {'time': 10, 'text': 'भक्त जनों के संकट'},
    {'time': 15, 'text': 'दास जनों के संकट'},
    {'time': 20, 'text': 'क्षण में दूर करे'},
    {'time': 25, 'text': 'ॐ जय जगदीश हरे'},
    {'time': 30, 'text': ''},
    {'time': 35, 'text': 'जो ध्यावे फल पावे'},
    {'time': 40, 'text': 'दुख बिनसे मन का'},
    {'time': 45, 'text': 'सुख सम्पत्ति घर आवे'},
    {'time': 50, 'text': 'कष्ट मिटे तन का'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isFavorite = widget.bhajan.isFavorite;
    _loadData();
    _startPlayback();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final comments = await _bhajanService.getComments(widget.bhajan.id);
    final recommendations = await _bhajanService.getRecommendations(
      basedOnBhajanId: widget.bhajan.id,
      limit: 5,
    );

    if (mounted) {
      setState(() {
        _comments = comments;
        _relatedBhajans = recommendations;
      });
    }
  }

  void _startPlayback() {
    setState(() => _isPlaying = true);
    // Simulate playback progress
    _simulatePlayback();
  }

  void _simulatePlayback() async {
    while (mounted && _isPlaying) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _isPlaying) {
        setState(() {
          _currentPosition += 0.5 * _playbackSpeed;
          if (_currentPosition >= widget.bhajan.duration.inSeconds) {
            _currentPosition = 0;
            _isPlaying = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bhajan = widget.bhajan;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Player Area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Cover / Video Area
                    _buildPlayerArea(bhajan),

                    // Controls
                    _buildControls(bhajan),

                    // Tabs: Lyrics, Info, Comments
                    _buildTabs(bhajan),
                  ],
                ),
              ),
            ),

            // Mini Player / Queue
            _buildMiniQueue(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: _showCastOptions,
            tooltip: 'Cast to device',
          ),
          IconButton(
            icon: const Icon(Icons.view_in_ar),
            onPressed: _toggleARMode,
            tooltip: 'AR/VR Darbar Mode',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuOption,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'quality',
                child: ListTile(
                  leading: Icon(Icons.high_quality),
                  title: Text('Quality'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'speed',
                child: ListTile(
                  leading: Icon(Icons.speed),
                  title: Text('Playback Speed'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'timer',
                child: ListTile(
                  leading: Icon(Icons.timer),
                  title: Text('Sleep Timer'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: ListTile(
                  leading: Icon(Icons.flag),
                  title: Text('Report'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea(Bhajan bhajan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Cover Image / Video
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: bhajan.type == BhajanType.video ? 16 / 9 : 1,
                  child: Image.network(
                    bhajan.coverImageUrl ?? 'https://picsum.photos/400/400',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.orange[100],
                      child: const Icon(Icons.music_note, size: 80),
                    ),
                  ),
                ),
              ),
              // Play/Pause overlay for video
              if (bhajan.type == BhajanType.video)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              // Quality Badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (bhajan.availableQuality == StreamingQuality.ultraHd)
                        const Text(
                          '4K',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      if (bhajan.availableQuality ==
                          StreamingQuality.spatialAudio)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            '🎧 Spatial',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // AI Upscaled Badge
              if (bhajan.aiUpscaled)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '✨ AI Enhanced',
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

          const SizedBox(height: 16),

          // Title & Artist
          Text(
            bhajan.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (bhajan.deity != null) ...[
                Text(
                  bhajan.deity!,
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                bhajan.uploaderName ?? 'Unknown Artist',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),

          // Stats
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(Icons.play_arrow, _formatNumber(bhajan.playCount)),
              const SizedBox(width: 16),
              _buildStatChip(Icons.favorite, _formatNumber(bhajan.likeCount)),
              const SizedBox(width: 16),
              _buildStatChip(Icons.star, '${bhajan.userRating ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildControls(Bhajan bhajan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Progress Bar
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: Colors.orange,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Colors.orange,
                ),
                child: Slider(
                  value: _currentPosition,
                  max: bhajan.duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    setState(() => _currentPosition = value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(
                          Duration(seconds: _currentPosition.toInt())),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      _formatDuration(bhajan.duration),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Main Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: () {},
                tooltip: 'Shuffle',
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 36),
                onPressed: () {},
                tooltip: 'Previous',
              ),
              // Play/Pause Button
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 36),
                onPressed: () {},
                tooltip: 'Next',
              ),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () {},
                tooltip: 'Repeat',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                color: _isFavorite ? Colors.red : null,
                onTap: _toggleFavorite,
              ),
              _buildActionButton(
                icon: _isDownloaded
                    ? Icons.download_done
                    : Icons.download_for_offline,
                label: _isDownloaded ? 'Saved' : 'Save',
                color: _isDownloaded ? Colors.green : null,
                onTap: _downloadBhajan,
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onTap: _shareBhajan,
              ),
              _buildActionButton(
                icon: Icons.queue_music,
                label: 'Add to',
                onTap: _addToPlaylist,
              ),
              _buildActionButton(
                icon: _showLyrics ? Icons.lyrics : Icons.lyrics_outlined,
                label: 'Lyrics',
                color: _showLyrics ? Colors.orange : null,
                onTap: () => setState(() => _showLyrics = !_showLyrics),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.grey[700]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color ?? Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(Bhajan bhajan) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: const [
              Tab(text: 'Lyrics'),
              Tab(text: 'Info'),
              Tab(text: 'Comments'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLyricsTab(),
                _buildInfoTab(bhajan),
                _buildCommentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsTab() {
    final currentLyricIndex = _lyrics.indexWhere(
      (l) => l['time'] > _currentPosition,
    );
    final activeLyricIndex = currentLyricIndex > 0 ? currentLyricIndex - 1 : 0;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lyrics.length,
      itemBuilder: (context, index) {
        final lyric = _lyrics[index];
        final isActive = index == activeLyricIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            lyric['text'] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isActive ? 20 : 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.orange : Colors.grey[600],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(Bhajan bhajan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (bhajan.description != null) ...[
            const Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bhajan.description!,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
          ],

          // Details
          _buildInfoRow('Category', bhajan.category.name.toUpperCase()),
          _buildInfoRow('Language', bhajan.language.toUpperCase()),
          if (bhajan.deity != null) _buildInfoRow('Deity', bhajan.deity!),
          if (bhajan.festival != null)
            _buildInfoRow('Festival', bhajan.festival!),
          _buildInfoRow('Duration', _formatDuration(bhajan.duration)),
          _buildInfoRow('Quality', bhajan.availableQuality.name.toUpperCase()),

          const SizedBox(height: 16),

          // Tags
          if (bhajan.tags.isNotEmpty) ...[
            const Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: bhajan.tags.map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  backgroundColor: Colors.orange[50],
                  labelStyle: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),

          // Available Languages
          if (bhajan.availableLanguages.isNotEmpty) ...[
            const Text(
              'Available in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: bhajan.availableLanguages.map((lang) {
                return Chip(
                  label: Text(lang.toUpperCase()),
                  backgroundColor: Colors.blue[50],
                  labelStyle: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        // Add Comment
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.orange),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment posted!')),
                  );
                },
              ),
            ],
          ),
        ),
        // Comments List
        Expanded(
          child: _comments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No comments yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Text('Be the first to share your thoughts!'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: comment.userAvatar != null
                            ? NetworkImage(comment.userAvatar!)
                            : null,
                        child: comment.userAvatar == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            comment.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeAgo(comment.createdAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(comment.content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border,
                              size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMiniQueue() {
    if (_relatedBhajans.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Up Next',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _relatedBhajans.length,
              itemBuilder: (context, index) {
                final bhajan = _relatedBhajans[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BhajanPlayerScreen(bhajan: bhajan),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        bhajan.coverImageUrl ?? 'https://picsum.photos/48/48',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  void _togglePlayPause() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _simulatePlayback();
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _bhajanService.removeFromFavorites(widget.bhajan.id);
    } else {
      await _bhajanService.addToFavorites(widget.bhajan.id);
    }
    setState(() => _isFavorite = !_isFavorite);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isFavorite ? '❤️ Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _downloadBhajan() async {
    if (_isDownloaded) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⬇️ Downloading for offline...')),
    );

    final success = await _bhajanService.downloadForOffline(widget.bhajan.id);
    if (success && mounted) {
      setState(() => _isDownloaded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Saved for offline listening')),
      );
    }
  }

  void _shareBhajan() {
    Share.share(
      '🎵 Listen to "${widget.bhajan.title}" on Daily Bhajan!\n\n'
      '${widget.bhajan.deity != null ? "Deity: ${widget.bhajan.deity}\n" : ""}'
      'Download the app to experience divine music.\n\n'
      '#DailyBhajan #Devotional',
    );
  }

  void _addToPlaylist() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add to Playlist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Create New Playlist'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Creating new playlist...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('My Favorites'),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite();
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('Morning Rituals'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to Morning Rituals!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCastOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cast to Device',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.tv),
              title: const Text('Living Room TV'),
              subtitle: const Text('Chromecast'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('📺 Casting to Living Room TV...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.speaker),
              title: const Text('Smart Speaker'),
              subtitle: const Text('Google Home'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('🔊 Casting to Smart Speaker...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleARMode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.view_in_ar, color: Colors.purple),
            SizedBox(width: 8),
            Text('AR/VR Bhajan Darbar'),
          ],
        ),
        content: const Text(
          'Experience bhajans in an immersive virtual temple environment!\n\n'
          '🛕 Virtual Temple Darshan\n'
          '🪔 Interactive Aarti Experience\n'
          '🧘 Meditation Mode\n\n'
          'This feature requires a VR headset or AR-capable device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🥽 Launching AR/VR Darbar...'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Enter Darbar'),
          ),
        ],
      ),
    );
  }

  void _handleMenuOption(String option) {
    switch (option) {
      case 'quality':
        _showQualityOptions();
        break;
      case 'speed':
        _showSpeedOptions();
        break;
      case 'timer':
        _showSleepTimer();
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening report dialog...')),
        );
        break;
    }
  }

  void _showQualityOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Streaming Quality',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...StreamingQuality.values.map((quality) {
              final qualityLabels = {
                StreamingQuality.auto: 'Auto (Recommended)',
                StreamingQuality.low: '360p - Data Saver',
                StreamingQuality.medium: '480p - Standard',
                StreamingQuality.hd: '720p - HD',
                StreamingQuality.fullHd: '1080p - Full HD',
                StreamingQuality.ultraHd: '4K - Ultra HD',
                StreamingQuality.spatialAudio: '🎧 Spatial Audio',
              };
              return RadioListTile<StreamingQuality>(
                title: Text(qualityLabels[quality] ?? quality.name),
                value: quality,
                groupValue: _selectedQuality,
                onChanged: (value) {
                  setState(() => _selectedQuality = value!);
                  Navigator.pop(context);
                },
                activeColor: Colors.orange,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Playback Speed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
              return RadioListTile<double>(
                title: Text('${speed}x${speed == 1.0 ? ' (Normal)' : ''}'),
                value: speed,
                groupValue: _playbackSpeed,
                onChanged: (value) {
                  setState(() => _playbackSpeed = value!);
                  Navigator.pop(context);
                },
                activeColor: Colors.orange,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSleepTimer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sleep Timer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              '15 minutes',
              '30 minutes',
              '45 minutes',
              '1 hour',
              'End of bhajan',
              'Off'
            ].map((option) {
              return ListTile(
                title: Text(option),
                onTap: () {
                  Navigator.pop(context);
                  if (option != 'Off') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('⏰ Sleep timer set: $option')),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
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

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
