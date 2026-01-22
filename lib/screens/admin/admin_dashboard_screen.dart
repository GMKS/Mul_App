/// Comprehensive Admin Dashboard Screen
/// Central hub for all admin operations with modern features

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
  // Check if user is admin
  bool get _isAdmin => widget.currentUser.isAdmin;

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
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
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF16213e),
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.admin_panel_settings, color: Colors.white),
          SizedBox(width: 12),
          Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            setState(() {
              // Refresh dashboard data
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // Settings
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeSection(),
          const SizedBox(height: 24),

          // Quick stats
          _buildQuickStats(),
          const SizedBox(height: 24),

          // Action cards grid
          _buildActionCardsGrid(),
          const SizedBox(height: 24),

          // Recent activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(
              widget.currentUser.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.currentUser.name}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Super Admin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified_user, color: Colors.white),
          ),
        ],
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
                '24',
                Icons.pending_actions,
                const Color(0xFFf59e0b),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Active Users',
                '1,234',
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
                '8',
                Icons.flag,
                const Color(0xFFef4444),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Total Content',
                '5,678',
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
      String label, String value, IconData icon, Color color) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
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
            label,
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
        'title': 'Content Management',
        'subtitle': 'Bulk operations',
        'icon': Icons.folder_open,
        'color': const Color(0xFF6366f1),
        'onTap': () => _navigateTo(const AdminContentManagementScreen()),
      },
      {
        'title': 'Analytics',
        'subtitle': 'Insights & trends',
        'icon': Icons.analytics,
        'color': const Color(0xFF10b981),
        'onTap': () => _navigateTo(const AdminAnalyticsScreen()),
      },
      {
        'title': 'Moderation',
        'subtitle': 'AI-powered tools',
        'icon': Icons.shield,
        'color': const Color(0xFFf59e0b),
        'onTap': () => _navigateTo(const AdminModerationScreen()),
      },
      {
        'title': 'Roles & Access',
        'subtitle': 'User permissions',
        'icon': Icons.admin_panel_settings,
        'color': const Color(0xFF8b5cf6),
        'onTap': () => _navigateTo(const AdminRolesScreen()),
      },
      {
        'title': 'Scheduled Content',
        'subtitle': 'Publishing calendar',
        'icon': Icons.schedule,
        'color': const Color(0xFF3b82f6),
        'onTap': () => _navigateTo(const AdminScheduledContentScreen()),
      },
      {
        'title': 'Notifications',
        'subtitle': 'Push & alerts',
        'icon': Icons.notifications_active,
        'color': const Color(0xFFec4899),
        'onTap': () => _navigateTo(const AdminNotificationManagerScreen()),
      },
      {
        'title': 'Reports & Feedback',
        'subtitle': 'User submissions',
        'icon': Icons.feedback,
        'color': const Color(0xFFef4444),
        'onTap': () => _navigateTo(const AdminReportsScreen()),
      },
      {
        'title': 'Audit Trail',
        'subtitle': 'History & logs',
        'icon': Icons.history,
        'color': const Color(0xFF14b8a6),
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
            final action = actions[index];
            return _buildActionCard(
              title: action['title'] as String,
              subtitle: action['subtitle'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
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
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'action': 'Approved business listing',
        'target': 'ABC Electronics',
        'time': '5 minutes ago',
        'icon': Icons.check_circle,
        'color': const Color(0xFF10b981),
      },
      {
        'action': 'Flagged content',
        'target': 'Video #12345',
        'time': '15 minutes ago',
        'icon': Icons.flag,
        'color': const Color(0xFFef4444),
      },
      {
        'action': 'Added new moderator',
        'target': 'John Doe',
        'time': '1 hour ago',
        'icon': Icons.person_add,
        'color': const Color(0xFF6366f1),
      },
      {
        'action': 'Sent notification',
        'target': '1,234 users',
        'time': '2 hours ago',
        'icon': Icons.notifications,
        'color': const Color(0xFFec4899),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _navigateTo(const AdminAuditTrailScreen()),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const Divider(
              color: Color(0xFF2a2a3e),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    color: activity['color'] as Color,
                    size: 20,
                  ),
                ),
                title: Text(
                  activity['action'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  activity['target'] as String,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  activity['time'] as String,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              );
            },
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
