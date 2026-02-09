/// Quick Actions Widget
/// Row of quick action buttons for Post, Share, Donate, Shop

import 'package:flutter/material.dart';
import '../screens/community/create_post_screen.dart';
import '../screens/community/community_feed_screen.dart';
import '../screens/donate/donate_screen.dart';
import '../screens/shop/local_shop_screen.dart';
import '../screens/devotional/devotional_feed_screen.dart';
import '../services/share_service.dart';

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? badge;

  QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.badge,
  });
}

class QuickActionsWidget extends StatelessWidget {
  final List<QuickAction>? actions;
  final Function(String)? onActionTap;

  const QuickActionsWidget({
    super.key,
    this.actions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultActions = [
      QuickAction(
        label: 'Post',
        icon: Icons.add_circle_outline,
        color: const Color(0xFF4CAF50),
        onTap: () => _navigateToPost(context),
      ),
      QuickAction(
        label: 'Share',
        icon: Icons.share,
        color: const Color(0xFF2196F3),
        onTap: () => _showShareOptions(context),
      ),
      QuickAction(
        label: 'Donate',
        icon: Icons.volunteer_activism,
        color: const Color(0xFFE91E63),
        onTap: () => _navigateToDonate(context),
      ),
      QuickAction(
        label: 'Devotional',
        icon: Icons.self_improvement,
        color: const Color(0xFF9C27B0),
        onTap: () => _navigateToDevotional(context),
      ),
    ];

    final actionsList = actions ?? defaultActions;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actionsList.map((action) {
          return _buildActionButton(context, action);
        }).toList(),
      ),
    );
  }

  /// Navigate to Post creation / Community Feed
  void _navigateToPost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📝 Community Posts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.green),
              ),
              title: const Text('Create New Post'),
              subtitle: const Text('Share updates with your community'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.list_alt, color: Colors.blue),
              ),
              title: const Text('View Community Feed'),
              subtitle: const Text('See posts from your neighborhood'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunityFeedScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show Share options with verified content
  void _showShareOptions(BuildContext context) {
    ShareService.shareContent(
      context: context,
      title: 'Share from My City App',
      description:
          'I\'m using the local community app to stay connected with my neighborhood! Join me to discover local businesses, news, and community updates.',
      isVerified: true,
    );
  }

  /// Navigate to Donate screen
  void _navigateToDonate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DonateScreen(),
      ),
    );
  }

  /// Navigate to Devotional Feed screen
  void _navigateToDevotional(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DevotionalFeedScreen(),
      ),
    );
  }

  /// Navigate to Local Shop screen
  void _navigateToShop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocalShopScreen(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, QuickAction action) {
    return GestureDetector(
      onTap: action.onTap ?? () => onActionTap?.call(action.label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: action.color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 26,
                ),
              ),
              if (action.badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      action.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// Referral Banner Widget
class ReferralBannerWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const ReferralBannerWidget({
    super.key,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🎁', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invite Friends & Earn ₹100',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Share app with friends, both earn rewards!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.7),
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Support Local CTA Widget
class SupportLocalCTAWidget extends StatelessWidget {
  final VoidCallback? onLocalHelpTap;
  final VoidCallback? onShopTap;
  final VoidCallback? onConnectTap;

  const SupportLocalCTAWidget({
    super.key,
    this.onLocalHelpTap,
    this.onShopTap,
    this.onConnectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏘️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  const Text(
                    'Support Local',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Help your community grow by supporting local businesses',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCTAButton(
                  '🛒 Shop',
                  Colors.orange,
                  onShopTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCTAButton(
                  '🔗 Connect',
                  Colors.blue,
                  onConnectTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButton(String label, Color color, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
