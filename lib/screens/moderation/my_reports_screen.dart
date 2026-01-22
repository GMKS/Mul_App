/// My Reports Screen
/// Shows user's submitted reports with status tracking

import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../services/moderation_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<ContentReport> _reports = [];
  bool _isLoading = true;
  ReportStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Get current user ID
      final userId = 'current_user_id';
      final reports = await ModerationService.getUserReports(userId);

      // Apply filter
      final filteredReports = _filterStatus == null
          ? reports
          : reports.where((r) => r.status == _filterStatus).toList();

      setState(() {
        _reports = filteredReports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Color(0xFF16213e),
        title: Text('My Reports'),
        actions: [
          // Filter button
          PopupMenuButton<ReportStatus?>(
            icon: Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() => _filterStatus = status);
              _loadReports();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text('All Reports'),
              ),
              ...ReportStatus.values.map((status) {
                return PopupMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(_getStatusDisplayName(status)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(_reports[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            _filterStatus == null
                ? 'No reports yet'
                : 'No ${_getStatusDisplayName(_filterStatus!).toLowerCase()} reports',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your submitted reports will appear here',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ContentReport report) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Color(0xFF2a2a3e),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReportDetails(report),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: report.statusColor),
                    ),
                    child: Text(
                      report.statusDisplayName,
                      style: TextStyle(
                        color: report.statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          report.category.icon,
                          style: TextStyle(fontSize: 10),
                        ),
                        SizedBox(width: 4),
                        Text(
                          report.category.displayName,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  // Date
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Content title
              Text(
                report.contentTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),

              // Content type
              Text(
                _getContentTypeText(report.contentType),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),

              // Moderator feedback (if any)
              if (report.feedbackToReporter != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF3a3a4e),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF3b82f6).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.feedback,
                              size: 14, color: Color(0xFF3b82f6)),
                          SizedBox(width: 6),
                          Text(
                            'Moderator Feedback',
                            style: TextStyle(
                              color: Color(0xFF3b82f6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        report.feedbackToReporter!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(ContentReport report) {
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
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Title
                  Text(
                    'Report Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Status
                  _buildDetailRow(
                      'Status', report.statusDisplayName, report.statusColor),
                  SizedBox(height: 12),

                  // Category
                  _buildDetailRow('Category',
                      '${report.category.icon} ${report.category.displayName}'),
                  SizedBox(height: 12),

                  // Content
                  _buildDetailRow('Content', report.contentTitle),
                  SizedBox(height: 12),

                  // Reported Date
                  _buildDetailRow(
                      'Reported', _formatDateLong(report.createdAt)),
                  SizedBox(height: 12),

                  // Your Comment
                  if (report.additionalComment?.isNotEmpty ?? false) ...[
                    _buildDetailRow('Your Comment', report.additionalComment!),
                    SizedBox(height: 12),
                  ],

                  // Moderator Feedback
                  if (report.feedbackToReporter != null) ...[
                    Divider(color: Colors.white.withOpacity(0.1)),
                    SizedBox(height: 12),
                    Text(
                      'Moderator Response',
                      style: TextStyle(
                        color: Color(0xFF3b82f6),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      report.feedbackToReporter!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    if (report.reviewedAt != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'Reviewed ${_formatDateLong(report.reviewedAt!)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],

                  // Thank you message
                  if (report.status == ReportStatus.resolved) ...[
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF10b981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Color(0xFF10b981).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF10b981)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Thank you for helping keep our community safe! 🙏',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 15,
            fontWeight:
                valueColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateLong(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getContentTypeText(ReportedContentType type) {
    switch (type) {
      case ReportedContentType.devotionalVideo:
        return 'Devotional Video';
      case ReportedContentType.businessVideo:
        return 'Business Video';
      case ReportedContentType.regionalVideo:
        return 'Regional Video';
      case ReportedContentType.businessPost:
        return 'Business Post';
      case ReportedContentType.event:
        return 'Event';
      case ReportedContentType.comment:
        return 'Comment';
      case ReportedContentType.user:
        return 'User Profile';
    }
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Color(0xFFf59e0b); // Orange
      case ReportStatus.underReview:
        return Color(0xFF3b82f6); // Blue
      case ReportStatus.resolved:
        return Color(0xFF10b981); // Green
      case ReportStatus.dismissed:
        return Color(0xFF6b7280); // Gray
    }
  }

  String _getStatusDisplayName(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }
}
