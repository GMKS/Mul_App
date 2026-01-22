/// Emergency Services Screen
/// Comprehensive emergency features including SOS, nearby facilities, alerts, and safety features

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';

class EmergencyServicesScreen extends StatefulWidget {
  const EmergencyServicesScreen({super.key});

  @override
  State<EmergencyServicesScreen> createState() =>
      _EmergencyServicesScreenState();
}

class _EmergencyServicesScreenState extends State<EmergencyServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Position? _currentPosition;
  bool _isLocationLoading = true;
  bool _isSharingLocation = false;
  Timer? _locationTimer;

  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Police',
      number: '100',
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyContact(
      name: 'Ambulance',
      number: '108',
      icon: Icons.local_hospital,
      color: Colors.red,
    ),
    EmergencyContact(
      name: 'Fire',
      number: '101',
      icon: Icons.local_fire_department,
      color: Colors.orange,
    ),
    EmergencyContact(
      name: 'Women Helpline',
      number: '1091',
      icon: Icons.shield,
      color: Colors.purple,
    ),
    EmergencyContact(
      name: 'Child Helpline',
      number: '1098',
      icon: Icons.child_care,
      color: Colors.pink,
    ),
    EmergencyContact(
      name: 'Senior Citizen',
      number: '14567',
      icon: Icons.elderly,
      color: Colors.teal,
    ),
    EmergencyContact(
      name: 'Disaster Mgmt',
      number: '108',
      icon: Icons.warning_amber,
      color: Colors.deepOrange,
    ),
    EmergencyContact(
      name: 'Railway Helpline',
      number: '139',
      icon: Icons.train,
      color: Colors.indigo,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() => _isLocationLoading = false);
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() => _isLocationLoading = false);
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocationLoading = false);
      }
    }
  }

  Future<void> _makeEmergencyCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to make call')),
        );
      }
    }
  }

  Future<void> _triggerSOSAlert() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            const Text('SOS Alert'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your SOS alert will be sent to:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('• Emergency contacts'),
            const Text('• Local authorities'),
            const Text('• Your current location'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Press "Confirm" to activate SOS',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activateSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm SOS'),
          ),
        ],
      ),
    );
  }

  void _activateSOS() {
    // Show SOS activated screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SOSActivatedDialog(
        position: _currentPosition,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _startLocationSharing() {
    setState(() => _isSharingLocation = true);

    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final position = await Geolocator.getCurrentPosition();
        setState(() => _currentPosition = position);
        // In real app, send location to server/contacts
      } catch (e) {
        // Handle error
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📍 Live location sharing started'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Stop',
          textColor: Colors.white,
          onPressed: _stopLocationSharing,
        ),
      ),
    );
  }

  void _stopLocationSharing() {
    _locationTimer?.cancel();
    setState(() => _isSharingLocation = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location sharing stopped'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Services'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.phone_in_talk), text: 'Quick Call'),
            Tab(icon: Icon(Icons.location_on), text: 'Nearby'),
            Tab(icon: Icon(Icons.notification_important), text: 'Alerts'),
            Tab(icon: Icon(Icons.health_and_safety), text: 'Safety'),
            Tab(icon: Icon(Icons.medical_information), text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuickCallTab(),
          _buildNearbyFacilitiesTab(),
          _buildAlertsTab(),
          _buildSafetyFeaturesTab(),
          _buildInfoTab(),
        ],
      ),
      floatingActionButton: _buildSOSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSOSButton() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _triggerSOSAlert,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sos, size: 32, color: Colors.white),
            Text('SOS',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCallTab() {
    return Column(
      children: [
        // Location Sharing Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.blue.shade100],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.share_location, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Live Location Sharing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isSharingLocation,
                    onChanged: (value) {
                      if (value) {
                        _startLocationSharing();
                      } else {
                        _stopLocationSharing();
                      }
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
              if (_currentPosition != null && _isSharingLocation) ...[
                const SizedBox(height: 8),
                Text(
                  'Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_currentPosition != null) {
                      Share.share(
                        'Emergency! I need help. My location: https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}',
                      );
                    }
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Emergency Contacts Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _emergencyContacts.length,
            itemBuilder: (context, index) {
              final contact = _emergencyContacts[index];
              return _EmergencyContactCard(
                contact: contact,
                onTap: () => _makeEmergencyCall(contact.number),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyFacilitiesTab() {
    final facilities = [
      {'name': 'Hospitals', 'icon': Icons.local_hospital, 'color': Colors.red},
      {
        'name': 'Police Stations',
        'icon': Icons.local_police,
        'color': Colors.blue
      },
      {
        'name': 'Fire Stations',
        'icon': Icons.local_fire_department,
        'color': Colors.orange
      },
      {
        'name': 'Pharmacies',
        'icon': Icons.local_pharmacy,
        'color': Colors.green
      },
      {
        'name': 'Blood Banks',
        'icon': Icons.bloodtype,
        'color': Colors.red.shade800
      },
      {'name': 'Shelters', 'icon': Icons.home, 'color': Colors.teal},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Map Preview Card
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to view facilities on map',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: FloatingActionButton.small(
                  onPressed: () async {
                    if (_currentPosition != null) {
                      final url =
                          'https://www.google.com/maps/search/hospital+police+fire/@${_currentPosition!.latitude},${_currentPosition!.longitude},15z';
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.open_in_new),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Find Nearby Facilities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...facilities.map((facility) => _FacilityCard(
              name: facility['name'] as String,
              icon: facility['icon'] as IconData,
              color: facility['color'] as Color,
              onTap: () async {
                if (_currentPosition != null) {
                  final searchQuery = facility['name'] as String;
                  final url =
                      'https://www.google.com/maps/search/$searchQuery/@${_currentPosition!.latitude},${_currentPosition!.longitude},14z';
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Getting your location...')),
                  );
                }
              },
            )),
      ],
    );
  }

  Widget _buildAlertsTab() {
    final alerts = [
      {
        'title': 'Heavy Rainfall Alert',
        'description':
            'IMD issues orange alert for Hyderabad. Expect heavy rainfall in next 24 hours.',
        'time': '2 hours ago',
        'type': 'weather',
        'severity': 'high',
      },
      {
        'title': 'Traffic Update',
        'description':
            'Heavy traffic reported on Hitech City Road due to waterlogging.',
        'time': '30 minutes ago',
        'type': 'traffic',
        'severity': 'medium',
      },
      {
        'title': 'Safety Advisory',
        'description':
            'Police advisory: Avoid isolated areas during night hours.',
        'time': '1 day ago',
        'type': 'safety',
        'severity': 'medium',
      },
      {
        'title': 'Health Alert',
        'description': 'Dengue cases rising. Take preventive measures.',
        'time': '2 days ago',
        'type': 'health',
        'severity': 'low',
      },
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            border: Border(bottom: BorderSide(color: Colors.orange.shade200)),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community Alerts',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Stay informed about local incidents',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _showReportIncidentDialog();
                },
                icon: const Icon(Icons.add_alert),
                color: Colors.orange.shade700,
                tooltip: 'Report Incident',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(
                title: alert['title'] as String,
                description: alert['description'] as String,
                time: alert['time'] as String,
                type: alert['type'] as String,
                severity: alert['severity'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyFeaturesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SafetyFeatureCard(
          title: 'Trusted Contacts',
          subtitle: 'Add people who will be notified in emergency',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => _showTrustedContactsSheet(),
        ),
        const SizedBox(height: 12),
        _SafetyFeatureCard(
          title: 'Safe Routes',
          subtitle: 'Find well-lit and safer routes to your destination',
          icon: Icons.route,
          color: Colors.green,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Safe routes feature coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _SafetyFeatureCard(
          title: 'Virtual Escort',
          subtitle: 'Someone virtually walks with you',
          icon: Icons.directions_walk,
          color: Colors.purple,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Virtual escort feature coming soon')),
            );
          },
        ),
        const SizedBox(height: 12),
        _SafetyFeatureCard(
          title: 'Safety Check-in',
          subtitle: 'Automatic check-in at intervals',
          icon: Icons.check_circle,
          color: Colors.orange,
          onTap: () => _showSafetyCheckInDialog(),
        ),
        const SizedBox(height: 12),
        _SafetyFeatureCard(
          title: 'Fake Call',
          subtitle: 'Simulate a call to exit uncomfortable situations',
          icon: Icons.phone_callback,
          color: Colors.teal,
          onTap: () => _triggerFakeCall(),
        ),
        const SizedBox(height: 12),
        _SafetyFeatureCard(
          title: 'Panic Alarm',
          subtitle: 'Loud alarm to attract attention',
          icon: Icons.volume_up,
          color: Colors.red,
          onTap: () => _showPanicAlarmDialog(),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Quick Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Auto-share location in emergency'),
          subtitle:
              const Text('Automatically share location with trusted contacts'),
          value: true,
          onChanged: (value) {},
          secondary: const Icon(Icons.location_on),
        ),
        SwitchListTile(
          title: const Text('Silent SOS'),
          subtitle: const Text('Send SOS without sound or notification'),
          value: false,
          onChanged: (value) {},
          secondary: const Icon(Icons.volume_off),
        ),
        SwitchListTile(
          title: const Text('Shake to activate SOS'),
          subtitle: const Text('Shake phone vigorously to trigger SOS'),
          value: true,
          onChanged: (value) {},
          secondary: const Icon(Icons.vibration),
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoSection(
          title: 'First Aid Guides',
          icon: Icons.medical_services,
          color: Colors.red,
          items: [
            'CPR Instructions',
            'Choking Emergency',
            'Bleeding Control',
            'Burns Treatment',
            'Fracture Management',
            'Heart Attack Response',
          ],
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: 'Safety Tips',
          icon: Icons.security,
          color: Colors.blue,
          items: [
            'Personal Safety',
            'Home Security',
            'Travel Safety',
            'Cyber Safety',
            'Child Safety',
            'Women Safety',
          ],
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: 'Disaster Preparedness',
          icon: Icons.warning,
          color: Colors.orange,
          items: [
            'Earthquake Preparedness',
            'Flood Safety',
            'Fire Safety',
            'Cyclone Safety',
            'Emergency Kit Checklist',
            'Evacuation Planning',
          ],
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Medical Information',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(
                    label: 'Blood Group', value: 'A+', icon: Icons.bloodtype),
                const Divider(height: 24),
                _InfoRow(
                    label: 'Allergies', value: 'None', icon: Icons.healing),
                const Divider(height: 24),
                _InfoRow(
                    label: 'Medical Conditions',
                    value: 'None',
                    icon: Icons.medical_information),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Medical info update coming soon')),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Information'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showReportIncidentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ReportIncidentSheet(),
    );
  }

  void _showTrustedContactsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TrustedContactsSheet(),
    );
  }

  void _showSafetyCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safety Check-in'),
        content: const Text(
          'Set intervals for automatic safety check-ins. If you don\'t respond, your trusted contacts will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Safety check-in activated')),
              );
            },
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _triggerFakeCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fake Call'),
        content: const Text('Select who should "call" you:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateFakeCall('Mom');
            },
            child: const Text('Mom'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateFakeCall('Boss');
            },
            child: const Text('Boss'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateFakeCall('Friend');
            },
            child: const Text('Friend'),
          ),
        ],
      ),
    );
  }

  void _simulateFakeCall(String caller) {
    // In a real app, this would trigger a full-screen call UI
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📞 Incoming call from $caller...'),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPanicAlarmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.volume_up, color: Colors.red),
            SizedBox(width: 8),
            Text('Panic Alarm'),
          ],
        ),
        content: const Text(
          'This will trigger a loud alarm sound to attract attention. Use only in emergency situations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚨 ALARM ACTIVATED!'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Activate Alarm'),
          ),
        ],
      ),
    );
  }
}

