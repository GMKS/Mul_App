/// Advanced Analytics Dashboard
/// Real-time insights with visual charts and trends

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _selectedPeriod = '7d';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Analytics Dashboard',
            style: TextStyle(color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            color: const Color(0xFF2a2a3e),
            onSelected: (value) => setState(() => _selectedPeriod = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 Days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 Days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 Days')),
              const PopupMenuItem(value: '1y', child: Text('Last Year')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            _buildUserGrowthChart(),
            const SizedBox(height: 24),
            _buildContentEngagementChart(),
            const SizedBox(height: 24),
            _buildCategoryDistribution(),
            const SizedBox(height: 24),
            _buildTopContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildMetricCard('Total Users', '1,234', '+12%',
            const Color(0xFF6366f1), Icons.people),
        _buildMetricCard('Active Content', '5,678', '+8%',
            const Color(0xFF10b981), Icons.video_library),
        _buildMetricCard('Engagement Rate', '78%', '+5%',
            const Color(0xFFf59e0b), Icons.trending_up),
        _buildMetricCard('Avg. Watch Time', '4.2m', '+15%',
            const Color(0xFFec4899), Icons.timer),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String change,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: Color(0xFF10b981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserGrowthChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Growth',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 4),
                      const FlSpot(2, 3.5),
                      const FlSpot(3, 5),
                      const FlSpot(4, 4.5),
                      const FlSpot(5, 6),
                      const FlSpot(6, 7),
                    ],
                    isCurved: true,
                    color: const Color(0xFF6366f1),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF6366f1).withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentEngagementChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Content Engagement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: 8, color: const Color(0xFF6366f1), width: 20)
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: 6, color: const Color(0xFF10b981), width: 20)
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: 7, color: const Color(0xFFf59e0b), width: 20)
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(
                        toY: 5, color: const Color(0xFFec4899), width: 20)
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDistribution() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 40,
                          color: const Color(0xFF6366f1),
                          title: '40%',
                          radius: 80,
                        ),
                        PieChartSectionData(
                          value: 30,
                          color: const Color(0xFF10b981),
                          title: '30%',
                          radius: 80,
                        ),
                        PieChartSectionData(
                          value: 30,
                          color: const Color(0xFFf59e0b),
                          title: '30%',
                          radius: 80,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem('Devotional', const Color(0xFF6366f1)),
                  const SizedBox(height: 8),
                  _buildLegendItem('Business', const Color(0xFF10b981)),
                  const SizedBox(height: 8),
                  _buildLegendItem('Events', const Color(0xFFf59e0b)),
                ],
              ),
            ],
          ),
        ],
      ),
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
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTopContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Content',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366f1).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF6366f1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Title ${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(index + 1) * 1000} views',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.trending_up, color: Color(0xFF10b981)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
