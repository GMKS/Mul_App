/// Local News Screen
/// Hyperlocal news feed with AI verification, community validation, and social features
/// Features: Short-form cards, trending, breaking news, filters, search

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/local_news_model.dart';
import '../../services/local_news_service.dart';
import 'news_detail_screen.dart';
import 'news_submission_screen.dart';

class LocalNewsScreen extends StatefulWidget {
  const LocalNewsScreen({super.key});

  @override
  State<LocalNewsScreen> createState() => _LocalNewsScreenState();
}

class _LocalNewsScreenState extends State<LocalNewsScreen>
    with SingleTickerProviderStateMixin {
  final LocalNewsService _newsService = LocalNewsService();
  late TabController _tabController;

  List<LocalNews> _allNews = [];
  List<LocalNews> _breakingNews = [];
  List<LocalNews> _trendingNews = [];
  bool _isLoading = true;

  NewsCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  // Mock location (would come from GPS)
  final double _userLat = 17.4326;
  final double _userLng = 78.4071;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);

    final all = await _newsService.getNews(
      latitude: _userLat,
      longitude: _userLng,
      radiusKm: 10.0,
    );

    final breaking = await _newsService.getBreakingNews(
      latitude: _userLat,
      longitude: _userLng,
    );

    final trending = await _newsService.getTrendingNews(
      latitude: _userLat,
      longitude: _userLng,
    );

    if (mounted) {
      setState(() {
        _allNews = all;
        _breakingNews = breaking;
        _trendingNews = trending;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildBreakingNewsBar(),
            _buildCategoryFilters(),
            _buildTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTabContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSubmitNews,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'Report News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Local News',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Jubilee Hills, Hyderabad',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search local news...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {},
            tooltip: 'Voice search',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildBreakingNewsBar() {
    if (_breakingNews.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _breakingNews.length,
        itemBuilder: (context, index) {
          final news = _breakingNews[index];
          return GestureDetector(
            onTap: () => _openNewsDetail(news),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[600]!, Colors.red[400]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.campaign,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCategoryFilters() {
    final categories = [
      {'icon': Icons.whatshot, 'label': 'All', 'category': null},
      {
        'icon': Icons.directions_car,
        'label': 'Traffic',
        'category': NewsCategory.traffic
      },
      {
        'icon': Icons.warning,
        'label': 'Accident',
        'category': NewsCategory.accident
      },
      {
        'icon': Icons.cloud,
        'label': 'Weather',
        'category': NewsCategory.weather
      },
      {'icon': Icons.event, 'label': 'Events', 'category': NewsCategory.event},
      {
        'icon': Icons.group,
        'label': 'Community',
        'category': NewsCategory.community
      },
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['category'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['category'] as NewsCategory?;
              });
              _filterByCategory(_selectedCategory);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.orange,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.orange,
      tabs: const [
        Tab(text: 'For You'),
        Tab(text: 'Trending'),
        Tab(text: 'Recent'),
        Tab(text: 'Stories'),
      ],
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNewsList(_allNews),
        _buildNewsList(_trendingNews),
        _buildNewsList(_allNews),
        _buildStoriesView(),
      ],
    );
  }

  Widget _buildNewsList(List<LocalNews> newsList) {
    if (newsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No news available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to report!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(newsList[index]);
        },
      ),
    );
  }

  Widget _buildNewsCard(LocalNews news) {
    final hasImage = news.imageUrls.isNotEmpty;

    return GestureDetector(
      onTap: () => _openNewsDetail(news),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: news.reporterAvatar != null
                        ? NetworkImage(news.reporterAvatar!)
                        : null,
                    child: news.reporterAvatar == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                news.reporterName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (news.isVerifiedReporter) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.blue,
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 10,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                news.locationName ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            Text(
                              ' • ${_timeAgo(news.createdAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildVerificationBadge(news),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'flag',
                        child: ListTile(
                          leading: Icon(Icons.flag),
                          title: Text('Report'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'hide',
                        child: ListTile(
                          leading: Icon(Icons.visibility_off),
                          title: Text('Hide'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleNewsOption(value, news),
                  ),
                ],
              ),
            ),

            // Image (if available)
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  news.imageUrls.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Row(
                    children: [
                      _buildCategoryChip(news.category),
                      if (news.isBreaking) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BREAKING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // TL;DR or Content
                  Text(
                    news.tldr ?? news.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _buildActionButton(
                    icon: _newsService.hasUpvoted(news.id)
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    label: '${news.upvotes}',
                    color:
                        _newsService.hasUpvoted(news.id) ? Colors.orange : null,
                    onTap: () => _upvoteNews(news),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    label: '${news.commentsCount}',
                    onTap: () => _openNewsDetail(news),
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: '${news.sharesCount}',
                    onTap: () => _shareNews(news),
                  ),
                  const Spacer(),
                  _buildActionButton(
                    icon: Icons.remove_red_eye_outlined,
                    label: _formatCount(news.viewCount),
                    onTap: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(LocalNews news) {
    if (news.adminVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 10, color: Colors.white),
            SizedBox(width: 2),
            Text(
              'Verified',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (news.communityVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (news.aiVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'AI Verified',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCategoryChip(NewsCategory category) {
    final categoryIcons = {
      NewsCategory.traffic: Icons.directions_car,
      NewsCategory.accident: Icons.warning,
      NewsCategory.weather: Icons.cloud,
      NewsCategory.event: Icons.event,
      NewsCategory.health: Icons.favorite,
      NewsCategory.community: Icons.group,
      NewsCategory.development: Icons.construction,
      NewsCategory.education: Icons.school,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcons[category] ?? Icons.article,
            size: 12,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            category.name.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? Colors.grey[700]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color ?? Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'News Stories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '24-hour news stories coming soon!',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  void _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    final results = await _newsService.searchNews(
      query,
      latitude: _userLat,
      longitude: _userLng,
    );

    setState(() => _allNews = results);
  }

  void _filterByCategory(NewsCategory? category) async {
    setState(() => _isLoading = true);

    final news = await _newsService.getNews(
      latitude: _userLat,
      longitude: _userLng,
      category: category,
    );

    setState(() {
      _allNews = news;
      _isLoading = false;
    });
  }

  void _upvoteNews(LocalNews news) async {
    if (_newsService.hasUpvoted(news.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already upvoted')),
      );
      return;
    }

    await _newsService.upvoteNews(news.id);
    _loadNews();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('👍 Upvoted!')),
    );
  }

  void _shareNews(LocalNews news) {
    Share.share(
      '📰 ${news.title}\n\n'
      '${news.tldr ?? news.content}\n\n'
      '📍 ${news.locationName}\n'
      'Read more on My City App',
    );
  }

  void _openNewsDetail(LocalNews news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(news: news),
      ),
    );
  }

  void _openSubmitNews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewsSubmissionScreen(),
      ),
    );
  }

  void _handleNewsOption(String option, LocalNews news) async {
    switch (option) {
      case 'flag':
        await _newsService.flagNews(news.id, 'User reported');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('News reported')),
        );
        break;
      case 'hide':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('News hidden')),
        );
        break;
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('News Preferences'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Change Location'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Reporter Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
