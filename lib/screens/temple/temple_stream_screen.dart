/// Temple Stream Screen
/// Full-screen video/audio player for live temple streams

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/temple_live_model.dart';
import '../../services/temple_live_service.dart';
import 'temple_detail_screen.dart';

class TempleStreamScreen extends StatefulWidget {
  final TempleLive temple;

  const TempleStreamScreen({super.key, required this.temple});

  @override
  State<TempleStreamScreen> createState() => _TempleStreamScreenState();
}

class _TempleStreamScreenState extends State<TempleStreamScreen> {
  final TempleLiveService _service = TempleLiveService();
  bool _showControls = true;
  bool _isFullScreen = false;
  bool _isMuted = false;
  bool _isPlaying = true;
  bool _showChat = false;
  List<TempleEvent> _todaySchedule = [];

  // Mock chat messages
  final List<Map<String, dynamic>> _chatMessages = [
    {'user': 'Devotee123', 'message': '🙏 Jai Shri Ram'},
    {'user': 'SpiritualSoul', 'message': 'Beautiful darshan'},
    {'user': 'BhaktaRam', 'message': 'Om Namah Shivaya 🙏'},
    {'user': 'DevotedHeart', 'message': 'Thank you for this live stream'},
    {'user': 'PeacefulMind', 'message': '🕉️ Har Har Mahadev'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  Future<void> _loadSchedule() async {
    final schedule = await _service.getTodaySchedule(widget.temple.id);
    if (mounted) {
      setState(() => _todaySchedule = schedule);
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls) setState(() => _showControls = false);
      });
    }
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return _buildFullScreenPlayer();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Area
            Expanded(
              flex: _showChat ? 5 : 7,
              child: _buildVideoPlayer(),
            ),
            // Bottom Section
            Expanded(
              flex: _showChat ? 5 : 3,
              child: _showChat ? _buildChatSection() : _buildInfoSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video placeholder
          GestureDetector(
            onTap: _toggleControls,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.temple.religionIcon,
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.temple.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Live Stream',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Controls Overlay
          if (_showControls) ...[
            // Exit fullscreen button
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit,
                    color: Colors.white, size: 30),
                onPressed: _toggleFullScreen,
              ),
            ),
            // Play/Pause Center
            Center(
              child: IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 80,
                ),
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        // Video Placeholder (in real app, use video_player package)
        GestureDetector(
          onTap: _toggleControls,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              image: widget.temple.thumbnailUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.temple.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.temple.thumbnailUrl == null
                ? Center(
                    child: Text(
                      widget.temple.religionIcon,
                      style: const TextStyle(fontSize: 100),
                    ),
                  )
                : null,
          ),
        ),

        // Controls Overlay
        if (_showControls)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

        // Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.temple.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.temple.city} • ${widget.temple.formattedViewers} watching',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Live Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Text('LIVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Center Play/Pause
        if (_showControls)
          Center(
            child: IconButton(
              icon: Icon(
                _isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white,
                size: 70,
              ),
              onPressed: () => setState(() => _isPlaying = !_isPlaying),
            ),
          ),

        // Bottom Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _isMuted = !_isMuted),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showChat ? Icons.chat_bubble : Icons.chat_bubble_outline,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _showChat = !_showChat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      color: Colors.white,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab Bar
            const TabBar(
              labelColor: Color(0xFFFF6B00),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFFFF6B00),
              tabs: [
                Tab(text: "Today's Schedule"),
                Tab(text: 'Temple Info'),
              ],
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildScheduleTab(),
                  _buildTempleInfoTab(),
                ],
              ),
            ),
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    if (_todaySchedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text('No schedule available',
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todaySchedule.length,
      itemBuilder: (context, index) {
        final event = _todaySchedule[index];
        final isPast = event.dateTime.isBefore(DateTime.now());
        final isNow =
            DateTime.now().difference(event.dateTime).inMinutes.abs() < 30;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isNow
                ? const Color(0xFFFF6B00).withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: isNow
                ? Border.all(color: const Color(0xFFFF6B00), width: 2)
                : null,
          ),
          child: Row(
            children: [
              Text(event.typeIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey : Colors.black87,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (event.description != null)
                      Text(
                        event.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isNow ? const Color(0xFFFF6B00) : Colors.grey[700],
                    ),
                  ),
                  if (isNow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NOW',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTempleInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temple Header
          Row(
            children: [
              Text(widget.temple.religionIcon,
                  style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.temple.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (widget.temple.deity != null)
                      Text(
                        widget.temple.deity!,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location
          _buildInfoRow(Icons.location_on,
              '${widget.temple.city}, ${widget.temple.state ?? ''}'),
          const SizedBox(height: 8),

          // Timings
          if (widget.temple.timings != null)
            _buildInfoRow(Icons.access_time, widget.temple.timings!),
          const SizedBox(height: 8),

          // Description
          if (widget.temple.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              widget.temple.description,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ],

          // View Full Profile Button
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TempleDetailScreen(temple: widget.temple),
                ),
              );
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('View Full Temple Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B00),
              side: const BorderSide(color: Color(0xFFFF6B00)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildChatSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Chat Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 18),
                const SizedBox(width: 8),
                const Text('Live Chat',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _showChat = false),
                  child: const Text('Hide'),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final msg = _chatMessages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${msg['user']}: ',
                          style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: msg['message'],
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF6B00)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message sent! 🙏')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isSubscribed = _service.isSubscribedToTemple(widget.temple.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share link copied! 📋')),
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (isSubscribed) {
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
                        content: Text(
                            '🔔 Subscribed! You\'ll get alerts for this temple'),
                        backgroundColor: Color(0xFFFF6B00),
                      ),
                    );
                  }
                }
                setState(() {});
              },
              icon: Icon(isSubscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none),
              label: Text(isSubscribed ? 'Subscribed' : 'Subscribe for Alerts'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSubscribed ? Colors.grey : const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
