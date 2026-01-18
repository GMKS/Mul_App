/// Date Filter Chips Widget
/// Reusable filter chips for date selection in event screens

import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class DateFilterChips extends StatelessWidget {
  final DateFilter selectedFilter;
  final ValueChanged<DateFilter> onFilterChanged;
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;

  const DateFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.selectedColor = const Color(0xFFE91E63),
    this.unselectedColor = const Color(0xFF1a1a2e),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: DateFilter.values.length,
        itemBuilder: (context, index) {
          final filter = DateFilter.values[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? selectedColor : Colors.white24,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter.icon != null) ...[
                    Text(filter.icon!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filter.displayName,
                    style: TextStyle(
                      color:
                          isSelected ? textColor : textColor.withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Category Filter Chips Widget
class CategoryFilterChips extends StatelessWidget {
  final EventCategory selectedCategory;
  final ValueChanged<EventCategory> onCategoryChanged;
  final Color selectedColor;
  final Color unselectedColor;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    this.selectedColor = const Color(0xFF9B59B6),
    this.unselectedColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: EventCategory.values.length,
        itemBuilder: (context, index) {
          final category = EventCategory.values[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () => onCategoryChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Quick Filter Row Widget
/// Horizontal row of quick filter buttons
class QuickFilterRow extends StatelessWidget {
  final VoidCallback? onTodayTap;
  final VoidCallback? onTomorrowTap;
  final VoidCallback? onLiveTap;
  final VoidCallback? onNearbyTap;
  final int todayCount;
  final int tomorrowCount;
  final int liveCount;
  final int nearbyCount;

  const QuickFilterRow({
    super.key,
    this.onTodayTap,
    this.onTomorrowTap,
    this.onLiveTap,
    this.onNearbyTap,
    this.todayCount = 0,
    this.tomorrowCount = 0,
    this.liveCount = 0,
    this.nearbyCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (liveCount > 0)
            _buildQuickChip(
              label: '🔴 LIVE',
              count: liveCount,
              color: Colors.red,
              onTap: onLiveTap,
            ),
          _buildQuickChip(
            label: '🔥 Today',
            count: todayCount,
            color: Colors.orange,
            onTap: onTodayTap,
          ),
          _buildQuickChip(
            label: '📅 Tomorrow',
            count: tomorrowCount,
            color: Colors.blue,
            onTap: onTomorrowTap,
          ),
          _buildQuickChip(
            label: '📍 Nearby',
            count: nearbyCount,
            color: const Color(0xFFE91E63),
            onTap: onNearbyTap,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required int count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Extension to add icon property to DateFilter
extension DateFilterExtension on DateFilter {
  String? get icon {
    switch (this) {
      case DateFilter.all:
        return '📋';
      case DateFilter.today:
        return '🔥';
      case DateFilter.tomorrow:
        return '📅';
      case DateFilter.thisWeek:
        return '📆';
      case DateFilter.thisMonth:
        return '🗓️';
    }
  }
}
