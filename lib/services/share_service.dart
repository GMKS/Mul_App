/// Share Service
/// Handles sharing verified content with preview

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  /// Share verified content with preview
  static Future<void> shareContent({
    required BuildContext context,
    required String title,
    required String description,
    String? source,
    String? url,
    bool isVerified = false,
  }) async {
    // Show share preview modal
    final shouldShare = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SharePreviewSheet(
        title: title,
        description: description,
        source: source,
        url: url,
        isVerified: isVerified,
      ),
    );

    if (shouldShare == true) {
      await _performShare(
        title: title,
        description: description,
        source: source,
        url: url,
      );
    }
  }

  /// Share directly without preview
  static Future<void> shareDirectly({
    required String title,
    required String description,
    String? source,
    String? url,
  }) async {
    await _performShare(
      title: title,
      description: description,
      source: source,
      url: url,
    );
  }

  /// Share to WhatsApp
  static Future<bool> shareToWhatsApp({
    required String text,
    String? phoneNumber,
  }) async {
    try {
      final encodedText = Uri.encodeComponent(text);
      final whatsappUrl = phoneNumber != null
          ? 'whatsapp://send?phone=$phoneNumber&text=$encodedText'
          : 'whatsapp://send?text=$encodedText';

      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      } else {
        // Fallback to web WhatsApp
        final webUrl = Uri.parse('https://wa.me/?text=$encodedText');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      print('❌ Error sharing to WhatsApp: $e');
      return false;
    }
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Perform the actual share
  static Future<void> _performShare({
    required String title,
    required String description,
    String? source,
    String? url,
  }) async {
    final shareText = _buildShareText(
      title: title,
      description: description,
      source: source,
      url: url,
    );

    await Share.share(shareText);
  }

  /// Build clean share text without tracking/referral junk
  static String _buildShareText({
    required String title,
    required String description,
    String? source,
    String? url,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('📢 $title');
    buffer.writeln();
    buffer.writeln(description);

    if (source != null && source.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('📰 Source: $source');
    }

    if (url != null && url.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🔗 $url');
    }

    buffer.writeln();
    buffer.writeln('— Shared via My City App');

    return buffer.toString();
  }
}

/// Share Preview Bottom Sheet
class _SharePreviewSheet extends StatelessWidget {
  final String title;
  final String description;
  final String? source;
  final String? url;
  final bool isVerified;

  const _SharePreviewSheet({
    required this.title,
    required this.description,
    this.source,
    this.url,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Share Preview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verified badge
                if (isVerified)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Verified Information',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Source
                if (source != null && source!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.source_outlined,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        'Source: $source',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Share options
          const Text(
            'Share via',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.send,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () async {
                  final text = ShareService._buildShareText(
                    title: title,
                    description: description,
                    source: source,
                    url: url,
                  );
                  await ShareService.shareToWhatsApp(text: text);
                  if (context.mounted) Navigator.pop(context, false);
                },
              ),
              _ShareOption(
                icon: Icons.copy,
                label: 'Copy',
                color: Colors.grey[700]!,
                onTap: () {
                  final text = ShareService._buildShareText(
                    title: title,
                    description: description,
                    source: source,
                    url: url,
                  );
                  ShareService.copyToClipboard(context, text);
                  Navigator.pop(context, false);
                },
              ),
              _ShareOption(
                icon: Icons.share,
                label: 'More',
                color: Colors.blue,
                onTap: () => Navigator.pop(context, true),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shareable Content Types
class ShareableContent {
  final String title;
  final String description;
  final String? source;
  final String? url;
  final bool isVerified;
  final ShareContentType type;

  ShareableContent({
    required this.title,
    required this.description,
    this.source,
    this.url,
    this.isVerified = false,
    required this.type,
  });
}

enum ShareContentType {
  news,
  healthTip,
  alert,
  event,
  business,
}
