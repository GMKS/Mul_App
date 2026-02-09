/// Admin Translation Screen
/// UI to manually trigger translations for businesses

import 'package:flutter/material.dart';
import '../../services/translation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TranslationAdminScreen extends StatefulWidget {
  const TranslationAdminScreen({super.key});

  @override
  State<TranslationAdminScreen> createState() => _TranslationAdminScreenState();
}

class _TranslationAdminScreenState extends State<TranslationAdminScreen> {
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
          .eq('is_featured', true)
          .eq('is_approved', true);

      setState(() {
        _totalBusinesses = (response as List).length;
      });
      _addLog('📊 Found $_totalBusinesses featured businesses');
    } catch (e) {
      _addLog('❌ Error fetching business count: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, message);
      if (_logs.length > 100) _logs.removeLast();
    });
    print(message); // Also print to console
  }

  Future<void> _translateAllBusinesses() async {
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
      _addLog('📊 Found ${businesses.length} featured businesses to process');

      for (var i = 0; i < businesses.length; i++) {
        final business = businesses[i];
        final id = business['id'];
        final name = business['name'] ?? 'Unnamed';

        _addLog('');
        _addLog('═══════════════════════════════════════');
        _addLog('[$i/${businesses.length}] Processing: $name');

        // Check if already has translations
        final hasTeluguTranslation = business['name_te'] != null &&
            business['name_te'].toString().isNotEmpty;
        final hasHindiTranslation = business['name_hi'] != null &&
            business['name_hi'].toString().isNotEmpty;

        _addLog(
            'Current status: Te ${hasTeluguTranslation ? "✓" : "✗"} | Hi ${hasHindiTranslation ? "✓" : "✗"}');

        if (hasTeluguTranslation && hasHindiTranslation) {
          _addLog('⏭️  Already has both translations - Skipping');
          setState(() => _skippedCount++);
          continue;
        }

        _addLog('🔄 Translating to Telugu and Hindi...');

        try {
          // Translate the business
          final translations = await TranslationService.translateBusiness(
            name: business['name'] ?? '',
            offer: business['offer'],
            tagline: business['tagline'],
            description: business['description'],
            ctaText: business['cta_text'] ?? 'Visit Store',
          );

          _addLog('   Telugu (te): ${translations['name_te']}');
          _addLog('   Hindi (hi): ${translations['name_hi']}');

          // Update in database
          _addLog('💾 Saving to database...');
          final success = await TranslationService.updateBusinessTranslations(
              id, translations);

          if (success) {
            _addLog('✅ Successfully translated and saved!');
            setState(() => _translatedCount++);
          } else {
            _addLog('❌ Failed to save translations to database');
            setState(() => _errorCount++);
          }
        } catch (e) {
          _addLog('❌ Translation error: $e');
          setState(() => _errorCount++);
        }

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 800));
      }

      _addLog('');
      _addLog('═══════════════════════════════════════');
      _addLog('🎉 BATCH TRANSLATION COMPLETE!');
      _addLog('');
      _addLog('📊 Summary:');
      _addLog('   ✅ Successfully translated: $_translatedCount');
      _addLog('   ⏭️  Already translated (skipped): $_skippedCount');
      _addLog('   ❌ Errors: $_errorCount');
      _addLog('   📦 Total processed: ${businesses.length}');
      _addLog('═══════════════════════════════════════');

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Translation Complete'),
            content: Text(
              'Successfully translated $_translatedCount businesses!\n\n'
              'Skipped: $_skippedCount\n'
              'Errors: $_errorCount',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _addLog('');
      _addLog('❌ CRITICAL ERROR: $e');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Translation Failed'),
            content: Text('Error: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Translation'),
        backgroundColor: const Color(0xFF16213e),
      ),
      backgroundColor: const Color(0xFF1a1a2e),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF16213e),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto-Translation Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Automatically translates English business content to Telugu and Hindi using Google Cloud Translation API.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isTranslating
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isTranslating ? Colors.orange : Colors.green,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isTranslating ? Icons.hourglass_empty : Icons.check,
                          color: _isTranslating ? Colors.orange : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isTranslating
                                ? 'Translating... ($_translatedCount translated, $_skippedCount skipped)'
                                : 'Ready to translate $_totalBusinesses businesses',
                            style: TextStyle(
                              color:
                                  _isTranslating ? Colors.orange : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Translate Button
            ElevatedButton.icon(
              onPressed: _isTranslating ? null : _translateAllBusinesses,
              icon: _isTranslating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.translate),
              label: Text(
                _isTranslating
                    ? 'Translating...'
                    : 'Translate All Featured Businesses',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Setup Instructions',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Get Google Cloud Translation API key\n'
                    '2. Open lib/services/translation_service.dart\n'
                    '3. Replace YOUR_GOOGLE_CLOUD_API_KEY\n'
                    '4. Click "Translate All" button above\n'
                    '5. Wait for translation to complete\n'
                    '6. Hot reload the app to see results',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Logs
            if (_logs.isNotEmpty) ...[
              const Text(
                'Translation Log:',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          _logs[index],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
