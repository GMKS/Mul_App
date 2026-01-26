/// Community Help Screen
/// Comprehensive community assistance platform with help requests, volunteers, and resources

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/community_help_model.dart';
import '../services/community_help_service.dart';
import '../l10n/app_localizations.dart';

class CommunityHelpScreen extends StatefulWidget {
  const CommunityHelpScreen({super.key});

  @override
  State<CommunityHelpScreen> createState() => _CommunityHelpScreenState();
}

class _CommunityHelpScreenState extends State<CommunityHelpScreen>
    with SingleTickerProviderStateMixin {
  final _helpService = CommunityHelpService();
  late TabController _tabController;

  List<HelpRequest> _helpRequests = [];
  List<CommunityVolunteer> _volunteers = [];
  List<ResourceShare> _resources = [];
  List<CommunityBulletin> _bulletins = [];
  bool _isLoading = true;

  HelpCategory? _selectedCategory;
  String _sortBy = 'urgent';
  bool _showOpenOnly = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _helpService.initializeMockData();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final requests = await _helpService.fetchHelpRequests(
      category: _selectedCategory,
      status: _showOpenOnly ? HelpRequestStatus.open : null,
      sortBy: _sortBy,
    );

    final volunteers = await _helpService.fetchVolunteers(
      skill: _selectedCategory,
      isAvailable: true,
      sortBy: 'rating',
    );

    final resources = await _helpService.fetchResources();
    final bulletins = await _helpService.fetchBulletins();

    setState(() {
      _helpRequests = requests;
      _volunteers = volunteers;
      _resources = resources;
      _bulletins = bulletins;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1419) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n?.communityHelp ?? 'Community Help'),
        backgroundColor: isDark ? const Color(0xFF1C2938) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.help), text: 'Requests'),
            Tab(icon: Icon(Icons.people), text: 'Volunteers'),
            Tab(icon: Icon(Icons.card_giftcard), text: 'Resources'),
            Tab(icon: Icon(Icons.announcement), text: 'Bulletin'),
            Tab(icon: Icon(Icons.group), text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(isDark),
          _buildVolunteersTab(isDark),
          _buildResourcesTab(isDark),
          _buildBulletinTab(isDark),
          _buildGroupsTab(isDark),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // FAB based on active tab
  Widget _buildFAB() {
    if (_tabController.index == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'sos',
            onPressed: _showSOSDialog,
            backgroundColor: Colors.red,
            child: const Icon(Icons.emergency),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'request',
            onPressed: _showCreateRequestDialog,
            icon: const Icon(Icons.add),
            label: const Text('Request Help'),
          ),
        ],
      );
    } else if (_tabController.index == 2) {
      return FloatingActionButton.extended(
        onPressed: _showShareResourceDialog,
        icon: const Icon(Icons.volunteer_activism),
        label: const Text('Share Resource'),
      );
    }
    return const SizedBox.shrink();
  }

  // Requests Tab
  Widget _buildRequestsTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Category filter
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: HelpCategory.values.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildCategoryChip(
                        'All', null, Icons.apps, Colors.grey, isDark);
                  }
                  final category = HelpCategory.values[index - 1];
                  return _buildCategoryChip(
                    HelpCategoryHelper.getName(category),
                    category,
                    HelpCategoryHelper.getIcon(category),
                    HelpCategoryHelper.getColor(category),
                    isDark,
                  );
                },
              ),
            ),
          ),

          // Help requests list
          if (_helpRequests.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No help requests',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildHelpRequestCard(_helpRequests[index], isDark);
                  },
                  childCount: _helpRequests.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, HelpCategory? category, IconData icon,
      Color color, bool isDark) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          setState(() => _selectedCategory = category);
          _loadData();
        },
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.2)
                : (isDark ? const Color(0xFF1C2938) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpRequestCard(HelpRequest request, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1C2938) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(request.userPhotoUrl),
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
                                request.userName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (request.isAnonymous)
                              const Icon(Icons.visibility_off,
                                  size: 14, color: Colors.grey),
                          ],
                        ),
                        Text(
                          timeago.format(request.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: request.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: request.statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      request.statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: request.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: HelpCategoryHelper.getColor(request.category)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      HelpCategoryHelper.getIcon(request.category),
                      color: HelpCategoryHelper.getColor(request.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      HelpCategoryHelper.getName(request.category),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: HelpCategoryHelper.getColor(request.category),
                      ),
                    ),
                  ),
                  if (request.isEmergency)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.emergency, size: 14, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                request.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                request.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              if (request.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: request.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$tag',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.comment, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${request.responseCount} responses',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  if (request.status == HelpRequestStatus.open)
                    ElevatedButton(
                      onPressed: () => _showRespondDialog(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text('I Can Help'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Volunteers Tab
  Widget _buildVolunteersTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _volunteers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No volunteers available',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _volunteers.length,
              itemBuilder: (context, index) {
                return _buildVolunteerCard(_volunteers[index], isDark);
              },
            ),
    );
  }

  Widget _buildVolunteerCard(CommunityVolunteer volunteer, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1C2938) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(volunteer.photoUrl),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: volunteer.levelColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          volunteer.levelIcon,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        volunteer.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 16, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${volunteer.rating} • ${volunteer.totalHelps} helps',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (volunteer.isAvailable)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.check, size: 14, color: Colors.white),
                  ),
              ],
            ),
            if (volunteer.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                volunteer.bio,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: volunteer.skills.take(4).map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: HelpCategoryHelper.getColor(skill).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        HelpCategoryHelper.getIcon(skill),
                        size: 12,
                        color: HelpCategoryHelper.getColor(skill),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        HelpCategoryHelper.getName(skill),
                        style: TextStyle(
                          fontSize: 11,
                          color: HelpCategoryHelper.getColor(skill),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (volunteer.badges.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: volunteer.badges.take(3).map((badge) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events,
                            size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          badge,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.amber),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.red.shade400),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    volunteer.location,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),
                if (volunteer.isAvailable)
                  ElevatedButton(
                    onPressed: () {
                      // Contact volunteer
                    },
                    child: const Text('Contact'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Resources Tab
  Widget _buildResourcesTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _resources.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No resources shared',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _resources.length,
              itemBuilder: (context, index) {
                return _buildResourceCard(_resources[index], isDark);
              },
            ),
    );
  }

  Widget _buildResourceCard(ResourceShare resource, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1C2938) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                ResourceTypeHelper.getIcon(resource.type),
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(resource.userPhotoUrl),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        resource.userName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Qty: ${resource.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: resource.isAvailable ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Claim'),
            ),
          ],
        ),
      ),
    );
  }

  // Bulletin Tab
  Widget _buildBulletinTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _bulletins.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.announcement,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No bulletins',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bulletins.length,
              itemBuilder: (context, index) {
                return _buildBulletinCard(_bulletins[index], isDark);
              },
            ),
    );
  }

  Widget _buildBulletinCard(CommunityBulletin bulletin, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? const Color(0xFF1C2938) : Colors.white,
      elevation: bulletin.isPinned ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: bulletin.isPinned
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (bulletin.isPinned)
                  Icon(Icons.push_pin,
                      size: 20, color: Theme.of(context).primaryColor),
                if (bulletin.isPinned) const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bulletin.category,
                    style: const TextStyle(fontSize: 11, color: Colors.blue),
                  ),
                ),
                const Spacer(),
                Text(
                  timeago.format(bulletin.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              bulletin.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bulletin.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(bulletin.userPhotoUrl),
                ),
                const SizedBox(width: 8),
                Text(
                  bulletin.userName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const Spacer(),
                Icon(Icons.visibility, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '${bulletin.viewCount}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Groups Tab
  Widget _buildGroupsTab(bool isDark) {
    return const Center(
      child: Text('Community Groups - Coming Soon'),
    );
  }

  // Dialogs
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Requests'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Show Open Only'),
                value: _showOpenOnly,
                onChanged: (value) =>
                    setDialogState(() => _showOpenOnly = value),
              ),
              const Divider(),
              RadioListTile(
                title: const Text('Most Urgent'),
                value: 'urgent',
                groupValue: _sortBy,
                onChanged: (value) => setDialogState(() => _sortBy = value!),
              ),
              RadioListTile(
                title: const Text('Most Recent'),
                value: 'recent',
                groupValue: _sortBy,
                onChanged: (value) => setDialogState(() => _sortBy = value!),
              ),
            ],
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
              _loadData();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'This will send an emergency alert to all nearby volunteers and authorities. Use only for urgent situations.',
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
                const SnackBar(
                  content: Text('Emergency alert sent to nearby volunteers'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  void _showCreateRequestDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    HelpCategory selectedCategory = HelpCategory.medical;
    HelpPriority selectedPriority = HelpPriority.medium;
    bool isEmergency = false;
    bool isAnonymous = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Help'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<HelpCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: HelpCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(HelpCategoryHelper.getName(cat)),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedCategory = value!),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                CheckboxListTile(
                  title: const Text('Emergency'),
                  value: isEmergency,
                  onChanged: (value) =>
                      setDialogState(() => isEmergency = value!),
                ),
                CheckboxListTile(
                  title: const Text('Post Anonymously'),
                  value: isAnonymous,
                  onChanged: (value) =>
                      setDialogState(() => isAnonymous = value!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;

              await _helpService.createHelpRequest(
                userId: 'u1',
                userName: 'Current User',
                userPhotoUrl: 'https://i.pravatar.cc/150?img=68',
                category: selectedCategory,
                title: titleController.text,
                description: descController.text,
                location: 'User location',
                latitude: 17.4948,
                longitude: 78.3985,
                isEmergency: isEmergency,
                isAnonymous: isAnonymous,
                priority:
                    isEmergency ? HelpPriority.critical : HelpPriority.medium,
              );

              Navigator.pop(context);
              _loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help request created!')),
              );
            },
            child: const Text('Post Request'),
          ),
        ],
      ),
    );
  }

  void _showShareResourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Resource'),
        content: const Text('Resource sharing dialog - Coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(HelpRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Category: ${HelpCategoryHelper.getName(request.category)}'),
              const SizedBox(height: 8),
              Text('Status: ${request.statusText}'),
              const SizedBox(height: 8),
              Text('Posted by: ${request.userName}'),
              const SizedBox(height: 8),
              Text(request.description),
              const SizedBox(height: 12),
              Text('Location: ${request.location}'),
              if (request.contactPhone != null) ...[
                const SizedBox(height: 8),
                Text('Contact: ${request.contactPhone}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (request.status == HelpRequestStatus.open)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showRespondDialog(request);
              },
              child: const Text('Respond'),
            ),
        ],
      ),
    );
  }

  void _showRespondDialog(HelpRequest request) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offer Help'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Your message',
            hintText: 'How can you help?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.isEmpty) return;

              await _helpService.respondToRequest(
                requestId: request.id,
                volunteerId: 'u1',
                volunteerName: 'Current User',
                volunteerPhotoUrl: 'https://i.pravatar.cc/150?img=68',
                message: messageController.text,
              );

              Navigator.pop(context);
              _loadData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Response sent!')),
              );
            },
            child: const Text('Send Response'),
          ),
        ],
      ),
    );
  }
}
