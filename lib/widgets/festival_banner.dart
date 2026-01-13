// STEP 8: Festival Banner Widget
// Display festival-related UI elements

import 'package:flutter/material.dart';
import '../models/festival_model.dart';
import '../services/festival_service.dart';

class FestivalBanner extends StatelessWidget {
  final Festival festival;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const FestivalBanner({
    super.key,
    required this.festival,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              festival.color,
              festival.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: festival.color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Festival icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                festival.iconEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 16),

            // Festival info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FestivalService.getFestivalGreeting(festival),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore ${festival.name} special content',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Dismiss button
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

// Festival filter chip
class FestivalFilterChip extends StatelessWidget {
  final Festival festival;
  final bool isSelected;
  final VoidCallback onTap;

  const FestivalFilterChip({
    super.key,
    required this.festival,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? festival.color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(festival.iconEmoji),
            const SizedBox(width: 4),
            Text(
              festival.name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Upcoming festival card
class UpcomingFestivalCard extends StatelessWidget {
  final Festival festival;
  final VoidCallback? onTap;

  const UpcomingFestivalCard({
    super.key,
    required this.festival,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntil = FestivalService.getDaysUntilFestival(festival);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: festival.color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(festival.iconEmoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: festival.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    daysUntil == 0 ? 'Today!' : '${daysUntil}d',
                    style: TextStyle(
                      fontSize: 12,
                      color: festival.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              festival.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              festival.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
