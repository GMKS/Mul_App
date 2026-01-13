// STEP 9: Social Interactions Widget
// Implement likes, comments, emoji reactions.
// Add voice comment option for videos.

import 'package:flutter/material.dart';

class SocialInteractions extends StatefulWidget {
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback? onVoiceComment;
  final Function(String)? onEmojiReaction;

  const SocialInteractions({
    super.key,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.onVoiceComment,
    this.onEmojiReaction,
  });

  @override
  State<SocialInteractions> createState() => _SocialInteractionsState();
}

class _SocialInteractionsState extends State<SocialInteractions>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showEmojiPicker = false;

  final List<String> _emojis = ['❤️', '😂', '😮', '😢', '😡', '👏', '🔥', '🙏'];

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    widget.onLike();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button
        _buildActionButton(
          icon: AnimatedBuilder(
            animation: _likeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _likeAnimation.value,
                child: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? Colors.red : Colors.white,
                  size: 32,
                ),
              );
            },
          ),
          label: _formatCount(widget.likes),
          onTap: _handleLike,
          onLongPress: () {
            setState(() => _showEmojiPicker = !_showEmojiPicker);
          },
        ),

        // Emoji reactions (shown on long press)
        if (_showEmojiPicker) _buildEmojiPicker(),

        const SizedBox(height: 16),

        // Comment button
        _buildActionButton(
          icon: const Icon(
            Icons.comment,
            color: Colors.white,
            size: 32,
          ),
          label: _formatCount(widget.comments),
          onTap: widget.onComment,
        ),

        const SizedBox(height: 16),

        // Voice comment button
        if (widget.onVoiceComment != null)
          _buildActionButton(
            icon: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 32,
            ),
            label: 'Voice',
            onTap: widget.onVoiceComment!,
          ),

        if (widget.onVoiceComment != null) const SizedBox(height: 16),

        // Share button
        _buildActionButton(
          icon: const Icon(
            Icons.share,
            color: Colors.white,
            size: 32,
          ),
          label: _formatCount(widget.shares),
          onTap: widget.onShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _emojis.map((emoji) {
          return GestureDetector(
            onTap: () {
              widget.onEmojiReaction?.call(emoji);
              setState(() => _showEmojiPicker = false);
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Comment input widget
class CommentInput extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback? onVoiceRecord;
  final bool isRecording;

  const CommentInput({
    super.key,
    required this.onSubmit,
    this.onVoiceRecord,
    this.isRecording = false,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Voice record button
          if (widget.onVoiceRecord != null)
            GestureDetector(
              onTap: widget.onVoiceRecord,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isRecording ? Colors.red : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isRecording ? Icons.stop : Icons.mic,
                  color:
                      widget.isRecording ? Colors.white : Colors.grey.shade700,
                  size: 20,
                ),
              ),
            ),
          const SizedBox(width: 8),

          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
                isDense: true,
              ),
              maxLines: null,
            ),
          ),

          // Send button
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onSubmit(_controller.text.trim());
                _controller.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
