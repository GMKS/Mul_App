// BUSINESS FEATURE 6: Call & WhatsApp Buttons
// Reusable contact buttons for business videos

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class BusinessContactButtons extends StatelessWidget {
  final String phoneNumber;
  final String whatsappNumber;
  final String businessName;
  final Function()? onCallPressed;
  final Function()? onWhatsappPressed;
  final bool showLabels;
  final bool isCompact;

  const BusinessContactButtons({
    super.key,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.businessName,
    this.onCallPressed,
    this.onWhatsappPressed,
    this.showLabels = true,
    this.isCompact = false,
  });

  Future<void> _makeCall(BuildContext context) async {
    HapticFeedback.mediumImpact();
    onCallPressed?.call();

    final Uri phoneUri = Uri(scheme: 'tel', path: '+91$phoneNumber');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showError(context, 'Could not launch phone dialer');
      }
    } catch (e) {
      _showError(context, 'Error making call: $e');
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    HapticFeedback.mediumImpact();
    onWhatsappPressed?.call();

    final message =
        'Hi! I saw your business on Regional Shorts. I\'m interested in your products/services.';
    final encodedMessage = Uri.encodeComponent(message);

    // Try WhatsApp first, then fall back to wa.me link
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/91$whatsappNumber?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showError(context, 'Could not open WhatsApp');
      }
    } catch (e) {
      _showError(context, 'Error opening WhatsApp: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactButton(
            context,
            icon: Icons.call,
            color: Colors.blue,
            onTap: () => _makeCall(context),
          ),
          const SizedBox(width: 8),
          _buildCompactButton(
            context,
            icon: Icons.chat,
            color: Colors.green,
            onTap: () => _openWhatsApp(context),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildButton(
            context,
            icon: Icons.call,
            label: 'Call',
            color: Colors.blue,
            onTap: () => _makeCall(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildButton(
            context,
            icon: Icons.chat,
            label: 'WhatsApp',
            color: Colors.green,
            onTap: () => _openWhatsApp(context),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (showLabels) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

/// Floating action buttons for business videos
class BusinessFloatingButtons extends StatelessWidget {
  final String phoneNumber;
  final String whatsappNumber;
  final String businessName;
  final Function()? onCallPressed;
  final Function()? onWhatsappPressed;

  const BusinessFloatingButtons({
    super.key,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.businessName,
    this.onCallPressed,
    this.onWhatsappPressed,
  });

  Future<void> _makeCall(BuildContext context) async {
    HapticFeedback.mediumImpact();
    onCallPressed?.call();

    final Uri phoneUri = Uri(scheme: 'tel', path: '+91$phoneNumber');

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    HapticFeedback.mediumImpact();
    onWhatsappPressed?.call();

    final message =
        'Hi! I saw your business "$businessName" on Regional Shorts.';
    final encodedMessage = Uri.encodeComponent(message);

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/91$whatsappNumber?text=$encodedMessage',
    );

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Call button
        _buildFloatingButton(
          context,
          icon: Icons.call,
          label: 'Call',
          color: Colors.blue,
          onTap: () => _makeCall(context),
        ),
        const SizedBox(height: 12),
        // WhatsApp button
        _buildFloatingButton(
          context,
          icon: Icons.chat,
          label: 'Chat',
          color: Colors.green,
          onTap: () => _openWhatsApp(context),
        ),
      ],
    );
  }

  Widget _buildFloatingButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
