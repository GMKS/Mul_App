import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/devotional_controller.dart';
import '../models/devotional_video_model.dart';
import 'upload_devotional_video_screen.dart';
import '../../theme/app_theme.dart';

/// Example: Simple devotional feed with real-time updates
class SimpleDevotionalFeedScreen extends StatefulWidget {
  const SimpleDevotionalFeedScreen({super.key});

  @override
  State<SimpleDevotionalFeedScreen> createState() =>
      _SimpleDevotionalFeedScreenState();
}

class _SimpleDevotionalFeedScreenState
    extends State<SimpleDevotionalFeedScreen> {
  String? _selectedDeity;

  @override
  void initState() {
    super.initState();
    // Start real-time streaming when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DevotionalController>().startRealtimeStream();
    });
  }

  @override
  void dispose() {
    // Stop streaming when leaving screen
    context.read<DevotionalController>().stopRealtimeStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Devotional Videos'),
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (deity) {
              setState(() => _selectedDeity = deity);
              context.read<DevotionalController>().filterByDeity(deity);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Deities')),
              const PopupMenuItem(value: 'Lord Rama', child: Text('Lord Rama')),
              const PopupMenuItem(
                  value: 'Lord Hanuman', child: Text('Lord Hanuman')),
              const PopupMenuItem(
                  value: 'Lord Ganesha', child: Text('Lord Ganesha')),
              const PopupMenuItem(
                  value: 'Lord Shiva', child: Text('Lord Shiva')),
            ],
          ),
        ],
      ),
      body: Consumer<DevotionalController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${controller.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No videos yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to upload!',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.videos.length,
              itemBuilder: (context, index) {
                final video = controller.videos[index];
                return _buildVideoCard(video);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to upload screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UploadDevotionalVideoScreen(),
            ),
          );

          // Video was uploaded and verified - it automatically appears via real-time stream!
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Video will appear after verification'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Upload Video'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildVideoCard(DevotionalVideo video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.video_library, size: 64),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  video.title,
                  style: AppTextStyles.headline3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Deity & Temple
                Row(
                  children: [
                    Icon(Icons.temple_hindu,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${video.deity} • ${video.templeName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Language & Tags
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(video.language.toUpperCase()),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle:
                          const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                    ...video.festivalTags.take(2).map((tag) => Chip(
                          label: Text(tag.replaceAll('_', ' ')),
                          backgroundColor: Colors.orange.shade50,
                          labelStyle: const TextStyle(
                              fontSize: 12, color: Colors.orange),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
