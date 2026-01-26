import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/user_model.dart';
import 'admin_content_management_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_moderation_screen.dart';
import 'admin_roles_screen.dart';
import 'admin_scheduled_content_screen.dart';
import 'admin_notification_manager_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_audit_trail_screen.dart';
import '../business/business_approval_screen_enhanced.dart';
import '../../services/business_service_supabase.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserProfile currentUser;

  const AdminDashboardScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool get _isAdmin => widget.currentUser.isAdmin;

  // Add state variables for statistics
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _totalUsers = 0;
  int _flaggedContent = 0;
  int _totalContent = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    if (_isAdmin) {
      _loadStatistics();
    }
  }

  // Add method to load statistics
  Future<void> _loadStatistics() async {
    setState(() => _isLoadingStats = true);

    try {
      final businessService = BusinessServiceSupabase();

      // Load pending businesses
      final pending = await businessService.getPendingBusinesses();

      // Load approved businesses
      final approved = await businessService.getApprovedBusinesses();

      setState(() {
        _pendingCount = pending.length;
        _approvedCount = approved.length;
        _totalContent = pending.length + approved.length;
        _totalUsers = 1234; // Mock data - replace with actual user count
        _flaggedContent = 8; // Mock data - replace with actual flagged count
        _isLoadingStats = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() {
        _pendingCount = 0;
        _approvedCount = 0;
        _totalContent = 0;
        _totalUsers = 0;
        _flaggedContent = 0;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF0f0f1e),
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: const Color(0xFF16213e),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Admin Access Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('You do not have permission to access this area.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: _buildAppBar(),
      body: _isLoadingStats
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366f1),
              ),
            )
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Admin Dashboard'),
      backgroundColor: const Color(0xFF16213e),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadStatistics,
          tooltip: 'Refresh Statistics',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminNotificationManagerScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadStatistics,
      color: const Color(0xFF6366f1),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildActionCardsGrid(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Stats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pending Approvals',
                '$_pendingCount',
                Icons.pending_actions,
                const Color(0xFFf59e0b),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Users',
                '$_totalUsers',
                Icons.people,
                const Color(0xFF10b981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Flagged Content',
                '$_flaggedContent',
                Icons.flag,
                const Color(0xFFef4444),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Content',
                '$_totalContent',
                Icons.video_library,
                const Color(0xFF6366f1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCardsGrid() {
    final actions = [
      {
        'title': 'Business Approvals',
        'subtitle': 'Review submissions',
        'icon': Icons.business_center,
        'color': const Color(0xFF06b6d4),
        'badge': _pendingCount > 0,
        'badgeCount': _pendingCount,
        'onTap': () => _navigateTo(const BusinessApprovalScreenEnhanced()),
      },
      {
        'title': 'Content Management',
        'subtitle': 'Manage videos & posts',
        'icon': Icons.video_library,
        'color': const Color(0xFF8b5cf6),
        'badge': false,
        'badgeCount': 0,
        'onTap': () => _navigateTo(const AdminContentManagementScreen()),
      },
      {
        'title': 'User Moderation',
        'subtitle': 'Review reports',
        'icon': Icons.shield,
        'color': const Color(0xFFef4444),
        'badge': _flaggedContent > 0,
        'badgeCount': _flaggedContent,
        'onTap': () => _navigateTo(const AdminModerationScreen()),
      },
      {
        'title': 'Analytics',
        'subtitle': 'View insights',
        'icon': Icons.analytics,
        'color': const Color(0xFF10b981),
        'badge': false,
        'badgeCount': 0,
        'onTap': () => _navigateTo(const AdminAnalyticsScreen()),
      },
      {
        'title': 'Role Management',
        'subtitle': 'Manage permissions',
        'icon': Icons.admin_panel_settings,
        'color': const Color(0xFFf59e0b),
        'badge': false,
        'badgeCount': 0,
        'onTap': () => _navigateTo(const AdminRolesScreen()),
      },
      {
        'title': 'Notifications',
        'subtitle': 'Send announcements',
        'icon': Icons.notifications_active,
        'color': const Color(0xFFec4899),
        'badge': false,
        'badgeCount': 0,
        'onTap': () => _navigateTo(const AdminNotificationManagerScreen()),
      },
      {
        'title': 'Scheduled Content',
        'subtitle': 'Manage schedule',
        'icon': Icons.schedule,
        'color': const Color(0xFF06b6d4),
        'badge': false,
        'badgeCount': 0,
        'onTap': () => _navigateTo(const AdminScheduledContentScreen()),
      },
      {
        'title': 'Reports',
        'subtitle': 'Generate reports',
        'icon': Icons.assessment,
        'color': const Color(0xFF8b5cf6),
        'badge': false,
        'badgeCount': 0,
        'onTap': () => _navigateTo(const AdminReportsScreen()),
      },
      {
        'title': 'Audit Trail',
        'subtitle': 'View activity logs',
        'icon': Icons.history,
        'color': const Color(0xFF64748b),
        'badge': false,
        'badgeCount': 0,
        'onTap': () => _navigateTo(const AdminAuditTrailScreen()),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Tools',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return _buildActionCard(
              actions[index]['title'] as String,
              actions[index]['subtitle'] as String,
              actions[index]['icon'] as IconData,
              actions[index]['color'] as Color,
              actions[index]['onTap'] as VoidCallback,
              badge: actions[index]['badge'] as bool? ?? false,
              badgeCount: actions[index]['badgeCount'] as int? ?? 0,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool badge = false,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    if (badge && badgeCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFef4444),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'New business submitted',
                '2 minutes ago',
                Icons.business,
                const Color(0xFF06b6d4),
              ),
              const Divider(color: Colors.white10, height: 24),
              _buildActivityItem(
                'User reported content',
                '15 minutes ago',
                Icons.flag,
                const Color(0xFFef4444),
              ),
              const Divider(color: Colors.white10, height: 24),
              _buildActivityItem(
                'New user registered',
                '1 hour ago',
                Icons.person_add,
                const Color(0xFF10b981),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
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
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}
