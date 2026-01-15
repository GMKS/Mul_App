/// Religion Selection Screen
/// Clean card-based UI for selecting user's religion

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/devotional_video_model.dart';
import '../../services/religion_service.dart';

class ReligionSelectionScreen extends StatefulWidget {
  final bool isOnboarding;
  final VoidCallback? onComplete;

  const ReligionSelectionScreen({
    super.key,
    this.isOnboarding = false,
    this.onComplete,
  });

  @override
  State<ReligionSelectionScreen> createState() =>
      _ReligionSelectionScreenState();
}

class _ReligionSelectionScreenState extends State<ReligionSelectionScreen> {
  Religion? _selectedReligion;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _religions = [
    {
      'religion': Religion.hinduism,
      'name': 'Hinduism',
      'icon': '🕉️',
      'color': const Color(0xFFFF6B00),
      'gradient': [const Color(0xFFFF8C00), const Color(0xFFFF6B00)],
      'description': 'Sanatan Dharma',
    },
    {
      'religion': Religion.islam,
      'name': 'Islam',
      'icon': '☪️',
      'color': const Color(0xFF00A86B),
      'gradient': [const Color(0xFF00C77B), const Color(0xFF00A86B)],
      'description': 'Peace through Submission',
    },
    {
      'religion': Religion.christianity,
      'name': 'Christianity',
      'icon': '✝️',
      'color': const Color(0xFF6C63FF),
      'gradient': [const Color(0xFF7C73FF), const Color(0xFF6C63FF)],
      'description': 'Faith in Christ',
    },
    {
      'religion': Religion.sikhism,
      'name': 'Sikhism',
      'icon': '☬',
      'color': const Color(0xFFF39C12),
      'gradient': [const Color(0xFFF5AB35), const Color(0xFFF39C12)],
      'description': 'Ik Onkar',
    },
    {
      'religion': Religion.buddhism,
      'name': 'Buddhism',
      'icon': '☸️',
      'color': const Color(0xFF9B59B6),
      'gradient': [const Color(0xFFAB69C6), const Color(0xFF9B59B6)],
      'description': 'Path to Enlightenment',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentReligion();
  }

  Future<void> _loadCurrentReligion() async {
    final religion = await ReligionService.getSelectedReligion();
    setState(() {
      _selectedReligion = religion;
      _isLoading = false;
    });
  }

  Future<void> _saveReligion() async {
    if (_selectedReligion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a religion'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await ReligionService.saveReligion(_selectedReligion!);

    if (widget.isOnboarding && widget.onComplete != null) {
      widget.onComplete!();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Religion saved: ${_selectedReligion!.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, _selectedReligion);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: widget.isOnboarding
          ? null
          : AppBar(
              title: const Text('Select Religion'),
              backgroundColor: const Color(0xFF16213e),
            ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (widget.isOnboarding) ...[
                          const SizedBox(height: 20),
                          const Icon(
                            Icons.self_improvement,
                            size: 64,
                            color: Color(0xFF6C63FF),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          widget.isOnboarding
                              ? 'Welcome to Devotional'
                              : 'Choose Your Religion',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isOnboarding
                              ? 'Select your religion to personalize your devotional experience'
                              : 'This helps us show you relevant content',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Religion Cards
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _religions.length,
                      itemBuilder: (context, index) {
                        final religionData = _religions[index];
                        final religion = religionData['religion'] as Religion;
                        final isSelected = _selectedReligion == religion;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildReligionCard(
                            religion: religion,
                            name: religionData['name'],
                            icon: religionData['icon'],
                            description: religionData['description'],
                            gradient: religionData['gradient'],
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedReligion = religion;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            _selectedReligion != null ? _saveReligion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          disabledBackgroundColor: Colors.grey.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          widget.isOnboarding ? 'Continue' : 'Save',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildReligionCard({
    required Religion religion,
    required String name,
    required String icon,
    required String description,
    required List<Color> gradient,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradient) : null,
          color: isSelected ? null : const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : gradient[0].withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Check icon
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: gradient[0],
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
