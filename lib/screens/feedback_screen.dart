/// Feedback & Suggestions Screen
/// Main screen for community feedback, suggestions, and polls

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';
import '../l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  final FeedbackService _service = FeedbackService();
  late TabController _tabController;

  List<UserFeedback> _feedbackList = [];
  List<CommunityPoll> _pollsList = [];
  bool _isLoading = true;
  String _sortBy = 'trending'; // 'trending' or 'recent'
  FeedbackType? _filterType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final appState = context.read<AppState>();
    _service.initializeMockData(
      appState.selectedCity ?? 'Hyderabad',
      appState.selectedState ?? 'Telangana',
    );

    final feedback = await _service.fetchFeedback(sortBy: _sortBy);
    final polls = await _service.fetchPolls();

    setState(() {
      _feedbackList = feedback;
      _pollsList = polls;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2938),
        elevation: 0,
        title: Text(
          l10n.feedbackAndSuggestions,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
                text: l10n.feedback,
                icon: const Icon(Icons.feedback, size: 20)),
            Tab(
                text: l10n.suggestions,
                icon: const Icon(Icons.lightbulb, size: 20)),
            Tab(
                text: l10n.communityPolls,
                icon: const Icon(Icons.poll, size: 20)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFeedbackTab(),
                _buildSuggestionsTab(),
                _buildPollsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSubmitFeedbackDialog,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: Text(l10n.submitFeedback),
      ),
    );
  }

  Widget _buildFeedbackTab() {
    if (_feedbackList.isEmpty) {
      return const Center(
        child: Text(
          'No feedback yet. Be the first to share!',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _feedbackList.length,
        itemBuilder: (context, index) {
          final feedback = _feedbackList[index];
          return _buildFeedbackCard(feedback);
        },
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    final suggestions =
        _feedbackList.where((f) => f.type == FeedbackType.feature).toList();

    if (suggestions.isEmpty) {
      return const Center(
        child: Text(
          'No suggestions yet. Share your ideas!',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildFeedbackCard(suggestion);
      },
    );
  }

  Widget _buildPollsTab() {
    if (_pollsList.isEmpty) {
      return const Center(
        child: Text(
          'No active polls',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pollsList.length,
      itemBuilder: (context, index) {
        final poll = _pollsList[index];
        return _buildPollCard(poll);
      },
    );
  }

  Widget _buildFeedbackCard(UserFeedback feedback) {
    final hasVoted = _service.getUserVote(feedback.id, 'current_user');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2938),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: feedback.typeIcon == Icons.bug_report
                      ? Colors.red
                      : Colors.blue,
                  child: Icon(feedback.typeIcon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              feedback.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: feedback.statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              feedback.status.toString().split('.').last,
                              style: TextStyle(
                                color: feedback.statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(feedback.createdAt),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  feedback.description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (feedback.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: feedback.tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // Admin Response
          if (feedback.adminResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings,
                      color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Response',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feedback.adminResponse!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Upvote
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleVote(feedback.id, true),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            hasVoted == true
                                ? Icons.arrow_upward
                                : Icons.arrow_upward_outlined,
                            color:
                                hasVoted == true ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${feedback.upvotes}',
                            style: TextStyle(
                              color:
                                  hasVoted == true ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Downvote
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleVote(feedback.id, false),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            hasVoted == false
                                ? Icons.arrow_downward
                                : Icons.arrow_downward_outlined,
                            color: hasVoted == false ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${feedback.downvotes}',
                            style: TextStyle(
                              color:
                                  hasVoted == false ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Comments
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showFeedbackDetails(feedback),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.comment_outlined,
                              color: Colors.grey[400], size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${feedback.commentCount}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Share
                IconButton(
                  icon: Icon(Icons.share, color: Colors.grey[400], size: 20),
                  onPressed: () {
                    // Share feedback
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(CommunityPoll poll) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2938),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.poll, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    poll.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              poll.description,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Poll options
            ...poll.options.map((option) {
              final percentage = option.getPercentage(poll.totalVotes);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handlePollVote(poll.id, option.id),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: option.color ?? Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation(
                                  option.color ?? Colors.blue),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${option.votes} votes',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

            const Divider(color: Colors.white10),
            Row(
              children: [
                Text(
                  '${poll.totalVotes} total votes',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (poll.expiresAt != null)
                  Text(
                    'Ends ${timeago.format(poll.expiresAt!)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVote(String feedbackId, bool isUpvote) async {
    await _service.voteFeedback(feedbackId, 'current_user', isUpvote: isUpvote);
    _loadData();
  }

  Future<void> _handlePollVote(String pollId, String optionId) async {
    await _service.votePoll(pollId, 'current_user', optionId);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for voting!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2938),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.white),
              title:
                  const Text('Trending', style: TextStyle(color: Colors.white)),
              trailing: _sortBy == 'trending'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'trending');
                Navigator.pop(context);
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.white),
              title:
                  const Text('Recent', style: TextStyle(color: Colors.white)),
              trailing: _sortBy == 'recent'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() => _sortBy = 'recent');
                Navigator.pop(context);
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2938),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Filter by Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.white),
              title: const Text('All', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _filterType = null);
                Navigator.pop(context);
                _loadData();
              },
            ),
            ...FeedbackType.values.map((type) => ListTile(
                  leading: Icon(_getTypeIcon(type), color: Colors.white),
                  title: Text(
                    type.toString().split('.').last,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    setState(() => _filterType = type);
                    Navigator.pop(context);
                    _loadData();
                  },
                )),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.bug:
        return Icons.bug_report;
      case FeedbackType.feature:
        return Icons.lightbulb;
      case FeedbackType.improvement:
        return Icons.trending_up;
      case FeedbackType.service:
        return Icons.build;
      case FeedbackType.safety:
        return Icons.shield;
      case FeedbackType.event:
        return Icons.event;
      case FeedbackType.general:
        return Icons.feedback;
    }
  }

  void _showSubmitFeedbackDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    FeedbackType selectedType = FeedbackType.general;
    bool isAnonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C2938),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Type selector
                const Text(
                  'Type',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FeedbackType.values.map((type) {
                    final isSelected = selectedType == type;
                    return FilterChip(
                      label: Text(type.toString().split('.').last),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() => selectedType = type);
                      },
                      backgroundColor: Colors.white10,
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Anonymous option
                CheckboxListTile(
                  value: isAnonymous,
                  onChanged: (value) {
                    setModalState(() => isAnonymous = value ?? false);
                  },
                  title: const Text(
                    'Submit anonymously',
                    style: TextStyle(color: Colors.white),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields'),
                          ),
                        );
                        return;
                      }

                      final appState = context.read<AppState>();
                      await _service.submitFeedback(
                        userId: 'current_user',
                        userName: 'User Name',
                        type: selectedType,
                        title: titleController.text,
                        description: descriptionController.text,
                        city: appState.selectedCity ?? 'Hyderabad',
                        state: appState.selectedState ?? 'Telangana',
                        language: appState.selectedLanguage ?? 'en',
                        isAnonymous: isAnonymous,
                      );

                      Navigator.pop(context);
                      _loadData();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feedback submitted successfully!'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDetails(UserFeedback feedback) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackDetailsScreen(feedback: feedback),
      ),
    );
  }
}

// Feedback Details Screen
class FeedbackDetailsScreen extends StatelessWidget {
  final UserFeedback feedback;

  const FeedbackDetailsScreen({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2938),
        title: const Text('Feedback Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedback.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              feedback.description,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            // Add more details and comments here
          ],
        ),
      ),
    );
  }
}
