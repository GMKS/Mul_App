/// Bulk Content Management Screen
/// Upload, approve, delete content in bulk with drag-and-drop

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AdminContentManagementScreen extends StatefulWidget {
  const AdminContentManagementScreen({super.key});

  @override
  State<AdminContentManagementScreen> createState() =>
      _AdminContentManagementScreenState();
}

class _AdminContentManagementScreenState
    extends State<AdminContentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> _selectedItems = [];
  bool _isMultiSelectMode = false;
  String _filterType = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _mockContent = List.generate(
    20,
    (index) => {
      'id': 'content_$index',
      'title': 'Content Title $index',
      'type': index % 3 == 0
          ? 'devotional'
          : index % 3 == 1
              ? 'business'
              : 'event',
      'status': index % 4 == 0 ? 'pending' : 'approved',
      'author': 'User ${index + 1}',
      'date': DateTime.now().subtract(Duration(days: index)),
      'views': (index + 1) * 100,
    },
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTopActions(),
          _buildTabBar(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
      floatingActionButton: _isMultiSelectMode && _selectedItems.isNotEmpty
          ? _buildBulkActionFAB()
          : _buildUploadFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF16213e),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Content Management',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isMultiSelectMode ? Icons.close : Icons.checklist,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isMultiSelectMode = !_isMultiSelectMode;
              if (!_isMultiSelectMode) _selectedItems.clear();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterOptions,
        ),
      ],
    );
  }

  Widget _buildTopActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search content...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF2a2a3e),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_isMultiSelectMode && _selectedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6366f1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF6366f1)),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedItems.length} items selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _selectedItems.clear()),
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF16213e),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF6366f1),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'All Content'),
          Tab(text: 'Devotional'),
          Tab(text: 'Business'),
          Tab(text: 'Events'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildContentList('all'),
        _buildContentList('devotional'),
        _buildContentList('business'),
        _buildContentList('event'),
      ],
    );
  }

  Widget _buildContentList(String type) {
    final filteredContent = _mockContent.where((item) {
      if (type != 'all' && item['type'] != type) return false;
      if (_filterType != 'all' && item['status'] != _filterType) return false;
      if (_searchQuery.isNotEmpty &&
          !item['title'].toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    if (filteredContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No content found',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredContent.length,
      itemBuilder: (context, index) {
        final item = filteredContent[index];
        final isSelected = _selectedItems.contains(item['id']);

        return _buildContentCard(item, isSelected);
      },
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item, bool isSelected) {
    final status = item['status'] as String;
    final statusColor =
        status == 'pending' ? const Color(0xFFf59e0b) : const Color(0xFF10b981);

    return GestureDetector(
      onTap: () {
        if (_isMultiSelectMode) {
          setState(() {
            if (isSelected) {
              _selectedItems.remove(item['id']);
            } else {
              _selectedItems.add(item['id']);
            }
          });
        } else {
          _showContentDetails(item);
        }
      },
      onLongPress: () {
        setState(() {
          _isMultiSelectMode = true;
          _selectedItems.add(item['id']);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366f1) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            if (_isMultiSelectMode)
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedItems.add(item['id']);
                    } else {
                      _selectedItems.remove(item['id']);
                    }
                  });
                },
                activeColor: const Color(0xFF6366f1),
              ),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(item['type']),
                color: statusColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        item['author'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.visibility, size: 14, color: Colors.white54),
                      const SizedBox(width: 4),
                      Text(
                        '${item['views']} views',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!_isMultiSelectMode)
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: const Color(0xFF2a2a3e),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('View', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  if (status == 'pending')
                    const PopupMenuItem(
                      value: 'approve',
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 18, color: Color(0xFF10b981)),
                          SizedBox(width: 8),
                          Text('Approve',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Color(0xFFef4444)),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) =>
                    _handleItemAction(value.toString(), item),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadFAB() {
    return FloatingActionButton.extended(
      onPressed: _showBulkUploadDialog,
      backgroundColor: const Color(0xFF6366f1),
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Bulk Upload'),
    );
  }

  Widget _buildBulkActionFAB() {
    return FloatingActionButton.extended(
      onPressed: _showBulkActionsDialog,
      backgroundColor: const Color(0xFF6366f1),
      icon: const Icon(Icons.done_all),
      label: const Text('Bulk Actions'),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'devotional':
        return Icons.temple_hindu;
      case 'business':
        return Icons.business;
      case 'event':
        return Icons.event;
      default:
        return Icons.article;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter by Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Colors.white),
              title: const Text('All', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _filterType = 'all');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.pending_actions, color: Color(0xFFf59e0b)),
              title:
                  const Text('Pending', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _filterType = 'pending');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF10b981)),
              title:
                  const Text('Approved', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _filterType = 'approved');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkUploadDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Bulk Upload', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUploadOption(
              'Upload Videos',
              'Multiple video files',
              Icons.video_library,
              () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.video,
                );
                if (result != null) {
                  _showUploadProgress(result.files.length);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              'Upload Images',
              'Multiple image files',
              Icons.image,
              () async {
                Navigator.pop(context);
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.image,
                );
                if (result != null) {
                  _showUploadProgress(result.files.length);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildUploadOption(
              'Import from CSV',
              'Bulk data import',
              Icons.table_chart,
              () {
                Navigator.pop(context);
                _showComingSoon();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a3e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF6366f1)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  void _showBulkActionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bulk Actions (${_selectedItems.length} items)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF10b981)),
              title: const Text('Approve All',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _bulkApprove();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFef4444)),
              title: const Text('Delete All',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _bulkDelete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF3b82f6)),
              title: const Text('Schedule Publish',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'view':
        _showContentDetails(item);
        break;
      case 'approve':
        _approveContent(item);
        break;
      case 'edit':
        _showComingSoon();
        break;
      case 'delete':
        _deleteContent(item);
        break;
    }
  }

  void _showContentDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(item['title'], style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', item['type']),
            _buildDetailRow('Status', item['status']),
            _buildDetailRow('Author', item['author']),
            _buildDetailRow('Views', '${item['views']}'),
            _buildDetailRow(
              'Date',
              '${(item['date'] as DateTime).day}/${(item['date'] as DateTime).month}/${(item['date'] as DateTime).year}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _approveContent(Map<String, dynamic> item) {
    setState(() {
      item['status'] = 'approved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['title']} approved'),
        backgroundColor: const Color(0xFF10b981),
      ),
    );
  }

  void _deleteContent(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title:
            const Text('Delete Content', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${item['title']}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mockContent.remove(item);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content deleted'),
                  backgroundColor: Color(0xFFef4444),
                ),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFef4444))),
          ),
        ],
      ),
    );
  }

  void _bulkApprove() {
    setState(() {
      for (var id in _selectedItems) {
        final item = _mockContent.firstWhere((item) => item['id'] == id);
        item['status'] = 'approved';
      }
      _selectedItems.clear();
      _isMultiSelectMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content approved'),
        backgroundColor: Color(0xFF10b981),
      ),
    );
  }

  void _bulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Bulk Delete', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${_selectedItems.length} items?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _mockContent
                    .removeWhere((item) => _selectedItems.contains(item['id']));
                _selectedItems.clear();
                _isMultiSelectMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content deleted'),
                  backgroundColor: Color(0xFFef4444),
                ),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFef4444))),
          ),
        ],
      ),
    );
  }

  void _showUploadProgress(int fileCount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Uploading Files',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF6366f1)),
            const SizedBox(height: 16),
            Text(
              'Uploading $fileCount files...',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    // Simulate upload
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fileCount files uploaded successfully'),
          backgroundColor: const Color(0xFF10b981),
        ),
      );
    });
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: Color(0xFF6366f1),
      ),
    );
  }
}
