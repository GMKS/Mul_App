/// Daily Puzzle Screen — Enhanced Edition
/// World-class puzzle gameplay with knowledge-based challenges,
/// adaptive difficulty, rich gamification, and diverse puzzle types.
///
/// Puzzle categories per slot:
/// - Morning (6AM-12PM): Elders — Logic, GK, History, Science, Wisdom
/// - Afternoon (12PM-5PM): Women — Words, Patterns, Wellness, Creative
/// - Evening (5PM-6AM): Kids — STEM, Math, Space, Nature, Tech

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../widgets/daily_triple_puzzle_widget.dart';

// ─────────────────────────── SCREEN ───────────────────────────

class DailyPuzzleScreen extends StatefulWidget {
  final PuzzleSlot? initialSlot;
  const DailyPuzzleScreen({super.key, this.initialSlot});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PuzzleSlot _currentSlot;
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  // Game state
  int _score = 0;
  int _streak = 0;
  int _coins = 0;
  int _puzzlesSolved = 0;
  int _hintsUsed = 0;
  bool _puzzleSolved = false;
  String _difficulty = 'Easy';

  // Puzzle queue — 5 puzzles per session
  late List<PuzzleData> _puzzleQueue;
  int _currentPuzzleIndex = 0;
  PuzzleData get _currentPuzzle => _puzzleQueue[_currentPuzzleIndex];

  // Speed round timer
  int _speedSeconds = 0;
  Timer? _speedTimer;
  bool _isSpeedRound = false;

  // Animations
  late AnimationController _correctAnim;
  late AnimationController _shakeAnim;
  late Animation<double> _shakeAnimation;
  bool _showCorrectOverlay = false;
  bool _showWrongShake = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentSlot = widget.initialSlot ?? _getCurrentSlot();
    _tabController.index = _currentSlot.index;

