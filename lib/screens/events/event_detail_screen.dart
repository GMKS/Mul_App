/// Event Detail Screen
/// Displays full event details with actions

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: _buildContent(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF16213e),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white),
          ),
          onPressed: () => _shareEvent(),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border, color: Colors.white),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event saved to bookmarks'),
                backgroundColor: Color(0xFFE91E63),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Event image
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF16213e),
                    child: Center(
                      child: Text(
                        event.categoryIcon,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                color: const Color(0xFF16213e),
                child: Center(
                  child: Text(
                    event.categoryIcon,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Status badge
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 16,
              child: Row(
                children: [
                  if (event.isLive)
                    _buildStatusBadge('🔴 LIVE NOW', Colors.red),
                  if (event.isToday && !event.isLive)
                    _buildStatusBadge('🔥 TODAY', Colors.orange),
                  if (event.isTomorrow)
                    _buildStatusBadge('📅 TOMORROW', Colors.blue),
                  if (event.isFeatured)
                    _buildStatusBadge('⭐ FEATURED', Colors.amber),
                ],
              ),
            ),

            // Category
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${event.categoryIcon} ${event.category}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Quick info cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Date',
                  value: event.formattedDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.access_time,
                  title: 'Time',
                  value: event.formattedTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Location card
          _buildInfoCard(
            icon: Icons.location_on,
            title: 'Location',
            value: event.locationName,
            isFullWidth: true,
            onTap: () => _openMaps(),
          ),

          // Ticket price
          if (event.ticketPrice != null) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.confirmation_number,
              title: 'Ticket Price',
              value: event.ticketPrice == 0
                  ? 'FREE Entry'
                  : '₹${event.ticketPrice!.toStringAsFixed(0)}',
              isFullWidth: true,
              valueColor: Colors.green,
            ),
          ],

          const SizedBox(height: 24),

          // Description section
          _buildSectionTitle('About Event'),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // Organizer section
          _buildSectionTitle('Organizer'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.organizerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.contactInfo != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.contactInfo!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (event.contactInfo != null)
                  IconButton(
                    onPressed: () => _contactOrganizer(),
                    icon: const Icon(
                      Icons.phone,
                      color: Color(0xFFE91E63),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Event Details section
          _buildSectionTitle('Event Details'),
          const SizedBox(height: 12),
          _buildDetailRow(
              'Category', '${event.categoryIcon} ${event.category}'),
          _buildDetailRow(
              'Start', '${event.formattedDate} at ${event.formattedTime}'),
          if (event.endDatetime != null)
            _buildDetailRow('End', _formatDateTime(event.endDatetime!)),
          _buildDetailRow('Status', event.statusTag),
          _buildDetailRow('Distance', event.distanceCategory ?? 'Unknown'),

          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool isFullWidth = false,
    VoidCallback? onTap,
    Color? valueColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFE91E63), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: isFullWidth ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Reminder button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder set for this event'),
                      backgroundColor: Color(0xFFE91E63),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Remind Me'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE91E63),
                  side: const BorderSide(color: Color(0xFFE91E63)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Book/Register button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (event.registrationUrl != null) {
                    _openRegistration();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration will open soon'),
                        backgroundColor: Color(0xFFE91E63),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.confirmation_number),
                label: Text(
                  event.ticketPrice == 0 ? 'Register Free' : 'Book Tickets',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.day} ${months[dateTime.month - 1]} at $hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  void _shareEvent() {
    Share.share(
      'Check out this event: ${event.title}\n'
      '📅 ${event.formattedDate}\n'
      '📍 ${event.locationName}\n'
      '${event.description.substring(0, event.description.length > 100 ? 100 : event.description.length)}...',
      subject: event.title,
    );
  }

  void _openMaps() async {
    if (event.latitude != null && event.longitude != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${event.latitude},${event.longitude}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  void _contactOrganizer() async {
    if (event.contactInfo != null) {
      final phone = event.contactInfo!.replaceAll(RegExp(r'[^0-9+]'), '');
      final url = 'tel:$phone';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  void _openRegistration() async {
    if (event.registrationUrl != null) {
      if (await canLaunchUrl(Uri.parse(event.registrationUrl!))) {
        await launchUrl(
          Uri.parse(event.registrationUrl!),
          mode: LaunchMode.externalApplication,
        );
      }
    }
  }
}