// Supporting Classes and Widgets

class EmergencyContact {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}

class _EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback onTap;

  const _EmergencyContactCard({
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                contact.color.withOpacity(0.1),
                contact.color.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(contact.icon, size: 28, color: contact.color),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                contact.number,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: contact.color,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: contact.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'CALL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FacilityCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Find nearby on map'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final String type;
  final String severity;

  const _AlertCard({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.severity,
  });

  Color _getSeverityColor() {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case 'weather':
        return Icons.cloud;
      case 'traffic':
        return Icons.traffic;
      case 'safety':
        return Icons.security;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getTypeIcon(), size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SafetyFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items
            .map((item) => ListTile(
                  dense: true,
                  leading: Icon(Icons.article, size: 20, color: Colors.grey),
                  title: Text(item),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening $item...')),
                    );
                  },
                ))
            .toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SOSActivatedDialog extends StatefulWidget {
  final Position? position;
  final VoidCallback onCancel;

  const _SOSActivatedDialog({
    required this.position,
    required this.onCancel,
  });

  @override
  State<_SOSActivatedDialog> createState() => _SOSActivatedDialogState();
}

class _SOSActivatedDialogState extends State<_SOSActivatedDialog> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚨 SOS Alert Sent to Emergency Contacts!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red.shade50,
      title: Row(
        children: [
          Icon(Icons.sos, color: Colors.red.shade700, size: 32),
          const SizedBox(width: 12),
          const Text('SOS ACTIVATED'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_countdown',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sending alerts to:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('✓ Emergency contacts'),
          const Text('✓ Local authorities'),
          const Text('✓ Current location'),
          if (widget.position != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${widget.position!.latitude.toStringAsFixed(4)}, ${widget.position!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            widget.onCancel();
          },
          child: const Text('CANCEL SOS'),
        ),
      ],
    );
  }
}

