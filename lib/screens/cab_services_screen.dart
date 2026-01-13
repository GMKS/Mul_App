import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CabServicesScreen extends StatefulWidget {
  final String? userCity;

  const CabServicesScreen({super.key, this.userCity});

  @override
  State<CabServicesScreen> createState() => _CabServicesScreenState();
}

class _CabServicesScreenState extends State<CabServicesScreen> {
  String? _expandedService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cab Services'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4F8),
              Color(0xFFE8EEF4),
              Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with location
            if (widget.userCity != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFFF6B6B)),
                    const SizedBox(width: 12),
                    Text(
                      'Cab Services in ${widget.userCity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
              ),
            // Cab services list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCabServiceItem(
                    name: 'Ola',
                    icon: Icons.directions_car,
                    color: const Color(0xFF00C853),
                    rideTypes: ['Mini', 'Sedan', 'SUV', 'Auto'],
                    url:
                        'https://play.google.com/store/apps/details?id=com.olacabs.customer',
                    webUrl: 'https://www.olacabs.com/',
                  ),
                  _buildCabServiceItem(
                    name: 'Uber',
                    icon: Icons.local_taxi,
                    color: Colors.black,
                    rideTypes: ['UberGo', 'Premier', 'XL', 'Moto'],
                    url:
                        'https://play.google.com/store/apps/details?id=com.ubercab',
                    webUrl: 'https://www.uber.com/',
                  ),
                  _buildCabServiceItem(
                    name: 'Rapido',
                    icon: Icons.two_wheeler,
                    color: const Color(0xFFFFB300),
                    rideTypes: ['Bike', 'Auto', 'Cab Economy', 'Cab Premium'],
                    url:
                        'https://play.google.com/store/apps/details?id=com.rapido.passenger',
                    webUrl: 'https://www.rapido.bike/',
                  ),
                  _buildCabServiceItem(
                    name: 'BluSmart',
                    icon: Icons.electric_car,
                    color: const Color(0xFF2196F3),
                    rideTypes: ['Compact', 'Standard', 'Premium'],
                    url:
                        'https://play.google.com/store/apps/details?id=com.blusmart',
                    webUrl: 'https://www.blu-smart.com/',
                  ),
                  _buildCabServiceItem(
                    name: 'Namma Yatri',
                    icon: Icons.commute,
                    color: const Color(0xFFFF6B6B),
                    rideTypes: ['Auto Rickshaw', 'Bike Taxi'],
                    url:
                        'https://play.google.com/store/apps/details?id=in.juspay.nammayatri',
                    webUrl: 'https://nammayatri.in/',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabServiceItem({
    required String name,
    required IconData icon,
    required Color color,
    required List<String> rideTypes,
    required String url,
    required String webUrl,
  }) {
    final isExpanded = _expandedService == name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main clickable row
          InkWell(
            onTap: () {
              setState(() {
                _expandedService = isExpanded ? null : name;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  // Service name
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  // Arrow icon
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_right,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Available Ride Types',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rideTypes.map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _launchCabService(context, name, url, webUrl),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.open_in_new, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Open $name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _launchCabService(
    BuildContext context,
    String name,
    String appUrl,
    String webUrl,
  ) async {
    final Uri appUri = Uri.parse(appUrl);
    final Uri webUri = Uri.parse(webUrl);

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $name'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching $name: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
