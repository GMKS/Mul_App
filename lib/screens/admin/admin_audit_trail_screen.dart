/// Audit Trail & Version History
/// Track changes and admin actions with timestamps

import 'package:flutter/material.dart';

class AdminAuditTrailScreen extends StatefulWidget {
  const AdminAuditTrailScreen({super.key});

  @override
  State<AdminAuditTrailScreen> createState() => _AdminAuditTrailScreenState();
}

class _AdminAuditTrailScreenState extends State<AdminAuditTrailScreen> {
  String _filterAction = 'all';
  String _filterAdmin = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _auditLogs = List.generate(
    30,
    (index) => {
      'id': 'log_$index',
      'action': [
        'Content Approved',
        'Content Deleted',
        'User Banned',
        'Role Changed',
        'Notification Sent',
        'Settings Updated',
      ][index % 6],
      'admin': ['John Doe', 'Jane Smith', 'Bob Johnson'][index % 3],
      'target': 'Target Item #${index + 1}',
      'details': 'Action details and description for log entry ${index + 1}',
      'timestamp': DateTime.now().subtract(Duration(hours: index)),
      'ipAddress': '192.168.1.${100 + (index % 50)}',
      'changes': {
        'before': 'Previous value',
        'after': 'New value',
      },
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Audit Trail', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _exportLogs,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildAuditLogsList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search logs...',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'Action: ${_filterAction == 'all' ? 'All' : _filterAction}',
                  Icons.event,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Admin: ${_filterAdmin == 'all' ? 'All' : _filterAdmin}',
                  Icons.person,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogsList() {
    final filteredLogs = _auditLogs.where((log) {
      if (_filterAction != 'all' && log['action'] != _filterAction)
        return false;
      if (_filterAdmin != 'all' && log['admin'] != _filterAdmin) return false;
      if (_searchQuery.isNotEmpty &&
          !log['action'].toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !log['target'].toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        return _buildAuditLogCard(log);
      },
    );
  }

  Widget _buildAuditLogCard(Map<String, dynamic> log) {
    final color = _getActionColor(log['action']);
    final icon = _getActionIcon(log['action']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['action'],
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log['target'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTimestamp(log['timestamp']),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2a2a3e), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withOpacity(0.3),
                child: Text(
                  log['admin'][0],
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                log['admin'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.computer, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                log['ipAddress'],
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            log['details'],
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showLogDetails(log),
                icon: const Icon(Icons.visibility, size: 14),
                label: const Text('Details', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showChanges(log),
                icon: const Icon(Icons.compare, size: 14),
                label: const Text('Changes', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('Approved') || action.contains('Updated')) {
      return const Color(0xFF10b981);
    } else if (action.contains('Deleted') || action.contains('Banned')) {
      return const Color(0xFFef4444);
    } else if (action.contains('Changed')) {
      return const Color(0xFFf59e0b);
    } else {
      return const Color(0xFF6366f1);
    }
  }

  IconData _getActionIcon(String action) {
    if (action.contains('Approved')) {
      return Icons.check_circle;
    } else if (action.contains('Deleted')) {
      return Icons.delete;
    } else if (action.contains('Banned')) {
      return Icons.block;
    } else if (action.contains('Changed')) {
      return Icons.edit;
    } else if (action.contains('Sent')) {
      return Icons.send;
    } else {
      return Icons.settings;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showFilterDialog() {
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
              'Filter Logs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'By Action',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'all',
                'Content Approved',
                'Content Deleted',
                'User Banned',
                'Role Changed',
                'Notification Sent',
                'Settings Updated',
              ].map((action) {
                return FilterChip(
                  label: Text(action == 'all' ? 'All Actions' : action),
                  selected: _filterAction == action,
                  onSelected: (selected) {
                    setState(() {
                      _filterAction = action;
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: const Color(0xFF2a2a3e),
                  selectedColor: const Color(0xFF6366f1),
                  labelStyle: TextStyle(
                    color:
                        _filterAction == action ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Log Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Action', log['action']),
            _buildDetailRow('Admin', log['admin']),
            _buildDetailRow('Target', log['target']),
            _buildDetailRow('IP Address', log['ipAddress']),
            _buildDetailRow(
              'Timestamp',
              '${log['timestamp'].day}/${log['timestamp'].month}/${log['timestamp'].year} ${log['timestamp'].hour}:${log['timestamp'].minute}',
            ),
            const SizedBox(height: 12),
            const Text(
              'Details:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              log['details'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  void _showChanges(Map<String, dynamic> log) {
    final changes = log['changes'] as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Version History',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Before:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFef4444).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                changes['before'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'After:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10b981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                changes['after'],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature coming soon!'),
                  backgroundColor: Color(0xFF6366f1),
                ),
              );
            },
            child: const Text('Restore Previous Version'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Export Logs', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.white),
              title: const Text('Export as CSV',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.white),
              title: const Text('Export as PDF',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
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
