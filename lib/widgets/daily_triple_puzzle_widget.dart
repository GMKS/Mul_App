/// Daily Triple Puzzle Widget - Enhanced Edition
/// World-class puzzle experience with knowledge-based challenges
/// Time-based puzzles for different age groups:
/// - 6AM - 12PM: Elders (Logic, Wisdom, General Knowledge)
/// - 12:01PM - 5PM: Women (Lifestyle, Wellness, Creative Thinking)
/// - 5PM - 6AM: Kids (STEM, Fun Learning, Exploration)

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../screens/puzzle/daily_puzzle_screen.dart';

class DailyTriplePuzzleWidget extends StatefulWidget {
  final bool compact;

  const DailyTriplePuzzleWidget({
    super.key,
    this.compact = false,
  });

  @override
  State<DailyTriplePuzzleWidget> createState() =>
      _DailyTriplePuzzleWidgetState();
}

class _DailyTriplePuzzleWidgetState extends State<DailyTriplePuzzleWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late PuzzleSlot _currentSlot;
  late Duration _timeRemaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Simulated user progress
  int _userStreak = 0;
  int _userLevel = 1;
  double _dailyProgress = 0.0;
  String _todayFactPreview = '';

  @override
  void initState() {
    super.initState();
    _currentSlot = PuzzleSlot.morning; // default before first update
    _timeRemaining = Duration.zero;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _updateCurrentSlot();
    _loadUserProgress();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCurrentSlot();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadUserProgress() {
    final random = Random(DateTime.now().day);
    _userStreak = random.nextInt(15) + 1;
    _userLevel = (_userStreak / 3).ceil().clamp(1, 50);
    _dailyProgress = random.nextDouble() * 0.6;
    _todayFactPreview = _currentSlot.todayFact;
  }

  void _updateCurrentSlot() {
    final now = DateTime.now();
    final hour = now.hour;

    PuzzleSlot newSlot;
    DateTime nextSlotTime;

    if (hour >= 6 && hour < 12) {
      newSlot = PuzzleSlot.morning;
      nextSlotTime = DateTime(now.year, now.month, now.day, 12, 0, 1);
    } else if (hour >= 12 && hour < 17) {
      newSlot = PuzzleSlot.afternoon;
      nextSlotTime = DateTime(now.year, now.month, now.day, 17, 0, 0);
    } else if (hour >= 17 || hour < 6) {
      newSlot = PuzzleSlot.evening;
      if (hour >= 17) {
        nextSlotTime = DateTime(now.year, now.month, now.day + 1, 6, 0, 0);
      } else {
        nextSlotTime = DateTime(now.year, now.month, now.day, 6, 0, 0);
      }
    } else {
      newSlot = PuzzleSlot.evening;
      nextSlotTime = DateTime(now.year, now.month, now.day, 6, 0, 0);
    }

    if (mounted) {
      setState(() {
        _currentSlot = newSlot;
        _timeRemaining = nextSlotTime.difference(now);
        _todayFactPreview = _currentSlot.todayFact;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DailyPuzzleScreen(initialSlot: _currentSlot),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _currentSlot.gradientColors,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _currentSlot.gradientColors[0].withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background pattern
            ..._buildDecorations(),

            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildDailyFactBanner(),
                  const SizedBox(height: 14),
                  _buildStatsRow(),
                  const SizedBox(height: 14),
                  _buildProgressAndCategories(),
                  const SizedBox(height: 12),
                  _buildBottomAction(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorations() {
    return [
      Positioned(
        top: -25,
        right: -25,
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        bottom: -35,
        left: -35,
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        top: 50,
        right: 40,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
        ),
      ),
      // Subtle grid pattern
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CustomPaint(
            painter: _SubtlePatternPainter(),
          ),
        ),
      ),
    ];
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Animated emoji container
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              _currentSlot.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _currentSlot.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildLiveBadge(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _currentSlot.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildLevelBadge(),
      ],
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.yellow[200],
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lv',
            style: TextStyle(
              color: _currentSlot.gradientColors[0],
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '$_userLevel',
            style: TextStyle(
              color: _currentSlot.gradientColors[0],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFactBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Text('\u{1F4A1}', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Knowledge Teaser",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _todayFactPreview,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withOpacity(0.6),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.timer_outlined,
            'Ends in',
            _formatDuration(_timeRemaining),
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.local_fire_department_rounded,
            'Streak',
            '$_userStreak Days',
            iconColor: Colors.orangeAccent,
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.emoji_events_rounded,
            'Win up to',
            '${_currentSlot.rewardCoins} XP',
            iconColor: Colors.amberAccent,
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.people_alt_outlined,
            'Playing',
            '${_currentSlot.activePlayers}+',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              color: iconColor ?? Colors.white.withOpacity(0.8), size: 18),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildProgressAndCategories() {
    return Row(
      children: [
        // Daily progress ring
        SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _dailyProgress,
                backgroundColor: Colors.white.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                strokeWidth: 3,
              ),
              Text(
                '${(_dailyProgress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        // Category chips
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _currentSlot.categories.map((cat) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  cat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Row(
      children: [
        // Streak mini calendar (last 7 days)
        Expanded(
          child: Row(
            children: List.generate(7, (i) {
              final streakMod = _userStreak % 7 == 0 ? 7 : _userStreak % 7;
              final isFilled = i < streakMod;
              return Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: isFilled
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: isFilled
                      ? Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: _currentSlot.gradientColors[0],
                        )
                      : null,
                ),
              );
            }),
          ),
        ),
        // Play button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: _currentSlot.gradientColors[0],
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                'PLAY',
                style: TextStyle(
                  color: _currentSlot.gradientColors[0],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Subtle dot pattern painter for the card
class _SubtlePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Puzzle slot enum with all properties
enum PuzzleSlot {
  morning,
  afternoon,
  evening,
}

extension PuzzleSlotExtension on PuzzleSlot {
  String get title {
    switch (this) {
      case PuzzleSlot.morning:
        return "Elder's Puzzle";
      case PuzzleSlot.afternoon:
        return "Women's Challenge";
      case PuzzleSlot.evening:
        return 'Kids Fun Zone';
    }
  }

  String get subtitle {
    switch (this) {
      case PuzzleSlot.morning:
        return 'Wisdom & Knowledge \u00b7 6AM \u2013 12PM';
      case PuzzleSlot.afternoon:
        return 'Creative Thinking \u00b7 12PM \u2013 5PM';
      case PuzzleSlot.evening:
        return 'STEM & Exploration \u00b7 5PM \u2013 6AM';
    }
  }

  String get emoji {
    switch (this) {
      case PuzzleSlot.morning:
        return '\u{1F9E0}';
      case PuzzleSlot.afternoon:
        return '\u{1F490}';
      case PuzzleSlot.evening:
        return '\u{1F680}';
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case PuzzleSlot.morning:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case PuzzleSlot.afternoon:
        return [const Color(0xFFEC4899), const Color(0xFFF472B6)];
      case PuzzleSlot.evening:
        return [const Color(0xFF10B981), const Color(0xFF34D399)];
    }
  }

  int get rewardCoins {
    switch (this) {
      case PuzzleSlot.morning:
        return 100;
      case PuzzleSlot.afternoon:
        return 150;
      case PuzzleSlot.evening:
        return 200;
    }
  }

  int get activePlayers {
    final base = switch (this) {
      PuzzleSlot.morning => 234,
      PuzzleSlot.afternoon => 567,
      PuzzleSlot.evening => 892,
    };
    return base + (DateTime.now().minute % 50);
  }

  List<String> get puzzleTypes {
    switch (this) {
      case PuzzleSlot.morning:
        return [
          '\u{1F9E9} Logic',
          '\u{1F522} Sequence',
          '\u{1F0CF} Memory',
          '\u{1F4DD} Trivia'
        ];
      case PuzzleSlot.afternoon:
        return [
          '\u{1F524} Word Play',
          '\u{1F9EC} Pattern',
          '\u2753 Quiz',
          '\u{1F3AF} Spot It'
        ];
      case PuzzleSlot.evening:
        return [
          '\u{1F52C} Science',
          '\u2795 Math',
          '\u{1F0CF} Match',
          '\u{1F30D} Explore'
        ];
    }
  }

  /// Knowledge categories shown as chips on the widget
  List<String> get categories {
    switch (this) {
      case PuzzleSlot.morning:
        return [
          '\u{1F9E9} Logic',
          '\u{1F4DA} GK',
          '\u{1F3DB}\uFE0F History',
          '\u{1F4A1} Wisdom'
        ];
      case PuzzleSlot.afternoon:
        return [
          '\u{1F524} Words',
          '\u{1F9EC} Pattern',
          '\u{1F957} Wellness',
          '\u{1F3A8} Creative'
        ];
      case PuzzleSlot.evening:
        return [
          '\u{1F52C} Science',
          '\u2795 Math',
          '\u{1F30D} Explore',
          '\u{1F4BB} Tech'
        ];
    }
  }

  String get timeRange {
    switch (this) {
      case PuzzleSlot.morning:
        return '6:00 AM - 12:00 PM';
      case PuzzleSlot.afternoon:
        return '12:01 PM - 5:00 PM';
      case PuzzleSlot.evening:
        return '5:00 PM - 6:00 AM';
    }
  }

  /// A rotating daily knowledge teaser shown on the widget card
  String get todayFact {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final facts = switch (this) {
      PuzzleSlot.morning => [
          'Can you solve a 200-year-old chess puzzle?',
          'Which ancient empire built the first roads?',
          'What logical paradox stumped Aristotle?',
          'How many Indian states can you name in 60s?',
          'What is the Fibonacci sequence used for?',
          'Which planet has the most moons?',
          'Test your vocabulary \u2014 10 words, 60 seconds!',
        ],
      PuzzleSlot.afternoon => [
          'Can you unscramble 5 words in 30 seconds?',
          'Which spice has the most health benefits?',
          'Spot the hidden pattern in this sequence!',
          'Which fabric was used in ancient royal courts?',
          'How many flowers can you identify by photo?',
          'What creative design won the 2024 award?',
          'Test your color perception \u2014 are you a tetrachromat?',
        ],
      PuzzleSlot.evening => [
          'How does AI learn to play chess?',
          'Can you code a simple calculator in your head?',
          'Which animal can survive in outer space?',
          "What makes a rocket escape Earth's gravity?",
          'How do volcanoes form under the ocean?',
          'Build a bridge with 3 shapes \u2014 is it possible?',
          'What is the fastest computer in the world?',
        ],
    };
    return facts[dayOfYear % facts.length];
  }
}
