/// Education Corner Screen
/// Comprehensive education platform for KG to PG students, teachers, schools & colleges
/// Features: AI Learning Assistant, Study Materials, Live Classes, Doubt Solving, etc.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'tutor_marketplace_screen.dart';
import 'institution_directory_screen.dart';

class EducationCornerScreen extends StatefulWidget {
  const EducationCornerScreen({super.key});

  @override
  State<EducationCornerScreen> createState() => _EducationCornerScreenState();
}

class _EducationCornerScreenState extends State<EducationCornerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _askQuestionController = TextEditingController();
  String _selectedLevel = 'School';
  String _selectedGrade = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _askQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Corner'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Learn'),
            Tab(icon: Icon(Icons.live_tv), text: 'Live Classes'),
            Tab(icon: Icon(Icons.quiz), text: 'Practice'),
            Tab(icon: Icon(Icons.help_outline), text: 'Ask AI'),
            Tab(icon: Icon(Icons.local_library), text: 'Library'),
            Tab(icon: Icon(Icons.people), text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLearnTab(),
          _buildLiveClassesTab(),
          _buildPracticeTab(),
          _buildAskAITab(),
          _buildLibraryTab(),
          _buildCommunityTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(),
        backgroundColor: Colors.teal.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Quick Actions'),
      ),
    );
  }

  Widget _buildLearnTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Access Cards
        Row(
          children: [
            Expanded(
              child: _QuickAccessCard(
                title: 'Find Tutors',
                subtitle: 'Expert Mentorship',
                icon: Icons.person,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TutorMarketplaceScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickAccessCard(
                title: 'Schools',
                subtitle: 'Find Institutions',
                icon: Icons.school,
                color: Colors.indigo,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InstitutionDirectoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Level Selector Card
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Your Level',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'KG',
                    'Primary',
                    'School',
                    'High School',
                    'College',
                    'PG'
                  ].map((level) {
                    return ChoiceChip(
                      label: Text(level),
                      selected: _selectedLevel == level,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedLevel = level);
                        }
                      },
                      selectedColor: Colors.teal.shade700,
                      labelStyle: TextStyle(
                        color: _selectedLevel == level
                            ? Colors.white
                            : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Popular Subjects
        _buildSectionHeader('Popular Subjects', Icons.subject),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _SubjectCard(
              title: 'Mathematics',
              icon: Icons.calculate,
              color: Colors.blue,
              count: '150+ lessons',
              onTap: () => _openSubject('Mathematics'),
            ),
            _SubjectCard(
              title: 'Science',
              icon: Icons.science,
              color: Colors.green,
              count: '200+ lessons',
              onTap: () => _openSubject('Science'),
            ),
            _SubjectCard(
              title: 'English',
              icon: Icons.menu_book,
              color: Colors.orange,
              count: '180+ lessons',
              onTap: () => _openSubject('English'),
            ),
            _SubjectCard(
              title: 'Social Studies',
              icon: Icons.public,
              color: Colors.purple,
              count: '120+ lessons',
              onTap: () => _openSubject('Social Studies'),
            ),
            _SubjectCard(
              title: 'Computer',
              icon: Icons.computer,
              color: Colors.teal,
              count: '100+ lessons',
              onTap: () => _openSubject('Computer'),
            ),
            _SubjectCard(
              title: 'Languages',
              icon: Icons.language,
              color: Colors.pink,
              count: '90+ lessons',
              onTap: () => _openSubject('Languages'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Continue Learning
        _buildSectionHeader('Continue Learning', Icons.play_circle),
        const SizedBox(height: 12),
        _ContinueLearningCard(
          title: 'Quadratic Equations',
          subject: 'Mathematics - Class 10',
          progress: 0.65,
          duration: '12 min left',
          thumbnail: Icons.functions,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _ContinueLearningCard(
          title: 'Photosynthesis',
          subject: 'Biology - Class 9',
          progress: 0.40,
          duration: '18 min left',
          thumbnail: Icons.eco,
          color: Colors.green,
        ),
        const SizedBox(height: 24),

        // Skill Development
        _buildSectionHeader('Skill Development', Icons.psychology),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _SkillCard(
                title: 'Coding',
                subtitle: 'Python, Java, C++',
                icon: Icons.code,
                color: Colors.indigo,
                courses: 50,
              ),
              _SkillCard(
                title: 'Design',
                subtitle: 'UI/UX, Graphics',
                icon: Icons.design_services,
                color: Colors.pink,
                courses: 35,
              ),
              _SkillCard(
                title: 'Communication',
                subtitle: 'Public Speaking',
                icon: Icons.record_voice_over,
                color: Colors.orange,
                courses: 25,
              ),
              _SkillCard(
                title: 'Leadership',
                subtitle: 'Team Management',
                icon: Icons.groups,
                color: Colors.purple,
                courses: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Competitive Exams
        _buildSectionHeader('Competitive Exams', Icons.workspace_premium),
        const SizedBox(height: 12),
        _ExamPrepCard(
          examName: 'JEE Main/Advanced',
          description: 'Engineering entrance exam preparation',
          icon: Icons.engineering,
          color: Colors.blue,
          enrolled: '50K+',
        ),
        const SizedBox(height: 12),
        _ExamPrepCard(
          examName: 'NEET',
          description: 'Medical entrance exam preparation',
          icon: Icons.medical_services,
          color: Colors.red,
          enrolled: '40K+',
        ),
        const SizedBox(height: 12),
        _ExamPrepCard(
          examName: 'UPSC',
          description: 'Civil services exam preparation',
          icon: Icons.account_balance,
          color: Colors.amber,
          enrolled: '30K+',
        ),
      ],
    );
  }

  Widget _buildLiveClassesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Now Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade600, Colors.red.shade800],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.circle, color: Colors.red, size: 12),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3 Classes LIVE Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Join and learn with experts',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
                child: const Text('Join'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Upcoming Classes
        _buildSectionHeader('Upcoming Classes', Icons.schedule),
        const SizedBox(height: 12),
        _LiveClassCard(
          title: 'Trigonometry - Advanced Concepts',
          teacher: 'Prof. Rajesh Kumar',
          subject: 'Mathematics',
          startTime: '4:00 PM',
          duration: '1 hour',
          students: 234,
          isLive: false,
          date: 'Today',
        ),
        const SizedBox(height: 12),
        _LiveClassCard(
          title: 'Organic Chemistry - Reactions',
          teacher: 'Dr. Priya Sharma',
          subject: 'Chemistry',
          startTime: '5:30 PM',
          duration: '1.5 hours',
          students: 189,
          isLive: false,
          date: 'Today',
        ),
        const SizedBox(height: 12),
        _LiveClassCard(
          title: 'English Grammar - Tenses',
          teacher: 'Ms. Anjali Verma',
          subject: 'English',
          startTime: 'Now',
          duration: '45 min',
          students: 145,
          isLive: true,
          date: 'Now',
        ),
        const SizedBox(height: 24),

        // Recorded Classes
        _buildSectionHeader('Recorded Classes', Icons.video_library),
        const SizedBox(height: 12),
        _RecordedClassCard(
          title: 'Newton\'s Laws of Motion',
          teacher: 'Prof. Suresh Reddy',
          subject: 'Physics',
          duration: '45 min',
          views: '12K',
          rating: 4.8,
        ),
        const SizedBox(height: 12),
        _RecordedClassCard(
          title: 'World War II - Complete History',
          teacher: 'Dr. Meena Iyer',
          subject: 'History',
          duration: '1 hour',
          views: '8.5K',
          rating: 4.9,
        ),
      ],
    );
  }

  Widget _buildPracticeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Daily Practice
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.purple.shade100],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.today, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Practice',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '15 questions waiting',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '9/15 completed today',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Practice by Subject
        _buildSectionHeader('Practice by Subject', Icons.subject),
        const SizedBox(height: 12),
        _PracticeCard(
          subject: 'Mathematics',
          icon: Icons.calculate,
          color: Colors.blue,
          totalQuestions: 500,
          attempted: 234,
          accuracy: 85,
        ),
        const SizedBox(height: 12),
        _PracticeCard(
          subject: 'Science',
          icon: Icons.science,
          color: Colors.green,
          totalQuestions: 450,
          attempted: 189,
          accuracy: 78,
        ),
        const SizedBox(height: 12),
        _PracticeCard(
          subject: 'English',
          icon: Icons.menu_book,
          color: Colors.orange,
          totalQuestions: 400,
          attempted: 156,
          accuracy: 92,
        ),
        const SizedBox(height: 24),

        // Mock Tests
        _buildSectionHeader('Mock Tests', Icons.timer),
        const SizedBox(height: 12),
        _MockTestCard(
          title: 'Class 10 - Mid Term Mock',
          subjects: ['Math', 'Science', 'English'],
          questions: 90,
          duration: '3 hours',
          attempts: 12,
        ),
        const SizedBox(height: 12),
        _MockTestCard(
          title: 'JEE Main - Full Length Test',
          subjects: ['Physics', 'Chemistry', 'Math'],
          questions: 75,
          duration: '3 hours',
          attempts: 5,
        ),
        const SizedBox(height: 24),

        // Previous Year Papers
        _buildSectionHeader('Previous Year Papers', Icons.history_edu),
        const SizedBox(height: 12),
        _PreviousYearCard(
          exam: 'CBSE Board - 2025',
          subject: 'Mathematics',
          year: '2025',
          downloads: '25K',
        ),
        const SizedBox(height: 12),
        _PreviousYearCard(
          exam: 'JEE Main - 2025',
          subject: 'Physics',
          year: '2025',
          downloads: '45K',
        ),
      ],
    );
  }

  Widget _buildAskAITab() {
    return Column(
      children: [
        // AI Assistant Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade900],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.psychology,
                    color: Colors.teal.shade700, size: 48),
              ),
              const SizedBox(height: 12),
              const Text(
                'AI Learning Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask anything, get instant answers',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        // Quick Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickActionChip(
                    label: 'Solve Math Problem',
                    icon: Icons.calculate,
                    onTap: () => _askAI('Solve math problem'),
                  ),
                  _QuickActionChip(
                    label: 'Explain Concept',
                    icon: Icons.lightbulb_outline,
                    onTap: () => _askAI('Explain concept'),
                  ),
                  _QuickActionChip(
                    label: 'Essay Writing',
                    icon: Icons.article,
                    onTap: () => _askAI('Help with essay'),
                  ),
                  _QuickActionChip(
                    label: 'Code Help',
                    icon: Icons.code,
                    onTap: () => _askAI('Programming help'),
                  ),
                  _QuickActionChip(
                    label: 'Study Tips',
                    icon: Icons.tips_and_updates,
                    onTap: () => _askAI('Study tips'),
                  ),
                  _QuickActionChip(
                    label: 'Career Guidance',
                    icon: Icons.work,
                    onTap: () => _askAI('Career advice'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chat Area
        Expanded(
          child: Container(
            color: Colors.grey.shade100,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AIMessageBubble(
                  message:
                      'Hello! I\'m your AI learning assistant. Ask me anything about your studies!',
                  isUser: false,
                  timestamp: 'Just now',
                ),
                const SizedBox(height: 12),
                _AIMessageBubble(
                  message: 'Can you explain Newton\'s third law?',
                  isUser: true,
                  timestamp: '2:30 PM',
                ),
                const SizedBox(height: 12),
                _AIMessageBubble(
                  message:
                      'Newton\'s Third Law states: "For every action, there is an equal and opposite reaction." This means when object A exerts a force on object B, object B simultaneously exerts a force of equal magnitude but opposite direction on object A.\n\nExample: When you jump, you push the ground down (action), and the ground pushes you up (reaction).',
                  isUser: false,
                  timestamp: '2:30 PM',
                ),
              ],
            ),
          ),
        ),

        // Input Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Upload image to scan questions')),
                  );
                },
                color: Colors.teal.shade700,
              ),
              Expanded(
                child: TextField(
                  controller: _askQuestionController,
                  decoration: InputDecoration(
                    hintText: 'Ask anything...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.teal.shade700,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_askQuestionController.text.isNotEmpty) {
                      _sendQuestion(_askQuestionController.text);
                      _askQuestionController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search books, notes, papers...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 20),

        // Categories
        _buildSectionHeader('Categories', Icons.category),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _LibraryCategoryCard(
                title: 'Textbooks',
                icon: Icons.menu_book,
                color: Colors.blue,
                count: 500,
              ),
              _LibraryCategoryCard(
                title: 'Notes',
                icon: Icons.note,
                color: Colors.orange,
                count: 1200,
              ),
              _LibraryCategoryCard(
                title: 'Reference',
                icon: Icons.library_books,
                color: Colors.green,
                count: 350,
              ),
              _LibraryCategoryCard(
                title: 'Research',
                icon: Icons.school,
                color: Colors.purple,
                count: 180,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recently Added
        _buildSectionHeader('Recently Added', Icons.new_releases),
        const SizedBox(height: 12),
        _BookCard(
          title: 'Advanced Mathematics - Class 12',
          author: 'R.D. Sharma',
          subject: 'Mathematics',
          pages: 450,
          downloads: '25K',
          rating: 4.8,
        ),
        const SizedBox(height: 12),
        _BookCard(
          title: 'Concepts of Physics',
          author: 'H.C. Verma',
          subject: 'Physics',
          pages: 520,
          downloads: '40K',
          rating: 4.9,
        ),
        const SizedBox(height: 12),
        _BookCard(
          title: 'Organic Chemistry',
          author: 'Morrison & Boyd',
          subject: 'Chemistry',
          pages: 680,
          downloads: '30K',
          rating: 4.7,
        ),
        const SizedBox(height: 24),

        // NCERT Books
        _buildSectionHeader('NCERT Books', Icons.book),
        const SizedBox(height: 12),
        _NCERTBookCard(
          title: 'Mathematics',
          class_: 'Class 10',
          chapters: 15,
          size: '45 MB',
        ),
        const SizedBox(height: 12),
        _NCERTBookCard(
          title: 'Science',
          class_: 'Class 10',
          chapters: 16,
          size: '52 MB',
        ),
      ],
    );
  }

  Widget _buildCommunityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Study Groups
        _buildSectionHeader('Study Groups', Icons.groups),
        const SizedBox(height: 12),
        _StudyGroupCard(
          name: 'JEE 2026 Aspirants',
          members: 1250,
          activeNow: 45,
          description: 'Preparing for JEE Main & Advanced',
          icon: Icons.engineering,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _StudyGroupCard(
          name: 'NEET Preparation',
          members: 980,
          activeNow: 32,
          description: 'Medical entrance exam preparation',
          icon: Icons.medical_services,
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _StudyGroupCard(
          name: 'Class 10 CBSE',
          members: 2500,
          activeNow: 68,
          description: 'Board exam preparation',
          icon: Icons.school,
          color: Colors.green,
        ),
        const SizedBox(height: 24),

        // Discussion Forum
        _buildSectionHeader('Recent Discussions', Icons.forum),
        const SizedBox(height: 12),
        _DiscussionCard(
          question: 'How to solve quadratic equations quickly?',
          author: 'Rahul Kumar',
          subject: 'Mathematics',
          replies: 23,
          likes: 45,
          timestamp: '2 hours ago',
        ),
        const SizedBox(height: 12),
        _DiscussionCard(
          question: 'Best books for Organic Chemistry?',
          author: 'Priya Sharma',
          subject: 'Chemistry',
          replies: 18,
          likes: 32,
          timestamp: '5 hours ago',
        ),
        const SizedBox(height: 24),

        // Expert Sessions
        _buildSectionHeader('Expert Sessions', Icons.person),
        const SizedBox(height: 12),
        _ExpertSessionCard(
          expertName: 'Dr. Rajesh Kumar',
          designation: 'IIT Professor',
          topic: 'Career Guidance in Engineering',
          date: 'Tomorrow, 6 PM',
          registered: 234,
        ),
        const SizedBox(height: 12),
        _ExpertSessionCard(
          expertName: 'Prof. Meena Iyer',
          designation: 'AIIMS Faculty',
          topic: 'Medical Career Opportunities',
          date: 'This Weekend',
          registered: 189,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal.shade700, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _openSubject(String subject) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubjectDetailSheet(subject: subject),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search courses, classes, books...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon')),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('My Schedule'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Schedule feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.orange),
              title: const Text('Assignments'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Assignments feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.grade, color: Colors.green),
              title: const Text('My Grades'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grades feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: Colors.purple),
              title: const Text('Saved Content'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Saved content feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _askAI(String prompt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('AI: $prompt')),
    );
  }

  void _sendQuestion(String question) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending your question to AI...')),
    );
  }
}

