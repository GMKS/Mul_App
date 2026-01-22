/// Moderation Analytics Dashboard Screen
/// Comprehensive metrics and insights for admins

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'
    show
        LineChart,
        LineChartData,
        FlSpot,
        LineTouchData,
        LineBarsData,
        LineChartBarData,
        FlGridData,
        FlBorderData,
        FlTitlesData,
        AxisTitles,
        SideTitles,
        LineChartBarData;

class ModerationAnalyticsScreen extends StatefulWidget {
  const ModerationAnalyticsScreen({super.key});

  @override
  State<ModerationAnalyticsScreen> createState() =>
      _ModerationAnalyticsScreenState();
}

class _ModerationAnalyticsScreenState extends State<ModerationAnalyticsScreen> {
  String _selectedPeriod = '7d';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Color(0xFF16213e),
        title: Text('Moderation Analytics'),
        actions: [
          // Period selector
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: '24h', child: Text('Last 24 Hours')),
              PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
              PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
              PopupMenuItem(value: 'all', child: Text('All Time')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Overview Cards
                _buildOverviewCards(),
                SizedBox(height: 24),

                // Reports Trend Chart
                _buildTrendChart(),
                SizedBox(height: 24),

                // Category Breakdown
                _buildCategoryBreakdown(),
                SizedBox(height: 24),

                // Response Time Metrics
                _buildResponseTimeMetrics(),
                SizedBox(height: 24),

                // Moderator Performance
                _buildModeratorPerformance(),
                SizedBox(height: 24),

                // Community Health Score
                _buildHealthScore(),
              ],
            ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Reports',
          '1,247',
          '+12% vs last week',
          Icons.report,
          Colors.blue,
        ),
        _buildStatCard(
          'Resolved',
          '1,089',
          '87.3% resolution rate',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Pending',
          '123',
          'Avg 15min response',
          Icons.pending,
          Colors.orange,
        ),
        _buildStatCard(
          'False Reports',
          '35',
          '2.8% false positive',
          Icons.cancel,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle.split(' ')[0],
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports Trend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Daily reports over the last 7 days',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _buildSimpleLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLineChart() {
    // Simple visualization without fl_chart dependency
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBar('Mon', 45, 80),
        _buildBar('Tue', 65, 80),
        _buildBar('Wed', 52, 80),
        _buildBar('Thu', 78, 80),
        _buildBar('Fri', 85, 80),
        _buildBar('Sat', 48, 80),
        _buildBar('Sun', 62, 80),
      ],
    );
  }

  Widget _buildBar(String label, double value, double maxValue) {
    final height = (value / maxValue) * 150;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.blue, Colors.blue.withOpacity(0.5)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    final categories = [
      {'name': 'Spam', 'count': 342, 'percent': 27.4, 'color': Colors.orange},
      {
        'name': 'Inappropriate',
        'count': 298,
        'percent': 23.9,
        'color': Colors.red
      },
      {
        'name': 'Misinformation',
        'count': 189,
        'percent': 15.2,
        'color': Colors.purple
      },
      {
        'name': 'Harassment',
        'count': 156,
        'percent': 12.5,
        'color': Colors.pink
      },
      {'name': 'Other', 'count': 262, 'percent': 21.0, 'color': Colors.grey},
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...categories.map((cat) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: cat['color'] as Color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cat['name'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${cat['count']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${cat['percent']}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (cat['percent'] as double) / 100,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(cat['color'] as Color),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildResponseTimeMetrics() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeMetric(
                  'Average',
                  '15m',
                  Icons.av_timer,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTimeMetric(
                  'Median',
                  '8m',
                  Icons.timer,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildTimeMetric(
                  'P95',
                  '45m',
                  Icons.timer_off,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF3a3a4e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeratorPerformance() {
    final moderators = [
      {'name': 'Admin Kumar', 'resolved': 245, 'accuracy': 96.5},
      {'name': 'Moderator Priya', 'resolved': 198, 'accuracy': 94.2},
      {'name': 'Moderator Raj', 'resolved': 176, 'accuracy': 92.8},
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Moderators',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...moderators.map((mod) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        mod['name'].toString().substring(0, 1),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mod['name'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${mod['resolved']} resolved',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${mod['accuracy']}%',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHealthScore() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Community Health Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '87',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Excellent',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Low report rate • High resolution • Active community',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
