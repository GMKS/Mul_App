// STEP 12: Boost Video Dialog
// Video boost UI for monetization

import 'package:flutter/material.dart';
import '../models/monetization_model.dart';
import '../services/monetization_service.dart';

class BoostVideoDialog extends StatefulWidget {
  final String videoId;
  final String creatorId;

  const BoostVideoDialog({
    super.key,
    required this.videoId,
    required this.creatorId,
  });

  @override
  State<BoostVideoDialog> createState() => _BoostVideoDialogState();
}

class _BoostVideoDialogState extends State<BoostVideoDialog> {
  BoostDuration _selectedDuration = BoostDuration.oneDay;
  List<String> _targetRegions = [];
  bool _isProcessing = false;

  final List<String> _availableRegions = [
    'North',
    'South',
    'East',
    'West',
    'Central',
    'Northeast',
  ];

  Future<void> _processBoost() async {
    setState(() => _isProcessing = true);

    try {
      final boost = await MonetizationService.createVideoBoost(
        videoId: widget.videoId,
        creatorId: widget.creatorId,
        duration: _selectedDuration,
        targetRegions: _targetRegions.isEmpty ? ['all'] : _targetRegions,
      );

      if (mounted) {
        Navigator.pop(context, boost);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Video boost activated! Your video will reach more viewers.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing boost: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = MonetizationService.getBoostOptions();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Boost Your Video',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reach more viewers and grow your audience',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Duration selection
            const Text(
              'Select Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((option) {
              final duration = option['duration'] as BoostDuration;
              final isSelected = _selectedDuration == duration;

              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = duration),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option['display'],
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        option['price'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.orange : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Target regions
            const Text(
              'Target Regions (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Leave empty to reach all regions',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableRegions.map((region) {
                final isSelected = _targetRegions.contains(region);
                return FilterChip(
                  label: Text(region),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _targetRegions.add(region);
                      } else {
                        _targetRegions.remove(region);
                      }
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                  checkmarkColor: Colors.orange,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Duration'),
                      Text(
                        MonetizationService.getBoostDurationDisplay(
                            _selectedDuration),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Regions'),
                      Text(
                        _targetRegions.isEmpty
                            ? 'All'
                            : _targetRegions.join(', '),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        MonetizationService.getBoostPriceDisplay(
                            _selectedDuration),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Boost button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processBoost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rocket_launch),
                          const SizedBox(width: 8),
                          Text(
                            'Boost Now - ${MonetizationService.getBoostPriceDisplay(_selectedDuration)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Boosted badge for videos
class BoostedBadge extends StatelessWidget {
  const BoostedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text(
            'Boosted',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
