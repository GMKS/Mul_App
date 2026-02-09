// BUSINESS FEATURE 6: Call & WhatsApp Buttons
// Reusable contact buttons for business videos

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class BusinessContactButtons extends StatelessWidget {
  final String phoneNumber;
  final String whatsappNumber;
  final String businessName;
  final String? businessAddress;
  final double? latitude;
  final double? longitude;
  final String? city;
  final Function()? onCallPressed;
  final Function()? onWhatsappPressed;
  final Function()? onDirectionsPressed;
  final bool showLabels;
  final bool isCompact;
  final bool showDirections;

  const BusinessContactButtons({
    super.key,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.businessName,
    this.businessAddress,
    this.latitude,
    this.longitude,
    this.city,
    this.onCallPressed,
    this.onWhatsappPressed,
    this.onDirectionsPressed,
    this.showLabels = true,
    this.isCompact = false,
    this.showDirections = true,
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

  Future<void> _openDirections(BuildContext context) async {
    HapticFeedback.mediumImpact();
    onDirectionsPressed?.call();

    Uri uri;

    // Use geo: URI with coordinates + business name only as label
    if (latitude != null && longitude != null) {
      final label = Uri.encodeComponent(businessName);
      uri = Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude($label)',
      );
    } else if (businessAddress != null && businessAddress!.isNotEmpty) {
      final searchQuery = Uri.encodeComponent(
          '$businessName, $businessAddress${city != null ? ', $city' : ''}');
      uri = Uri.parse('geo:0,0?q=$searchQuery');
    } else {
      final searchQuery =
          Uri.encodeComponent('$businessName${city != null ? ', $city' : ''}');
      uri = Uri.parse('geo:0,0?q=$searchQuery');
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError(context, 'Could not open maps. Please install Google Maps.');
      }
    } catch (e) {
      _showError(context, 'Error opening maps: $e');
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
          if (showDirections) ...[
            _buildCompactButton(
              context,
              icon: Icons.directions,
              color: Colors.orange,
              onTap: () => _openDirections(context),
            ),
            const SizedBox(width: 8),
          ],
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
        if (showDirections)
          Expanded(
            child: _buildButton(
              context,
              icon: Icons.directions,
              label: 'Directions',
              color: Colors.orange,
              onTap: () => _openDirections(context),
            ),
          ),
        if (showDirections) const SizedBox(width: 12),
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
  final String? businessAddress;
  final double? latitude;
  final double? longitude;
  final String? city;
  final Function()? onCallPressed;
  final Function()? onWhatsappPressed;
  final Function()? onDirectionsPressed;
  final bool showDirections;

  const BusinessFloatingButtons({
    super.key,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.businessName,
    this.businessAddress,
    this.latitude,
    this.longitude,
    this.city,
    this.onCallPressed,
    this.onWhatsappPressed,
    this.onDirectionsPressed,
    this.showDirections = true,
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

  Future<void> _openDirections(BuildContext context) async {
    HapticFeedback.mediumImpact();
    onDirectionsPressed?.call();

    String mapsUrl;

    // Priority 1: Use GPS coordinates if available
    if (latitude != null && longitude != null) {
      final query = Uri.encodeComponent(businessName);
      mapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$query';
    }
    // Priority 2: Use business address if available
    else if (businessAddress != null && businessAddress!.isNotEmpty) {
      final query = Uri.encodeComponent(
          '$businessName, $businessAddress${city != null ? ', $city' : ''}');
      mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    }
    // Fallback: Search by business name
    else {
      final query =
          Uri.encodeComponent('$businessName${city != null ? ', $city' : ''}');
      mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    }

    final uri = Uri.parse(mapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        if (showDirections) ...[
          // Directions button
          _buildFloatingButton(
            context,
            icon: Icons.directions,
            label: 'Directions',
            color: Colors.orange,
            onTap: () => _openDirections(context),
          ),
          const SizedBox(height: 12),
        ],
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
