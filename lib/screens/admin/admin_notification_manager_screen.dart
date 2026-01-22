/// Notification Management System
/// Send targeted push notifications with templates

import 'package:flutter/material.dart';

class AdminNotificationManagerScreen extends StatefulWidget {
  const AdminNotificationManagerScreen({super.key});

  @override
  State<AdminNotificationManagerScreen> createState() =>
      _AdminNotificationManagerScreenState();
}

class _AdminNotificationManagerScreenState
    extends State<AdminNotificationManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedAudience = 'all';
  String _selectedTemplate = 'custom';

  final List<Map<String, dynamic>> _notificationHistory = List.generate(
    10,
    (index) => {
      'title': 'Notification ${index + 1}',
      'message': 'This is notification message ${index + 1}',
      'audience': ['All Users', 'Business Users', 'Premium Users'][index % 3],
      'sentAt': DateTime.now().subtract(Duration(days: index)),
      'status': 'sent',
      'recipients': (index + 1) * 100,
      'openRate': '${65 + (index % 20)}%',
    },
  );

  final Map<String, Map<String, String>> _templates = {
    'welcome': {
      'title': 'Welcome to My City App!',
      'message': 'Thank you for joining us. Explore content near you!',
    },
    'business_approval': {
      'title': 'Your Business Approved!',
      'message': 'Congratulations! Your business listing is now live.',
    },
    'content_update': {
      'title': 'New Content Available',
      'message': 'Check out the latest devotional videos in your area.',
    },
    'offer': {
      'title': 'Special Offer Alert!',
      'message': 'Exclusive deals from businesses near you.',
    },
    'event': {
      'title': 'Upcoming Event',
      'message': 'Don\'t miss this exciting event in your community.',
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
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
        title: const Text('Notification Manager',
            style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF6366f1),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Send New'),
            Tab(text: 'Templates'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendNewTab(),
          _buildTemplatesTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildSendNewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Notification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildAudienceSelector(),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              label: 'Notification Title',
              hint: 'Enter title',
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _messageController,
              label: 'Message',
              hint: 'Enter message',
              maxLines: 5,
              maxLength: 200,
            ),
            const SizedBox(height: 20),
            _buildPreview(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendNotification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text('Send Notification', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Audience',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAudienceChip('all', 'All Users', '1,234'),
              _buildAudienceChip('business', 'Business Users', '456'),
              _buildAudienceChip('premium', 'Premium Users', '123'),
              _buildAudienceChip('regional', 'Regional Users', '789'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceChip(String value, String label, String count) {
    final isSelected = _selectedAudience == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedAudience = value;
        });
      },
      backgroundColor: const Color(0xFF2a2a3e),
      selectedColor: const Color(0xFF6366f1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1a1a2e),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_android, color: Colors.white54, size: 20),
              SizedBox(width: 8),
              Text(
                'Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2a2a3e),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.isEmpty
                      ? 'Notification Title'
                      : _titleController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _messageController.text.isEmpty
                      ? 'Your message will appear here'
                      : _messageController.text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _templates.entries.map((entry) {
        return _buildTemplateCard(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildTemplateCard(String key, Map<String, String> template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366f1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.article, color: Color(0xFF6366f1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  key.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, color: Colors.white54),
                onPressed: () => _useTemplate(template),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            template['title']!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            template['message']!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notificationHistory.length,
      itemBuilder: (context, index) {
        final item = _notificationHistory[index];
        return _buildHistoryCard(item);
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF10b981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['audience']} • ${item['recipients']} recipients',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['message'],
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
              _buildMetric('Sent', item['sentAt'].toString().split(' ')[0]),
              const SizedBox(width: 16),
              _buildMetric('Open Rate', item['openRate']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF10b981),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _useTemplate(Map<String, String> template) {
    setState(() {
      _titleController.text = template['title']!;
      _messageController.text = template['message']!;
      _tabController.animateTo(0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template applied'),
        backgroundColor: Color(0xFF10b981),
      ),
    );
  }

  void _sendNotification() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          title: const Text('Send Notification',
              style: TextStyle(color: Colors.white)),
          content: Text(
            'Send notification to $_selectedAudience users?',
            style: const TextStyle(color: Colors.white),
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
                    content: Text('Notification sent successfully!'),
                    backgroundColor: Color(0xFF10b981),
                  ),
                );
                _titleController.clear();
                _messageController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366f1),
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      );
    }
  }
}
