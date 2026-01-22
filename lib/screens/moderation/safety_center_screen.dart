/// Safety Center Screen
/// Central hub for all safety and moderation features

import 'package:flutter/material.dart';
import '../../models/user_safety_model.dart';
import '../../services/user_safety_service.dart';
import 'my_reports_screen.dart';
import 'community_guidelines_screen.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  List<BlockedUser> _blockedUsers = [];
  List<MutedKeyword> _mutedKeywords = [];
  UserTrustLevel? _trustLevel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Get current user ID
      final userId = 'current_user_id';

      final blockedUsers = await UserSafetyService.getBlockedUsers(userId);
      final mutedKeywords = await UserSafetyService.getMutedKeywords(userId);
      final trustLevel = await UserSafetyService.getUserTrustLevel(userId);

      setState(() {
        _blockedUsers = blockedUsers;
        _mutedKeywords = mutedKeywords;
        _trustLevel = trustLevel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Color(0xFF16213e),
        title: Text('Safety Center'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Trust Badge Card
                if (_trustLevel != null) _buildTrustBadgeCard(),
                SizedBox(height: 16),

                // My Reports Section
                _buildSectionCard(
                  icon: Icons.report_outlined,
                  title: 'My Reports',
                  subtitle: 'Track your submitted reports',
                  color: Color(0xFF3b82f6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MyReportsScreen()),
                    );
                  },
                ),

                // Community Guidelines
                _buildSectionCard(
                  icon: Icons.menu_book,
                  title: 'Community Guidelines',
                  subtitle: 'Learn about our rules',
                  color: Color(0xFF9B59B6),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => CommunityGuidelinesScreen()),
                    );
                  },
                ),

                // Blocked Users
                _buildSectionCard(
                  icon: Icons.block,
                  title: 'Blocked Users',
                  subtitle: '${_blockedUsers.length} blocked',
                  color: Color(0xFFef4444),
                  trailing: _blockedUsers.isEmpty
                      ? null
                      : Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFef4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_blockedUsers.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  onTap: () => _showBlockedUsersSheet(),
                ),

                // Muted Keywords
                _buildSectionCard(
                  icon: Icons.volume_off,
                  title: 'Muted Keywords',
                  subtitle: '${_mutedKeywords.length} keywords',
                  color: Color(0xFFf59e0b),
                  trailing: _mutedKeywords.isEmpty
                      ? null
                      : Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFf59e0b),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_mutedKeywords.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  onTap: () => _showMutedKeywordsSheet(),
                ),

                SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.flag,
                        label: 'Report',
                        color: Color(0xFFef4444),
                        onTap: () {
                          Navigator.pop(context);
                          // User will then report content
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.add,
                        label: 'Mute Word',
                        color: Color(0xFFf59e0b),
                        onTap: () => _showAddMutedKeywordDialog(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildTrustBadgeCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _trustLevel!.badgeColor,
            _trustLevel!.badgeColor.withOpacity(0.6)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_trustLevel!.badgeEmoji.isNotEmpty)
                Text(
                  _trustLevel!.badgeEmoji,
                  style: TextStyle(fontSize: 48),
                ),
              if (_trustLevel!.badgeEmoji.isNotEmpty) SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _trustLevel!.badgeText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Thank you for keeping our community safe!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrustStat(
                  'Valid Reports', _trustLevel!.validReports.toString()),
              _buildTrustStat('Accuracy',
                  '${(_trustLevel!.accuracyRate * 100).toStringAsFixed(0)}%'),
              _buildTrustStat(
                  'Helpful Votes', _trustLevel!.helpfulVotes.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Color(0xFF2a2a3e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        trailing: trailing ??
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Color(0xFF2a2a3e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockedUsersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF2a2a3e),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Color(0xFFef4444)),
                      SizedBox(width: 12),
                      Text(
                        'Blocked Users',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1)),
                // List
                Expanded(
                  child: _blockedUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.block_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3)),
                              SizedBox(height: 16),
                              Text(
                                'No blocked users',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: _blockedUsers.length,
                          itemBuilder: (context, index) {
                            final user = _blockedUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: user.blockedUserAvatar != null
                                    ? NetworkImage(user.blockedUserAvatar!)
                                    : null,
                                child: user.blockedUserAvatar == null
                                    ? Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                user.blockedUserName,
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Blocked ${_formatDate(user.blockedAt)}',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5)),
                              ),
                              trailing: TextButton(
                                onPressed: () async {
                                  await UserSafetyService.unblockUser(
                                    userId: user.userId,
                                    blockedUserId: user.blockedUserId,
                                  );
                                  _loadData();
                                  Navigator.pop(context);
                                },
                                child: Text('Unblock'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMutedKeywordsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF2a2a3e),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.volume_off, color: Color(0xFFf59e0b)),
                      SizedBox(width: 12),
                      Text(
                        'Muted Keywords',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddMutedKeywordDialog();
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.1)),
                // List
                Expanded(
                  child: _mutedKeywords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.volume_off_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3)),
                              SizedBox(height: 16),
                              Text(
                                'No muted keywords',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showAddMutedKeywordDialog();
                                },
                                child: Text('Add Keyword'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: _mutedKeywords.length,
                          itemBuilder: (context, index) {
                            final keyword = _mutedKeywords[index];
                            return Card(
                              color: Color(0xFF3a3a4e),
                              child: ListTile(
                                leading:
                                    Icon(Icons.label, color: Color(0xFFf59e0b)),
                                title: Text(
                                  keyword.displayKeyword,
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Added ${_formatDate(keyword.createdAt)}',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5)),
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    await UserSafetyService.removeMutedKeyword(
                                      userId: keyword.userId,
                                      keywordId: keyword.id,
                                    );
                                    _loadData();
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.delete,
                                      color: Color(0xFFef4444)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMutedKeywordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF2a2a3e),
          title:
              Text('Add Muted Keyword', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter keyword',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await UserSafetyService.addMutedKeyword(
                    userId: 'current_user_id',
                    keyword: controller.text.trim(),
                  );
                  _loadData();
                  Navigator.pop(context);
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xFFf59e0b)),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
