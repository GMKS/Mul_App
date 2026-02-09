/// Automatic Translation Service
/// Translates English text to Telugu and Hindi using Google Cloud Translation API
/// Updates Supabase database with translations

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class TranslationService {
  // TODO: Replace with your Google Cloud Translation API key
  // Get it from: https://console.cloud.google.com/apis/credentials
  static const String _apiKey = 'AIzaSyBd9zb16OGKy5KRIJIcZr-ByseNM1WW3ok';
  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  /// Translate text to a target language
  static Future<String> translateText(
      String text, String targetLanguage) async {
    if (text.isEmpty) return '';

    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'source': 'en',
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['translatedText'] ?? text;
      } else {
        print('❌ Translation API error: ${response.statusCode}');
        return text; // Return original text on error
      }
    } catch (e) {
      print('❌ Translation error: $e');
      return text; // Return original text on error
    }
  }

  /// Translate a business record to Telugu and Hindi
  static Future<Map<String, String>> translateBusiness({
    required String name,
    String? offer,
    String? tagline,
    String? description,
    String? ctaText,
  }) async {
    print('🔄 Translating: $name');

    // Translate to Telugu
    final nameTe = await translateText(name, 'te');
    final offerTe = offer != null ? await translateText(offer, 'te') : null;
    final taglineTe =
        tagline != null ? await translateText(tagline, 'te') : null;
    final descriptionTe =
        description != null ? await translateText(description, 'te') : null;
    final ctaTextTe =
        ctaText != null ? await translateText(ctaText, 'te') : null;

    // Translate to Hindi
    final nameHi = await translateText(name, 'hi');
    final offerHi = offer != null ? await translateText(offer, 'hi') : null;
    final taglineHi =
        tagline != null ? await translateText(tagline, 'hi') : null;
    final descriptionHi =
        description != null ? await translateText(description, 'hi') : null;
    final ctaTextHi =
        ctaText != null ? await translateText(ctaText, 'hi') : null;

    print('✅ Translated: $nameTe (te), $nameHi (hi)');

    return {
      'name_te': nameTe,
      'name_hi': nameHi,
      if (offerTe != null) 'offer_te': offerTe,
      if (offerHi != null) 'offer_hi': offerHi,
      if (taglineTe != null) 'tagline_te': taglineTe,
      if (taglineHi != null) 'tagline_hi': taglineHi,
      if (descriptionTe != null) 'description_te': descriptionTe,
      if (descriptionHi != null) 'description_hi': descriptionHi,
      if (ctaTextTe != null) 'cta_text_te': ctaTextTe,
      if (ctaTextHi != null) 'cta_text_hi': ctaTextHi,
    };
  }

  /// Update a business in Supabase with translations
  static Future<bool> updateBusinessTranslations(
      String businessId, Map<String, String> translations) async {
    try {
      await Supabase.instance.client
          .from('businesses')
          .update(translations)
          .eq('id', businessId);
      print('✅ Updated business $businessId with translations');
      return true;
    } catch (e) {
      print('❌ Error updating business: $e');
      return false;
    }
  }

  /// Batch translate all featured businesses
  static Future<void> translateAllFeaturedBusinesses() async {
    try {
      print('🚀 Starting batch translation of featured businesses...');

      // Fetch all featured businesses without translations
      final response = await Supabase.instance.client
          .from('businesses')
          .select()
          .eq('is_featured', true);

      final businesses = List<Map<String, dynamic>>.from(response);
      print('📊 Found ${businesses.length} featured businesses');

      int successCount = 0;
      int skipCount = 0;

      for (var business in businesses) {
        final id = business['id'];
        final name = business['name'];

        // Skip if already has Telugu translation
        if (business['name_te'] != null &&
            business['name_te'].toString().isNotEmpty) {
          print('⏭️  Skipping $name (already translated)');
          skipCount++;
          continue;
        }

        // Translate the business
        final translations = await translateBusiness(
          name: name ?? '',
          offer: business['offer'],
          tagline: business['tagline'],
          description: business['description'],
          ctaText: business['cta_text'] ?? 'Visit Store',
        );

        // Update in database
        final success = await updateBusinessTranslations(id, translations);
        if (success) {
          successCount++;
        }

        // Add delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }

      print('🎉 Batch translation complete!');
      print('   ✅ Translated: $successCount');
      print('   ⏭️  Skipped: $skipCount');
    } catch (e) {
      print('❌ Batch translation error: $e');
    }
  }

  /// Translate a single business by ID
  static Future<bool> translateBusinessById(String businessId) async {
    try {
      print('🔄 Fetching business $businessId...');

      final response = await Supabase.instance.client
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();

      final business = response as Map<String, dynamic>;

      // Translate
      final translations = await translateBusiness(
        name: business['name'] ?? '',
        offer: business['offer'],
        tagline: business['tagline'],
        description: business['description'],
        ctaText: business['cta_text'] ?? 'Visit Store',
      );

      // Update
      return await updateBusinessTranslations(businessId, translations);
    } catch (e) {
      print('❌ Error translating business: $e');
      return false;
    }
  }
}
