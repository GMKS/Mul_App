/// Translate Businesses Screen
/// Utility screen to translate all featured businesses to Telugu and Hindi
/// Run this once to populate translations in database

import 'package:flutter/material.dart';
import '../../services/translation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TranslateBusinessesScreen extends StatefulWidget {
  const TranslateBusinessesScreen({super.key});

  @override
  State<TranslateBusinessesScreen> createState() =>
      _TranslateBusinessesScreenState();
}

class _TranslateBusinessesScreenState extends State<TranslateBusinessesScreen> {
  bool _isTranslating = false;
  List<String> _logs = [];
  int _totalBusinesses = 0;
  int _translatedCount = 0;
  int _skippedCount = 0;
  int _errorCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchBusinessCount();
  }

  Future<void> _fetchBusinessCount() async {
    try {
      final response = await Supabase.instance.client
          .from('businesses')
          .select()
          .eq('is_featured', true);

      setState(() {
        _totalBusinesses = (response as List).length;
      });
    } catch (e) {
      _addLog('❌ Error fetching business count: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, message);
      if (_logs.length > 100) _logs.removeLast();
    });
  }

  Future<void> _startTranslation() async {
    setState(() {
      _isTranslating = true;
      _logs.clear();
      _translatedCount = 0;
      _skippedCount = 0;
      _errorCount = 0;
    });

    _addLog('🚀 Starting batch translation...');

    try {
      // Fetch all featured businesses
      final response = await Supabase.instance.client
          .from('businesses')
          .select()
          .eq('is_featured', true)
          .eq('is_approved', true);

      final businesses = List<Map<String, dynamic>>.from(response);
      _addLog('📊 Found ${businesses.length} featured businesses');

      for (var i = 0; i < businesses.length; i++) {
        final business = businesses[i];
        final id = business['id'];
        final name = business['name'] ?? 'Unnamed';

        _addLog('');
        _addLog('[$i/${businesses.length}] Processing: $name');

        // Check if already has translations
        final hasTeluguTranslation = business['name_te'] != null &&
            business['name_te'].toString().isNotEmpty;
        final hasHindiTranslation = business['name_hi'] != null &&
            business['name_hi'].toString().isNotEmpty;

        if (hasTeluguTranslation && hasHindiTranslation) {
          _addLog('⏭️  Already translated (Te: ✓, Hi: ✓)');
          setState(() => _skippedCount++);
          continue;
        }

        _addLog('🔄 Translating...');

        try {
          // Translate the business
          final translations = await TranslationService.translateBusiness(
            name: business['name'] ?? '',
            offer: business['offer'],
            tagline: business['tagline'],
            description: business['description'],
            ctaText: business['cta_text'] ?? 'Visit Store',
          );

          _addLog('   Te: ${translations['name_te']}');
          _addLog('   Hi: ${translations['name_hi']}');

          // Update in database
          final success = await TranslationService.updateBusinessTranslations(
              id, translations);

          if (success) {
            _addLog('✅ Successfully translated and saved');
            setState(() => _translatedCount++);
          } else {
            _addLog('❌ Failed to save translations');
            setState(() => _errorCount++);
          }
        } catch (e) {
          _addLog('❌ Translation error: $e');
          setState(() => _errorCount++);
        }

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _addLog('');
      _addLog('🎉 Batch translation complete!');
      _addLog('   ✅ Translated: $_translatedCount');
      _addLog('   ⏭️  Skipped: $_skippedCount');
      _addLog('   ❌ Errors: $_errorCount');
    } catch (e) {
      _addLog('❌ Batch translation error: $e');
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate Businesses'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Stats Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF50C9C3)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Featured Businesses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_totalBusinesses',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('✅', 'Translated', _translatedCount),
                    _buildStatItem('⏭️', 'Skipped', _skippedCount),
                    _buildStatItem('❌', 'Errors', _errorCount),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          if (!_isTranslating)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _startTranslation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.translate, size: 24),
                  label: const Text(
                    'Start Translation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Translating businesses...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text(
                        'Translation Logs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      if (_logs.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _logs.clear());
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear'),
                        ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text(
                              'No logs yet. Click "Start Translation" to begin.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            reverse: false,
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  _logs[index],
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: _logs[index].startsWith('❌')
                                        ? Colors.red
                                        : _logs[index].startsWith('✅')
                                            ? Colors.green
                                            : _logs[index].startsWith('⏭️')
                                                ? Colors.orange
                                                : Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, int count) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
