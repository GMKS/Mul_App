/// Health Tips Screen
/// Main screen for browsing health tips with categories, alerts, and personalization
/// Features: Tip of the day, categories, alerts, search, saved tips

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/health_tips_model.dart';
import '../../services/health_tips_service.dart';
import 'health_tip_detail_screen.dart';

class HealthTipsScreen extends StatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  State<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends State<HealthTipsScreen>
    with SingleTickerProviderStateMixin {
  final HealthTipsService _service = HealthTipsService();
  late TabController _tabController;

  List<HealthTip> _allTips = [];
  List<HealthAlert> _alerts = [];
  HealthTip? _tipOfTheDay;
  bool _isLoading = true;

  HealthCategory? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  bool _showDisclaimer = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _showDisclaimerDialog();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showDisclaimerDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showDisclaimer) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Health Information Disclaimer',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The health tips provided here are for general awareness and informational purposes only.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
                Text(
                  '⚕️ This is NOT medical advice',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Always consult a qualified healthcare professional for medical concerns\n'
                  '• Do not delay seeking medical advice based on information here\n'
                  '• Individual health needs vary - what works for one may not work for all',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _showDisclaimer = false);
                },
                child: const Text('I Understand'),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final tips = await _service.getTips();
    final alerts = await _service.getActiveAlerts(city: 'Hyderabad');
    final tipOfDay = await _service.getTipOfTheDay();

    if (mounted) {
      setState(() {
        _allTips = tips;
        _alerts = alerts;
        _tipOfTheDay = tipOfDay;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            if (_alerts.isNotEmpty) _buildAlertsBar(),
            _buildCategoryFilters(),
            _buildTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💊', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'For awareness & information only',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: _openSavedTips,
            tooltip: 'Saved Tips',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openPreferences,
            tooltip: 'Preferences',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search health tips...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadData();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildAlertsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          final isUrgent = alert.priority == TipPriority.urgent ||
              alert.priority == TipPriority.emergency;

          return GestureDetector(
            onTap: () {
              if (alert.tipId != null) {
                final tip = _allTips.firstWhere(
                  (t) => t.id == alert.tipId,
                  orElse: () => _allTips.first,
                );
                _openTipDetail(tip);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isUrgent
                      ? [Colors.red[600]!, Colors.red[400]!]
                      : [Colors.orange[600]!, Colors.orange[400]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getAlertIcon(alert.trigger),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getAlertIcon(AlertTrigger trigger) {
    switch (trigger) {
      case AlertTrigger.aqi:
        return Icons.air;
      case AlertTrigger.weather:
        return Icons.thermostat;
      case AlertTrigger.outbreak:
        return Icons.coronavirus;
      case AlertTrigger.seasonal:
        return Icons.calendar_today;
      case AlertTrigger.festival:
        return Icons.celebration;
      case AlertTrigger.emergency:
        return Icons.emergency;
    }
  }

  Widget _buildCategoryFilters() {
    final categories = [
      {'icon': Icons.local_hospital, 'label': 'All', 'category': null},
      {
        'icon': Icons.favorite,
        'label': 'General',
        'category': HealthCategory.general
      },
      {
        'icon': Icons.pregnant_woman,
        'label': 'Women & Child',
        'category': HealthCategory.womenChild
      },
      {
        'icon': Icons.elderly,
        'label': 'Senior Care',
        'category': HealthCategory.seniorCare
      },
      {
        'icon': Icons.psychology,
        'label': 'Mental',
        'category': HealthCategory.mentalWellness
      },
      {
        'icon': Icons.wb_sunny,
        'label': 'Seasonal',
        'category': HealthCategory.seasonal
      },
      {
        'icon': Icons.restaurant,
        'label': 'Nutrition',
        'category': HealthCategory.nutrition
      },
      {
        'icon': Icons.fitness_center,
        'label': 'Fitness',
        'category': HealthCategory.fitness
      },
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['category'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['category'] as HealthCategory?;
              });
              _filterByCategory(_selectedCategory);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.green,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.green,
      tabs: const [
        Tab(text: 'For You'),
        Tab(text: 'Trending'),
        Tab(text: 'Latest'),
      ],
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildForYouTab(),
        _buildTipsList(_allTips.where((t) => t.viewCount > 10000).toList()
          ..sort((a, b) => b.viewCount.compareTo(a.viewCount))),
        _buildTipsList(
            _allTips..sort((a, b) => b.createdAt.compareTo(a.createdAt))),
      ],
    );
  }

  Widget _buildForYouTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disclaimer Banner
            _buildDisclaimerBanner(),
            const SizedBox(height: 16),

            // Tip of the Day
            if (_tipOfTheDay != null) ...[
              _buildSectionHeader('💡 Tip of the Day', null),
              const SizedBox(height: 12),
              _buildTipOfDayCard(_tipOfTheDay!),
              const SizedBox(height: 24),
            ],

            // Categories
            _buildSectionHeader('📂 Browse by Category', null),
            const SizedBox(height: 12),
            _buildCategoryGrid(),
            const SizedBox(height: 24),

            // Recommended Tips
            _buildSectionHeader('🎯 Recommended for You', () {}),
            const SizedBox(height: 12),
            ..._allTips.take(5).map((tip) => _buildTipCard(tip)),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Health tips are for awareness only. Always consult a doctor for medical advice.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }

  Widget _buildTipOfDayCard(HealthTip tip) {
    return GestureDetector(
      onTap: () => _openTipDetail(tip),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tip.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  tip.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    color: Colors.green[300],
                    child: const Icon(Icons.health_and_safety,
                        size: 48, color: Colors.white),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lightbulb,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              tip.category.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildVerificationBadgeWhite(tip),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tip.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip.shortDescription,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatWhite(Icons.remove_red_eye,
                          '${_formatCount(tip.viewCount)} views'),
                      const SizedBox(width: 16),
                      _buildStatWhite(Icons.thumb_up,
                          '${tip.helpfulnessScore.toStringAsFixed(0)}% helpful'),
                      const Spacer(),
                      const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadgeWhite(HealthTip tip) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tip.verificationSource.emoji,
              style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            tip.verificationSource.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatWhite(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = HealthCategory.values.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final tipCount = _allTips.where((t) => t.category == category).length;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedCategory = category);
            _tabController.animateTo(1);
            _filterByCategory(category);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  category.displayName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$tipCount tips',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipsList(List<HealthTip> tips) {
    if (tips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tips available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) => _buildTipCard(tips[index]),
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    final isSaved = _service.isTipSaved(tip.id);

    return GestureDetector(
      onTap: () => _openTipDetail(tip),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (tip.imageUrl != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      tip.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.health_and_safety, size: 48),
                      ),
                    ),
                  ),
                  // Sponsored badge
                  if (tip.isSponsored)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Sponsored',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Save button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleSave(tip),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                          color: isSaved ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Verification
                  Row(
                    children: [
                      _buildCategoryChip(tip.category),
                      const SizedBox(width: 8),
                      _buildVerificationBadge(tip),
                      if (tip.isAlert) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ALERT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    tip.shortDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Stats & Actions
                  Row(
                    children: [
                      _buildStat(Icons.remove_red_eye_outlined,
                          _formatCount(tip.viewCount)),
                      const SizedBox(width: 16),
                      _buildStat(Icons.thumb_up_outlined,
                          _formatCount(tip.helpfulCount)),
                      const SizedBox(width: 16),
                      _buildStat(
                          Icons.share_outlined, _formatCount(tip.shareCount)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _shareTip(tip),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share,
                                  size: 14, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Share',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(HealthCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(HealthTip tip) {
    Color badgeColor;
    switch (tip.verificationSource) {
      case VerificationSource.doctorVerified:
        badgeColor = Colors.green;
        break;
      case VerificationSource.govtHealth:
        badgeColor = Colors.blue;
        break;
      case VerificationSource.whoApproved:
        badgeColor = Colors.cyan;
        break;
      case VerificationSource.ayushCertified:
        badgeColor = Colors.purple;
        break;
      default:
        badgeColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            tip.verificationSource.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ==================== ACTIONS ====================

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _loadData();
      return;
    }

    setState(() => _isLoading = true);
    final results = await _service.searchTips(query);
    setState(() {
      _allTips = results;
      _isLoading = false;
    });
  }

  void _filterByCategory(HealthCategory? category) async {
    setState(() => _isLoading = true);
    final tips = await _service.getTips(category: category);
    setState(() {
      _allTips = tips;
      _isLoading = false;
    });
  }

  void _openTipDetail(HealthTip tip) {
    _service.recordView(tip.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthTipDetailScreen(tip: tip),
      ),
    ).then((_) => setState(() {})); // Refresh saved state
  }

  void _toggleSave(HealthTip tip) async {
    if (_service.isTipSaved(tip.id)) {
      await _service.unsaveTip(tip.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tip removed from saved')),
      );
    } else {
      await _service.saveTip(tip.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💾 Tip saved!')),
      );
    }
    setState(() {});
  }

  void _shareTip(HealthTip tip) {
    _service.recordShare(tip.id);
    Share.share(
      '💊 Health Tip: ${tip.title}\n\n'
      '${tip.shortDescription}\n\n'
      '${tip.verificationSource.emoji} ${tip.verificationSource.displayName}\n\n'
      '⚠️ For awareness only. Consult a doctor for medical advice.\n'
      'Shared via My City App',
    );
  }

  void _openSavedTips() async {
    final savedTips = await _service.getSavedTips();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '💾 Saved Tips',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: savedTips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No saved tips yet',
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: savedTips.length,
                      itemBuilder: (context, index) =>
                          _buildTipCard(savedTips[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPreferences() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚙️ Health Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Daily Health Reminder'),
              subtitle: const Text('Get a health tip every morning'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.green,
            ),
            SwitchListTile(
              title: const Text('Emergency Alerts'),
              subtitle: const Text('Receive urgent health alerts'),
              value: true,
              onChanged: (value) {},
              activeColor: Colors.green,
            ),
            ListTile(
              title: const Text('Preferred Categories'),
              subtitle: const Text('General, Fitness, Nutrition'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
