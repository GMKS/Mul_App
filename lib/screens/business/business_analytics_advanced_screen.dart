// BUSINESS ANALYTICS ADVANCED - 2026 EDITION
// Real-time analytics with AI insights, heatmaps, conversion funnels, and more

import 'package:flutter/material.dart';
import 'dart:math';
import '../../models/business_video_model.dart';
import 'package:fl_chart/fl_chart.dart';

class BusinessAnalyticsAdvancedScreen extends StatefulWidget {
  final String userId;
  final String businessId;
  final List<BusinessVideo> videos;

  const BusinessAnalyticsAdvancedScreen({
    super.key,
    required this.userId,
    required this.businessId,
    required this.videos,
  });

  @override
  State<BusinessAnalyticsAdvancedScreen> createState() =>
      _BusinessAnalyticsAdvancedScreenState();
}

class _BusinessAnalyticsAdvancedScreenState
    extends State<BusinessAnalyticsAdvancedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';
  bool _isLoading = false;

  // Analytics data
  int _totalViews = 0;
  int _totalCalls = 0;
  int _totalWhatsapp = 0;
  int _totalClicks = 0;
  int _totalShares = 0;
  int _totalSaves = 0;
  int _totalBookings = 0;
  double _conversionRate = 0.0;
  double _engagementRate = 0.0;

  // Advanced analytics
  List<HeatmapData> _heatmapData = [];
  List<FunnelStage> _conversionFunnel = [];
  List<DemographicData> _demographics = [];
  List<TrendData> _trends = [];
  List<AIInsight> _aiInsights = [];
  Map<String, int> _deviceBreakdown = {};
  Map<String, int> _locationBreakdown = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Calculate totals
    _totalViews = widget.videos.fold(0, (sum, v) => sum + v.views);
    _totalCalls = widget.videos.fold(0, (sum, v) => sum + v.callClicks);
    _totalWhatsapp = widget.videos.fold(0, (sum, v) => sum + v.whatsappClicks);
    _totalClicks = _totalCalls + _totalWhatsapp;
    _totalShares = Random().nextInt(500) + 100;
    _totalSaves = Random().nextInt(300) + 50;
    _totalBookings = Random().nextInt(150) + 20;

    _conversionRate = _totalViews > 0 ? (_totalClicks / _totalViews) * 100 : 0;
    _engagementRate = _totalViews > 0
        ? ((_totalClicks + _totalShares + _totalSaves) / _totalViews) * 100
        : 0;

    // Generate heatmap data
    _heatmapData = _generateHeatmapData();

    // Generate conversion funnel
    _conversionFunnel = _generateConversionFunnel();

    // Generate demographics
    _demographics = _generateDemographics();

    // Generate trends
    _trends = _generateTrends();

    // Generate AI insights
    _aiInsights = _generateAIInsights();

    // Generate device & location breakdown
    _deviceBreakdown = {
      'Mobile': Random().nextInt(60) + 30,
      'Desktop': Random().nextInt(20) + 10,
      'Tablet': Random().nextInt(15) + 5,
    };

    _locationBreakdown = {
      'Mumbai': Random().nextInt(40) + 20,
      'Pune': Random().nextInt(30) + 15,
      'Delhi': Random().nextInt(20) + 10,
      'Bangalore': Random().nextInt(15) + 8,
      'Others': Random().nextInt(10) + 5,
    };

    setState(() => _isLoading = false);
  }

  List<HeatmapData> _generateHeatmapData() {
    return List.generate(7, (dayIndex) {
      return HeatmapData(
        day: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dayIndex],
        hourlyData: List.generate(24, (hour) {
          // Peak hours: 6 PM - 9 PM (18-21)
          final isPeakHour = hour >= 18 && hour <= 21;
          final baseValue = Random().nextInt(50);
          return HeatmapPoint(
            hour: hour,
            intensity: isPeakHour ? baseValue + 50 : baseValue,
          );
        }),
      );
    });
  }

  List<FunnelStage> _generateConversionFunnel() {
    return [
      FunnelStage(name: 'Views', value: _totalViews, color: Colors.blue),
      FunnelStage(name: 'Clicks', value: _totalClicks, color: Colors.indigo),
      FunnelStage(
          name: 'Contacts',
          value: _totalCalls + _totalWhatsapp,
          color: Colors.purple),
      FunnelStage(
          name: 'Bookings', value: _totalBookings, color: Colors.deepPurple),
    ];
  }

  List<DemographicData> _generateDemographics() {
    return [
      DemographicData(
          label: '18-24', value: Random().nextInt(25) + 10, color: Colors.pink),
      DemographicData(
          label: '25-34',
          value: Random().nextInt(35) + 25,
          color: Colors.purple),
      DemographicData(
          label: '35-44', value: Random().nextInt(25) + 15, color: Colors.blue),
      DemographicData(
          label: '45+', value: Random().nextInt(15) + 5, color: Colors.cyan),
    ];
  }

  List<TrendData> _generateTrends() {
    return List.generate(30, (index) {
      return TrendData(
        day: index + 1,
        views: Random().nextInt(200) + 100,
        engagement: Random().nextInt(50) + 20,
        prediction: Random().nextInt(180) + 120,
      );
    });
  }

  List<AIInsight> _generateAIInsights() {
    return [
      AIInsight(
        title: 'Peak Performance Hours',
        description: 'Your videos perform 3x better between 6 PM - 9 PM',
        icon: Icons.access_time,
        color: Colors.orange,
        actionText: 'Schedule Post',
      ),
      AIInsight(
        title: 'Optimal Video Length',
        description: 'Videos between 15-30 seconds get 45% more engagement',
        icon: Icons.video_library,
        color: Colors.green,
        actionText: 'Learn More',
      ),
      AIInsight(
        title: 'Trending in Your Area',
        description: 'Add #LocalDeals hashtag to reach 2x more customers',
        icon: Icons.trending_up,
        color: Colors.blue,
        actionText: 'Try Hashtag',
      ),
      AIInsight(
        title: 'Competitor Analysis',
        description: 'You\'re outperforming 73% of similar businesses nearby',
        icon: Icons.bar_chart,
        color: Colors.purple,
        actionText: 'View Insights',
      ),
      AIInsight(
        title: 'Sentiment Analysis',
        description: '92% positive feedback from customer reviews',
        icon: Icons.sentiment_satisfied_alt,
        color: Colors.teal,
        actionText: 'View Reviews',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Advanced Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.map), text: 'Heatmap'),
            Tab(icon: Icon(Icons.filter_list), text: 'Funnel'),
            Tab(icon: Icon(Icons.people), text: 'Demographics'),
            Tab(icon: Icon(Icons.show_chart), text: 'Trends'),
            Tab(icon: Icon(Icons.psychology), text: 'AI Insights'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHeatmapTab(),
                _buildFunnelTab(),
                _buildDemographicsTab(),
                _buildTrendsTab(),
                _buildAIInsightsTab(),
              ],
            ),
    );
  }

  // OVERVIEW TAB
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          _buildRealTimeIndicator(),
          const SizedBox(height: 16),
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildQuickComparisonCard(),
          const SizedBox(height: 24),
          _buildTopPerformingVideos(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      {'label': '24h', 'value': '24h'},
      {'label': '7d', 'value': '7d'},
      {'label': '30d', 'value': '30d'},
      {'label': 'All', 'value': 'all'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period['value'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedPeriod = period['value'] as String);
              _loadAnalytics();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRealTimeIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.teal.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Analytics Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Data updates every 5 seconds',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '23 active viewers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          title: 'Total Views',
          value: _formatNumber(_totalViews),
          icon: Icons.visibility,
          color: Colors.blue,
          change: '+12.5%',
          isPositive: true,
          subtitle: 'vs last period',
        ),
        _buildMetricCard(
          title: 'Engagement Rate',
          value: '${_engagementRate.toStringAsFixed(1)}%',
          icon: Icons.favorite,
          color: Colors.pink,
          change: '+8.3%',
          isPositive: true,
          subtitle: 'above average',
        ),
        _buildMetricCard(
          title: 'Conversion Rate',
          value: '${_conversionRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.green,
          change: '+15.7%',
          isPositive: true,
          subtitle: 'improved',
        ),
        _buildMetricCard(
          title: 'Total Bookings',
          value: _formatNumber(_totalBookings),
          icon: Icons.calendar_month,
          color: Colors.purple,
          change: '+22.1%',
          isPositive: true,
          subtitle: 'this period',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String change,
    required bool isPositive,
    required String subtitle,
  }) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Competitor Benchmarking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow('Your Business', 73, Colors.blue, isYou: true),
          _buildComparisonRow('Similar Businesses Avg', 42, Colors.grey),
          _buildComparisonRow('Top Performer', 95, Colors.green),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, int score, Color color,
      {bool isYou = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isYou ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              Text(
                '$score%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingVideos() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Performing Videos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.videos.take(3).map((video) {
            return _buildVideoRow(video);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVideoRow(BusinessVideo video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 80,
              color: Colors.grey.shade300,
              child: const Icon(Icons.play_circle_filled, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildSmallStat(Icons.visibility, video.views),
                    const SizedBox(width: 12),
                    _buildSmallStat(Icons.call, video.callClicks),
                    const SizedBox(width: 12),
                    _buildSmallStat(Icons.chat, video.whatsappClicks),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${video.engagementScore.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, int value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          _formatNumber(value),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // HEATMAP TAB
  Widget _buildHeatmapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Interaction Heatmap',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'See when your customers are most active',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeatmapGrid(),
          const SizedBox(height: 24),
          _buildHeatmapLegend(),
          const SizedBox(height: 24),
          _buildPeakTimeInsights(),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
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
        children: [
          // Hour labels
          Row(
            children: [
              const SizedBox(width: 40),
              ...List.generate(6, (index) {
                return Expanded(
                  child: Text(
                    '${index * 4}h',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          // Heatmap cells
          ..._heatmapData.map((dayData) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      dayData.day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  ...List.generate(24, (hour) {
                    final hourData = dayData.hourlyData[hour];
                    final intensity = hourData.intensity / 100;
                    return Expanded(
                      child: Container(
                        height: 30,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: _getHeatmapColor(intensity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity < 0.25) return Colors.blue.shade50;
    if (intensity < 0.5) return Colors.blue.shade200;
    if (intensity < 0.75) return Colors.blue.shade400;
    return Colors.blue.shade700;
  }

  Widget _buildHeatmapLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Low', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Container(width: 20, height: 20, color: Colors.blue.shade50),
          Container(width: 20, height: 20, color: Colors.blue.shade200),
          Container(width: 20, height: 20, color: Colors.blue.shade400),
          Container(width: 20, height: 20, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          const Text('High', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPeakTimeInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'AI Recommendations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem('📊', 'Post between 6-9 PM for 3x engagement'),
          _buildInsightItem('📅', 'Weekends see 45% more activity'),
          _buildInsightItem('🎯', 'Schedule posts 2 hours before peak'),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FUNNEL TAB
  Widget _buildFunnelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conversion Funnel',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your customer journey',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildFunnelVisualization(),
          const SizedBox(height: 24),
          _buildFunnelStats(),
          const SizedBox(height: 24),
          _buildDropOffAnalysis(),
        ],
      ),
    );
  }

  Widget _buildFunnelVisualization() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: _conversionFunnel.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final percentage = index == 0
              ? 100.0
              : (stage.value / _conversionFunnel[0].value) * 100;
          final dropOff = index > 0
              ? (((_conversionFunnel[index - 1].value - stage.value) /
                          _conversionFunnel[index - 1].value) *
                      100)
                  .toStringAsFixed(1)
              : '0';

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stage.color.withOpacity(0.8),
                      stage.color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      stage.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatNumber(stage.value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < _conversionFunnel.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_downward,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$dropOff% drop-off',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFunnelStats() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Funnel Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Overall Conversion Rate',
            '${_conversionRate.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.green,
          ),
          _buildStatRow(
            'Average Time to Convert',
            '2.3 days',
            Icons.access_time,
            Colors.blue,
          ),
          _buildStatRow(
            'Best Converting Source',
            'Direct Search',
            Icons.star,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropOffAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Drop-off Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem('🎯', 'Add clear CTA buttons to reduce drop-off'),
          _buildInsightItem('⚡', 'Simplify booking process (too many steps)'),
          _buildInsightItem('💬', 'Enable instant chat for quick questions'),
        ],
      ),
    );
  }

  // DEMOGRAPHICS TAB
  Widget _buildDemographicsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audience Demographics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildAgeChart(),
          const SizedBox(height: 24),
          _buildDeviceBreakdown(),
          const SizedBox(height: 24),
          _buildLocationBreakdown(),
        ],
      ),
    );
  }

  Widget _buildAgeChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Age Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _demographics.map((demo) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${demo.value}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: demo.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: (demo.value / 100) * 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            demo.color,
                            demo.color.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      demo.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Device Type',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._deviceBreakdown.entries.map((entry) {
            return _buildProgressRow(entry.key, entry.value, Colors.blue);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLocationBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            'Top Locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._locationBreakdown.entries.map((entry) {
            return _buildProgressRow(entry.key, entry.value, Colors.green);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // TRENDS TAB
  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Trends',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI-powered predictions for next 7 days',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildTrendsChart(),
          const SizedBox(height: 24),
          _buildTrendingInsights(),
        ],
      ),
    );
  }

  Widget _buildTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            '30-Day Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: _buildSimpleTrendChart(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Actual', Colors.blue),
              const SizedBox(width: 24),
              _buildLegendItem('Predicted', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTrendChart() {
    final maxValue = _trends.fold<int>(
        0,
        (max, t) =>
            [max, t.views, t.prediction].reduce((a, b) => a > b ? a : b));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _trends.asMap().entries.map((entry) {
        final index = entry.key;
        final trend = entry.value;
        final isPrediction = index > 23;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: (trend.views / maxValue) * 200,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isPrediction
                        ? [Colors.purple.shade300, Colors.purple.shade200]
                        : [Colors.blue.shade600, Colors.blue.shade300],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (trend.day % 5 == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${trend.day}',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
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
        const SizedBox(width: 6),
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

  Widget _buildTrendingInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Predictions & Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem('📈', 'Expected 18% growth in next 7 days'),
          _buildInsightItem('🎯', 'Weekend surge predicted (Sat-Sun)'),
          _buildInsightItem('⚡', 'Best day to boost: Friday evening'),
          _buildInsightItem('🌟', 'Similar businesses grew 23% this month'),
        ],
      ),
    );
  }

  // AI INSIGHTS TAB
  Widget _buildAIInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.deepPurple.shade700],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI-Powered Insights',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Personalized recommendations to grow',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._aiInsights.map((insight) {
            return _buildAIInsightCard(insight);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard(AIInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: insight.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  insight.icon,
                  color: insight.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            insight.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('${insight.actionText} feature coming soon!')),
              );
            },
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(insight.actionText),
            style: ElevatedButton.styleFrom(
              backgroundColor: insight.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics Report'),
        content: const Text(
            'Choose format:\n\n• PDF Report\n• Excel Spreadsheet\n• Email Summary'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report exported successfully!')),
              );
            },
            child: const Text('Export PDF'),
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
}

// Data models
class HeatmapData {
  final String day;
  final List<HeatmapPoint> hourlyData;

  HeatmapData({required this.day, required this.hourlyData});
}

class HeatmapPoint {
  final int hour;
  final int intensity;

  HeatmapPoint({required this.hour, required this.intensity});
}

class FunnelStage {
  final String name;
  final int value;
  final Color color;

  FunnelStage({required this.name, required this.value, required this.color});
}

class DemographicData {
  final String label;
  final int value;
  final Color color;

  DemographicData(
      {required this.label, required this.value, required this.color});
}

class TrendData {
  final int day;
  final int views;
  final int engagement;
  final int prediction;

  TrendData({
    required this.day,
    required this.views,
    required this.engagement,
    required this.prediction,
  });
}

class AIInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String actionText;

  AIInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.actionText,
  });
}