class _ReportIncidentSheet extends StatefulWidget {
  const _ReportIncidentSheet();

  @override
  State<_ReportIncidentSheet> createState() => _ReportIncidentSheetState();
}

class _ReportIncidentSheetState extends State<_ReportIncidentSheet> {
  String _selectedType = 'Accident';
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.report, color: Colors.red),
                const SizedBox(width: 12),
                const Text(
                  'Report Incident',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Incident Type',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'Accident',
                'Crime',
                'Fire',
                'Medical',
                'Suspicious Activity',
                'Other'
              ]
                  .map((type) => ChoiceChip(
                        label: Text(type),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedType = type);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the incident...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Report anonymously'),
              value: false,
              onChanged: (value) {},
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incident reported. Authorities notified.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustedContactsSheet extends StatelessWidget {
  const _TrustedContactsSheet();

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {'name': 'Mom', 'phone': '+91 98765 43210', 'relation': 'Mother'},
      {'name': 'Dad', 'phone': '+91 98765 43211', 'relation': 'Father'},
      {'name': 'Spouse', 'phone': '+91 98765 43212', 'relation': 'Partner'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: Colors.blue),
              const SizedBox(width: 12),
              const Text(
                'Trusted Contacts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...contacts.map((contact) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      contact['name']![0],
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                  title: Text(contact['name']!),
                  subtitle:
                      Text('${contact['relation']} • ${contact['phone']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {},
                  ),
                ),
              )),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Add contact feature coming soon')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Trusted Contact'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
