/// Enhanced Home Feed Widget
/// Combines all modern features: Stories, Quote, AQI, Deals, Polls, etc.

import 'package:flutter/material.dart';
import 'user_stories_bar.dart';
import 'quote_of_the_day_widget.dart';
import 'aqi_widget.dart';
import 'local_deals_widget.dart';
import 'business_teasers_carousel.dart';
import 'daily_triple_puzzle_widget.dart';
import 'quick_actions_widget.dart';
import 'skeleton_loaders.dart';
import 'gamified_streaks_widget.dart';
import '../screens/business_feed_screen.dart';
import '../screens/devotional/devotional_feed_screen.dart';
import '../screens/emergency/emergency_services_screen.dart';
import '../screens/temple/temple_live_screen.dart';
import '../screens/bhajan/daily_bhajan_screen.dart';
import '../screens/news/local_news_screen.dart';
import '../screens/health/health_tips_screen.dart';
import '../screens/local_help_screen.dart';
import '../screens/local_alerts_screen.dart';
import '../screens/education/education_corner_screen.dart';
import '../screens/shop/local_shop_screen.dart';
import '../screens/feedback_suggestions_screen.dart';
import '../screens/cab_services_screen.dart';
import '../screens/jobs_screen.dart';
import '../screens/home_services_screen.dart';
import '../core/route_manager.dart';

class EnhancedHomeFeed extends StatefulWidget {
  final VoidCallback? onRefresh;
  final Function(String)? onQuickAction;
  final VoidCallback? onAddStory;
  final Function(StoryItem)? onStoryTap;

  const EnhancedHomeFeed({
    super.key,
    this.onRefresh,
    this.onQuickAction,
    this.onAddStory,
    this.onStoryTap,
  });

  @override
  State<EnhancedHomeFeed> createState() => _EnhancedHomeFeedState();
}

