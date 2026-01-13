import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String videoId;
  final int commentCount;
  final Function(String) onAddComment;

  const CommentsBottomSheet({
    super.key,
    required this.videoId,
    required this.commentCount,
    required this.onAddComment,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<CommentItem> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComments() {
    // Simulate loading comments
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _comments.addAll([
            CommentItem(
              id: '1',
              userName: 'User123',
              userAvatar: 'https://i.pravatar.cc/150?img=1',
              comment: 'Great video! Love the content 🔥',
              likes: 245,
              timeAgo: '2h ago',
              isLiked: false,
            ),
            CommentItem(
              id: '2',
              userName: 'RegionalFan',
              userAvatar: 'https://i.pravatar.cc/150?img=2',
              comment: 'This is amazing! Keep creating!',
              likes: 156,
              timeAgo: '4h ago',
              isLiked: true,
            ),
            CommentItem(
              id: '3',
              userName: 'Viewer99',
              userAvatar: 'https://i.pravatar.cc/150?img=3',
              comment: 'Very informative, thanks for sharing',
              likes: 89,
              timeAgo: '6h ago',
              isLiked: false,
            ),
            CommentItem(
              id: '4',
              userName: 'ContentLover',
              userAvatar: 'https://i.pravatar.cc/150?img=4',
              comment: 'Subscribed! More videos please 🙏',
              likes: 67,
              timeAgo: '8h ago',
              isLiked: false,
            ),
            CommentItem(
              id: '5',
              userName: 'LocalViewer',
              userAvatar: 'https://i.pravatar.cc/150?img=5',
              comment: 'Best content on the platform!',
              likes: 34,
              timeAgo: '12h ago',
              isLiked: false,
            ),
          ]);
          _isLoading = false;
        });
      }
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        CommentItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: 'You',
          userAvatar: 'https://i.pravatar.cc/150?img=10',
          comment: _commentController.text.trim(),
          likes: 0,
          timeAgo: 'Just now',
          isLiked: false,
        ),
      );
    });

    widget.onAddComment(_commentController.text.trim());
    _commentController.clear();
    HapticFeedback.lightImpact();
  }

  void _toggleLike(int index) {
    setState(() {
      final comment = _comments[index];
      _comments[index] = CommentItem(
        id: comment.id,
        userName: comment.userName,
        userAvatar: comment.userAvatar,
        comment: comment.comment,
        likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
        timeAgo: comment.timeAgo,
        isLiked: !comment.isLiked,
      );
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${_comments.length + widget.commentCount} Comments',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to comment!',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentItem(comment, index);
                        },
                      ),
          ),

          // Comment input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      NetworkImage('https://i.pravatar.cc/150?img=10'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentItem comment, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(comment.userAvatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.comment,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(index),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likes}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Reply to comment
                        _commentController.text = '@${comment.userName} ';
                        _commentController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: _commentController.text.length),
                        );
                      },
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentItem {
  final String id;
  final String userName;
  final String userAvatar;
  final String comment;
  final int likes;
  final String timeAgo;
  final bool isLiked;

  CommentItem({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.comment,
    required this.likes,
    required this.timeAgo,
    required this.isLiked,
  });
}
