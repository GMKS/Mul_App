// STEP 7: Creator Badge Widget
// Display creator badges

import 'package:flutter/material.dart';
import '../models/creator_model.dart';

class CreatorBadgeWidget extends StatelessWidget {
  final CreatorBadge badge;
  final double size;
  final bool showLabel;

  const CreatorBadgeWidget({
    super.key,
    required this.badge,
    this.size = 24,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (badge == CreatorBadge.none) return const SizedBox.shrink();

    final badgeInfo = Creator.getBadgeInfo(badge);

    return Tooltip(
      message: badgeInfo['description'],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(size * 0.2),
            decoration: BoxDecoration(
              color: Color(badgeInfo['color']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(size * 0.4),
            ),
            child: Text(
              badgeInfo['icon'],
              style: TextStyle(fontSize: size * 0.6),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              badgeInfo['name'],
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w500,
                color: Color(badgeInfo['color']),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Creator badges row
class CreatorBadgesRow extends StatelessWidget {
  final List<CreatorBadge> badges;
  final double size;
  final int maxBadges;

  const CreatorBadgesRow({
    super.key,
    required this.badges,
    this.size = 20,
    this.maxBadges = 3,
  });

  @override
  Widget build(BuildContext context) {
    final displayBadges =
        badges.where((b) => b != CreatorBadge.none).take(maxBadges).toList();

    if (displayBadges.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: displayBadges.map((badge) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: CreatorBadgeWidget(badge: badge, size: size),
        );
      }).toList(),
    );
  }
}

// Verified badge
class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.1),
      decoration: const BoxDecoration(
        color: Color(0xFF1DA1F2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.8,
      ),
    );
  }
}
