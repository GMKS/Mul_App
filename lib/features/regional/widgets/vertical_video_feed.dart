/// Vertical Video Feed Widget
/// TikTok-style vertical scrolling feed with auto-play and lazy loading

import 'package:flutter/material.dart';

import '../models/models.dart';
import 'regional_video_card.dart';
import 'video_controller_pool.dart';
import 'shimmer_widgets.dart';

class VerticalVideoFeed extends StatefulWidget {
  final List<RegionalVideo> videos;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final VoidCallback? onRefresh;
  final Function(RegionalVideo)? onLike;
  final Function(RegionalVideo)? onComment;
  final Function(RegionalVideo)? onShare;
  final Function(RegionalVideo)? onCreatorTap;
  final Widget? emptyWidget;
  final Widget? errorWidget;

  const VerticalVideoFeed({
    super.key,
    required this.videos,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onRefresh,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onCreatorTap,
    this.emptyWidget,
    this.errorWidget,
  });

  @override
  State<VerticalVideoFeed> createState() => _VerticalVideoFeedState();
}

class _VerticalVideoFeedState extends State<VerticalVideoFeed>
    with WidgetsBindingObserver {
  late PageController _pageController;
  final VideoControllerPool _pool = VideoControllerPool();
  int _currentIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause videos when app goes to background
    if (state == AppLifecycleState.paused) {
      _pool.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      // Resume current video when app comes back
      if (widget.videos.isNotEmpty && _currentIndex < widget.videos.length) {
        _pool.playVideo(widget.videos[_currentIndex].id);
      }
    }
  }

  void _onScroll() {
    if (!_pageController.hasClients) return;

    final page = _pageController.page ?? 0;
    final newIndex = page.round();

    // Check if we need to load more
    if (widget.hasMore &&
        !widget.isLoadingMore &&
        newIndex >= widget.videos.length - 3) {
      widget.onLoadMore?.call();
    }

    // Detect scroll start/end
    if (page % 1 != 0) {
      if (!_isScrolling) {
        setState(() => _isScrolling = true);
      }
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex == index) return;

    // Pause previous video
    if (_currentIndex < widget.videos.length) {
      _pool.pauseVideo(widget.videos[_currentIndex].id);
    }

    setState(() {
      _currentIndex = index;
      _isScrolling = false;
    });

    // Play current video
    if (index < widget.videos.length) {
      _pool.playVideo(widget.videos[index].id);

      // Update pool with current visibility
      _pool.updateVisibleIndex(
        index,
        widget.videos.map((v) => v.id).toList(),
        widget.videos.map((v) => v.videoUrl).toList(),
      );
    }
  }

  Future<void> _handleRefresh() async {
    widget.onRefresh?.call();
    // Wait for the refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // Show loading shimmer
    if (widget.isLoading && widget.videos.isEmpty) {
      return const FeedShimmerList();
    }

    // Show empty state
    if (!widget.isLoading && widget.videos.isEmpty) {
      return widget.emptyWidget ?? _buildDefaultEmpty();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.white,
      backgroundColor: Colors.grey[900],
      displacement: 80,
      child: Stack(
        children: [
          // Video PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.videos.length + (widget.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end
              if (index >= widget.videos.length) {
                return const Center(
                  child: LoadMoreIndicator(isLoading: true),
                );
              }

              final video = widget.videos[index];
              final isVisible = index == _currentIndex && !_isScrolling;

              return RegionalVideoCard(
                video: video,
                isVisible: isVisible,
                onLike: () => widget.onLike?.call(video),
                onComment: () => widget.onComment?.call(video),
                onShare: () => widget.onShare?.call(video),
                onCreatorTap: () => widget.onCreatorTap?.call(video),
              );
            },
          ),

          // Loading more indicator
          if (widget.isLoadingMore)
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: LoadMoreIndicator(isLoading: true),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No videos available',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
