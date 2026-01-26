/// Temple Live Screen
/// Main screen showing live temple streams and temple directory

import 'package:flutter/material.dart';
import '../../models/temple_live_model.dart';
import '../../services/temple_live_service.dart';
import 'temple_stream_screen.dart';
import 'temple_detail_screen.dart';

class TempleLiveScreen extends StatefulWidget {
  const TempleLiveScreen({super.key});

  @override
  State<TempleLiveScreen> createState() => _TempleLiveScreenState();
}

class _TempleLiveScreenState extends State<TempleLiveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TempleLiveService _service = TempleLiveService();

  List<TempleLive> _liveTemples = [];
  List<TempleLive> _allTemples = [];
  bool _isLoading = true;
  String? _selectedReligion;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _religions = [
    {'id': null, 'name': 'All', 'icon': '🙏'},
    {'id': 'hinduism', 'name': 'Hindu', 'icon': '🛕'},
    {'id': 'sikhism', 'name': 'Sikh', 'icon': '☬'},
    {'id': 'islam', 'name': 'Islam', 'icon': '🕌'},
    {'id': 'christianity', 'name': 'Christian', 'icon': '⛪'},
    {'id': 'buddhism', 'name': 'Buddhist', 'icon': '☸️'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final liveTemples = await _service.getLiveTemples();
      final allTemples =
          await _service.getAllTemples(religion: _selectedReligion);

      if (mounted) {
        setState(() {
          _liveTemples = liveTemples;
          _allTemples = allTemples;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading temples: $e')),
        );
      }
    }
  }

  void _onReligionSelected(String? religionId) {
    setState(() => _selectedReligion = religionId);
    _loadData();
  }

  List<TempleLive> _getFilteredTemples(List<TempleLive> temples) {
    if (_searchQuery.isEmpty) return temples;

    final query = _searchQuery.toLowerCase();
    return temples
        .where((t) =>
            t.name.toLowerCase().contains(query) ||
            t.city.toLowerCase().contains(query) ||
            (t.deity?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🛕 ', style: TextStyle(fontSize: 24)),
            Text('Temple Live'),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Now (${_liveTemples.length})'),
                ],
              ),
            ),
            const Tab(text: 'All Temples'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _showSubscribedTemples,
            tooltip: 'Subscribed Temples',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFF6B00),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search temples, deity, city...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Religion Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _religions.map((religion) {
                  final isSelected = _selectedReligion == religion['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(religion['icon'],
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(religion['name']),
                        ],
                      ),
                      onSelected: (_) => _onReligionSelected(religion['id']),
                      selectedColor: const Color(0xFFFF6B00).withOpacity(0.2),
                      checkmarkColor: const Color(0xFFFF6B00),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLiveTab(),
                      _buildAllTemplesTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab() {
    final filteredLive = _getFilteredTemples(_liveTemples);

    if (filteredLive.isEmpty) {
      return _buildEmptyState(
        icon: Icons.live_tv_outlined,
        title: 'No Live Streams',
        subtitle: 'Check back later for live temple darshans',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFFF6B00),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredLive.length,
        itemBuilder: (context, index) {
          return _buildLiveTempleCard(filteredLive[index]);
        },
      ),
    );
  }

  Widget _buildAllTemplesTab() {
    final filteredAll = _getFilteredTemples(_allTemples);

    if (filteredAll.isEmpty) {
      return _buildEmptyState(
        icon: Icons.temple_hindu_outlined,
        title: 'No Temples Found',
        subtitle: 'Try a different search or filter',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFFFF6B00),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredAll.length,
        itemBuilder: (context, index) {
          return _buildTempleCard(filteredAll[index]);
        },
      ),
    );
  }

  Widget _buildLiveTempleCard(TempleLive temple) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openStream(temple),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Live Badge
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    image: temple.thumbnailUrl != null
                        ? DecorationImage(
                            image: NetworkImage(temple.thumbnailUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: temple.thumbnailUrl == null
                      ? Center(
                          child: Text(
                            temple.religionIcon,
                            style: const TextStyle(fontSize: 60),
                          ),
                        )
                      : null,
                ),
                // Live Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Viewer Count
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          temple.formattedViewers,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                // Play Button Overlay
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Temple Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(temple.religionIcon,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          temple.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${temple.city}, ${temple.state ?? ''}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                      if (temple.deity != null) ...[
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          temple.deity!,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Live for ${temple.liveDuration}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                      const Spacer(),
                      _buildSubscribeButton(temple),
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

  Widget _buildTempleCard(TempleLive temple) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openTempleDetail(temple),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Temple Image/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  image: temple.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(temple.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: temple.thumbnailUrl == null
                    ? Center(
                        child: Text(temple.religionIcon,
                            style: const TextStyle(fontSize: 36)),
                      )
                    : temple.isLive
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: const Center(
                              child: Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 36),
                            ),
                          )
                        : null,
              ),
              const SizedBox(width: 12),
              // Temple Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            temple.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (temple.isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${temple.city}, ${temple.state ?? ''}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (temple.deity != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        temple.deity!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            temple.timings ?? 'Timings not available',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _buildSubscribeButton(temple, compact: true),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(TempleLive temple, {bool compact = false}) {
    final isSubscribed = _service.isSubscribedToTemple(temple.id);

    if (compact) {
      return GestureDetector(
        onTap: () => _toggleSubscription(temple),
        child: Icon(
          isSubscribed ? Icons.notifications_active : Icons.notifications_none,
          color: isSubscribed ? const Color(0xFFFF6B00) : Colors.grey,
          size: 24,
        ),
      );
    }

    return TextButton.icon(
      onPressed: () => _toggleSubscription(temple),
      icon: Icon(
        isSubscribed ? Icons.notifications_active : Icons.notifications_none,
        size: 18,
      ),
      label: Text(isSubscribed ? 'Subscribed' : 'Subscribe'),
      style: TextButton.styleFrom(
        foregroundColor:
            isSubscribed ? const Color(0xFFFF6B00) : Colors.grey[600],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSubscription(TempleLive temple) async {
    final isCurrentlySubscribed = _service.isSubscribedToTemple(temple.id);

    if (isCurrentlySubscribed) {
      await _service.unsubscribeFromTemple(temple.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unsubscribed from ${temple.name}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _service
                  .subscribeToTemple(temple.id)
                  .then((_) => setState(() {})),
            ),
          ),
        );
      }
    } else {
      await _service.subscribeToTemple(temple.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 Subscribed to ${temple.name}'),
            backgroundColor: const Color(0xFFFF6B00),
          ),
        );
      }
    }

    setState(() {});
  }

  void _openStream(TempleLive temple) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TempleStreamScreen(temple: temple),
      ),
    );
  }

  void _openTempleDetail(TempleLive temple) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TempleDetailScreen(temple: temple),
      ),
    );
  }

  void _showSubscribedTemples() async {
    final subscribed = await _service.getSubscribedTemples();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active,
                      color: Color(0xFFFF6B00)),
                  const SizedBox(width: 12),
                  const Text(
                    'Subscribed Temples',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${subscribed.length} temples',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: subscribed.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off,
                              size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No subscriptions yet',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Subscribe to temples to get alerts',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: subscribed.length,
                      itemBuilder: (context, index) {
                        return _buildTempleCard(subscribed[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
