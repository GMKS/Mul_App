/// User Stories Bar Widget
/// Horizontal scrollable stories bar (like Instagram)

import 'package:flutter/material.dart';
import 'dart:math';

class StoryItem {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String? thumbnailUrl;
  final String? videoUrl;
  final bool isViewed;
  final bool isSponsored;
  final bool isLive;
  final DateTime createdAt;

  StoryItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.thumbnailUrl,
    this.videoUrl,
    this.isViewed = false,
    this.isSponsored = false,
    this.isLive = false,
    required this.createdAt,
  });
}

class UserStoriesBar extends StatefulWidget {
  final Function(StoryItem)? onStoryTap;
  final VoidCallback? onAddStoryTap;

  const UserStoriesBar({
    super.key,
    this.onStoryTap,
    this.onAddStoryTap,
  });

  @override
  State<UserStoriesBar> createState() => _UserStoriesBarState();
}

class _UserStoriesBarState extends State<UserStoriesBar> {
  List<StoryItem> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock stories data
    final random = Random();
    final mockUsers = [
      {
        'name': 'Temple Live',
        'avatar': '🛕',
        'sponsored': false,
        'isLive': true
      },
      {
        'name': 'Daily Bhajan',
        'avatar': '🎵',
        'sponsored': false,
        'isLive': false
      },
      {
        'name': 'Local News',
        'avatar': '📰',
        'sponsored': true,
        'isLive': false
      },
      {
        'name': 'Festival Updates',
        'avatar': '🎉',
        'sponsored': false,
        'isLive': false
      },
      {
        'name': 'Business Deals',
        'avatar': '💼',
        'sponsored': true,
        'isLive': false
      },
      {
        'name': 'Health Tips',
        'avatar': '💊',
        'sponsored': false,
        'isLive': false
      },
      {
        'name': 'Event Alerts',
        'avatar': '📅',
        'sponsored': false,
        'isLive': false
      },
      {
        'name': 'Community',
        'avatar': '👥',
        'sponsored': false,
        'isLive': false
      },
    ];

    setState(() {
      _stories = mockUsers.asMap().entries.map((entry) {
        final user = entry.value;
        return StoryItem(
          id: 'story_${entry.key}',
          userId: 'user_${entry.key}',
          userName: user['name'] as String,
          userAvatar: user['avatar'] as String,
          isViewed: user['isLive'] == true ? false : random.nextBool(),
          isSponsored: user['sponsored'] as bool,
          isLive: user['isLive'] as bool,
          createdAt:
              DateTime.now().subtract(Duration(hours: random.nextInt(24))),
        );
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return Container(
      height: 135,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _stories.length + 1, // +1 for "Add Story"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryItem();
          }
          return _buildStoryItem(_stories[index - 1]);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 135,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 75,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddStoryItem() {
    return GestureDetector(
      onTap: widget.onAddStoryTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.grey[600],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add Story',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(StoryItem story) {
    final bool hasUnviewedStory = !story.isViewed || story.isLive;

    return GestureDetector(
      onTap: () => widget.onStoryTap?.call(story),
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Story Avatar with gradient border
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story.isLive
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFF0000),
                              Color(0xFFFF4444),
                              Color(0xFFFF0000),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : hasUnviewedStory
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFFFF6B6B),
                                  Color(0xFFFF8E53),
                                  Color(0xFFFFD93D),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                    color: (hasUnviewedStory || story.isLive)
                        ? null
                        : Colors.grey[300],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getAvatarColor(story.userName),
                      ),
                      child: Center(
                        child: Text(
                          story.userAvatar,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  ),
                ),
                // Live Badge
                if (story.isLive)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // User Name with Sponsored badge
            SizedBox(
              width: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (story.isSponsored)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'Ad',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  Flexible(
                    child: Text(
                      story.userName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: hasUnviewedStory
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: hasUnviewedStory
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFFFE5E5),
      const Color(0xFFE5F3FF),
      const Color(0xFFE5FFE5),
      const Color(0xFFFFF5E5),
      const Color(0xFFE5E5FF),
      const Color(0xFFFFF0F5),
    ];
    return colors[name.length % colors.length];
  }
}
