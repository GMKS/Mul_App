import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareBottomSheet extends StatelessWidget {
  final String videoId;
  final String videoTitle;
  final String creatorName;
  final Function(String platform) onShare;

  const ShareBottomSheet({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.creatorName,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Share Video',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            videoTitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Share options grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildShareOption(
                context,
                'WhatsApp',
                Icons.chat,
                Colors.green,
                () => _handleShare(context, 'whatsapp'),
              ),
              _buildShareOption(
                context,
                'Instagram',
                Icons.camera_alt,
                Colors.pink,
                () => _handleShare(context, 'instagram'),
              ),
              _buildShareOption(
                context,
                'Facebook',
                Icons.facebook,
                Colors.blue,
                () => _handleShare(context, 'facebook'),
              ),
              _buildShareOption(
                context,
                'Twitter',
                Icons.alternate_email,
                Colors.lightBlue,
                () => _handleShare(context, 'twitter'),
              ),
              _buildShareOption(
                context,
                'Telegram',
                Icons.send,
                Colors.blue.shade700,
                () => _handleShare(context, 'telegram'),
              ),
              _buildShareOption(
                context,
                'Message',
                Icons.message,
                Colors.green.shade700,
                () => _handleShare(context, 'sms'),
              ),
              _buildShareOption(
                context,
                'Email',
                Icons.email,
                Colors.red,
                () => _handleShare(context, 'email'),
              ),
              _buildShareOption(
                context,
                'More',
                Icons.more_horiz,
                Colors.grey,
                () => _handleShare(context, 'more'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Copy link button
          InkWell(
            onTap: () => _copyLink(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Copy Link',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context, String platform) {
    HapticFeedback.lightImpact();
    onShare(platform);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared to $platform'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyLink(BuildContext context) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(
      ClipboardData(text: 'https://regionalshorts.app/video/$videoId'),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Link copied to clipboard'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
