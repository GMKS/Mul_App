import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BusinessApprovalScreenEnhanced extends StatefulWidget {
  const BusinessApprovalScreenEnhanced({super.key});

  @override
  State<BusinessApprovalScreenEnhanced> createState() =>
      _BusinessApprovalScreenEnhancedState();
}

class _BusinessApprovalScreenEnhancedState
    extends State<BusinessApprovalScreenEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _allBusinesses = [];
  List<Map<String, dynamic>> _displayedBusinesses = [];
  bool _isLoading = true;
  String _searchQuery = '';

  int get _totalCount => _allBusinesses.length;
  int get _approvedCount =>
      _allBusinesses.where((b) => b['status'] == 'approved').length;
  int get _pendingCount =>
      _allBusinesses.where((b) => b['status'] == 'pending').length;
  int get _rejectedCount =>
      _allBusinesses.where((b) => b['status'] == 'rejected').length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _applyFilter();
      }
    });
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    setState(() => _isLoading = true);

    try {
      final response = await _supabase
          .from('business_submissions')
          .select()
          .order('submitted_at', ascending: false);

      print('✅ Loaded ${response.length} businesses from Supabase');

      setState(() {
        _allBusinesses = List<Map<String, dynamic>>.from(response);
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading businesses: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading businesses: $e')),
        );
      }
    }
  }

  void _applyFilter() {
    List<Map<String, dynamic>> filtered;

    switch (_tabController.index) {
      case 0: // All
        filtered = _allBusinesses;
        break;
      case 1: // Approved
        filtered = _allBusinesses
            .where((b) => b['status'] == 'approved')
            .toList();
        break;
      case 2: // Pending
        filtered = _allBusinesses
            .where((b) => b['status'] == 'pending')
            .toList();
        break;
      case 3: // Rejected
        filtered = _allBusinesses
            .where((b) => b['status'] == 'rejected')
            .toList();
        break;
      default:
        filtered = _allBusinesses;
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((b) =>
              (b['name'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (b['description'] ?? '')
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _displayedBusinesses = filtered;
    });

    print(
        '📊 Tab ${_tabController.index}: Showing ${_displayedBusinesses.length} businesses');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Business Approvals',
          style: TextStyle(fontSize: 18),
        ),
        titleSpacing: 0,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBusinesses,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBusinessList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Business Approvals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.grid_view, _totalCount, 'Total', 0),
              _buildStatItem(Icons.check_circle, _approvedCount, 'Approved', 1),
              _buildStatItem(Icons.more_horiz, _pendingCount, 'Pending', 2),
              _buildStatItem(Icons.cancel, _rejectedCount, 'Rejected', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, int count, String label, int tabIndex) {
    final bool isSelected = _tabController.index == tabIndex;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(tabIndex);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2196F3) : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search businesses...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          _searchQuery = value;
          _applyFilter();
        },
      ),
    );
  }

  Widget _buildBusinessList() {
    if (_displayedBusinesses.isEmpty) {
      String statusText = '';
      switch (_tabController.index) {
        case 0:
          statusText = '';
          break;
        case 1:
          statusText = 'approved';
          break;
        case 2:
          statusText = 'pending';
          break;
        case 3:
          statusText = 'rejected';
          break;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              statusText.isEmpty
                  ? 'No Businesses'
                  : 'No ${statusText.substring(0, 1).toUpperCase()}${statusText.substring(1)} Businesses',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              statusText.isEmpty
                  ? 'No businesses have been submitted yet'
                  : 'No businesses have been $statusText yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBusinesses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _displayedBusinesses.length,
        itemBuilder: (context, index) {
          return _buildBusinessCard(_displayedBusinesses[index]);
        },
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> business) {
    final status = business['status'] ?? 'pending';
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return GestureDetector(
      onTap: () => _showBusinessDetailDialog(business),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (business['image_url'] != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  business['image_url'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.business, size: 60, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(
                  child: Icon(Icons.business, size: 60, color: Colors.grey),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business['name'] ?? 'Unnamed Business',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              status.toString().toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Category
                  if (business['category'] != null)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        business['category'],
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    business['description'] ?? 'No description',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Address
                  if (business['address'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.grey[500], size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business['address'],
                            style:
                                TextStyle(color: Colors.grey[500], fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Tap to view hint
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Tap to view details',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
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

  void _showBusinessDetailDialog(Map<String, dynamic> business) {
    final status = business['status'] ?? 'pending';
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (business['image_url'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            business['image_url'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.business, size: 80, color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.business, size: 80, color: Colors.grey),
                        ),

                      const SizedBox(height: 20),

                      // Title and Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              business['name'] ?? 'Unnamed Business',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, color: statusColor, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  status.toString().toUpperCase(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Category
                      if (business['category'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            business['category'],
                            style: const TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        business['description'] ?? 'No description provided',
                        style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
                      ),

                      const SizedBox(height: 20),

                      // Contact Details
                      _buildDetailRow(Icons.location_on, 'Address', business['address']),
                      _buildDetailRow(Icons.location_city, 'City', business['city']),
                      _buildDetailRow(Icons.map, 'State', business['state']),
                      _buildDetailRow(Icons.phone, 'Phone', business['phone_number']),
                      _buildDetailRow(Icons.email, 'Email', business['email']),
                      _buildDetailRow(Icons.message, 'WhatsApp', business['whatsapp_number']),
                      _buildDetailRow(Icons.language, 'Website', business['website_url']),
                      _buildDetailRow(Icons.calendar_today, 'Submitted', _formatDate(business['submitted_at'])),

                      const SizedBox(height: 30),

                      // Action Buttons for Pending
                      if (status == 'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _updateStatus(business['id'], 'approved');
                                },
                                icon: const Icon(Icons.check, size: 20),
                                label: const Text('Approve', style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showRejectWithReasonDialog(business['id'], business['name'] ?? 'Business');
                                },
                                icon: const Icon(Icons.close, size: 20),
                                label: const Text('Reject', style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (status == 'approved') ...[
                        // Actions for Approved businesses
                        const Text(
                          'Change Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showRejectWithReasonDialog(business['id'], business['name'] ?? 'Business');
                                },
                                icon: const Icon(Icons.cancel, size: 20),
                                label: const Text('Reject', style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showDeleteWithReasonDialog(business['id'], business['name'] ?? 'Business');
                                },
                                icon: const Icon(Icons.delete, size: 20),
                                label: const Text('Delete', style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else if (status == 'rejected') ...[
                        // Show rejection reason if available
                        if (business['rejection_reason'] != null && business['rejection_reason'].toString().isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rejection Reason:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  business['rejection_reason'],
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Actions for Rejected businesses
                        const Text(
                          'Change Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showApproveWithNoteDialog(business['id'], business['name'] ?? 'Business');
                                },
                                icon: const Icon(Icons.check_circle, size: 20),
                                label: const Text('Approve', style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showDeleteWithReasonDialog(business['id'], business['name'] ?? 'Business');
                                },
                                icon: const Icon(Icons.delete, size: 20),
                                label: const Text('Delete', style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showRejectWithReasonDialog(String businessId, String businessName) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Business'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject "$businessName"?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for rejection *',
                hintText: 'Enter the reason for rejection...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a reason for rejection'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _updateStatusWithReason(businessId, 'rejected', reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteWithReasonDialog(String businessId, String businessName) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete "$businessName"?',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reason for deletion *',
                hintText: 'Enter the reason for deletion...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a reason for deletion'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _deleteBusiness(businessId, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showApproveWithNoteDialog(String businessId, String businessName) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Business'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approve "$businessName"?'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Add any notes about the approval...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
              Navigator.pop(context);
              _updateStatusWithReason(businessId, 'approved', noteController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatusWithReason(String id, String newStatus, String reason) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'reviewed_at': DateTime.now().toIso8601String(),
      };
      
      if (newStatus == 'rejected') {
        updateData['rejection_reason'] = reason;
      } else if (newStatus == 'approved') {
        // Clear rejection reason when approving
        updateData['rejection_reason'] = null;
      }

      await _supabase
          .from('business_submissions')
          .update(updateData)
          .eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Business ${newStatus == 'approved' ? 'approved' : 'rejected'} successfully'),
            backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
          ),
        );
      }

      _loadBusinesses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBusiness(String id, String reason) async {
    try {
      // Log the deletion reason before deleting
      print('Deleting business $id with reason: $reason');
      
      await _supabase
          .from('business_submissions')
          .delete()
          .eq('id', id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
      }

      _loadBusinesses();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await _supabase
          .from('business_submissions')
          .update({'status': newStatus}).eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Business ${newStatus == 'approved' ? 'approved' : 'rejected'} successfully'),
          backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );

      _loadBusinesses();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
