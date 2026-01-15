/// Regional Video Card Widget
/// Individual video card with auto-play, interactions, and creator info

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/models.dart';
import 'video_controller_pool.dart';

class RegionalVideoCard extends StatefulWidget {
  final RegionalVideo video;
  final bool isVisible;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onCreatorTap;

  const RegionalVideoCard({
    super.key,
    required this.video,
    this.isVisible = false,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onCreatorTap,
  });

  @override
  State<RegionalVideoCard> createState() => _RegionalVideoCardState();
}

class _RegionalVideoCardState extends State<RegionalVideoCard>
    with SingleTickerProviderStateMixin {
  final VideoControllerPool _pool = VideoControllerPool();
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = true; // Start muted
  bool _showPlayIcon = false;
  bool _showHeartAnimation = false;
  bool _hasError = false;

  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _initializeVideo();
  }

  @override
  void didUpdateWidget(RegionalVideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle visibility changes
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _playVideo();
      } else {
        _pauseVideo();
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = await _pool.getController(
        widget.video.id,
        widget.video.videoUrl,
      );

      if (mounted && _controller != null) {
        // Start with muted audio
        _controller!.setVolume(0.0);

        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        if (widget.isVisible) {
          _playVideo();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _playVideo() {
    if (_controller?.value.isInitialized == true) {
      _controller?.play();
      setState(() => _isPlaying = true);
    }
  }

  void _pauseVideo() {
    _controller?.pause();
    setState(() => _isPlaying = false);
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
      _showPlayIcon = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showPlayIcon = false);
      }
    });
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _handleDoubleTap() {
    setState(() => _showHeartAnimation = true);
    _heartAnimationController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _showHeartAnimation = false);
      }
    });

    widget.onLike?.call();
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    // Don't dispose controller - managed by pool
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: _handleDoubleTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player or Thumbnail
            _buildVideoPlayer(),

            // Gradient overlay
            _buildGradientOverlay(),

            // Play/Pause indicator
            if (_showPlayIcon) _buildPlayPauseIndicator(),

            // Heart animation
            if (_showHeartAnimation) _buildHeartAnimation(),

            // Video info overlay
            _buildVideoInfo(),

            // Action buttons
            _buildActionButtons(),

            // Loading indicator
            if (!_isInitialized && !_hasError) _buildLoadingIndicator(),

            // Error indicator
            if (_hasError) _buildErrorIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return _buildThumbnail();
    }

    if (_isInitialized && _controller != null) {
      return Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      );
    }

    return _buildThumbnail();
  }

  Widget _buildThumbnail() {
    return Image.network(
      widget.video.thumbnailUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[900],
          child: const Center(
            child: Icon(
              Icons.video_library,
              size: 48,
              color: Colors.grey,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[900],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.transparent,
              const Color(0xFF1a1a2e).withOpacity(0.4),
              const Color(0xFF0f0f1e).withOpacity(0.85),
            ],
            stops: const [0.0, 0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayPauseIndicator() {
    return Center(
      child: AnimatedOpacity(
        opacity: _showPlayIcon ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPlaying ? Icons.play_arrow : Icons.pause,
            size: 50,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeartAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _heartAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _heartAnimation.value,
            child: Icon(
              Icons.favorite,
              size: 100,
              color: Colors.red.withOpacity(1 - _heartAnimation.value * 0.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Positioned(
      left: 16,
      right: 80,
      bottom: MediaQuery.of(context).padding.bottom + 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Creator info
          GestureDetector(
            onTap: widget.onCreatorTap,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.video.creatorAvatar),
                  backgroundColor: Colors.grey[800],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.video.creatorName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (widget.video.isVerifiedCreator) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        widget.video.city,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            widget.video.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            widget.video.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Hashtags
          if (widget.video.hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.video.hashtags.take(3).map((tag) {
                return Text(
                  tag.startsWith('#') ? tag : '#$tag',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      right: 12,
      bottom: MediaQuery.of(context).padding.bottom + 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mute/Unmute button
          _ActionButton(
            icon: _isMuted ? Icons.volume_off : Icons.volume_up,
            label: '',
            onTap: _toggleMute,
            color: _isMuted ? Colors.grey : Colors.white,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.favorite,
            label: _formatCount(widget.video.likes),
            onTap: widget.onLike,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.comment,
            label: _formatCount(widget.video.comments),
            onTap: widget.onComment,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.share,
            label: _formatCount(widget.video.shares),
            onTap: widget.onShare,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.visibility,
            label: _formatCount(widget.video.views),
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.white54,
          ),
          const SizedBox(height: 8),
          const Text(
            'Failed to load video',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _initializeVideo,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: color ?? Colors.white,
            ),
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
}
