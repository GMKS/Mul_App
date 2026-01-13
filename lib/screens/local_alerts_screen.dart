// Local Alerts Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/local_alerts_controller.dart';
import '../services/region_service.dart';

class LocalAlertsScreen extends StatefulWidget {
  const LocalAlertsScreen({super.key});

  @override
  State<LocalAlertsScreen> createState() => _LocalAlertsScreenState();
}

class _LocalAlertsScreenState extends State<LocalAlertsScreen> {
  String? _city;
  String? _state;

  @override
  void initState() {
    super.initState();
    _loadRegionAndAlerts();
  }

  Future<void> _loadRegionAndAlerts() async {
    final regionData = await RegionService.getStoredRegion();
    setState(() {
      _city = regionData['city'];
      _state = regionData['state'];
    });

    if (_city != null && _state != null) {
      context.read<LocalAlertsController>().loadAlerts(
            city: _city!,
            state: _state!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocalAlertsController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A90E2),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Local Alerts',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            PopupMenuButton<AlertDistanceFilter>(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onSelected: (filter) {
                context.read<LocalAlertsController>().applyFilter(filter);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: AlertDistanceFilter.all,
                  child: Text('All distances'),
                ),
                PopupMenuItem(
                  value: AlertDistanceFilter.km0to5,
                  child: Text('0 - 5 km'),
                ),
                PopupMenuItem(
                  value: AlertDistanceFilter.km5to10,
                  child: Text('5 - 10 km'),
                ),
                PopupMenuItem(
                  value: AlertDistanceFilter.km10to20,
                  child: Text('10 - 20 km'),
                ),
              ],
            ),
          ],
        ),
        body: Consumer<LocalAlertsController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${controller.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadRegionAndAlerts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (controller.filteredAlerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No active alerts',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for local updates',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (_city != null && _state != null) {
                  await controller.refresh(city: _city!, state: _state!);
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredAlerts.length,
                itemBuilder: (context, index) {
                  final alert = controller.filteredAlerts[index];
                  return _buildAlertCard(alert);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertCard(alert) {
    final categoryColors = {
      'offer': Colors.green,
      'announcement': Colors.blue,
      'update': Colors.orange,
      'event': Colors.purple,
    };

    final categoryIcons = {
      'offer': Icons.local_offer,
      'announcement': Icons.campaign,
      'update': Icons.info,
      'event': Icons.event,
    };

    final color = categoryColors[alert.category] ?? Colors.grey;
    final icon = categoryIcons[alert.category] ?? Icons.notifications;

    final timeAgo = _getTimeAgo(alert.startTime);
    final expiresIn =
        alert.expiryTime != null ? _getExpiresIn(alert.expiryTime!) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alert.message,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.red.shade400),
                const SizedBox(width: 4),
                Text(
                  '${alert.area} • ${alert.distanceKm.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            if (expiresIn != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 12, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Expires in $expiresIn',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _getExpiresIn(DateTime expiryTime) {
    final diff = expiryTime.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
