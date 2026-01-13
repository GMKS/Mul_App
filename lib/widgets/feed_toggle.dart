// STEP 3: Feed Toggle Widget
// Implement feed toggle for Trending and Latest.

import 'package:flutter/material.dart';
import '../services/feed_service.dart';

class FeedToggle extends StatelessWidget {
  final FeedType selectedType;
  final Function(FeedType) onChanged;

  const FeedToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: '🔥 Trending',
            type: FeedType.trending,
            isSelected: selectedType == FeedType.trending,
          ),
          _buildToggleButton(
            label: '✨ Latest',
            type: FeedType.latest,
            isSelected: selectedType == FeedType.latest,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required FeedType type,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
