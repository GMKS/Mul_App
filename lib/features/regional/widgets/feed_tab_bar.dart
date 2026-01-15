/// Feed Tab Bar Widget
/// Toggle between Latest and Trending tabs in regional feed

import 'package:flutter/material.dart';

import '../models/models.dart';

class FeedTabBar extends StatelessWidget {
  final RegionalFeedTab selectedTab;
  final ValueChanged<RegionalFeedTab> onTabChanged;
  final bool showIndicator;

  const FeedTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: 'Latest',
            icon: Icons.schedule,
            isSelected: selectedTab == RegionalFeedTab.latest,
            onTap: () => onTabChanged(RegionalFeedTab.latest),
          ),
          _TabButton(
            label: 'Trending',
            icon: Icons.trending_up,
            isSelected: selectedTab == RegionalFeedTab.trending,
            onTap: () => onTabChanged(RegionalFeedTab.trending),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alternative minimalist tab style
class FeedTabBarMinimal extends StatelessWidget {
  final RegionalFeedTab selectedTab;
  final ValueChanged<RegionalFeedTab> onTabChanged;

  const FeedTabBarMinimal({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MinimalTabButton(
          label: 'Latest',
          isSelected: selectedTab == RegionalFeedTab.latest,
          onTap: () => onTabChanged(RegionalFeedTab.latest),
        ),
        Container(
          width: 1,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          color: Colors.white30,
        ),
        _MinimalTabButton(
          label: 'Trending',
          isSelected: selectedTab == RegionalFeedTab.trending,
          onTap: () => onTabChanged(RegionalFeedTab.trending),
        ),
      ],
    );
  }
}

class _MinimalTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MinimalTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: isSelected ? 30 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width segmented tab bar
class FeedSegmentedTabBar extends StatelessWidget {
  final RegionalFeedTab selectedTab;
  final ValueChanged<RegionalFeedTab> onTabChanged;

  const FeedSegmentedTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Latest',
              subtitle: 'Newest first',
              icon: Icons.access_time,
              isSelected: selectedTab == RegionalFeedTab.latest,
              onTap: () => onTabChanged(RegionalFeedTab.latest),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SegmentButton(
              label: 'Trending',
              subtitle: 'Most popular',
              icon: Icons.local_fire_department,
              isSelected: selectedTab == RegionalFeedTab.trending,
              onTap: () => onTabChanged(RegionalFeedTab.trending),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.white38,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
