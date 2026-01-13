// regional_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/regional_controller.dart';

class RegionalFeedScreen extends StatelessWidget {
  const RegionalFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegionalController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Regional Feed'),
          actions: [
            PopupMenuButton<DistanceFilter>(
              onSelected: (filter) {
                context.read<RegionalController>().applyFilter(filter);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: DistanceFilter.km0to100,
                  child: Text('0 - 100 km'),
                ),
                PopupMenuItem(
                  value: DistanceFilter.km100to200,
                  child: Text('100 - 200 km'),
                ),
                PopupMenuItem(
                  value: DistanceFilter.km200to500,
                  child: Text('200 - 500 km'),
                ),
              ],
            ),
          ],
        ),
        body: Consumer<RegionalController>(
          builder: (context, controller, _) {
            if (controller.filteredVideos.isEmpty) {
              return const Center(child: Text('No regional videos'));
            }

            return ListView.builder(
              itemCount: controller.filteredVideos.length,
              itemBuilder: (context, index) {
                final video = controller.filteredVideos[index];
                return ListTile(
                  leading: const Icon(Icons.play_circle),
                  title: Text(video.title),
                  subtitle: Text('${video.location} • ${video.distanceKm} km'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
