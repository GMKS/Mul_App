/// Feedback & Reporting System
/// View user reports and resolve issues

import 'package:flutter/material.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'all';

  final List<Map<String, dynamic>> _reports = List.generate(
    15,
    (index) => {
      'id': 'report_$index',
      'type': ['Content Report', 'User Feedback', 'Bug Report'][index % 3],
      'subject': 'Report Subject ${index + 1}',
      'description':
          'Detailed description of the issue or feedback ${index + 1}',
      'reporter': 'User ${index + 1}',
      'reportedItem': 'Content #${index + 100}',
      'status': ['pending', 'reviewed', 'resolved'][index % 3],
      'priority': ['low', 'medium', 'high'][index % 3],
      'createdAt': DateTime.now().subtract(Duration(days: index)),
    },
  );

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
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reports & Feedback',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366f1),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'All Reports'),
            Tab(text: 'Content'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsList('all'),
          _buildReportsList('Content Report'),
          _buildReportsList('User Feedback'),
        ],
      ),
    );
  }

  Widget _buildReportsList(String filterType) {
    final filteredReports = _reports.where((report) {
      if (filterType != 'all' && report['type'] != filterType) return false;
      if (_filterStatus != 'all' && report['status'] != _filterStatus)
        return false;
      return true;
    }).toList();

    if (filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No reports found',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final priority = report['priority'] as String;
    final status = report['status'] as String;

    final priorityColor = priority == 'high'
        ? const Color(0xFFef4444)
        : priority == 'medium'
            ? const Color(0xFFf59e0b)
            : const Color(0xFF10b981);

    final statusColor = status == 'pending'
        ? const Color(0xFFf59e0b)
        : status == 'reviewed'
            ? const Color(0xFF6366f1)
            : const Color(0xFF10b981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(report['type']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(report['type']),
                  color: _getTypeColor(report['type']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['subject'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
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
          const SizedBox(height: 12),
          Text(
            report['description'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                report['reporter'],
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(width: 12),
              Icon(Icons.flag, size: 14, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                report['reportedItem'],
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (status == 'pending')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _reviewReport(report),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366f1),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Review', style: TextStyle(fontSize: 12)),
                  ),
                ),
              if (status == 'pending') const SizedBox(width: 8),
              if (status != 'resolved')
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resolveReport(report),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF10b981)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Resolve',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF10b981))),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onPressed: () => _showReportDetails(report),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Content Report':
        return const Color(0xFFef4444);
      case 'User Feedback':
        return const Color(0xFF10b981);
      case 'Bug Report':
        return const Color(0xFFf59e0b);
      default:
        return const Color(0xFF6366f1);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Content Report':
        return Icons.flag;
      case 'User Feedback':
        return Icons.feedback;
      case 'Bug Report':
        return Icons.bug_report;
      default:
        return Icons.report;
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
                setState(() => _filterStatus = 'all');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.pending_actions, color: Color(0xFFf59e0b)),
              title:
                  const Text('Pending', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _filterStatus = 'pending');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Color(0xFF6366f1)),
              title:
                  const Text('Reviewed', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _filterStatus = 'reviewed');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF10b981)),
              title:
                  const Text('Resolved', style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _filterStatus = 'resolved');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _reviewReport(Map<String, dynamic> report) {
    setState(() {
      report['status'] = 'reviewed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${report['subject']} marked as reviewed'),
        backgroundColor: const Color(0xFF6366f1),
      ),
    );
  }

  void _resolveReport(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title:
            const Text('Resolve Report', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add resolution note...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2a2a3e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                report['status'] = 'resolved';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${report['subject']} resolved'),
                  backgroundColor: const Color(0xFF10b981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10b981),
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title:
            const Text('Report Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', report['type']),
            _buildDetailRow('Subject', report['subject']),
            _buildDetailRow('Reporter', report['reporter']),
            _buildDetailRow('Reported Item', report['reportedItem']),
            _buildDetailRow('Priority', report['priority']),
            _buildDetailRow('Status', report['status']),
            const SizedBox(height: 12),
            const Text(
              'Description:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report['description'],
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
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
