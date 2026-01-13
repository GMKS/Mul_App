// BUSINESS FEATURE 8: Business Analytics Dashboard
// Dashboard for business users to view their video analytics

import 'package:flutter/material.dart';
import '../../models/business_video_model.dart';
import '../../services/business_interaction_service.dart';

class BusinessAnalyticsScreen extends StatefulWidget {
  final String userId;
  final List<BusinessVideo> videos;

  const BusinessAnalyticsScreen({
    super.key,
    required this.userId,
    required this.videos,
  });

  @override
  State<BusinessAnalyticsScreen> createState() =>
      _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends State<BusinessAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';
  bool _isLoading = true;

  int _totalViews = 0;
  int _totalCalls = 0;
  int _totalWhatsapp = 0;
  List<VideoAnalytics> _videoAnalytics = [];
  List<DailyStats> _dailyStats = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    // Calculate totals from videos
    _totalViews = widget.videos.fold(0, (sum, v) => sum + v.views);
    _totalCalls = widget.videos.fold(0, (sum, v) => sum + v.callClicks);
    _totalWhatsapp = widget.videos.fold(0, (sum, v) => sum + v.whatsappClicks);

    // Generate analytics per video
    _videoAnalytics = widget.videos.map((video) {
      return VideoAnalytics(
        videoId: video.id,
        productName: video.productName,
        thumbnailUrl: video.thumbnailUrl,
        views: video.views,
        calls: video.callClicks,
        whatsappClicks: video.whatsappClicks,
        engagement: video.engagementScore,
        createdAt: video.createdAt,
      );
    }).toList();

    // Generate daily stats for the last 7 days
    _dailyStats = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return DailyStats(
        date: date,
        views: (_totalViews ~/ 10) + (index * 50),
        calls: (_totalCalls ~/ 10) + (index * 5),
        whatsappClicks: (_totalWhatsapp ~/ 10) + (index * 8),
      );
    });

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Business Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Videos'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildVideosTab(),
                _buildInsightsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          _buildPeriodSelector(),
          const SizedBox(height: 16),

          // Stats cards
          _buildStatsCards(),
          const SizedBox(height: 24),

          // Performance chart
          _buildPerformanceChart(),
          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['24h', '7d', '30d', 'All'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPeriod = period);
              _loadAnalytics();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Views',
            value: _formatNumber(_totalViews),
            icon: Icons.visibility,
            color: Colors.blue,
            change: '+12%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Calls',
            value: _formatNumber(_totalCalls),
            icon: Icons.call,
            color: Colors.green,
            change: '+8%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'WhatsApp',
            value: _formatNumber(_totalWhatsapp),
            icon: Icons.chat,
            color: Colors.teal,
            change: '+15%',
            isPositive: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildSimpleChart(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Views', Colors.blue),
              const SizedBox(width: 24),
              _buildLegendItem('Calls', Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem('WhatsApp', Colors.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    if (_dailyStats.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxViews =
        _dailyStats.map((s) => s.views).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _dailyStats.map((stats) {
        final height = maxViews > 0 ? (stats.views / maxViews) * 150 : 0.0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.blue, Colors.lightBlue],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDayShort(stats.date),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.rocket_launch,
                  label: 'Boost Video',
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Boost feature coming soon!')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.upload,
                  label: 'Upload Video',
                  color: Colors.blue,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Upload feature coming soon!')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.workspace_premium,
                  label: 'Upgrade Plan',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Upgrade feature coming soon!')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    if (_videoAnalytics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No videos yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to upload
              },
              icon: const Icon(Icons.add),
              label: const Text('Upload Your First Video'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videoAnalytics.length,
      itemBuilder: (context, index) {
        final analytics = _videoAnalytics[index];
        return _buildVideoAnalyticsCard(analytics);
      },
    );
  }

  Widget _buildVideoAnalyticsCard(VideoAnalytics analytics) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 100,
              color: Colors.grey.shade300,
              child: analytics.thumbnailUrl != null
                  ? Image.network(
                      analytics.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.play_circle,
                        color: Colors.grey.shade500,
                        size: 40,
                      ),
                    )
                  : Icon(
                      Icons.play_circle,
                      color: Colors.grey.shade500,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analytics.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Posted ${_formatTimeAgo(analytics.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildMiniStat(Icons.visibility, analytics.views),
                    const SizedBox(width: 16),
                    _buildMiniStat(Icons.call, analytics.calls),
                    const SizedBox(width: 16),
                    _buildMiniStat(Icons.chat, analytics.whatsappClicks),
                  ],
                ),
              ],
            ),
          ),

          // Action
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Handle actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'boost', child: Text('Boost')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          _formatNumber(value),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightCard(
            title: 'Top Performing Video',
            subtitle: _videoAnalytics.isNotEmpty
                ? _videoAnalytics.first.productName
                : 'No videos yet',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          _buildInsightCard(
            title: 'Best Time to Post',
            subtitle: '6 PM - 9 PM gets most engagement',
            icon: Icons.access_time,
            color: Colors.blue,
          ),
          _buildInsightCard(
            title: 'Audience Location',
            subtitle: 'Most viewers from your city',
            icon: Icons.location_on,
            color: Colors.orange,
          ),
          _buildInsightCard(
            title: 'Engagement Rate',
            subtitle:
                '${((_totalCalls + _totalWhatsapp) / (_totalViews == 0 ? 1 : _totalViews) * 100).toStringAsFixed(1)}% conversion',
            icon: Icons.analytics,
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          _buildTipsSection(),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Tips to Grow',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Post videos during evening hours'),
          _buildTipItem('Use trending hashtags in your area'),
          _buildTipItem('Boost your top performing videos'),
          _buildTipItem('Keep videos short and engaging'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            tip,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  String _formatDayShort(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

class VideoAnalytics {
  final String videoId;
  final String productName;
  final String? thumbnailUrl;
  final int views;
  final int calls;
  final int whatsappClicks;
  final double engagement;
  final DateTime createdAt;

  VideoAnalytics({
    required this.videoId,
    required this.productName,
    this.thumbnailUrl,
    required this.views,
    required this.calls,
    required this.whatsappClicks,
    required this.engagement,
    required this.createdAt,
  });
}

class DailyStats {
  final DateTime date;
  final int views;
  final int calls;
  final int whatsappClicks;

  DailyStats({
    required this.date,
    required this.views,
    required this.calls,
    required this.whatsappClicks,
  });
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
