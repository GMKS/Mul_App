import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool autoPlay;
  final bool showControls;
  final Function()? onTap;
  final Function()? onDoubleTap;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.autoPlay = true,
    this.showControls = true,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showPlayIcon = false;
  bool _showHeartAnimation = false;
  bool _hasError = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  // Sample video URLs for demo (free stock videos)
  static const List<String> _sampleVideos = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  ];

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

  Future<void> _initializeVideo() async {
    // Use a sample video based on the hash of the provided URL
    final videoIndex = widget.videoUrl.hashCode.abs() % _sampleVideos.length;
    final actualVideoUrl = _sampleVideos[videoIndex];

    try {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(actualVideoUrl));

      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        _videoController!.setLooping(true);

        if (widget.autoPlay) {
          _videoController!.play();
          setState(() => _isPlaying = true);
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

  @override
  void dispose() {
    _videoController?.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isInitialized) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
      _showPlayIcon = true;
    });

    // Hide play/pause icon after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showPlayIcon = false);
      }
    });

    widget.onTap?.call();
  }

  void _handleDoubleTap() {
    setState(() => _showHeartAnimation = true);
    _heartAnimationController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _showHeartAnimation = false);
      }
    });

    widget.onDoubleTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player or Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isInitialized && _videoController != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : _hasError
                    ? _buildErrorWidget()
                    : _buildLoadingWidget(),
          ),

          // Play/Pause indicator
          if (_showPlayIcon)
            Center(
              child: AnimatedOpacity(
                opacity: _showPlayIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Heart animation on double tap
          if (_showHeartAnimation)
            Center(
              child: AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartAnimation.value,
                    child: Opacity(
                      opacity: 1.0 - (_heartAnimation.value * 0.5),
                      child: const Icon(
                        Icons.favorite,
                        size: 120,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Video progress indicator
          if (_isInitialized && widget.showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: VideoProgressIndicator(
                  _videoController!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Show thumbnail while loading
        Image.network(
          widget.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade900,
            );
          },
        ),
        // Loading overlay
        Container(
          color: Colors.black.withOpacity(0.3),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading video...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Show thumbnail on error
        Image.network(
          widget.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.grey.shade900);
          },
        ),
        // Error overlay with retry option
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Video unavailable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                    });
                    _initializeVideo();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
