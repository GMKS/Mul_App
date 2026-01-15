/// Quote of the Day Widget
/// Displays daily devotional quote with share functionality

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/quote_model.dart';
import '../../services/devotional_service.dart';
import '../../services/religion_service.dart';

class QuoteOfTheDayWidget extends StatefulWidget {
  final String? religion;
  final String? language;

  const QuoteOfTheDayWidget({
    super.key,
    this.religion,
    this.language,
  });

  @override
  State<QuoteOfTheDayWidget> createState() => _QuoteOfTheDayWidgetState();
}

class _QuoteOfTheDayWidgetState extends State<QuoteOfTheDayWidget> {
  DevotionalQuote? _quote;
  bool _isLoading = true;
  String? _userReligion;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    // Get user's religion if not provided
    String? religion = widget.religion;
    if (religion == null || religion.isEmpty) {
      religion = await ReligionService.getReligionString();
    }

    setState(() {
      _userReligion = religion;
    });

    if (religion == null || religion.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final quote = await DevotionalService.getQuoteOfTheDay(
      religion: religion,
      language: widget.language,
    );

    setState(() {
      _quote = quote;
      _isLoading = false;
    });
  }

  Future<void> _shareToWhatsApp() async {
    if (_quote == null) return;

    final text = '''✨ Quote of the Day ✨

"${_quote!.text}"

${_quote!.source != null ? '- ${_quote!.source}' : ''}

Shared from Regional Shorts App 🙏''';

    // Try WhatsApp first
    final whatsappUrl = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(text)}',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to general share
        await Share.share(text);
      }
    } catch (e) {
      // Fallback to general share
      await Share.share(text);
    }
  }

  Future<void> _shareGeneral() async {
    if (_quote == null) return;

    final text = '''✨ Quote of the Day ✨

"${_quote!.text}"

${_quote!.source != null ? '- ${_quote!.source}' : ''}

Shared from Regional Shorts App 🙏''';

    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_userReligion == null || _userReligion!.isEmpty) {
      return _buildSelectReligionState();
    }

    if (_quote == null) {
      return const SizedBox.shrink();
    }

    return _buildQuoteCard();
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B59B6).withOpacity(0.3),
            const Color(0xFF6C63FF).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildSelectReligionState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            size: 40,
            color: Colors.white54,
          ),
          const SizedBox(height: 12),
          const Text(
            'Set your religion to see daily quotes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Navigate to religion selection
              Navigator.pushNamed(context, '/religion-selection');
            },
            child: const Text(
              'Select Religion',
              style: TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    final religionColors = _getReligionColors(_userReligion ?? '');

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: religionColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: religionColors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.format_quote,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Quote of the Day',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getReligionEmoji(_userReligion ?? ''),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Quote text
                Text(
                  '"${_quote!.text}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Source
                if (_quote!.source != null)
                  Text(
                    '— ${_quote!.source}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 16),

                // Share buttons
                Row(
                  children: [
                    // WhatsApp share
                    _buildShareButton(
                      icon: Icons.message,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: _shareToWhatsApp,
                    ),
                    const SizedBox(width: 12),
                    // General share
                    _buildShareButton(
                      icon: Icons.share,
                      label: 'Share',
                      color: Colors.white.withOpacity(0.2),
                      onTap: _shareGeneral,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getReligionColors(String religion) {
    switch (religion.toLowerCase()) {
      case 'hinduism':
        return [const Color(0xFFFF8C00), const Color(0xFFFF6B00)];
      case 'islam':
        return [const Color(0xFF00C77B), const Color(0xFF00A86B)];
      case 'christianity':
        return [const Color(0xFF7C73FF), const Color(0xFF6C63FF)];
      case 'sikhism':
        return [const Color(0xFFF5AB35), const Color(0xFFF39C12)];
      case 'buddhism':
        return [const Color(0xFFAB69C6), const Color(0xFF9B59B6)];
      default:
        return [const Color(0xFF6C63FF), const Color(0xFF5A52E0)];
    }
  }

  String _getReligionEmoji(String religion) {
    switch (religion.toLowerCase()) {
      case 'hinduism':
        return '🕉️';
      case 'islam':
        return '☪️';
      case 'christianity':
        return '✝️';
      case 'sikhism':
        return '☬';
      case 'buddhism':
        return '☸️';
      default:
        return '🙏';
    }
  }
}