// Supporting Widget Classes

class _SubjectCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String count;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final String title;
  final String subject;
  final double progress;
  final String duration;
  final IconData thumbnail;
  final Color color;

  const _ContinueLearningCard({
    required this.title,
    required this.subject,
    required this.progress,
    required this.duration,
    required this.thumbnail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(thumbnail, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress, color: color),
            const SizedBox(height: 2),
            Text(duration, style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_filled),
          color: color,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int courses;

  const _SkillCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                '$courses courses',
                style: TextStyle(fontSize: 11, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamPrepCard extends StatelessWidget {
  final String examName;
  final String description;
  final IconData icon;
  final Color color;
  final String enrolled;

  const _ExamPrepCard({
    required this.examName,
    required this.description,
    required this.icon,
    required this.color,
    required this.enrolled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title:
            Text(examName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 16, color: Colors.grey.shade600),
            Text(enrolled, style: const TextStyle(fontSize: 11)),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}

class _LiveClassCard extends StatelessWidget {
  final String title;
  final String teacher;
  final String subject;
  final String startTime;
  final String duration;
  final int students;
  final bool isLive;
  final String date;

  const _LiveClassCard({
    required this.title,
    required this.teacher,
    required this.subject,
    required this.startTime,
    required this.duration,
    required this.students,
    required this.isLive,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8),
                        SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isLive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      date,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                Chip(
                  label: Text(subject),
                  labelStyle: const TextStyle(fontSize: 10),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(teacher,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('$startTime • $duration',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('$students students',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLive ? Colors.red : Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
                child: Text(isLive ? 'Join Now' : 'Remind Me'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordedClassCard extends StatelessWidget {
  final String title;
  final String teacher;
  final String subject;
  final String duration;
  final String views;
  final double rating;

  const _RecordedClassCard({
    required this.title,
    required this.teacher,
    required this.subject,
    required this.duration,
    required this.views,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.play_circle_filled,
              color: Colors.teal.shade700, size: 32),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$teacher • $subject',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                const Icon(Icons.timer, size: 12),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(duration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.visibility, size: 12),
                const SizedBox(width: 4),
                Text(views, style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 8),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$rating', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {},
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final String subject;
  final IconData icon;
  final Color color;
  final int totalQuestions;
  final int attempted;
  final int accuracy;

  const _PracticeCard({
    required this.subject,
    required this.icon,
    required this.color,
    required this.totalQuestions,
    required this.attempted,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 24,
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$attempted/$totalQuestions attempted',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: attempted / totalQuestions,
                    color: color,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accuracy: $accuracy%',
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              color: color,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MockTestCard extends StatelessWidget {
  final String title;
  final List<String> subjects;
  final int questions;
  final String duration;
  final int attempts;

  const _MockTestCard({
    required this.title,
    required this.subjects,
    required this.questions,
    required this.duration,
    required this.attempts,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: subjects
                  .map((s) => Chip(
                        label: Text(s),
                        labelStyle: const TextStyle(fontSize: 10),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.quiz, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('$questions questions',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 12),
                Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(duration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Text('$attempts attempts',
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousYearCard extends StatelessWidget {
  final String exam;
  final String subject;
  final String year;
  final String downloads;

  const _PreviousYearCard({
    required this.exam,
    required this.subject,
    required this.year,
    required this.downloads,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.description),
        ),
        title: Text(exam, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$subject • $year'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, size: 20),
            Text(downloads, style: const TextStyle(fontSize: 10)),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.teal.shade50,
      labelStyle: TextStyle(color: Colors.teal.shade700),
    );
  }
}

class _AIMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String timestamp;

  const _AIMessageBubble({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 10,
                color: isUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int count;

  const _LibraryCategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                '$count+',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String subject;
  final int pages;
  final String downloads;
  final double rating;

  const _BookCard({
    required this.title,
    required this.author,
    required this.subject,
    required this.pages,
    required this.downloads,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.book, color: Colors.teal.shade700),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by $author'),
            Row(
              children: [
                Text('$subject • $pages pages'),
                const Spacer(),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text(' $rating'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {},
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _NCERTBookCard extends StatelessWidget {
  final String title;
  final String class_;
  final int chapters;
  final String size;

  const _NCERTBookCard({
    required this.title,
    required this.class_,
    required this.chapters,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'NCERT',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
        title: Text('$title - $class_',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$chapters chapters • $size'),
        trailing: const Icon(Icons.download),
        onTap: () {},
      ),
    );
  }
}

class _StudyGroupCard extends StatelessWidget {
  final String name;
  final int members;
  final int activeNow;
  final String description;
  final IconData icon;
  final Color color;

  const _StudyGroupCard({
    required this.name,
    required this.members,
    required this.activeNow,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('$members members',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.circle, size: 8, color: Colors.green),
                const SizedBox(width: 4),
                Text('$activeNow online', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Join', style: TextStyle(fontSize: 12)),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  final String question;
  final String author;
  final String subject;
  final int replies;
  final int likes;
  final String timestamp;

  const _DiscussionCard({
    required this.question,
    required this.author,
    required this.subject,
    required this.replies,
    required this.likes,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(author[0]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(timestamp,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Chip(
                  label: Text(subject),
                  labelStyle: const TextStyle(fontSize: 10),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('$replies replies', style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.thumb_up, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('$likes', style: const TextStyle(fontSize: 12)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpertSessionCard extends StatelessWidget {
  final String expertName;
  final String designation;
  final String topic;
  final String date;
  final int registered;

  const _ExpertSessionCard({
    required this.expertName,
    required this.designation,
    required this.topic,
    required this.date,
    required this.registered,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(expertName[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expertName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(designation,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              topic,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(date, style: const TextStyle(fontSize: 13)),
                const Spacer(),
                Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('$registered registered',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectDetailSheet extends StatelessWidget {
  final String subject;

  const _SubjectDetailSheet({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subject,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text('Choose what you want to do:'),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: const Text('Video Lessons'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Practice Questions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text('Study Notes'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Take Test'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Quick Access Card Widget
class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create gradient colors from the base color
    final Color lightColor = Color.lerp(color, Colors.white, 0.2) ?? color;
    final Color darkColor = Color.lerp(color, Colors.black, 0.2) ?? color;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lightColor, darkColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
