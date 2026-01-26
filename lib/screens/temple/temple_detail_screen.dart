/// Temple Detail Screen
/// Temple profile with location, deity info, schedule, and events

import 'package:flutter/material.dart';
import '../../models/temple_live_model.dart';
import '../../services/temple_live_service.dart';
import 'temple_stream_screen.dart';

class TempleDetailScreen extends StatefulWidget {
  final TempleLive temple;

  const TempleDetailScreen({super.key, required this.temple});

  @override
  State<TempleDetailScreen> createState() => _TempleDetailScreenState();
}

class _TempleDetailScreenState extends State<TempleDetailScreen> {
  final TempleLiveService _service = TempleLiveService();
  List<TempleEvent> _todaySchedule = [];
  List<TempleEvent> _upcomingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final schedule = await _service.getTodaySchedule(widget.temple.id);
    final events = await _service.getUpcomingEvents(widget.temple.id);

    if (mounted) {
      setState(() {
        _todaySchedule = schedule;
        _upcomingEvents = events;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribed = _service.isSubscribedToTemple(widget.temple.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Temple Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.temple.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.temple.thumbnailUrl != null
                      ? Image.network(
                          widget.temple.thumbnailUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFFFF6B00),
                          child: Center(
                            child: Text(
                              widget.temple.religionIcon,
                              style: const TextStyle(fontSize: 100),
                            ),
                          ),
                        ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Live Badge
                  if (widget.temple.isLive)
                    Positioned(
                      top: 100,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record,
                                color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('LIVE NOW',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isSubscribed
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                ),
                onPressed: _toggleSubscription,
                tooltip: isSubscribed ? 'Subscribed' : 'Subscribe',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share link copied! 📋')),
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickInfo(),
                      _buildWatchLiveButton(),
                      _buildDescription(),
                      _buildTodaySchedule(),
                      _buildUpcomingEvents(),
                      _buildLocationSection(),
                      _buildSubscriptionSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: widget.temple.isLive
          ? FloatingActionButton.extended(
              onPressed: () => _openStream(),
              backgroundColor: Colors.red,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Watch Live'),
            )
          : null,
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Religion & Deity Row
          Row(
            children: [
              Text(widget.temple.religionIcon,
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getReligionName(widget.temple.religion),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.temple.deity != null)
                      Text(
                        widget.temple.deity!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.temple.isLive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        widget.temple.formattedViewers,
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Grid
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildInfoChip(Icons.location_on,
                  '${widget.temple.city}, ${widget.temple.state ?? ''}'),
              if (widget.temple.timings != null)
                _buildInfoChip(Icons.access_time, widget.temple.timings!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchLiveButton() {
    if (!widget.temple.isLive) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.videocam_off, size: 40, color: Colors.grey[400]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Not Live Right Now',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Subscribe to get notified when this temple goes live',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _openStream,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Watch Live Stream',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Text(
              '${widget.temple.formattedViewers} watching',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.temple.description.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFFF6B00)),
              SizedBox(width: 8),
              Text(
                'About',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.temple.description,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: Color(0xFFFF6B00)),
              SizedBox(width: 8),
              Text(
                "Today's Schedule",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_todaySchedule.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Schedule not available',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ..._todaySchedule.map((event) => _buildScheduleItem(event)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(TempleEvent event) {
    final isPast = event.dateTime.isBefore(DateTime.now());
    final isNow =
        DateTime.now().difference(event.dateTime).inMinutes.abs() < 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNow
            ? const Color(0xFFFF6B00).withOpacity(0.1)
            : isPast
                ? Colors.grey[50]
                : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isNow
              ? const Color(0xFFFF6B00)
              : isPast
                  ? Colors.grey[200]!
                  : Colors.grey[300]!,
          width: isNow ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isNow
                        ? const Color(0xFFFF6B00)
                        : isPast
                            ? Colors.grey
                            : Colors.black87,
                  ),
                ),
                if (isNow)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NOW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Event Icon
          Text(event.typeIcon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),

          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isPast ? Colors.grey : Colors.black87,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (event.description != null)
                  Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    if (_upcomingEvents.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event, color: Color(0xFFFF6B00)),
              SizedBox(width: 8),
              Text(
                'Upcoming Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._upcomingEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(TempleEvent event) {
    final daysUntil = event.dateTime.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: event.isSpecial
            ? LinearGradient(
                colors: [
                  const Color(0xFFFF6B00).withOpacity(0.1),
                  const Color(0xFFFFD93D).withOpacity(0.1),
                ],
              )
            : null,
        color: event.isSpecial ? null : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: event.isSpecial
            ? Border.all(color: const Color(0xFFFF6B00).withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          // Date Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  event.isSpecial ? const Color(0xFFFF6B00) : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.dateTime.day.toString(),
                  style: TextStyle(
                    color: event.isSpecial ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _getMonthName(event.dateTime.month),
                  style: TextStyle(
                    color: event.isSpecial ? Colors.white70 : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(event.typeIcon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (event.isSpecial)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '⭐ Special',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                if (event.description != null)
                  Text(
                    event.description!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                const SizedBox(height: 4),
                Text(
                  daysUntil == 0
                      ? 'Today'
                      : daysUntil == 1
                          ? 'Tomorrow'
                          : 'In $daysUntil days',
                  style: TextStyle(
                    color: const Color(0xFFFF6B00),
                    fontWeight: FontWeight.w500,
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

  Widget _buildLocationSection() {
    if (widget.temple.latitude == null || widget.temple.longitude == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map, color: Color(0xFFFF6B00)),
              SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Map Placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 40, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.temple.city}, ${widget.temple.state ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening in Maps... 🗺️')),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    final isSubscribed = _service.isSubscribedToTemple(widget.temple.id);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications, color: Color(0xFFFF6B00)),
              SizedBox(width: 8),
              Text(
                'Get Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Subscribe to receive notifications for:',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAlertChip('🔴 Live Streams', true),
              _buildAlertChip('🪔 Daily Poojas', true),
              _buildAlertChip('🎉 Festivals', true),
              _buildAlertChip('⭐ Special Events', true),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleSubscription,
              icon: Icon(isSubscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none),
              label:
                  Text(isSubscribed ? 'Subscribed ✓' : 'Subscribe for Alerts'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSubscribed ? Colors.green : const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertChip(String label, bool enabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: enabled ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled ? Colors.green[300]! : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          if (enabled) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check, size: 14, color: Colors.green),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleSubscription() async {
    final isCurrentlySubscribed =
        _service.isSubscribedToTemple(widget.temple.id);

    if (isCurrentlySubscribed) {
      await _service.unsubscribeFromTemple(widget.temple.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsubscribed from alerts')),
        );
      }
    } else {
      await _service.subscribeToTemple(widget.temple.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 Subscribed! You\'ll get alerts for this temple'),
            backgroundColor: Color(0xFFFF6B00),
          ),
        );
      }
    }

    setState(() {});
  }

  void _openStream() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TempleStreamScreen(temple: widget.temple),
      ),
    );
  }

  String _getReligionName(String? religion) {
    switch (religion?.toLowerCase()) {
      case 'hinduism':
        return 'Hindu Temple';
      case 'islam':
        return 'Mosque';
      case 'christianity':
        return 'Church';
      case 'sikhism':
        return 'Gurudwara';
      case 'buddhism':
        return 'Buddhist Temple';
      case 'jainism':
        return 'Jain Temple';
      default:
        return 'Temple';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
