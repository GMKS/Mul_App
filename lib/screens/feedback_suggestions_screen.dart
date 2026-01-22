import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class FeedbackSuggestionsScreen extends StatefulWidget {
  const FeedbackSuggestionsScreen({super.key});

  @override
  State<FeedbackSuggestionsScreen> createState() =>
      _FeedbackSuggestionsScreenState();
}

class _FeedbackSuggestionsScreenState extends State<FeedbackSuggestionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedbackAndSuggestions),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.poll), text: l10n.communityPolls),
            Tab(icon: const Icon(Icons.feedback), text: l10n.feedback),
            Tab(icon: const Icon(Icons.lightbulb), text: l10n.suggestions),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunityPollsTab(),
          _buildFeedbackTab(),
          _buildSuggestionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionDialog(),
        backgroundColor: Colors.teal.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Quick Action'),
      ),
    );
  }

  Widget _buildCommunityPollsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Create Poll Button
        Card(
          elevation: 4,
          color: Colors.teal.shade50,
          child: InkWell(
            onTap: () => _createPoll(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_chart,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Community Poll',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get opinions from your neighbors',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Active Polls
        _buildSectionHeader('Active Polls', Icons.poll_outlined),
        const SizedBox(height: 12),
        _buildPollCard(
          question: 'Should we organize a community cleanup drive this Sunday?',
          author: 'Community Manager',
          totalVotes: 245,
          options: [
            {
              'text': 'Yes, I\'ll participate',
              'votes': 156,
              'percentage': 63.7
            },
            {
              'text': 'Good idea, but can\'t join',
              'votes': 58,
              'percentage': 23.7
            },
            {'text': 'Not interested', 'votes': 31, 'percentage': 12.6},
          ],
          timeLeft: '2 days left',
          category: 'Community',
          userVoted: true,
        ),
        const SizedBox(height: 12),
        _buildPollCard(
          question: 'What time should the evening park lights be switched on?',
          author: 'Park Committee',
          totalVotes: 189,
          options: [
            {'text': '5:30 PM', 'votes': 45, 'percentage': 23.8},
            {'text': '6:00 PM', 'votes': 112, 'percentage': 59.3},
            {'text': '6:30 PM', 'votes': 32, 'percentage': 16.9},
          ],
          timeLeft: '5 days left',
          category: 'Infrastructure',
          userVoted: false,
        ),
        const SizedBox(height: 12),
        _buildPollCard(
          question: 'Which festival celebration should the community organize?',
          author: 'Cultural Committee',
          totalVotes: 312,
          options: [
            {'text': 'Diwali Celebration', 'votes': 145, 'percentage': 46.5},
            {'text': 'Holi Event', 'votes': 89, 'percentage': 28.5},
            {'text': 'New Year Party', 'votes': 78, 'percentage': 25.0},
          ],
          timeLeft: '1 week left',
          category: 'Events',
          userVoted: false,
        ),
        const SizedBox(height: 24),

        // Closed Polls
        _buildSectionHeader('Closed Polls', Icons.check_circle_outline),
        const SizedBox(height: 12),
        _buildClosedPollCard(
          question: 'Should parking fees be increased?',
          result: 'No - 67% voted against',
          totalVotes: 423,
          closedDate: '3 days ago',
        ),
        const SizedBox(height: 12),
        _buildClosedPollCard(
          question: 'Best time for weekly market?',
          result: 'Sunday Morning - 54% preference',
          totalVotes: 298,
          closedDate: '1 week ago',
        ),
      ],
    );
  }

  Widget _buildFeedbackTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Submit Feedback Button
        Card(
          elevation: 4,
          color: Colors.blue.shade50,
          child: InkWell(
            onTap: () => _submitFeedback(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.rate_review,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Share your experience with us',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Feedback Categories
        _buildSectionHeader('Feedback Categories', Icons.category),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeedbackCategory(
                  'App Experience', Icons.smartphone, Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeedbackCategory(
                  'Services', Icons.room_service, Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeedbackCategory(
                  'Community', Icons.people, Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeedbackCategory(
                  'Report Issue', Icons.report_problem, Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Recent Feedback
        _buildSectionHeader('Recent Community Feedback', Icons.forum),
        const SizedBox(height: 12),
        _buildFeedbackCard(
          category: 'Services',
          feedback:
              'The new home delivery service is excellent! Got groceries within 2 hours.',
          author: 'Priya S.',
          rating: 5,
          date: '2 days ago',
          helpful: 34,
        ),
        const SizedBox(height: 12),
        _buildFeedbackCard(
          category: 'App Experience',
          feedback:
              'App crashes when opening emergency services. Please fix this urgent issue.',
          author: 'Ramesh K.',
          rating: 2,
          date: '3 days ago',
          helpful: 12,
        ),
        const SizedBox(height: 12),
        _buildFeedbackCard(
          category: 'Community',
          feedback:
              'Love the volunteer opportunities section. Already joined 2 events!',
          author: 'Anonymous',
          rating: 5,
          date: '5 days ago',
          helpful: 45,
        ),
        const SizedBox(height: 12),
        _buildFeedbackCard(
          category: 'Services',
          feedback:
              'Need more plumbers listed in the services directory for our area.',
          author: 'Suresh M.',
          rating: 3,
          date: '1 week ago',
          helpful: 28,
        ),
      ],
    );
  }

  Widget _buildSuggestionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Submit Suggestion Button
        Card(
          elevation: 4,
          color: Colors.amber.shade50,
          child: InkWell(
            onTap: () => _suggestFeature(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lightbulb,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Suggest New Feature',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Help us improve the app',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Popular Suggestions
        _buildSectionHeader('Most Voted Suggestions', Icons.trending_up),
        const SizedBox(height: 12),
        _buildSuggestionCard(
          title: 'Add dark mode to the app',
          description:
              'Would love to have a dark theme option for night-time usage.',
          author: 'Tech Enthusiast',
          votes: 234,
          status: 'Under Review',
          category: 'App Feature',
          datePosted: '2 weeks ago',
        ),
        const SizedBox(height: 12),
        _buildSuggestionCard(
          title: 'Carpooling feature for office goers',
          description:
              'A carpooling system to share rides with neighbors going to the same areas.',
          author: 'Daily Commuter',
          votes: 189,
          status: 'Planned',
          category: 'Transportation',
          datePosted: '3 weeks ago',
        ),
        const SizedBox(height: 12),
        _buildSuggestionCard(
          title: 'Local farmer\'s market integration',
          description:
              'Connect local farmers directly with community for fresh produce delivery.',
          author: 'Green Living',
          votes: 156,
          status: 'In Development',
          category: 'Marketplace',
          datePosted: '1 month ago',
        ),
        const SizedBox(height: 24),

        // Recent Suggestions
        _buildSectionHeader('Recent Suggestions', Icons.new_releases),
        const SizedBox(height: 12),
        _buildSuggestionCard(
          title: 'Pet adoption center',
          description: 'Feature to list pets for adoption in the local area.',
          author: 'Animal Lover',
          votes: 67,
          status: 'New',
          category: 'Community',
          datePosted: '3 days ago',
        ),
        const SizedBox(height: 12),
        _buildSuggestionCard(
          title: 'Fitness group scheduling',
          description:
              'Allow creation of fitness groups for morning walks, yoga, etc.',
          author: 'Fitness Freak',
          votes: 45,
          status: 'New',
          category: 'Health',
          datePosted: '5 days ago',
        ),
        const SizedBox(height: 12),
        _buildSuggestionCard(
          title: 'Language learning exchange',
          description:
              'Connect people who want to learn/teach different languages.',
          author: 'Language Learner',
          votes: 34,
          status: 'New',
          category: 'Education',
          datePosted: '1 week ago',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal.shade700, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPollCard({
    required String question,
    required String author,
    required int totalVotes,
    required List<Map<String, dynamic>> options,
    required String timeLeft,
    required String category,
    required bool userVoted,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                if (userVoted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check,
                            size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Voted',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By $author',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: userVoted
                      ? null
                      : () => _voteOnPoll(question, option['text']),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option['text'],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '${option['percentage'].toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: option['percentage'] / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.teal.shade700,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${option['votes']} votes',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Divider(),
            Row(
              children: [
                Icon(Icons.how_to_vote, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$totalVotes total votes',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  timeLeft,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosedPollCard({
    required String question,
    required String result,
    required int totalVotes,
    required String closedDate,
  }) {
    return Card(
      elevation: 1,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Result: $result',
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalVotes votes • Closed $closedDate',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCategory(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _selectFeedbackCategory(title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard({
    required String category,
    required String feedback,
    required String author,
    required int rating,
    required String date,
    required int helpful,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                ...List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'By $author',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  ' • $date',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  onPressed: () => _markHelpful(feedback),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  '$helpful',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard({
    required String title,
    required String description,
    required String author,
    required int votes,
    required String status,
    required String category,
    required String datePosted,
  }) {
    Color statusColor;
    switch (status) {
      case 'In Development':
        statusColor = Colors.green;
        break;
      case 'Planned':
        statusColor = Colors.blue;
        break;
      case 'Under Review':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'By $author',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  ' • $datePosted',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.arrow_upward,
                      size: 20, color: Colors.teal.shade700),
                  onPressed: () => _upvoteSuggestion(title),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  '$votes',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.poll, color: Colors.teal),
              title: const Text('Create Poll'),
              onTap: () {
                Navigator.pop(context);
                _createPoll();
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.blue),
              title: const Text('Submit Feedback'),
              onTap: () {
                Navigator.pop(context);
                _submitFeedback();
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb, color: Colors.amber),
              title: const Text('Suggest Feature'),
              onTap: () {
                Navigator.pop(context);
                _suggestFeature();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createPoll() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create poll form opening...')),
    );
  }

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback form opening...')),
    );
  }

  void _suggestFeature() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suggestion form opening...')),
    );
  }

  void _voteOnPoll(String question, String option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Voted for: $option')),
    );
  }

  void _selectFeedbackCategory(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $category feedback...')),
    );
  }

  void _markHelpful(String feedback) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as helpful!')),
    );
  }

  void _upvoteSuggestion(String suggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suggestion upvoted!')),
    );
  }
}
