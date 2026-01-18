/// Enhanced Home Feed Widget
/// Combines all modern features: Stories, Quote, AQI, Deals, Polls, etc.

import 'package:flutter/material.dart';
import 'user_stories_bar.dart';
import 'quote_of_the_day_widget.dart';
import 'aqi_widget.dart';
import 'local_deals_widget.dart';
import 'community_polls_widget.dart';
import 'business_teasers_carousel.dart';
import 'gamified_streaks_widget.dart';
import 'quick_actions_widget.dart';
import 'skeleton_loaders.dart';

class EnhancedHomeFeed extends StatefulWidget {
  final VoidCallback? onRefresh;
  final Function(String)? onQuickAction;
  final VoidCallback? onAddStory;
  final Function(StoryItem)? onStoryTap;
  final Function(int)? onCategoryTap;

  const EnhancedHomeFeed({
    super.key,
    this.onRefresh,
    this.onQuickAction,
    this.onAddStory,
    this.onStoryTap,
    this.onCategoryTap,
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
              onStoryTap: widget.onStoryTap,
              onAddStoryTap: widget.onAddStory ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📸 Upload your story!')),
                    );
                  },
            ),

            // 2. Gamified Streaks (Compact) + AQI - Wrapped in Flexible to allow shrink
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: const [
                  GamifiedStreaksWidget(compact: true),
                  AQIWidget(compact: true),
                ],
              ),
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

            // 5. Today's Inspiring Quote
            const QuoteOfTheDayWidget(),

            // 6. AQI Widget (Full)
            const AQIWidget(),

            // 7. Featured Businesses Carousel
            const BusinessTeasersCarousel(),

            // 8. Local Deals & Discounts
            const LocalDealsWidget(),

            // 9. Support Local CTA
            SupportLocalCTAWidget(
              onDonateTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('🙏 Opening donation options...')),
                );
              },
              onShopTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🛒 Opening local shops...')),
                );
              },
              onBookTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('📅 Opening services to book...')),
                );
              },
            ),

            // 10. Community Polls
            const CommunityPollsWidget(),

            // 11. Gamified Streaks (Full Widget)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: GamifiedStreaksWidget(compact: false),
            ),

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
        'title': 'Regional',
        'subtitle': 'Local Services',
        'icon': Icons.location_on,
        'gradient': [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)],
        'index': 0,
      },
      {
        'title': 'Business',
        'subtitle': 'Opportunities',
        'icon': Icons.business_center,
        'gradient': [const Color(0xFF6C63FF), const Color(0xFF5A52E0)],
        'index': 1,
      },
      {
        'title': 'Devotional',
        'subtitle': 'Spiritual',
        'icon': Icons.self_improvement,
        'gradient': [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
        'index': 2,
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
      onTap: () => widget.onCategoryTap?.call(index),
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
