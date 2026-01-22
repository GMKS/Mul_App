/// Scheduled Content Publishing
/// Calendar view for scheduling posts and expiry

import 'package:flutter/material.dart';

class AdminScheduledContentScreen extends StatefulWidget {
  const AdminScheduledContentScreen({super.key});

  @override
  State<AdminScheduledContentScreen> createState() =>
      _AdminScheduledContentScreenState();
}

class _AdminScheduledContentScreenState
    extends State<AdminScheduledContentScreen> {
  DateTime _selectedDay = DateTime.now();

  final Map<DateTime, List<Map<String, dynamic>>> _scheduledContent = {
    DateTime.now(): [
      {'title': 'Devotional Video', 'time': '09:00 AM', 'type': 'publish'},
      {'title': 'Business Offer', 'time': '02:00 PM', 'type': 'publish'},
    ],
    DateTime.now().add(const Duration(days: 1)): [
      {'title': 'Event Promotion', 'time': '10:00 AM', 'type': 'publish'},
    ],
    DateTime.now().add(const Duration(days: 3)): [
      {'title': 'Old Offer Expires', 'time': '11:59 PM', 'type': 'expire'},
    ],
  };

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
        title: const Text('Scheduled Content',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showScheduleDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(child: _buildScheduledList()),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scheduled Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedDay =
                            _selectedDay.subtract(const Duration(days: 1));
                      });
                    },
                  ),
                  Text(
                    '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedDay =
                            _selectedDay.add(const Duration(days: 1));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  Widget _buildScheduledList() {
    final dayKey = _scheduledContent.keys.firstWhere(
      (key) => _isSameDay(key, _selectedDay),
      orElse: () => DateTime(0),
    );
    final items =
        dayKey.year > 0 ? _scheduledContent[dayKey]! : <Map<String, dynamic>>[];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy,
                size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No scheduled content',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildScheduledCard(item);
      },
    );
  }

  Widget _buildScheduledCard(Map<String, dynamic> item) {
    final isExpiry = item['type'] == 'expire';
    final color = isExpiry ? const Color(0xFFef4444) : const Color(0xFF10b981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isExpiry ? Icons.schedule_send : Icons.publish,
              color: color,
              size: 24,
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
                    Icon(Icons.access_time, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      item['time'],
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
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isExpiry ? 'EXPIRY' : 'PUBLISH',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            color: const Color(0xFF2a2a3e),
            itemBuilder: (context) => [
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
            onSelected: (value) {
              if (value == 'delete') {
                // Remove item
              }
            },
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Schedule Content',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Content Title',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2a2a3e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Time (HH:MM AM/PM)',
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content scheduled'),
                  backgroundColor: Color(0xFF10b981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
            ),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}
