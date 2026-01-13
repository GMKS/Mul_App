// STEP 10: Hashtag Widget
// Display and filter by hashtags

import 'package:flutter/material.dart';
import '../models/hashtag_model.dart';

class HashtagChip extends StatelessWidget {
  final String hashtag;
  final bool isSelected;
  final bool isTrending;
  final VoidCallback? onTap;

  const HashtagChip({
    super.key,
    required this.hashtag,
    this.isSelected = false,
    this.isTrending = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTrending) ...[
              const Text('🔥', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
            ],
            Text(
              hashtag.startsWith('#') ? hashtag : '#$hashtag',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isTrending ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Trending hashtags row
class TrendingHashtagsRow extends StatelessWidget {
  final List<Hashtag> hashtags;
  final String? selectedHashtag;
  final Function(String) onHashtagSelected;

  const TrendingHashtagsRow({
    super.key,
    required this.hashtags,
    this.selectedHashtag,
    required this.onHashtagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                '🔥 Trending',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Show all hashtags
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: hashtags.length,
            itemBuilder: (context, index) {
              final hashtag = hashtags[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: HashtagChip(
                  hashtag: hashtag.tag,
                  isSelected: selectedHashtag == hashtag.tag,
                  isTrending: hashtag.isTrending,
                  onTap: () => onHashtagSelected(hashtag.tag),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Regional hashtags section
class RegionalHashtagsSection extends StatelessWidget {
  final String region;
  final Function(String) onHashtagSelected;

  const RegionalHashtagsSection({
    super.key,
    required this.region,
    required this.onHashtagSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hashtags = Hashtag.regionalHashtags[region] ?? [];

    if (hashtags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '📍 Popular in $region',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: hashtags.map((tag) {
            return HashtagChip(
              hashtag: tag,
              onTap: () => onHashtagSelected(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Hashtag in video description (clickable)
class ClickableHashtags extends StatelessWidget {
  final String text;
  final Function(String) onHashtagTap;
  final TextStyle? style;

  const ClickableHashtags({
    super.key,
    required this.text,
    required this.onHashtagTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final hashtags = Hashtag.extractHashtags(text);

    if (hashtags.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <InlineSpan>[];
    String remainingText = text;

    for (final hashtag in hashtags) {
      final index = remainingText.indexOf(hashtag);
      if (index > 0) {
        spans.add(TextSpan(text: remainingText.substring(0, index)));
      }
      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () => onHashtagTap(hashtag),
            child: Text(
              hashtag,
              style: (style ?? const TextStyle()).copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
      remainingText = remainingText.substring(index + hashtag.length);
    }

    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(text: remainingText));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: style,
    );
  }
}
