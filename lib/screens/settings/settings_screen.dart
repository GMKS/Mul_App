// settings_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../business/business_approval_screen_enhanced.dart';
import '../notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  bool get _isAdmin {
    final user = AuthService.currentUser;
    return user?.email == 'admin@gmail.com' ||
        user?.email == 'admin@example.com';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // User Info Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AuthService.currentUser?.email ??
                      AuthService.currentUser?.phone ??
                      'Guest User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAdmin ? 'Administrator' : 'User',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Admin Section
          if (_isAdmin) ...[
            const SizedBox(height: 8),
            Container(
              color: Colors.orange.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ADMIN PANEL',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.business_center,
              title: 'Business Approvals',
              subtitle: 'Manage pending business submissions',
              iconColor: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const BusinessApprovalScreenEnhanced(),
                  ),
                );
              },
            ),
            const Divider(height: 1),
          ],

          // General Section
          const SizedBox(height: 8),
          _buildSectionHeader('General'),
          _buildSettingsTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'View your notifications',
            iconColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context: context,
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            iconColor: Colors.green,
            onTap: () {
              // TODO: Implement language selection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'FAQs and contact us',
            iconColor: Colors.purple,
            onTap: () {
              // TODO: Implement help screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help screen coming soon')),
              );
            },
          ),
          const Divider(height: 1),

          // Account Section
          const SizedBox(height: 8),
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            context: context,
            icon: Icons.person_outline,
            title: 'Profile Settings',
            subtitle: 'Edit your profile information',
            iconColor: Colors.teal,
            onTap: () {
              // TODO: Implement profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile settings coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            iconColor: Colors.indigo,
            onTap: () {
              // TODO: Implement privacy policy screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon')),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            context: context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            iconColor: Colors.brown,
            onTap: () {
              // TODO: Implement terms screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms of service coming soon')),
              );
            },
          ),
          const Divider(height: 1),

          // App Info Section
          const SizedBox(height: 8),
          _buildSectionHeader('About'),
          _buildSettingsTile(
            context: context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            iconColor: Colors.grey,
            showArrow: false,
            onTap: null,
          ),
          const Divider(height: 1),

          // Logout
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await AuthService.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: showArrow
          ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)
          : null,
      onTap: onTap,
    );
  }
}
