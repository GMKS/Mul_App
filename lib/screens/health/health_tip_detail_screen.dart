/// Health Tip Detail Screen
/// Full view of a health tip with content, verification, feedback, and sharing
/// Includes disclaimer and helpfulness rating

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/health_tips_model.dart';
import '../../services/health_tips_service.dart';

class HealthTipDetailScreen extends StatefulWidget {
  final HealthTip tip;

  const HealthTipDetailScreen({super.key, required this.tip});

  @override
  State<HealthTipDetailScreen> createState() => _HealthTipDetailScreenState();
}

class _HealthTipDetailScreenState extends State<HealthTipDetailScreen> {
  final HealthTipsService _service = HealthTipsService();
  bool? _userFeedback;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _userFeedback = _service.getFeedback(widget.tip.id);
    _isSaved = _service.isTipSaved(widget.tip.id);
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tip;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: tip.imageUrl != null ? 250 : 0,
            pinned: true,
            backgroundColor: Colors.green,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
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
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                  ),
                ),
                onPressed: _toggleSave,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: _shareTip,
              ),
            ],
            flexibleSpace: tip.imageUrl != null
                ? FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          tip.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.green[300],
                            child: const Icon(
                              Icons.health_and_safety,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disclaimer Banner
                  _buildDisclaimerBanner(),
                  const SizedBox(height: 16),

                  // Category & Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildCategoryChip(tip.category),
                      _buildVerificationBadge(tip),
                      if (tip.isAlert)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning,
                                  size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'HEALTH ALERT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (tip.isSponsored)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Sponsored',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Short Description
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip.shortDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Verification Info
                  _buildVerificationInfo(tip),
                  const SizedBox(height: 16),

                  // Stats Row
                  _buildStatsRow(tip),
                  const SizedBox(height: 24),

                  // Full Content
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMarkdownContent(tip.fullContent),
                  const SizedBox(height: 24),

                  // Tags
                  if (tip.tags.isNotEmpty) ...[
                    const Text(
                      'Related Topics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tip.tags
                          .map((tag) => Chip(
                                label: Text('#$tag',
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: Colors.grey[200],
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Feedback Section
                  _buildFeedbackSection(),
                  const SizedBox(height: 24),

                  // Final Disclaimer
                  _buildFinalDisclaimer(),
                  const SizedBox(height: 24),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareTip,
                      icon: const Icon(Icons.share),
                      label: const Text('Share with Family'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For Awareness Only',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This information is for general awareness. Please consult a healthcare professional for medical advice.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(HealthCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(HealthTip tip) {
    Color badgeColor;
    switch (tip.verificationSource) {
      case VerificationSource.doctorVerified:
        badgeColor = Colors.green;
        break;
      case VerificationSource.govtHealth:
        badgeColor = Colors.blue;
        break;
      case VerificationSource.whoApproved:
        badgeColor = Colors.cyan;
        break;
      case VerificationSource.ayushCertified:
        badgeColor = Colors.purple;
        break;
      default:
        badgeColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tip.verificationSource.emoji,
              style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            tip.verificationSource.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationInfo(HealthTip tip) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, size: 18, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Verification Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (tip.verifiedBy != null)
            _buildInfoRow('Verified by', tip.verifiedBy!),
          _buildInfoRow('Source', tip.verificationSource.displayName),
          _buildInfoRow('Trust Score', '${tip.trustScore}/100'),
          if (tip.verifiedAt != null)
            _buildInfoRow(
              'Verified on',
              '${tip.verifiedAt!.day}/${tip.verifiedAt!.month}/${tip.verifiedAt!.year}',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(HealthTip tip) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              Icons.remove_red_eye, _formatCount(tip.viewCount), 'Views'),
          _buildStatItem(Icons.bookmark, _formatCount(tip.saveCount), 'Saved'),
          _buildStatItem(Icons.share, _formatCount(tip.shareCount), 'Shares'),
          _buildStatItem(
            Icons.thumb_up,
            '${tip.helpfulnessScore.toStringAsFixed(0)}%',
            'Helpful',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkdownContent(String content) {
    // Simple markdown-like rendering
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            line.substring(3),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(
            line.substring(4),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14)),
              Expanded(
                child: _parseInlineFormatting(line.substring(2)),
              ),
            ],
          ),
        ));
      } else if (line.startsWith('1. ') ||
          line.startsWith('2. ') ||
          line.startsWith('3. ') ||
          line.startsWith('4. ') ||
          line.startsWith('5. ') ||
          line.startsWith('6. ') ||
          line.startsWith('7. ') ||
          line.startsWith('8. ') ||
          line.startsWith('9. ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${line.substring(0, 2)} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: _parseInlineFormatting(line.substring(3)),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _parseInlineFormatting(line),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseInlineFormatting(String text) {
    // Handle **bold** text
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    if (boldRegex.hasMatch(text)) {
      final spans = <TextSpan>[];
      int lastEnd = 0;

      for (final match in boldRegex.allMatches(text)) {
        if (match.start > lastEnd) {
          spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        lastEnd = match.end;
      }

      if (lastEnd < text.length) {
        spans.add(TextSpan(text: text.substring(lastEnd)));
      }

      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            height: 1.5,
          ),
          children: spans,
        ),
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
        height: 1.5,
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Was this tip helpful?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _submitFeedback(true),
                  icon: Icon(
                    _userFeedback == true
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    color: _userFeedback == true ? Colors.white : Colors.green,
                  ),
                  label: Text(
                    'Yes, Helpful',
                    style: TextStyle(
                      color:
                          _userFeedback == true ? Colors.white : Colors.green,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        _userFeedback == true ? Colors.green : null,
                    side: BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _submitFeedback(false),
                  icon: Icon(
                    _userFeedback == false
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                    color: _userFeedback == false ? Colors.white : Colors.red,
                  ),
                  label: Text(
                    'Not Helpful',
                    style: TextStyle(
                      color: _userFeedback == false ? Colors.white : Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _userFeedback == false ? Colors.red : null,
                    side: BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          if (_userFeedback != null) ...[
            const SizedBox(height: 12),
            Text(
              _userFeedback == true
                  ? '✅ Thanks for your feedback!'
                  : '📝 We\'ll improve our content. Thank you!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinalDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'Important Notice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• This tip is for general awareness and educational purposes only.\n'
            '• It is NOT a substitute for professional medical advice, diagnosis, or treatment.\n'
            '• Always seek advice from a qualified healthcare provider.\n'
            '• Never disregard professional medical advice based on this information.\n'
            '• In case of emergency, call your local emergency number immediately.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  void _toggleSave() async {
    if (_isSaved) {
      await _service.unsaveTip(widget.tip.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from saved tips')),
      );
    } else {
      await _service.saveTip(widget.tip.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💾 Saved!')),
      );
    }
    setState(() => _isSaved = !_isSaved);
  }

  void _shareTip() {
    final tip = widget.tip;
    _service.recordShare(tip.id);
    Share.share(
      '💊 *Health Tip*\n\n'
      '*${tip.title}*\n\n'
      '${tip.shortDescription}\n\n'
      '${tip.verificationSource.emoji} ${tip.verificationSource.displayName}\n\n'
      '⚠️ *Disclaimer:* This is for awareness only. Always consult a doctor for medical advice.\n\n'
      'Get more health tips on My City App!',
    );
  }

  void _submitFeedback(bool isHelpful) async {
    await _service.submitFeedback(widget.tip.id, isHelpful);
    setState(() => _userFeedback = isHelpful);
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