    _correctAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeAnim, curve: Curves.elasticIn),
    );

    _generatePuzzleQueue();
    _updateTimer();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimer();
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentSlot = PuzzleSlot.values[_tabController.index];
          _resetSession();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    _speedTimer?.cancel();
    _correctAnim.dispose();
    _shakeAnim.dispose();
    super.dispose();
  }

  PuzzleSlot _getCurrentSlot() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return PuzzleSlot.morning;
    if (hour >= 12 && hour < 17) return PuzzleSlot.afternoon;
    return PuzzleSlot.evening;
  }

  void _updateTimer() {
    final now = DateTime.now();
    final hour = now.hour;
    DateTime nextSlotTime;
    if (hour >= 6 && hour < 12) {
      nextSlotTime = DateTime(now.year, now.month, now.day, 12, 0, 1);
    } else if (hour >= 12 && hour < 17) {
      nextSlotTime = DateTime(now.year, now.month, now.day, 17, 0, 0);
    } else if (hour >= 17) {
      nextSlotTime = DateTime(now.year, now.month, now.day + 1, 6, 0, 0);
    } else {
      nextSlotTime = DateTime(now.year, now.month, now.day, 6, 0, 0);
    }
    if (mounted) setState(() => _timeRemaining = nextSlotTime.difference(now));
  }

  void _resetSession() {
    _score = 0;
    _streak = 0;
    _puzzlesSolved = 0;
    _hintsUsed = 0;
    _puzzleSolved = false;
    _currentPuzzleIndex = 0;
    _isSpeedRound = false;
    _speedTimer?.cancel();
    _generatePuzzleQueue();
  }

  void _generatePuzzleQueue() {
    _puzzleQueue = PuzzleData.generateQueue(_currentSlot, count: 5);
    _puzzleSolved = false;
    _difficulty = _puzzleQueue.first.difficulty;
  }

  void _nextPuzzle() {
    if (_currentPuzzleIndex < _puzzleQueue.length - 1) {
      setState(() {
        _currentPuzzleIndex++;
        _puzzleSolved = false;
        _difficulty = _currentPuzzle.difficulty;
      });
    } else {
      _showSessionComplete();
    }
  }

  void _startSpeedRound() {
    setState(() {
      _isSpeedRound = true;
      _speedSeconds = 60;
      _currentPuzzleIndex = 0;
      _puzzleQueue = PuzzleData.generateQueue(_currentSlot, count: 10);
      _puzzleSolved = false;
    });
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_speedSeconds <= 0) {
        t.cancel();
        _showSessionComplete();
      } else {
        if (mounted) setState(() => _speedSeconds--);
      }
    });
  }

  // ──────────── ANSWER CHECKING ────────────

  void _checkAnswer() {
    bool isCorrect = false;
    final p = _currentPuzzle;
    switch (p.puzzleType) {
      case PuzzleType.multipleChoice:
      case PuzzleType.mathProblem:
      case PuzzleType.trueFalse:
      case PuzzleType.sequencePuzzle:
      case PuzzleType.pictureRiddle:
      case PuzzleType.patternMatch:
        isCorrect = p.selectedAnswer == p.correctAnswer;
        break;
      case PuzzleType.wordScramble:
        isCorrect =
            p.userInput?.toLowerCase().trim() == p.correctWord?.toLowerCase();
        break;
      case PuzzleType.memoryMatch:
        isCorrect = p.memoryPairsFound >= (p.memoryCards.length ~/ 2);
        break;
    }

    if (isCorrect) {
      _onPuzzleSolved();
    } else {
      _shakeAnim.forward(from: 0);
      setState(() => _showWrongShake = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showWrongShake = false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.close, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Not quite! Think again...')),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onPuzzleSolved() {
    setState(() {
      _puzzleSolved = true;
      _score += _currentPuzzle.points;
      _streak++;
      _coins += (_currentPuzzle.points * 0.5).round();
      _puzzlesSolved++;
      _showCorrectOverlay = true;
    });
    _correctAnim.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _showCorrectOverlay = false);
        if (_isSpeedRound && _speedSeconds > 0) {
          _nextPuzzle();
        }
      }
    });
  }

  // ──────────── BUILD ────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _currentSlot.gradientColors[0],
              _currentSlot.gradientColors[1].withOpacity(0.3),
              Colors.grey.shade50,
            ],
            stops: const [0.0, 0.35, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Brain Challenge',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isSpeedRound
                      ? 'Speed Round \u2022 ${_speedSeconds}s left'
                      : '${_formatDuration(_timeRemaining)} remaining',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderChip(Icons.bolt, '$_score', Colors.amber),
          const SizedBox(width: 6),
          _buildHeaderChip(
              Icons.local_fire_department, '$_streak', Colors.orangeAccent),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _showLeaderboard,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: Colors.amberAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: _currentSlot.gradientColors[0],
        unselectedLabelColor: Colors.white.withOpacity(0.8),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        tabs: const [
          Tab(text: '\u{1F9E0} Elders'),
          Tab(text: '\u{1F490} Women'),
          Tab(text: '\u{1F680} Kids'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProgressBar(),
          const SizedBox(height: 16),
          _buildDifficultyAndCategory(),
          const SizedBox(height: 16),
          _buildPuzzleCard(),
          const SizedBox(height: 16),
          if (!_puzzleSolved) _buildActionButtons(),
          if (_puzzleSolved && !_isSpeedRound) _buildSolvedActions(),
          const SizedBox(height: 16),
          if (!_isSpeedRound) _buildSpeedRoundBanner(),
          const SizedBox(height: 12),
          _buildLeaderboardPreview(),
          const SizedBox(height: 16),
          _buildDidYouKnow(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = _puzzleQueue.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Puzzle ${_currentPuzzleIndex + 1} of $total',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              '$_puzzlesSolved solved',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ((_currentPuzzleIndex + (_puzzleSolved ? 1 : 0)) / total)
                .clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(_currentSlot.gradientColors[0]),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyAndCategory() {
    return Row(
      children: [
        _buildTag(
            _currentPuzzle.categoryIcon,
            _currentPuzzle.category,
            _currentSlot.gradientColors[0].withOpacity(0.1),
            _currentSlot.gradientColors[0]),
        const SizedBox(width: 8),
        _buildTag(
          _difficulty == 'Easy'
              ? '\u{1F7E2}'
              : _difficulty == 'Medium'
                  ? '\u{1F7E1}'
                  : '\u{1F534}',
          _difficulty,
          _difficulty == 'Easy'
              ? Colors.green.shade50
              : _difficulty == 'Medium'
                  ? Colors.orange.shade50
                  : Colors.red.shade50,
          _difficulty == 'Easy'
              ? Colors.green
              : _difficulty == 'Medium'
                  ? Colors.orange
                  : Colors.red,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '+${_currentPuzzle.points} pts',
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String emoji, String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  // ──────────── PUZZLE CARD ────────────

  Widget _buildPuzzleCard() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              _showWrongShake ? sin(_shakeAnimation.value * 3) * 8 : 0, 0),
          child: child,
        );
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _currentSlot.gradientColors[0].withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Puzzle type header
                Row(
                  children: [
                    Text(_currentPuzzle.emoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentPuzzle.type,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _currentSlot.gradientColors[0],
                        ),
                      ),
                    ),
                    if (_currentPuzzle.isBonusQuestion)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '\u2B50 BONUS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Question
                Text(
                  _currentPuzzle.question,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                // Math expression if any
                if (_currentPuzzle.mathExpression != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _currentSlot.gradientColors[0].withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _currentSlot.gradientColors[0].withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      _currentPuzzle.mathExpression!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _currentSlot.gradientColors[0],
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Interactive puzzle area
                _buildInteractivePuzzle(),
              ],
            ),
          ),

          // Correct overlay
          if (_showCorrectOverlay)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 60),
                      SizedBox(height: 12),
                      Text(
                        'Correct!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractivePuzzle() {
    switch (_currentPuzzle.puzzleType) {
      case PuzzleType.multipleChoice:
      case PuzzleType.pictureRiddle:
        return _buildMultipleChoice();
      case PuzzleType.wordScramble:
        return _buildWordScramble();
      case PuzzleType.mathProblem:
        return _buildMathProblem();
      case PuzzleType.memoryMatch:
        return _buildMemoryMatch();
      case PuzzleType.trueFalse:
        return _buildTrueFalse();
      case PuzzleType.sequencePuzzle:
        return _buildSequencePuzzle();
      case PuzzleType.patternMatch:
        return _buildPatternMatch();
    }
  }

  Widget _buildMultipleChoice() {
    return Column(
      children: List.generate(_currentPuzzle.options.length, (i) {
        final isSelected = _currentPuzzle.selectedAnswer == i;
        final isCorrect = _puzzleSolved && i == _currentPuzzle.correctAnswer;
        final isWrong = _puzzleSolved && isSelected && !isCorrect;
        final letter = String.fromCharCode(65 + i);

        return GestureDetector(
          onTap: _puzzleSolved
              ? null
              : () => setState(() => _currentPuzzle.selectedAnswer = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.shade50
                  : isWrong
                      ? Colors.red.shade50
                      : isSelected
                          ? _currentSlot.gradientColors[0].withOpacity(0.08)
                          : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCorrect
                    ? Colors.green
                    : isWrong
                        ? Colors.red
                        : isSelected
                            ? _currentSlot.gradientColors[0]
                            : Colors.grey.shade200,
                width: isSelected || isCorrect || isWrong ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _currentSlot.gradientColors[0]
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentPuzzle.options[i],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isCorrect
                          ? Colors.green.shade800
                          : isWrong
                              ? Colors.red.shade800
                              : null,
                    ),
                  ),
                ),
                if (isCorrect)
                  const Icon(Icons.check_circle, color: Colors.green, size: 22),
                if (isWrong)
                  const Icon(Icons.cancel, color: Colors.red, size: 22),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrueFalse() {
    return Row(
      children: [
        Expanded(
          child: _buildTFOption(0, '\u2705 True', Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTFOption(1, '\u274C False', Colors.red),
        ),
      ],
    );
  }

  Widget _buildTFOption(int value, String label, Color color) {
    final isSelected = _currentPuzzle.selectedAnswer == value;
    return GestureDetector(
      onTap: _puzzleSolved
          ? null
          : () => setState(() => _currentPuzzle.selectedAnswer = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? color : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSequencePuzzle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _currentSlot.gradientColors[0].withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (_currentPuzzle.sequenceDisplay ?? []).map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: item == '?'
                      ? Colors.amber.shade100
                      : _currentSlot.gradientColors[0].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: item == '?'
                      ? Border.all(color: Colors.amber, width: 2)
                      : null,
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: item == '?'
                        ? Colors.amber.shade800
                        : _currentSlot.gradientColors[0],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildMultipleChoice(),
      ],
    );
  }

  Widget _buildPatternMatch() {
    return Column(
      children: [
        if (_currentPuzzle.patternGrid != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: _currentPuzzle.patternGrid!.map((cell) {
                return Container(
                  decoration: BoxDecoration(
                    color: cell == '?'
                        ? Colors.amber.shade100
                        : _currentSlot.gradientColors[0].withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: cell == '?'
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      cell,
                      style: TextStyle(
                        fontSize: 22,
                        color: cell == '?'
                            ? Colors.amber.shade800
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),
        _buildMultipleChoice(),
      ],
    );
  }

  Widget _buildWordScramble() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _currentSlot.gradientColors[0].withOpacity(0.08),
                _currentSlot.gradientColors[1].withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (_currentPuzzle.scrambledWord ?? '').split('').map((c) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Text(
                  c,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _currentSlot.gradientColors[0],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (val) {
            _currentPuzzle.userInput = val;
            setState(() {});
          },
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4),
          decoration: InputDecoration(
            hintText: 'YOUR ANSWER',
            hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 2),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: _currentSlot.gradientColors[0], width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMathProblem() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(_currentPuzzle.options.length, (i) {
        final isSelected = _currentPuzzle.selectedAnswer == i;
        return GestureDetector(
          onTap: _puzzleSolved
              ? null
              : () => setState(() => _currentPuzzle.selectedAnswer = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? _currentSlot.gradientColors[0]
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? _currentSlot.gradientColors[0]
                    : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _currentSlot.gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                _currentPuzzle.options[i],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[800],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMemoryMatch() {
    if (_currentPuzzle.memoryCards.isEmpty) {
      final emojis = [
        '\u{1F34E}',
        '\u{1F34A}',
        '\u{1F34B}',
        '\u{1F347}',
        '\u{1F353}',
        '\u{1F352}'
      ];
      _currentPuzzle.memoryCards = [...emojis, ...emojis]..shuffle();
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(_currentPuzzle.memoryCards.length, (i) {
        final isRevealed = _currentPuzzle.revealedCards.contains(i) ||
            _currentPuzzle.matchedCards.contains(i);
        return GestureDetector(
          onTap: () => _onMemoryCardTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _currentPuzzle.matchedCards.contains(i)
                  ? Colors.green.shade50
                  : isRevealed
                      ? _currentSlot.gradientColors[0].withOpacity(0.1)
                      : _currentSlot.gradientColors[0],
              borderRadius: BorderRadius.circular(12),
              border: _currentPuzzle.matchedCards.contains(i)
                  ? Border.all(color: Colors.green, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isRevealed ? _currentPuzzle.memoryCards[i] : '?',
                style: TextStyle(
                  fontSize: isRevealed ? 26 : 22,
                  fontWeight: FontWeight.bold,
                  color: isRevealed ? null : Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onMemoryCardTap(int index) {
    if (_currentPuzzle.revealedCards.contains(index) ||
        _currentPuzzle.matchedCards.contains(index) ||
        _currentPuzzle.revealedCards.length >= 2) return;

    setState(() {
      _currentPuzzle.revealedCards.add(index);
    });

    if (_currentPuzzle.revealedCards.length == 2) {
      final first = _currentPuzzle.revealedCards[0];
      final second = _currentPuzzle.revealedCards[1];
      if (_currentPuzzle.memoryCards[first] ==
          _currentPuzzle.memoryCards[second]) {
        setState(() {
          _currentPuzzle.matchedCards.addAll([first, second]);
          _currentPuzzle.memoryPairsFound++;
          _currentPuzzle.revealedCards.clear();
        });
        if (_currentPuzzle.memoryPairsFound >=
            _currentPuzzle.memoryCards.length ~/ 2) {
          _onPuzzleSolved();
        }
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => _currentPuzzle.revealedCards.clear());
          }
        });
      }
    }
  }

  // ──────────── ACTION BUTTONS ────────────

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showHintDialog,
            icon: const Icon(Icons.lightbulb_outline, size: 18),
            label: const Text('Hint'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _currentSlot.gradientColors[0],
              side: BorderSide(color: _currentSlot.gradientColors[0]),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _nextPuzzle,
            icon: const Icon(Icons.skip_next_rounded, size: 18),
            label: const Text('Skip'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[600],
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _currentPuzzle.selectedAnswer != null ||
                    (_currentPuzzle.puzzleType == PuzzleType.wordScramble &&
                        (_currentPuzzle.userInput?.isNotEmpty ?? false))
                ? _checkAnswer
                : null,
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentSlot.gradientColors[0],
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSolvedActions() {
    return Column(
      children: [
        if (_currentPuzzle.explanation != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_rounded,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Did you know?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentPuzzle.explanation!,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _nextPuzzle,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Next Puzzle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentSlot.gradientColors[0],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedRoundBanner() {
    return GestureDetector(
      onTap: _startSpeedRound,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.deepOrange.shade400],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('\u26A1', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Speed Round Challenge!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Solve as many as you can in 60 seconds \u2022 2x points!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_filled, color: Colors.white, size: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildDidYouKnow() {
    final facts = [
      'The human brain processes 70,000 thoughts per day.',
      'Honey never spoils \u2014 3,000 year old honey is still edible.',
      'Octopuses have 3 hearts and blue blood.',
      'Bananas are berries, but strawberries are not.',
      'A day on Venus is longer than a year on Venus.',
      'The Eiffel Tower grows 6 inches in summer due to heat.',
      'Your brain uses 20% of your total energy.',
    ];
    final fact = facts[DateTime.now().day % facts.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        children: [
          const Text('\u{1F4DA}', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fun Fact of the Day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fact,
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardPreview() {
    final leaders = [
      {'name': 'Ramesh K.', 'score': 1250, 'rank': 1},
      {'name': 'Priya S.', 'score': 1180, 'rank': 2},
      {'name': 'Suresh M.', 'score': 1050, 'rank': 3},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('\u{1F3C6}', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                "Today's Leaders",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showLeaderboard,
                child: Text(
                  'View All',
                  style: TextStyle(color: _currentSlot.gradientColors[0]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...leaders.map((leader) {
            final rank = leader['rank'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: rank == 1
                          ? Colors.amber
                          : rank == 2
                              ? Colors.grey.shade400
                              : Colors.orange.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        rank == 1
                            ? '\u{1F947}'
                            : rank == 2
                                ? '\u{1F948}'
                                : '\u{1F949}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      leader['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${leader['score']} pts',
                    style: TextStyle(
                      color: _currentSlot.gradientColors[0],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ──────────── DIALOGS ────────────

  void _showSessionComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{1F389}', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Session Complete!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You solved $_puzzlesSolved puzzles!',
                style: TextStyle(color: Colors.grey[600], fontSize: 15)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildResultStat('\u26A1', '$_score', 'Points'),
                _buildResultStat('\u{1F525}', '$_streak', 'Streak'),
                _buildResultStat('\u{1F4B0}', '$_coins', 'Coins'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _resetSession();
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Play Again'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentSlot.gradientColors[0],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  void _showLeaderboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '\u{1F3C6} ${_currentSlot.title} Leaderboard',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final rank = index + 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? _currentSlot.gradientColors[0].withOpacity(0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: rank <= 3
                          ? Border.all(
                              color: _currentSlot.gradientColors[0]
                                  .withOpacity(0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: rank == 1
                                ? Colors.amber
                                : rank == 2
                                    ? Colors.grey.shade400
                                    : rank == 3
                                        ? Colors.orange.shade300
                                        : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: rank <= 3
                                ? Text(
                                    rank == 1
                                        ? '\u{1F947}'
                                        : rank == 2
                                            ? '\u{1F948}'
                                            : '\u{1F949}',
                                    style: const TextStyle(fontSize: 18))
                                : Text('$rank',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Player $rank',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text('${10 - (index % 5)} puzzles solved',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${1500 - (index * 50)} pts',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _currentSlot.gradientColors[0])),
                            Text('\u{1F525} ${10 - (index % 7)} streak',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('\u{1F4A1}', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('Need a Hint?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Use a hint to get help with this puzzle!',
                style: TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text('Cost: 10 coins',
                      style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _hintsUsed++);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Hint: ${_currentPuzzle.hint}')),
                    ],
                  ),
                  backgroundColor: Colors.amber.shade700,
                  duration: const Duration(seconds: 6),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Use Hint'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────── PUZZLE TYPES ───────────────────────

enum PuzzleType {
  multipleChoice,
  wordScramble,
  mathProblem,
  memoryMatch,
  trueFalse,
  sequencePuzzle,
  patternMatch,
  pictureRiddle,
}

// ─────────────────────── PUZZLE DATA ───────────────────────

class PuzzleData {
  final String type;
  final String emoji;
  final String question;
  final String difficulty;
  final int points;
  final List<String> options;
  final int correctAnswer;
  final String hint;
  final PuzzleType puzzleType;
  final String category;
  final String categoryIcon;
  final bool isBonusQuestion;
  final String? explanation;

  // Puzzle-specific data
  String? scrambledWord;
  String? correctWord;
  String? mathExpression;
  String? userInput;
  int? selectedAnswer;
  List<int> revealedCards = [];
  List<int> matchedCards = [];
  int memoryPairsFound = 0;
  List<String> memoryCards = [];
  List<String>? sequenceDisplay;
  List<String>? patternGrid;

  PuzzleData({
    required this.type,
    required this.emoji,
    required this.question,
    required this.difficulty,
    required this.points,
    required this.options,
    required this.correctAnswer,
    required this.hint,
    required this.puzzleType,
    this.category = 'General',
    this.categoryIcon = '\u{2753}',
    this.isBonusQuestion = false,
    this.explanation,
    this.scrambledWord,
    this.correctWord,
    this.mathExpression,
    this.sequenceDisplay,
    this.patternGrid,
  });

  /// Generate a queue of puzzles for a session
  static List<PuzzleData> generateQueue(PuzzleSlot slot, {int count = 5}) {
    final now = DateTime.now();
    final dateSeed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(dateSeed + slot.index);
    final allPuzzles = _getAllPuzzles(slot);
    allPuzzles.shuffle(random);
    return allPuzzles.take(count).toList();
  }

  /// Backward-compatible single puzzle generator
  static PuzzleData generate(PuzzleSlot slot) {
    return generateQueue(slot, count: 1).first;
  }

  static List<PuzzleData> _getAllPuzzles(PuzzleSlot slot) {
    switch (slot) {
      case PuzzleSlot.morning:
        return _eldersPuzzles();
      case PuzzleSlot.afternoon:
        return _womensPuzzles();
      case PuzzleSlot.evening:
        return _kidsPuzzles();
    }
  }

  // ════════════════════════════════════════════════════════════
  //  ELDERS — Logic, GK, History, Science, Wisdom
  // ════════════════════════════════════════════════════════════

  static List<PuzzleData> _eldersPuzzles() {
    return [
      PuzzleData(
        type: 'Logic Puzzle',
        emoji: '\u{1F9E0}',
        question:
            'If all roses are flowers, and some flowers fade quickly, which statement must be true?',
        difficulty: 'Medium',
        points: 50,
        options: [
          'All roses fade quickly',
          'Some roses may fade quickly',
          'No roses fade quickly',
          'Roses are not flowers',
        ],
        correctAnswer: 1,
        hint: 'Think about the relationship between "all" and "some"',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Logic',
        categoryIcon: '\u{1F9E9}',
        explanation:
            'Since all roses are flowers, and some flowers fade quickly, it is possible (but not certain) that some roses are among those that fade quickly.',
      ),
      PuzzleData(
        type: 'Logic Puzzle',
        emoji: '\u{1F9E9}',
        question:
            'A bat and a ball cost \u20B9110. The bat costs \u20B9100 more than the ball. How much does the ball cost?',
        difficulty: 'Hard',
        points: 80,
        options: ['\u20B910', '\u20B95', '\u20B915', '\u20B920'],
        correctAnswer: 1,
        hint: 'Let ball = x, then bat = x + 100, total = 2x + 100 = 110',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Logic',
        categoryIcon: '\u{1F9E9}',
        isBonusQuestion: true,
        explanation:
            'If the ball costs \u20B95, the bat costs \u20B95 + \u20B9100 = \u20B9105. Total: \u20B95 + \u20B9105 = \u20B9110. Most people intuitively say \u20B910 \u2014 this is the famous "bat and ball" cognitive puzzle!',
      ),
      PuzzleData(
        type: 'Lateral Thinking',
        emoji: '\u{1F50D}',
        question:
            'A man pushes his car to a hotel and tells the owner he is bankrupt. Why?',
        difficulty: 'Hard',
        points: 75,
        options: [
          'His car broke down',
          'He is playing Monopoly',
          'He owes the hotel money',
          'He is a taxi driver',
        ],
        correctAnswer: 1,
        hint: 'Think beyond the obvious \u2014 this might not be a real car',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Logic',
        categoryIcon: '\u{1F9E9}',
        explanation:
            'This is a classic lateral thinking puzzle. He is playing Monopoly! His game piece (car) lands on a hotel, and he has to pay rent he cannot afford.',
      ),
      PuzzleData(
        type: 'General Knowledge',
        emoji: '\u{1F4DA}',
        question: 'Which Indian city is known as the "City of Pearls"?',
        difficulty: 'Easy',
        points: 30,
        options: ['Mumbai', 'Hyderabad', 'Chennai', 'Jaipur'],
        correctAnswer: 1,
        hint: 'This city is also famous for Biryani',
        puzzleType: PuzzleType.multipleChoice,
        category: 'GK',
        categoryIcon: '\u{1F4DA}',
        explanation:
            'Hyderabad is called the "City of Pearls" due to its historical pearl trading industry. It was once the global center for trading large diamonds and pearls.',
      ),
      PuzzleData(
        type: 'General Knowledge',
        emoji: '\u{1F30D}',
        question: 'Which is the largest continent by area?',
        difficulty: 'Easy',
        points: 25,
        options: ['Africa', 'Europe', 'Asia', 'North America'],
        correctAnswer: 2,
        hint: 'India is part of this continent',
        puzzleType: PuzzleType.multipleChoice,
        category: 'GK',
        categoryIcon: '\u{1F4DA}',
        explanation:
            'Asia covers about 44.58 million sq km, making it the largest continent, home to over 60% of the world\u2019s population.',
      ),
      PuzzleData(
        type: 'True or False',
        emoji: '\u2705',
        question:
            'The Great Wall of China is visible from space with the naked eye.',
        difficulty: 'Medium',
        points: 40,
        options: ['True', 'False'],
        correctAnswer: 1,
        hint: 'Astronauts have spoken about this',
        puzzleType: PuzzleType.trueFalse,
        category: 'GK',
        categoryIcon: '\u{1F4DA}',
        explanation:
            'This is actually a myth! The Great Wall is too narrow to be seen from space with the naked eye. Astronaut Chris Hadfield confirmed this.',
      ),
      PuzzleData(
        type: 'History Quiz',
        emoji: '\u{1F3DB}\uFE0F',
        question: 'Who was the first President of India?',
        difficulty: 'Easy',
        points: 30,
        options: [
          'Jawaharlal Nehru',
          'Dr. Rajendra Prasad',
          'Sardar Patel',
          'B.R. Ambedkar'
        ],
        correctAnswer: 1,
        hint: 'He served from 1950 to 1962',
        puzzleType: PuzzleType.multipleChoice,
        category: 'History',
        categoryIcon: '\u{1F3DB}\uFE0F',
        explanation:
            'Dr. Rajendra Prasad served as the first President of India from 1950 to 1962. He is the only President to have served two full terms.',
      ),
      PuzzleData(
        type: 'History Quiz',
        emoji: '\u{1F3DB}\uFE0F',
        question: 'In which year did India gain independence?',
        difficulty: 'Easy',
        points: 25,
        options: ['1945', '1947', '1950', '1942'],
        correctAnswer: 1,
        hint: 'August 15 of this year',
        puzzleType: PuzzleType.multipleChoice,
        category: 'History',
        categoryIcon: '\u{1F3DB}\uFE0F',
        explanation:
            'India gained independence from British rule on August 15, 1947, after nearly 200 years of colonial rule.',
      ),
      PuzzleData(
        type: 'Science',
        emoji: '\u{1F52C}',
        question: 'Which planet is known as the Red Planet?',
        difficulty: 'Easy',
        points: 30,
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 1,
        hint: 'Named after the Roman god of war',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Science',
        categoryIcon: '\u{1F52C}',
        explanation:
            'Mars appears red because its surface contains iron oxide (rust). NASA\u2019s Perseverance rover is currently exploring it!',
      ),
      PuzzleData(
        type: 'Science',
        emoji: '\u{1F9EC}',
        question: 'How many bones does an adult human body have?',
        difficulty: 'Medium',
        points: 45,
        options: ['196', '206', '216', '186'],
        correctAnswer: 1,
        hint: 'Babies have about 270, but some fuse as we grow',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Science',
        categoryIcon: '\u{1F52C}',
        explanation:
            'An adult human has 206 bones. Babies are born with about 270 soft bones, many of which fuse together by adulthood.',
      ),
      PuzzleData(
        type: 'Number Sequence',
        emoji: '\u{1F522}',
        question: 'What comes next in the sequence?',
        difficulty: 'Medium',
        points: 50,
        options: ['32', '36', '28', '34'],
        correctAnswer: 0,
        hint: 'Each number doubles',
        puzzleType: PuzzleType.sequencePuzzle,
        sequenceDisplay: ['2', '4', '8', '16', '?'],
        category: 'Logic',
        categoryIcon: '\u{1F9E9}',
        explanation:
            'This is a geometric sequence where each number is multiplied by 2: 2, 4, 8, 16, 32.',
      ),
      PuzzleData(
        type: 'Word Wisdom',
        emoji: '\u{1F4DD}',
        question: 'What is the meaning of the proverb "Jaisa des vaisa bhes"?',
        difficulty: 'Easy',
        points: 30,
        options: [
          'Home is best',
          'When in Rome, do as Romans do',
          'Birds of a feather flock together',
          'Time is money',
        ],
        correctAnswer: 1,
        hint: "It's about adapting to surroundings",
        puzzleType: PuzzleType.multipleChoice,
        category: 'Wisdom',
        categoryIcon: '\u{1F4A1}',
        explanation:
            'This Hindi proverb teaches adaptability \u2014 adjust your behaviour based on the environment you are in.',
      ),
      PuzzleData(
        type: 'Indian Culture',
        emoji: '\u{1FA94}',
        question: 'Which festival is known as the Festival of Lights?',
        difficulty: 'Easy',
        points: 25,
        options: ['Holi', 'Diwali', 'Navratri', 'Pongal'],
        correctAnswer: 1,
        hint: 'Celebrates the victory of light over darkness',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Wisdom',
        categoryIcon: '\u{1F4A1}',
        explanation:
            'Diwali, the Festival of Lights, celebrates Lord Rama\u2019s return to Ayodhya. It symbolises the victory of good over evil and light over darkness.',
      ),
      PuzzleData(
        type: 'Pattern Recognition',
        emoji: '\u{1F9EC}',
        question: 'Which symbol replaces the "?" in the grid?',
        difficulty: 'Hard',
        points: 70,
        options: ['\u25B3', '\u25CB', '\u25A0', '\u2666'],
        correctAnswer: 0,
        hint: 'Look at rows and columns for repeating patterns',
        puzzleType: PuzzleType.patternMatch,
        patternGrid: [
          '\u25CB',
          '\u25A0',
          '\u25B3',
          '\u25A0',
          '\u25B3',
          '\u25CB',
          '\u25B3',
          '\u25CB',
          '?'
        ],
        category: 'Logic',
        categoryIcon: '\u{1F9E9}',
        isBonusQuestion: true,
        explanation:
            'Each row and column contains exactly one circle, one square, and one triangle. The missing piece is a square (\u25B3).',
      ),
      PuzzleData(
        type: 'Memory Match',
        emoji: '\u{1F0CF}',
        question: 'Match all the pairs! Test your memory.',
        difficulty: 'Medium',
        points: 60,
        options: [],
        correctAnswer: 0,
        hint: 'Try to remember positions as you flip',
        puzzleType: PuzzleType.memoryMatch,
        category: 'Memory',
        categoryIcon: '\u{1F9E0}',
        explanation:
            'Memory games strengthen your working memory and visual recall. Regular practice can improve cognitive function by up to 30%!',
      ),
    ];
  }

  // ════════════════════════════════════════════════════════════
  //  WOMEN — Words, Patterns, Wellness, Creative
  // ════════════════════════════════════════════════════════════

  static List<PuzzleData> _womensPuzzles() {
    return [
      PuzzleData(
        type: 'Word Scramble',
        emoji: '\u{1F524}',
        question: 'Unscramble this word related to cooking:',
        difficulty: 'Medium',
        points: 40,
        options: [],
        correctAnswer: 0,
        hint: "It's a common Indian spice",
        puzzleType: PuzzleType.wordScramble,
        scrambledWord: 'CMRIEU',
        correctWord: 'CUMIN',
        category: 'Words',
        categoryIcon: '\u{1F524}',
        explanation:
            'Cumin (Jeera) is one of the most widely used spices in Indian cooking. It aids digestion and is rich in iron.',
      ),
      PuzzleData(
        type: 'Word Scramble',
        emoji: '\u{1F524}',
        question: 'Unscramble this kitchen item:',
        difficulty: 'Medium',
        points: 40,
        options: [],
        correctAnswer: 0,
        hint: 'Used for rolling rotis',
        puzzleType: PuzzleType.wordScramble,
        scrambledWord: 'ELNAIB',
        correctWord: 'BELAN',
        category: 'Words',
        categoryIcon: '\u{1F524}',
        explanation:
            'A Belan (rolling pin) is essential in Indian kitchens for making rotis, parathas, and puris.',
      ),
      PuzzleData(
        type: 'Word Scramble',
        emoji: '\u{1F524}',
        question: 'Unscramble this fabric name:',
        difficulty: 'Hard',
        points: 55,
        options: [],
        correctAnswer: 0,
        hint: 'A luxurious Indian textile from Varanasi',
        puzzleType: PuzzleType.wordScramble,
        scrambledWord: 'AIRANSAB',
        correctWord: 'BANARASI',
        category: 'Words',
        categoryIcon: '\u{1F524}',
        isBonusQuestion: true,
        explanation:
            'Banarasi silk sarees from Varanasi are among the finest in India, known for gold and silver brocade and zari work.',
      ),
      PuzzleData(
        type: 'Pattern Recognition',
        emoji: '\u{1F9EC}',
        question:
            'What comes next: \u{1F338} \u{1F33C} \u{1F337} \u{1F338} \u{1F33C} \u{1F337} \u{1F338} ?',
        difficulty: 'Easy',
        points: 30,
        options: ['\u{1F33C}', '\u{1F337}', '\u{1F338}', '\u{1F339}'],
        correctAnswer: 0,
        hint: 'It follows a repeating 3-flower pattern',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Pattern',
        categoryIcon: '\u{1F9EC}',
        explanation:
            'The pattern repeats every 3 flowers: Cherry Blossom, Chrysanthemum, Tulip. After Cherry Blossom, Chrysanthemum is next.',
      ),
      PuzzleData(
        type: 'Number Sequence',
        emoji: '\u{1F522}',
        question: 'What number comes next?',
        difficulty: 'Medium',
        points: 45,
        options: ['21', '25', '24', '23'],
        correctAnswer: 0,
        hint: 'Look at the differences between consecutive numbers',
        puzzleType: PuzzleType.sequencePuzzle,
        sequenceDisplay: ['1', '3', '6', '10', '15', '?'],
        category: 'Pattern',
        categoryIcon: '\u{1F9EC}',
        explanation:
            'These are triangular numbers! The differences are 2, 3, 4, 5, 6... so the next number is 15 + 6 = 21.',
      ),
      PuzzleData(
        type: 'Health & Wellness',
        emoji: '\u{1F957}',
        question: 'Which vitamin is found abundantly in citrus fruits?',
        difficulty: 'Easy',
        points: 30,
        options: ['Vitamin A', 'Vitamin C', 'Vitamin D', 'Vitamin B12'],
        correctAnswer: 1,
        hint: 'It helps boost immunity',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Wellness',
        categoryIcon: '\u{1F957}',
        explanation:
            'Vitamin C is crucial for immune function, skin health, and iron absorption. Just one orange provides over 100% of your daily requirement.',
      ),
      PuzzleData(
        type: 'True or False',
        emoji: '\u2705',
        question:
            'Drinking warm water with lemon in the morning detoxifies the liver.',
        difficulty: 'Medium',
        points: 40,
        options: ['True', 'False'],
        correctAnswer: 1,
        hint: 'Think about what science says vs. popular belief',
        puzzleType: PuzzleType.trueFalse,
        category: 'Wellness',
        categoryIcon: '\u{1F957}',
        explanation:
            'While lemon water is hydrating and contains Vitamin C, there\u2019s no scientific evidence it "detoxifies" the liver. The liver detoxifies itself naturally!',
      ),
      PuzzleData(
        type: 'Health Quiz',
        emoji: '\u{1F9D8}\u200D\u2640\uFE0F',
        question:
            'Which yoga pose is best for improving flexibility of the spine?',
        difficulty: 'Medium',
        points: 40,
        options: ['Mountain Pose', 'Cat-Cow Pose', 'Warrior I', 'Tree Pose'],
        correctAnswer: 1,
        hint: 'It involves arching and rounding the back',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Wellness',
        categoryIcon: '\u{1F957}',
        explanation:
            'Cat-Cow Pose (Marjaryasana-Bitilasana) gently stretches the spine in both directions, improving flexibility and relieving back tension.',
      ),
      PuzzleData(
        type: 'Kitchen Trivia',
        emoji: '\u{1F469}\u200D\u{1F373}',
        question: 'Which ingredient makes rotis soft and fluffy?',
        difficulty: 'Easy',
        points: 30,
        options: ['Salt', 'Milk or yogurt', 'Sugar', 'Baking soda'],
        correctAnswer: 1,
        hint: "It's a dairy product",
        puzzleType: PuzzleType.multipleChoice,
        category: 'Creative',
        categoryIcon: '\u{1F3A8}',
        explanation:
            'Adding milk or yogurt to the dough makes rotis softer because the fat in dairy keeps the gluten strands tender.',
      ),
      PuzzleData(
        type: 'Fashion Quiz',
        emoji: '\u{1F457}',
        question:
            'Which fabric is traditionally used for making Banarasi sarees?',
        difficulty: 'Medium',
        points: 40,
        options: ['Cotton', 'Silk', 'Polyester', 'Wool'],
        correctAnswer: 1,
        hint: "It's a luxurious natural fabric",
        puzzleType: PuzzleType.multipleChoice,
        category: 'Creative',
        categoryIcon: '\u{1F3A8}',
        explanation:
            'Banarasi sarees are made from fine silk and are known for their gold and silver brocade, intricate zari work, and Mughal-inspired designs.',
      ),
      PuzzleData(
        type: 'Beauty Tips',
        emoji: '\u{1F484}',
        question: 'Which natural ingredient is known for skin brightening?',
        difficulty: 'Easy',
        points: 30,
        options: ['Turmeric', 'Salt', 'Sugar', 'Pepper'],
        correctAnswer: 0,
        hint: "It's yellow in color",
        puzzleType: PuzzleType.multipleChoice,
        category: 'Wellness',
        categoryIcon: '\u{1F957}',
        explanation:
            'Turmeric contains curcumin which has anti-inflammatory and antioxidant properties that can brighten skin and reduce dark spots.',
      ),
      PuzzleData(
        type: 'Home & Living',
        emoji: '\u{1F3E1}',
        question:
            'According to Vastu, which direction should the main door face ideally?',
        difficulty: 'Medium',
        points: 40,
        options: ['South', 'North or East', 'West', 'Southwest'],
        correctAnswer: 1,
        hint: 'These directions bring positive energy',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Creative',
        categoryIcon: '\u{1F3A8}',
        explanation:
            'In Vastu Shastra, North and East-facing doors are considered most auspicious as they allow maximum positive energy and sunlight.',
      ),
      PuzzleData(
        type: 'Memory Match',
        emoji: '\u{1F0CF}',
        question: 'Match the flower pairs! \u{1F338}',
        difficulty: 'Easy',
        points: 35,
        options: [],
        correctAnswer: 0,
        hint: 'Focus on positions as you flip',
        puzzleType: PuzzleType.memoryMatch,
        category: 'Pattern',
        categoryIcon: '\u{1F9EC}',
        explanation:
            'Memory matching improves visual-spatial memory and concentration. Playing regularly can sharpen your mind!',
      ),
    ];
  }

  // ════════════════════════════════════════════════════════════
  //  KIDS — STEM, Math, Space, Nature, Tech
  // ════════════════════════════════════════════════════════════

  static List<PuzzleData> _kidsPuzzles() {
    return [
      PuzzleData(
        type: 'Animal Quiz',
        emoji: '\u{1F981}',
        question: 'Which animal is known as the "King of the Jungle"?',
        difficulty: 'Easy',
        points: 20,
        options: ['Elephant', 'Lion', 'Tiger', 'Bear'],
        correctAnswer: 1,
        hint: 'It has a big mane',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Science',
        categoryIcon: '\u{1F52C}',
        explanation:
            'The lion is called the "King of the Jungle" because of its majestic mane and powerful roar. Fun fact: lions are actually found in grasslands, not jungles!',
      ),
      PuzzleData(
        type: 'Nature Quiz',
        emoji: '\u{1F333}',
        question: 'What do plants need to make food through photosynthesis?',
        difficulty: 'Easy',
        points: 25,
        options: [
          'Water, soil, and air',
          'Sunlight, water, and carbon dioxide',
          'Rain, wind, and soil',
          'Oxygen, water, and soil'
        ],
        correctAnswer: 1,
        hint: 'One comes from the sun!',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Science',
        categoryIcon: '\u{1F52C}',
        explanation:
            'Plants use sunlight as energy to combine water (H\u2082O) and carbon dioxide (CO\u2082) to make glucose (food) and release oxygen. This is photosynthesis!',
      ),
      PuzzleData(
        type: 'True or False',
        emoji: '\u{1F422}',
        question: 'A tortoise can live for more than 150 years.',
        difficulty: 'Easy',
        points: 25,
        options: ['True', 'False'],
        correctAnswer: 0,
        hint: 'Think about the Galapagos Islands',
        puzzleType: PuzzleType.trueFalse,
        category: 'Science',
        categoryIcon: '\u{1F52C}',
        explanation:
            'Giant tortoises can live over 175 years! Jonathan, a Seychelles tortoise, is over 190 years old \u2014 the oldest known living land animal!',
      ),
      PuzzleData(
        type: 'Space Quiz',
        emoji: '\u{1F680}',
        question: 'What is the largest planet in our solar system?',
        difficulty: 'Easy',
        points: 25,
        options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswer: 2,
        hint: 'It has a big red spot',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Explore',
        categoryIcon: '\u{1F30D}',
        explanation:
            'Jupiter is so large that over 1,300 Earths could fit inside it! Its Great Red Spot is actually a giant storm bigger than Earth.',
      ),
      PuzzleData(
        type: 'Space Quiz',
        emoji: '\u{1F319}',
        question:
            'How long does it take for light from the Sun to reach Earth?',
        difficulty: 'Medium',
        points: 40,
        options: ['8 seconds', '8 minutes', '8 hours', '8 days'],
        correctAnswer: 1,
        hint: 'Light travels at 300,000 km per second',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Explore',
        categoryIcon: '\u{1F30D}',
        explanation:
            'Light from the Sun takes about 8 minutes and 20 seconds to reach Earth, travelling at 299,792 km/s across 150 million km!',
      ),
      PuzzleData(
        type: 'Math Fun',
        emoji: '\u2795',
        question: 'Solve this:',
        difficulty: 'Easy',
        points: 25,
        options: ['12', '15', '18', '20'],
        correctAnswer: 1,
        hint: 'Add step by step',
        puzzleType: PuzzleType.mathProblem,
        mathExpression: '7 + 8 = ?',
        category: 'Math',
        categoryIcon: '\u2795',
        explanation:
            '7 + 8 = 15. Tip: You can think of it as 7 + 3 + 5 = 15, breaking 8 into parts!',
      ),
      PuzzleData(
        type: 'Emoji Math',
        emoji: '\u{1F3A8}',
        question: 'Solve this colourful math:',
        difficulty: 'Medium',
        points: 35,
        options: ['10', '12', '14', '16'],
        correctAnswer: 0,
        hint: 'Each apple equals 2',
        puzzleType: PuzzleType.mathProblem,
        mathExpression:
            '\u{1F34E}\u{1F34E}\u{1F34E} + \u{1F34E}\u{1F34E} = ? (\u{1F34E} = 2)',
        category: 'Math',
        categoryIcon: '\u2795',
        explanation:
            '3 apples + 2 apples = 5 apples. Each apple = 2, so 5 \u00D7 2 = 10!',
      ),
      PuzzleData(
        type: 'Math Sequence',
        emoji: '\u{1F522}',
        question: 'What comes next in the pattern?',
        difficulty: 'Medium',
        points: 40,
        options: ['12', '11', '13', '14'],
        correctAnswer: 0,
        hint: 'Add 2 each time',
        puzzleType: PuzzleType.sequencePuzzle,
        sequenceDisplay: ['2', '4', '6', '8', '10', '?'],
        category: 'Math',
        categoryIcon: '\u2795',
        explanation:
            'This is the sequence of even numbers! Each number increases by 2: 2, 4, 6, 8, 10, 12.',
      ),
      PuzzleData(
        type: 'Tech Quiz',
        emoji: '\u{1F4BB}',
        question: 'What does "AI" stand for?',
        difficulty: 'Easy',
        points: 25,
        options: [
          'Automatic Intelligence',
          'Artificial Intelligence',
          'Advanced Internet',
          'Applied Information'
        ],
        correctAnswer: 1,
        hint: 'Think of robots and smart machines',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Tech',
        categoryIcon: '\u{1F4BB}',
        explanation:
            'Artificial Intelligence (AI) is technology that allows computers to learn and make decisions like humans. ChatGPT, Siri, and self-driving cars all use AI!',
      ),
      PuzzleData(
        type: 'Coding Logic',
        emoji: '\u{1F469}\u200D\u{1F4BB}',
        question: 'In coding, what does a "loop" do?',
        difficulty: 'Medium',
        points: 35,
        options: [
          'Deletes code',
          'Repeats instructions',
          'Connects to internet',
          'Creates graphics'
        ],
        correctAnswer: 1,
        hint: 'Think of doing the same thing over and over',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Tech',
        categoryIcon: '\u{1F4BB}',
        explanation:
            'A loop repeats a set of instructions until a condition is met. For example, "repeat 10 times: print Hello" prints Hello 10 times!',
      ),
      PuzzleData(
        type: 'Nature Quiz',
        emoji: '\u{1F308}',
        question: 'How many colours are in a rainbow?',
        difficulty: 'Easy',
        points: 20,
        options: ['5', '6', '7', '8'],
        correctAnswer: 2,
        hint: 'VIBGYOR!',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Explore',
        categoryIcon: '\u{1F30D}',
        explanation:
            'A rainbow has 7 colours: Violet, Indigo, Blue, Green, Yellow, Orange, Red (VIBGYOR). They are caused by light refracting through water droplets!',
      ),
      PuzzleData(
        type: 'Ocean Quiz',
        emoji: '\u{1F30A}',
        question: 'What is the largest ocean on Earth?',
        difficulty: 'Easy',
        points: 20,
        options: [
          'Atlantic Ocean',
          'Indian Ocean',
          'Pacific Ocean',
          'Arctic Ocean'
        ],
        correctAnswer: 2,
        hint: 'It borders Asia and the Americas',
        puzzleType: PuzzleType.multipleChoice,
        category: 'Explore',
        categoryIcon: '\u{1F30D}',
        explanation:
            'The Pacific Ocean covers about 165.25 million sq km \u2014 larger than all the land on Earth combined!',
      ),
      PuzzleData(
        type: 'Emoji Pattern',
        emoji: '\u{1F9E9}',
        question: 'Which emoji completes the pattern?',
        difficulty: 'Medium',
        points: 35,
        options: ['\u{1F31F}', '\u{1F319}', '\u2600\uFE0F', '\u{1F308}'],
        correctAnswer: 0,
        hint: 'Look at each row \u2014 something repeats!',
        puzzleType: PuzzleType.patternMatch,
        patternGrid: [
          '\u2600\uFE0F',
          '\u{1F319}',
          '\u{1F31F}',
          '\u{1F319}',
          '\u{1F31F}',
          '\u2600\uFE0F',
          '\u{1F31F}',
          '\u2600\uFE0F',
          '?'
        ],
        category: 'Explore',
        categoryIcon: '\u{1F30D}',
        explanation:
            'Each row contains a Sun, Moon, and Star exactly once. The missing piece is a Star (\u{1F31F})!',
      ),
      PuzzleData(
        type: 'Memory Match',
        emoji: '\u{1F0CF}',
        question: 'Match the animal pairs! \u{1F43B}',
        difficulty: 'Easy',
        points: 30,
        options: [],
        correctAnswer: 0,
        hint: 'Flip carefully and remember!',
        puzzleType: PuzzleType.memoryMatch,
        category: 'Explore',
        categoryIcon: '\u{1F30D}',
        explanation:
            'Memory games help build your brain\u2019s working memory. The more you practice, the faster you get!',
      ),
    ];
  }
}