class _EnhancedHomeFeedState extends State<EnhancedHomeFeed>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _showReferralBanner = true;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _loadFeed();
    widget.onRefresh?.call();
  }

  /// Handle story tap navigation
  void _handleStoryTap(StoryItem story) {
    switch (story.userName) {
      case 'Place of Worship':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TempleLiveScreen()),
        );
        break;
      case 'Daily Bhajan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyBhajanScreen()),
        );
        break;
      case 'Local News':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LocalNewsScreen()),
        );
        break;
      case 'Health Tips':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HealthTipsScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${story.userName} stories coming soon!')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const SkeletonHomeFeed();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      displacement: 60,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. User Stories Bar (Top)
            UserStoriesBar(
              onStoryTap: widget.onStoryTap ?? _handleStoryTap,
              onAddStoryTap: widget.onAddStory ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📸 Upload your story!')),
                    );
                  },
            ),

            // 2. Gamified Streaks (Compact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GamifiedStreaksWidget(compact: true),
            ),

            // 3. Referral Banner (Dismissible)
            if (_showReferralBanner)
              ReferralBannerWidget(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('🎁 Share your referral link!')),
                  );
                },
                onDismiss: () {
                  setState(() => _showReferralBanner = false);
                },
              ),

            // 4. Quick Actions Row
            QuickActionsWidget(
              onActionTap: (action) {
                widget.onQuickAction?.call(action);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$action tapped!')),
                );
              },
            ),

            // 5. Air Quality Index - Shows detected location
            const AQIWidget(),

            // 6. Featured Businesses Carousel
            BusinessTeasersCarousel(
              onViewAllTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BusinessFeedScreen(),
                  ),
                );
              },
            ),

            // 8. Local Deals & Discounts
            const LocalDealsWidget(),

            // 9. Support Local CTA
            SupportLocalCTAWidget(
              onLocalHelpTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocalHelpScreen(),
                  ),
                );
              },
              onShopTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🛒 Opening local shops...')),
                );
              },
              onConnectTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('🔗 Connect with local businesses...')),
                );
              },
            ),

            // 11. Daily Triple Puzzle (Time-based puzzles for all ages)
            const DailyTriplePuzzleWidget(),

            // 12. Category Navigation Cards
            _buildCategoryCards(),

            // Bottom Spacing
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    final categories = [
      {
        'title': 'Cab Services',
        'subtitle': 'Easy & Safe Rides',
        'icon': Icons.local_taxi,
        'gradient': [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)],
        'index': 0,
      },
      {
        'title': 'Education Corner',
        'subtitle': 'Learning & Development',
        'icon': Icons.school,
        'gradient': [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
        'index': 1,
      },
      {
        'title': 'Emergency Services',
        'subtitle': 'Safety & Help',
        'icon': Icons.local_hospital,
        'gradient': [const Color(0xFFE91E63), const Color(0xFFC2185B)],
        'index': 2,
      },
      {
        'title': 'Feedback & Suggestions',
        'subtitle': 'Share Your Ideas',
        'icon': Icons.feedback,
        'gradient': [const Color(0xFF00BCD4), const Color(0xFF0097A7)],
        'index': 3,
      },
      {
        'title': 'Home Services',
        'subtitle': 'Professional Help at Home',
        'icon': Icons.home_repair_service,
        'gradient': [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
        'index': 4,
      },
      {
        'title': 'Jobs & Opportunities',
        'subtitle': 'Find Your Next Job',
        'icon': Icons.work,
        'gradient': [const Color(0xFF3498DB), const Color(0xFF2980B9)],
        'index': 5,
      },
      {
        'title': 'Local Alerts',
        'subtitle': 'Stay informed about your area',
        'icon': Icons.notifications_active,
        'gradient': [const Color(0xFFFF9800), const Color(0xFFF57C00)],
        'index': 6,
      },
      {
        'title': 'Local Help',
        'subtitle': 'Community Support',
        'icon': Icons.people_alt,
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
        'index': 7,
      },
      {
        'title': 'Shop Local',
        'subtitle': 'Nearby shops for daily needs.',
        'icon': Icons.shopping_bag,
        'gradient': [const Color(0xFF673AB7), const Color(0xFF512DA8)],
        'index': 8,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '📂 Explore Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryCard(
                  title: category['title'] as String,
                  subtitle: category['subtitle'] as String,
                  icon: category['icon'] as IconData,
                  gradient: category['gradient'] as List<Color>,
                  index: category['index'] as int,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate based on category index
        if (index == 0) {
          // Cab Services - Navigate to Cab Services Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CabServicesScreen(
                userCity: 'Hyderabad',
              ),
            ),
          );
        } else if (index == 1) {
          // Education Corner - Navigate to Education Corner Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EducationCornerScreen(),
            ),
          );
        } else if (index == 2) {
          // Emergency Services - Navigate to Emergency Services Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmergencyServicesScreen(),
            ),
          );
        } else if (index == 3) {
          // Feedback & Suggestions - Navigate to Feedback Suggestions Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FeedbackSuggestionsScreen(),
            ),
          );
        } else if (index == 4) {
          // Home Services - Navigate to Home Services Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeServicesScreen(),
            ),
          );
        } else if (index == 5) {
          // Jobs & Opportunities - Navigate to Jobs Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JobsScreen(),
            ),
          );
        } else if (index == 6) {
          // Local Alerts - Navigate to Local Alerts Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocalAlertsScreen(),
            ),
          );
        } else if (index == 7) {
          // Local Help - Navigate to Local Help Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocalHelpScreen(),
            ),
          );
        } else if (index == 8) {
          // Shop Local - Navigate to Local Shop Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocalShopScreen(),
            ),
          );
        } else {
          // Other categories - show coming soon
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title content coming soon!')),
          );
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home Feed Tab for integration into existing HomeScreen
class HomeFeedTab extends StatelessWidget {
  final VoidCallback? onRefresh;
  final Function(String)? onQuickAction;

  const HomeFeedTab({
    super.key,
    this.onRefresh,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedHomeFeed(
      onRefresh: onRefresh,
      onQuickAction: onQuickAction,
    );
  }
}
