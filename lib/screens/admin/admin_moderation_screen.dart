/// Automated Moderation Tools
/// AI-powered content scanning and flagging

import 'package:flutter/material.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  bool _autoModeration = true;
  bool _aiScanning = true;
  bool _duplicateDetection = true;

  final List<Map<String, dynamic>> _flaggedContent = List.generate(
    15,
    (index) => {
      'id': 'flagged_$index',
      'title': 'Flagged Content #${index + 1}',
      'reason': [
        'Inappropriate content',
        'Duplicate',
        'Spam',
        'Misinformation'
      ][index % 4],
      'confidence': 75 + (index % 25),
      'reportCount': index % 5 + 1,
      'status': 'pending',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Automated Moderation',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildModerationSettings(),
          Expanded(child: _buildFlaggedContentList()),
        ],
      ),
    );
  }

  Widget _buildModerationSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1a1a2e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moderation Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingSwitch(
            'Auto Moderation',
            'Automatically flag suspicious content',
            _autoModeration,
            (value) => setState(() => _autoModeration = value),
          ),
          _buildSettingSwitch(
            'AI Content Scanning',
            'Use AI to detect inappropriate content',
            _aiScanning,
            (value) => setState(() => _aiScanning = value),
          ),
          _buildSettingSwitch(
            'Duplicate Detection',
            'Identify and flag duplicate content',
            _duplicateDetection,
            (value) => setState(() => _duplicateDetection = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF10b981),
          ),
        ],
      ),
    );
  }

  Widget _buildFlaggedContentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _flaggedContent.length,
      itemBuilder: (context, index) {
        final item = _flaggedContent[index];
        return _buildFlaggedContentCard(item);
      },
    );
  }

  Widget _buildFlaggedContentCard(Map<String, dynamic> item) {
    final confidence = item['confidence'] as int;
    final confidenceColor = confidence > 85
        ? const Color(0xFFef4444)
        : confidence > 70
            ? const Color(0xFFf59e0b)
            : const Color(0xFF10b981);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: confidenceColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.flag, color: confidenceColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['reason'],
                      style: TextStyle(
                        color: confidenceColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$confidence% Confidence',
                      style: TextStyle(
                        color: confidenceColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['reportCount']} reports',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveContent(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10b981),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _removeContent(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFef4444),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _approveContent(Map<String, dynamic> item) {
    setState(() {
      _flaggedContent.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['title']} approved'),
        backgroundColor: const Color(0xFF10b981),
      ),
    );
  }

  void _removeContent(Map<String, dynamic> item) {
    setState(() {
      _flaggedContent.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['title']} removed'),
        backgroundColor: const Color(0xFFef4444),
      ),
    );
  }
}
