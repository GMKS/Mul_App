/// Community Polls Widget
/// Interactive polls for engagement and sponsored surveys

import 'package:flutter/material.dart';
import 'dart:math';

class PollOption {
  final String id;
  final String text;
  int votes;
  bool isSelected;

  PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.isSelected = false,
  });
}

class PollItem {
  final String id;
  final String question;
  final List<PollOption> options;
  final String? creatorName;
  final String? creatorEmoji;
  final bool isSponsored;
  final DateTime expiresAt;
  final String category;
  bool hasVoted;

  PollItem({
    required this.id,
    required this.question,
    required this.options,
    this.creatorName,
    this.creatorEmoji,
    this.isSponsored = false,
    required this.expiresAt,
    required this.category,
    this.hasVoted = false,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes);
}

class CommunityPollsWidget extends StatefulWidget {
  final VoidCallback? onViewAllTap;

  const CommunityPollsWidget({
    super.key,
    this.onViewAllTap,
  });

  @override
  State<CommunityPollsWidget> createState() => _CommunityPollsWidgetState();
}

class _CommunityPollsWidgetState extends State<CommunityPollsWidget> {
  List<PollItem> _polls = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPolls();
  }

  Future<void> _loadPolls() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final random = Random();
    final mockPolls = [
      {
        'question': 'Which festival are you most excited about this month?',
        'options': ['Diwali 🪔', 'Eid 🌙', 'Christmas 🎄', 'Pongal 🌾'],
        'creator': 'Community',
        'emoji': '🎉',
        'sponsored': false,
        'category': 'Festival',
      },
      {
        'question': 'Best local food spot in your area?',
        'options': [
          'Street Vendors',
          'Local Restaurant',
          'Home Delivery',
          'Cafe'
        ],
        'creator': 'Foodies Club',
        'emoji': '🍽️',
        'sponsored': true,
        'category': 'Food',
      },
      {
        'question': 'What community service do you need most?',
        'options': ['Healthcare', 'Education', 'Transport', 'Employment'],
        'creator': 'Local Admin',
        'emoji': '🏛️',
        'sponsored': false,
        'category': 'Community',
      },
    ];

    setState(() {
      _polls = mockPolls.map((poll) {
        final options =
            (poll['options'] as List<String>).asMap().entries.map((e) {
          return PollOption(
            id: 'opt_${e.key}',
            text: e.value,
            votes: random.nextInt(500) + 50,
          );
        }).toList();

        return PollItem(
          id: 'poll_${random.nextInt(10000)}',
          question: poll['question'] as String,
          options: options,
          creatorName: poll['creator'] as String,
          creatorEmoji: poll['emoji'] as String,
          isSponsored: poll['sponsored'] as bool,
          expiresAt: DateTime.now().add(Duration(days: random.nextInt(7) + 1)),
          category: poll['category'] as String,
        );
      }).toList();
      _isLoading = false;
    });
  }

  void _vote(PollItem poll, PollOption option) {
    if (poll.hasVoted) return;

    setState(() {
      option.votes++;
      option.isSelected = true;
      poll.hasVoted = true;
    });

    // Show vote confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Voted for "${option.text}"'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_polls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '📊 ',
                    style: TextStyle(fontSize: 18),
                  ),
                  const Text(
                    'Community Polls',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: widget.onViewAllTap,
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        // Polls List
        ...(_polls.take(2).map((poll) => _buildPollCard(poll))),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPollCard(PollItem poll) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Creator Info
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            _getCategoryColor(poll.category).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          poll.creatorEmoji ?? '📊',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                poll.creatorName ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (poll.isSponsored) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Sponsored',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${poll.totalVotes} votes • ${_getExpiryText(poll.expiresAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _getCategoryColor(poll.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        poll.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getCategoryColor(poll.category),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Question
                Text(
                  poll.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Poll Options
          ...poll.options.map((option) => _buildPollOption(poll, option)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPollOption(PollItem poll, PollOption option) {
    final percentage = poll.totalVotes > 0
        ? (option.votes / poll.totalVotes * 100).round()
        : 0;
    final isSelected = option.isSelected;

    return GestureDetector(
      onTap: () => _vote(poll, option),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? _getCategoryColor(poll.category)
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(
            children: [
              // Progress Bar (shown after voting)
              if (poll.hasVoted)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getCategoryColor(poll.category).withOpacity(0.2)
                            : Colors.grey[100],
                      ),
                    ),
                  ),
                ),
              // Option Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Radio/Check indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? _getCategoryColor(poll.category)
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isSelected
                            ? _getCategoryColor(poll.category)
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    // Option Text
                    Expanded(
                      child: Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? _getCategoryColor(poll.category)
                              : Colors.black87,
                        ),
                      ),
                    ),
                    // Percentage (shown after voting)
                    if (poll.hasVoted)
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? _getCategoryColor(poll.category)
                              : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'festival':
        return const Color(0xFFFF6B6B);
      case 'food':
        return const Color(0xFFFF9800);
      case 'community':
        return const Color(0xFF2196F3);
      case 'health':
        return const Color(0xFF4CAF50);
      case 'entertainment':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }

  String _getExpiryText(DateTime expiresAt) {
    final diff = expiresAt.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return 'Ending soon';
  }
}
