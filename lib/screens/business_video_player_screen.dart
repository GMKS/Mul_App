// Business Video Player Screen
// Full-screen vertical video player with interactive features

import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../models/business_video_model.dart' as video_model;
import '../models/report_model.dart';
import '../widgets/report_button_widget.dart';
import 'business_profile_screen.dart';

class BusinessVideoPlayerScreen extends StatefulWidget {
  final video_model.BusinessVideo video;
  final BusinessModel business;

  const BusinessVideoPlayerScreen({
    super.key,
    required this.video,
    required this.business,
  });

  @override
  State<BusinessVideoPlayerScreen> createState() =>
      _BusinessVideoPlayerScreenState();
}

class _BusinessVideoPlayerScreenState extends State<BusinessVideoPlayerScreen> {
  bool _isLiked = false;
  bool _isMuted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player (Mock)
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() => _isMuted = !_isMuted);
              },
              child: Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to ${_isMuted ? 'unmute' : 'mute'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Video: ${widget.video.productName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Side Actions
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                // Like
                _buildActionButton(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${widget.video.views}',
                  color: _isLiked ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() => _isLiked = !_isLiked);
                  },
                ),
                const SizedBox(height: 24),

                // Comment
                _buildActionButton(
                  icon: Icons.comment,
                  label: '123',
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                // Share
                _buildActionButton(
                  icon: Icons.share,
                  label: '${widget.video.callClicks}',
                  onTap: () {},
                ),
                const SizedBox(height: 24),

                // Report Button - NEW MODERATION FEATURE
                ReportButton(
                  contentId: widget.video.id,
                  contentType: ReportedContentType.businessVideo,
                  contentTitle: widget.video.productName,
                  contentOwnerId: widget.business.ownerId,
                  contentOwnerName: widget.business.name,
                  contentDescription: widget.video.description,
                  contentThumbnail: widget.video.thumbnailUrl,
                  iconColor: Colors.white,
                  showLabel: false,
                ),
                const SizedBox(height: 24),

                // Business Profile
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BusinessProfileScreen(business: widget.business),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        widget.business.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Info
          Positioned(
            left: 16,
            right: 80,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Name
                Row(
                  children: [
                    Text(
                      widget.business.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.business.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                    if (widget.business.isFeatured) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Video Title
                Text(
                  widget.video.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Price
                Text(
                  widget.video.formattedPrice,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Hashtags
                if (widget.video.hashtags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: widget.video.hashtags.map((tag) {
                      return InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('View product: $tag')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_bag,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          // CTA Button
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BusinessProfileScreen(business: widget.business),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business),
                  const SizedBox(width: 8),
                  const Text(
                    'Visit Business',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.business.distanceFromUser != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '• ${widget.business.distanceFromUser!.toStringAsFixed(1)}km',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
