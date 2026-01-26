/// Bhajan Room Screen
/// Live group listening experience with chat, reactions, and synchronized playback
/// Features: Real-time chat, emoji reactions, participant list, host controls

import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/bhajan_model.dart';
import '../../services/bhajan_service.dart';
import 'bhajan_player_screen.dart';

class BhajanRoomScreen extends StatefulWidget {
  final String roomId;

  const BhajanRoomScreen({super.key, required this.roomId});

  @override
  State<BhajanRoomScreen> createState() => _BhajanRoomScreenState();
}

class _BhajanRoomScreenState extends State<BhajanRoomScreen>
    with SingleTickerProviderStateMixin {
  final BhajanService _bhajanService = BhajanService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  late AnimationController _reactionAnimationController;

  BhajanRoom? _room;
  bool _isLoading = true;
  bool _isMuted = false;
  bool _showParticipants = false;
  double _currentPosition = 0.0;

  // Mock chat messages
  final List<Map<String, dynamic>> _messages = [
    {
      'user': 'Priya S.',
      'message': '🙏 Jai Shri Krishna!',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'avatar': 'https://i.pravatar.cc/100?img=1',
    },
    {
      'user': 'Rahul M.',
      'message': 'This bhajan is so peaceful',
      'time': DateTime.now().subtract(const Duration(minutes: 3)),
      'avatar': 'https://i.pravatar.cc/100?img=2',
    },
    {
      'user': 'Sunita D.',
      'message': 'Om Namah Shivaya 🙏',
      'time': DateTime.now().subtract(const Duration(minutes: 2)),
      'avatar': 'https://i.pravatar.cc/100?img=3',
    },
    {
      'user': 'Amit K.',
      'message': 'Can we play Hanuman Chalisa next? 🙌',
      'time': DateTime.now().subtract(const Duration(minutes: 1)),
      'avatar': 'https://i.pravatar.cc/100?img=4',
    },
  ];

  // Floating reactions
  final List<Map<String, dynamic>> _floatingReactions = [];

  @override
  void initState() {
    super.initState();
    _reactionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _loadRoom();
    _startPlaybackSimulation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    _reactionAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    final room = await _bhajanService.getRoomById(widget.roomId);
    if (mounted) {
      setState(() {
        _room = room;
        _isLoading = false;
      });
    }
  }

  void _startPlaybackSimulation() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _room?.currentBhajan != null) {
        setState(() {
          _currentPosition += 1;
          if (_currentPosition >= _room!.currentBhajan!.duration.inSeconds) {
            _currentPosition = 0;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                'Joining Bhajan Room...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Room Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('This room is no longer available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Now Playing
                _buildNowPlaying(),

                // Participants or Chat
                Expanded(
                  child: _showParticipants
                      ? _buildParticipantsList()
                      : _buildChat(),
                ),

                // Bottom Controls
                _buildBottomControls(),
              ],
            ),
          ),

          // Floating Reactions
          ..._buildFloatingReactions(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange[800]!,
            Colors.orange[600]!,
            Colors.orange[400]!,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _showLeaveDialog,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_room!.participantCount} listening',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _room!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showRoomOptions,
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying() {
    final bhajan = _room!.currentBhajan;
    if (bhajan == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  bhajan.coverImageUrl ?? 'https://picsum.photos/80/80',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.orange[200],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bhajan.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bhajan.uploaderName ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Open Full Player
              IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BhajanPlayerScreen(bhajan: bhajan),
                    ),
                  );
                },
                tooltip: 'Open Full Player',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _currentPosition / bhajan.duration.inSeconds,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(
                        Duration(seconds: _currentPosition.toInt())),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _formatDuration(bhajan.duration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Participants',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_room!.participantCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10, // Mock participants
              itemBuilder: (context, index) {
                final isHost = index == 0;
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/100?img=${index + 10}',
                        ),
                      ),
                      if (isHost)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    isHost
                        ? '${_room!.hostName} (Host)'
                        : 'Listener ${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isHost ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    isHost ? 'Managing this room' : 'Listening',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: isHost
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                          ),
                          onPressed: () {},
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Chat Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Live Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _showParticipants = true),
                  icon:
                      const Icon(Icons.people, size: 16, color: Colors.white70),
                  label: Text(
                    '${_room!.participantCount}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(msg['avatar']),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  msg['user'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timeAgo(msg['time']),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              msg['message'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          _buildControlButton(
            icon: _isMuted ? Icons.volume_off : Icons.volume_up,
            label: _isMuted ? 'Unmute' : 'Mute',
            onTap: () => setState(() => _isMuted = !_isMuted),
          ),
          // Reactions
          _buildControlButton(
            icon: Icons.favorite,
            label: 'React',
            color: Colors.red[300]!,
            onTap: () => _showReactions(),
          ),
          // Share
          _buildControlButton(
            icon: Icons.share,
            label: 'Share',
            onTap: _shareRoom,
          ),
          // Request Song
          _buildControlButton(
            icon: Icons.queue_music,
            label: 'Request',
            onTap: _requestSong,
          ),
          // Participants
          _buildControlButton(
            icon: Icons.people,
            label: 'People',
            onTap: () => setState(() => _showParticipants = !_showParticipants),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingReactions() {
    return _floatingReactions.map((reaction) {
      return Positioned(
        left: reaction['x'],
        bottom: reaction['y'],
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: reaction['opacity'],
          child: Text(
            reaction['emoji'],
            style: const TextStyle(fontSize: 32),
          ),
        ),
      );
    }).toList();
  }

  // ==================== ACTIONS ====================

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'user': 'You',
        'message': text,
        'time': DateTime.now(),
        'avatar': 'https://i.pravatar.cc/100?img=0',
      });
      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showReactions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.orange[800],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send Reaction',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: ['🙏', '❤️', '🪔', '🕉️', '✨', '🌸', '🎵', '👏']
                  .map((emoji) => GestureDetector(
                        onTap: () {
                          _addFloatingReaction(emoji);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _addFloatingReaction(String emoji) {
    final random = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _floatingReactions.add({
        'emoji': emoji,
        'x': 50.0 + (random % 200),
        'y': 100.0,
        'opacity': 1.0,
      });
    });

    // Animate and remove
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _floatingReactions.removeWhere((r) => r['emoji'] == emoji);
        });
      }
    });

    // Also send to chat
    _sendMessage(emoji);
  }

  void _shareRoom() {
    // Share.share would be called here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔗 Join my Bhajan Room: "${_room!.name}"\nCode: ${widget.roomId}',
        ),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {},
        ),
      ),
    );
  }

  void _requestSong() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Request a Bhajan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search bhajans...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular Requests',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/50/50',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    title: const Text('Hanuman Chalisa'),
                    subtitle: const Text('Devotional • 8:23'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Request sent to host!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Request'),
                    ),
                  ),
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://picsum.photos/51/51',
                        width: 50,
                        height: 50,
                      ),
                    ),
                    title: const Text('Gayatri Mantra'),
                    subtitle: const Text('Mantra • 5:10'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Request sent to host!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Request'),
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

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Room?'),
        content: const Text(
          'You will stop listening to this live bhajan session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showRoomOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Invite Friends'),
              onTap: () {
                Navigator.pop(context);
                _shareRoom();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Turn on Notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications enabled for this room'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Room'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title:
                  const Text('Leave Room', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLeaveDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
