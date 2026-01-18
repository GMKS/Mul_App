/// Gamified Streaks Widget
/// Daily check-in streaks with rewards and badges

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalCheckins;
  final List<DateTime> checkInHistory;
  final String currentBadge;
  final int pointsEarned;
  final int nextMilestone;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckins,
    required this.checkInHistory,
    required this.currentBadge,
    required this.pointsEarned,
    required this.nextMilestone,
  });

  factory StreakData.empty() => StreakData(
        currentStreak: 0,
        longestStreak: 0,
        totalCheckins: 0,
        checkInHistory: [],
        currentBadge: '🌱',
        pointsEarned: 0,
        nextMilestone: 7,
      );
}

class GamifiedStreaksWidget extends StatefulWidget {
  final bool compact;
  final VoidCallback? onTap;

  const GamifiedStreaksWidget({
    super.key,
    this.compact = false,
    this.onTap,
  });

  @override
  State<GamifiedStreaksWidget> createState() => _GamifiedStreaksWidgetState();
}

class _GamifiedStreaksWidgetState extends State<GamifiedStreaksWidget>
    with SingleTickerProviderStateMixin {
  StreakData _streakData = StreakData.empty();
  bool _isLoading = true;
  bool _checkedInToday = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  static const String _streakKey = 'user_streak_data';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _loadStreakData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStreakData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_streakKey);

      if (dataStr != null) {
        final data = json.decode(dataStr);
        final history = (data['checkInHistory'] as List)
            .map((d) => DateTime.parse(d))
            .toList();

        // Check if already checked in today
        final today = DateTime.now();
        _checkedInToday = history.any((d) =>
            d.year == today.year &&
            d.month == today.month &&
            d.day == today.day);

        // Calculate current streak
        int currentStreak = data['currentStreak'] ?? 0;

        // If last check-in was yesterday or today, keep streak
        if (history.isNotEmpty) {
          final lastCheckIn = history.last;
          final daysSinceLastCheckIn = today.difference(lastCheckIn).inDays;

          if (daysSinceLastCheckIn > 1) {
            // Streak broken
            currentStreak = _checkedInToday ? 1 : 0;
          }
        }

        setState(() {
          _streakData = StreakData(
            currentStreak: currentStreak,
            longestStreak: data['longestStreak'] ?? 0,
            totalCheckins: data['totalCheckins'] ?? 0,
            checkInHistory: history,
            currentBadge: _getBadge(currentStreak),
            pointsEarned: data['pointsEarned'] ?? 0,
            nextMilestone: _getNextMilestone(currentStreak),
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading streak data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIn() async {
    if (_checkedInToday) return;

    final now = DateTime.now();
    final newStreak = _streakData.currentStreak + 1;
    final newPoints = _streakData.pointsEarned + _getPointsForDay(newStreak);
    final newHistory = [..._streakData.checkInHistory, now];

    final newData = StreakData(
      currentStreak: newStreak,
      longestStreak: newStreak > _streakData.longestStreak
          ? newStreak
          : _streakData.longestStreak,
      totalCheckins: _streakData.totalCheckins + 1,
      checkInHistory: newHistory,
      currentBadge: _getBadge(newStreak),
      pointsEarned: newPoints,
      nextMilestone: _getNextMilestone(newStreak),
    );

    // Save to storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _streakKey,
          json.encode({
            'currentStreak': newData.currentStreak,
            'longestStreak': newData.longestStreak,
            'totalCheckins': newData.totalCheckins,
            'checkInHistory':
                newData.checkInHistory.map((d) => d.toIso8601String()).toList(),
            'pointsEarned': newData.pointsEarned,
          }));
    } catch (e) {
      print('Error saving streak: $e');
    }

    setState(() {
      _streakData = newData;
      _checkedInToday = true;
    });

    // Animate
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Show celebration
    if (mounted) {
      _showCheckInCelebration(newStreak);
    }
  }

  void _showCheckInCelebration(int streak) {
    String message;
    if (streak == 7) {
      message = '🎉 Amazing! 1 Week Streak! +50 bonus points!';
    } else if (streak == 30) {
      message = '🏆 Incredible! 1 Month Streak! +200 bonus points!';
    } else if (streak % 10 == 0) {
      message = '🌟 $streak Day Streak! Keep it up!';
    } else {
      message = '✅ Day $streak! +${_getPointsForDay(streak)} points';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getBadge(int streak) {
    if (streak >= 365) return '👑';
    if (streak >= 100) return '💎';
    if (streak >= 30) return '🏆';
    if (streak >= 14) return '⭐';
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '🌟';
    return '🌱';
  }

  int _getNextMilestone(int streak) {
    final milestones = [3, 7, 14, 30, 60, 100, 365];
    for (final m in milestones) {
      if (streak < m) return m;
    }
    return streak + 100;
  }

  int _getPointsForDay(int day) {
    if (day == 7) return 50; // Week bonus
    if (day == 30) return 200; // Month bonus
    if (day % 10 == 0) return 25; // 10-day bonus
    return 10; // Regular day
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      return _buildCompactWidget();
    }

    return _buildFullWidget();
  }

  Widget _buildCompactWidget() {
    return GestureDetector(
      onTap: _checkedInToday ? widget.onTap : _checkIn,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _checkedInToday
                      ? [Colors.green[400]!, Colors.green[600]!]
                      : [Colors.orange[400]!, Colors.orange[600]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_checkedInToday ? Colors.green : Colors.orange)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _streakData.currentBadge,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _checkedInToday
                        ? '${_streakData.currentStreak} 🔥'
                        : 'Check In',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildFullWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple[400]!,
            Colors.deepPurple[600]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorations
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Row
                Row(
                  children: [
                    // Badge and Streak
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _streakData.currentBadge,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // Streak Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${_streakData.currentStreak}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                ' Day Streak 🔥',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_streakData.nextMilestone - _streakData.currentStreak} days to next milestone',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value:
                        _streakData.currentStreak / _streakData.nextMilestone,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        '🏆', '${_streakData.longestStreak}', 'Best'),
                    _buildStatItem(
                        '✅', '${_streakData.totalCheckins}', 'Total'),
                    _buildStatItem(
                        '⭐', '${_streakData.pointsEarned}', 'Points'),
                  ],
                ),
                const SizedBox(height: 16),
                // Check-In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkedInToday ? null : _checkIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _checkedInToday ? Colors.grey : Colors.white,
                      foregroundColor:
                          _checkedInToday ? Colors.white : Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _checkedInToday
                          ? '✅ Checked In Today!'
                          : '🎯 Check In Now (+10 pts)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
