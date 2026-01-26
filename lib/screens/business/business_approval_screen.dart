import 'package:flutter/material.dart';
import '../../services/business_service.dart';

class BusinessApprovalScreen extends StatefulWidget {
  const BusinessApprovalScreen({super.key});

  @override
  State<BusinessApprovalScreen> createState() => _BusinessApprovalScreenState();
}

class _BusinessApprovalScreenState extends State<BusinessApprovalScreen> {
  final _businessService = BusinessService();
  List<Map<String, dynamic>> _submissions = [];
  Map<String, int> _statistics = {
    'total': 0,
    'approved': 0,
    'pending': 0,
    'rejected': 0,
  };
  bool _isLoading = true;
  String _filter = 'all';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Fetch statistics
      final stats = await _businessService.getAdminStatistics();

      // Fetch ALL data first
      final pending = await _businessService.getPendingBusinesses();
      final approved = await _businessService.getApprovedBusinesses();
      final rejected = await _businessService.getRejectedBusinesses();

      debugPrint('Pending: ${pending.length}');
      debugPrint('Approved: ${approved.length}');
      debugPrint('Rejected: ${rejected.length}');

      // Combine all submissions
      List<Map<String, dynamic>> allSubmissions = [];

      // Filter based on selection
      switch (_filter) {
        case 'pending':
          allSubmissions = pending;
          break;
        case 'approved':
          allSubmissions = approved;
          break;
        case 'rejected':
          allSubmissions = rejected;
          break;
        case 'all':
        default:
          allSubmissions = [...pending, ...approved, ...rejected];
          break;
      }

      // Sort submissions
      allSubmissions.sort((a, b) {
        try {
          final dateA = DateTime.parse(
              a['created_at'] ?? DateTime.now().toIso8601String());
          final dateB = DateTime.parse(
              b['created_at'] ?? DateTime.now().toIso8601String());
          return _sortBy == 'newest'
              ? dateB.compareTo(dateA)
              : dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      debugPrint('Total submissions after filter: ${allSubmissions.length}');

      if (mounted) {
        setState(() {
          _statistics = {
            'total': stats?['total'] ?? 0,
            'approved': stats?['approved'] ?? 0,
            'pending': stats?['pending'] ?? 0,
            'rejected': stats?['rejected'] ?? 0,
          };
          _submissions = allSubmissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _approveBusiness(String businessId, String businessName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Business'),
        content: Text('Are you sure you want to approve "$businessName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _businessService.approveBusiness(businessId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Business approved successfully!')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _rejectBusiness(String businessId, String businessName) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Business'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "$businessName"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _businessService.rejectBusiness(
            businessId, reasonController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Business rejected')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    reasonController.dispose();
  }

  void _showBusinessDetails(Map<String, dynamic> business) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                business['name'] ?? 'Unknown Business',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  (business['status'] ?? 'pending').toString().toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                backgroundColor:
                    _getStatusColor(business['status'] ?? 'pending'),
              ),
              const Divider(height: 32),
              _buildDetailItem(
                  Icons.category, 'Category', business['category'] ?? 'N/A'),
              _buildDetailItem(Icons.location_on, 'Location',
                  '${business['city'] ?? 'N/A'}, ${business['state'] ?? 'N/A'}'),
              _buildDetailItem(Icons.description, 'Description',
                  business['description'] ?? 'N/A'),
              _buildDetailItem(Icons.phone, 'Phone',
                  business['phone_number'] ?? business['phone'] ?? 'N/A'),
              _buildDetailItem(
                  Icons.email, 'Email', business['email'] ?? 'N/A'),
              _buildDetailItem(
                  Icons.location_city, 'Address', business['address'] ?? 'N/A'),
              if (business['whatsapp_number'] != null)
                _buildDetailItem(
                    Icons.chat, 'WhatsApp', business['whatsapp_number']),
              if (business['website_url'] != null)
                _buildDetailItem(
                    Icons.language, 'Website', business['website_url']),
              if (business['images'] != null &&
                  (business['images'] as List).isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Images:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (business['images'] as List).length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            business['images'][index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (business['status'] == 'pending') ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveBusiness(business['id'], business['name']);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectBusiness(business['id'], business['name']);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  // Dashboard Card
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.blueAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Admin Dashboard',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceEvenly,
                                children: [
                                  _buildStatCard(
                                      'Total',
                                      _statistics['total']!,
                                      Icons.business,
                                      Colors.blue,
                                      constraints.maxWidth),
                                  _buildStatCard(
                                      'Approved',
                                      _statistics['approved']!,
                                      Icons.check_circle,
                                      Colors.green,
                                      constraints.maxWidth),
                                  _buildStatCard(
                                      'Pending',
                                      _statistics['pending']!,
                                      Icons.schedule,
                                      Colors.orange,
                                      constraints.maxWidth),
                                  _buildStatCard(
                                      'Rejected',
                                      _statistics['rejected']!,
                                      Icons.cancel,
                                      Colors.red,
                                      constraints.maxWidth),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter Section
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('All', 'all'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Pending', 'pending'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Approved', 'approved'),
                                const SizedBox(width: 8),
                                _buildFilterChip('Rejected', 'rejected'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Sort',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildSortChip('Newest', 'newest'),
                              const SizedBox(width: 8),
                              _buildSortChip('Oldest', 'oldest'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Results Count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        '${_submissions.length} results',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),

                  // Submissions List
                  _submissions.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Businesses',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _filter == 'all'
                                      ? 'No business submissions yet'
                                      : 'No $_filter businesses',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final business = _submissions[index];
                                return _buildBusinessCard(business);
                              },
                              childCount: _submissions.length,
                            ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, int value, IconData icon, Color color, double maxWidth) {
    // Calculate width to fit 4 cards with spacing
    final cardWidth = (maxWidth - 24) / 4; // 24 = 3 gaps of 8px

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
        _loadData();
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _sortBy = value;
        });
        _loadData();
      },
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBusinessDetails(business),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (business['images'] != null &&
                (business['images'] as List).isNotEmpty)
              Image.network(
                business['images'][0],
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: Colors.grey[200],
                  child:
                      const Center(child: Icon(Icons.broken_image, size: 40)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business['name'] ?? 'Unknown',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business['category'] ?? 'N/A',
                    style: const TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${business['city'] ?? 'N/A'}, ${business['state'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    business['description'] ?? 'No description',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      (business['status'] ?? 'pending')
                          .toString()
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    backgroundColor:
                        _getStatusColor(business['status'] ?? 'pending'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            if (business['status'] == 'pending')
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _approveBusiness(business['id'], business['name']),
                        icon: const Icon(Icons.check_circle, size: 16),
                        label: const Text('Approve',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _rejectBusiness(business['id'], business['name']),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Reject',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
