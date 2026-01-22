/// AI-Assisted Moderation Service
/// Automatic content analysis with context awareness for Devotional content

import 'package:flutter/material.dart';

enum ContentSafety {
  safe,
  needsReview,
  inappropriate,
  dangerous,
}

enum ModerationTopic {
  religious,
  cultural,
  language,
  violence,
  spam,
  misinformation,
}

class ModerationResult {
  final ContentSafety safety;
  final double confidenceScore; // 0.0 to 1.0
  final List<ModerationTopic> flaggedTopics;
  final String? reason;
  final Map<String, dynamic>? details;
  final bool requiresHumanReview;

  ModerationResult({
    required this.safety,
    required this.confidenceScore,
    required this.flaggedTopics,
    this.reason,
    this.details,
    this.requiresHumanReview = false,
  });

  Color get safetyColor {
    switch (safety) {
      case ContentSafety.safe:
        return Colors.green;
      case ContentSafety.needsReview:
        return Colors.orange;
      case ContentSafety.inappropriate:
        return Colors.red;
      case ContentSafety.dangerous:
        return Colors.black;
    }
  }

  String get safetyLabel {
    switch (safety) {
      case ContentSafety.safe:
        return 'Safe';
      case ContentSafety.needsReview:
        return 'Needs Review';
      case ContentSafety.inappropriate:
        return 'Inappropriate';
      case ContentSafety.dangerous:
        return 'Dangerous';
    }
  }
}

class AIModerationService {
  // Singleton pattern
  static final AIModerationService _instance = AIModerationService._internal();
  factory AIModerationService() => _instance;
  AIModerationService._internal();

  /// Analyze devotional video content for safety
  Future<ModerationResult> analyzeDevotionalVideo({
    required String title,
    required String description,
    required String deity,
    required String religion,
    List<String>? hashtags,
  }) async {
    // Simulate AI analysis delay
    await Future.delayed(Duration(milliseconds: 500));

    final List<ModerationTopic> flagged = [];
    double confidenceScore = 0.95;
    ContentSafety safety = ContentSafety.safe;
    String? reason;

    // Religious sensitivity check
    final religiousKeywords = _getReligiousKeywords();
    final contentLower = '${title.toLowerCase()} ${description.toLowerCase()}';

    // Check for inappropriate religious mixing
    int religionMentions = 0;
    for (var religion in [
      'hindu',
      'muslim',
      'christian',
      'buddhist',
      'jain',
      'sikh'
    ]) {
      if (contentLower.contains(religion)) religionMentions++;
    }

    if (religionMentions > 2) {
      flagged.add(ModerationTopic.religious);
      safety = ContentSafety.needsReview;
      reason =
          'Multiple religious references detected - requires cultural sensitivity review';
      confidenceScore = 0.75;
    }

    // Check for spam patterns
    final spamIndicators = [
      'subscribe',
      'like share',
      'click here',
      'buy now',
      'limited offer',
      'call now',
      'whatsapp',
      'dm for'
    ];
    int spamCount = 0;
    for (var indicator in spamIndicators) {
      if (contentLower.contains(indicator)) spamCount++;
    }

    if (spamCount >= 2) {
      flagged.add(ModerationTopic.spam);
      safety = ContentSafety.needsReview;
      reason = 'Potential promotional/spam content detected';
      confidenceScore = 0.80;
    }

    // Check for controversial keywords
    final controversialKeywords = [
      'politics',
      'election',
      'government',
      'riot',
      'violence',
      'terrorism',
      'war',
      'hate',
      'kill',
      'blood',
      'weapon'
    ];

    for (var keyword in controversialKeywords) {
      if (contentLower.contains(keyword)) {
        flagged.add(ModerationTopic.violence);
        safety = ContentSafety.inappropriate;
        reason = 'Potentially harmful or controversial content detected';
        confidenceScore = 0.88;
        break;
      }
    }

    // Check for misinformation patterns
    final misinformationKeywords = [
      'cure cancer',
      'guaranteed',
      'miracle',
      '100% effective',
      'scientific proof',
      'doctors hate',
      'secret',
      'hidden truth'
    ];

    for (var keyword in misinformationKeywords) {
      if (contentLower.contains(keyword)) {
        flagged.add(ModerationTopic.misinformation);
        safety = ContentSafety.needsReview;
        reason = 'Potential misinformation or false claims detected';
        confidenceScore = 0.82;
        break;
      }
    }

    return ModerationResult(
      safety: safety,
      confidenceScore: confidenceScore,
      flaggedTopics: flagged,
      reason: reason,
      requiresHumanReview: safety != ContentSafety.safe,
      details: {
        'title': title,
        'deity': deity,
        'religion': religion,
        'analyzedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Analyze user comment for devotional content
  Future<ModerationResult> analyzeComment({
    required String comment,
    required String contextReligion,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));

    final List<ModerationTopic> flagged = [];
    double confidenceScore = 0.92;
    ContentSafety safety = ContentSafety.safe;
    String? reason;

    final commentLower = comment.toLowerCase();

    // Profanity check (basic)
    final profanityWords = [
      'damn',
      'hell',
      'stupid',
      'idiot',
      'fool',
      'hate',
      'kill',
      'die',
      'worst',
      'trash',
      'garbage'
    ];

    for (var word in profanityWords) {
      if (commentLower.contains(word)) {
        flagged.add(ModerationTopic.language);
        safety = ContentSafety.needsReview;
        reason = 'Potentially offensive language detected';
        confidenceScore = 0.85;
        break;
      }
    }

    // Religious disrespect check
    final disrespectfulPhrases = [
      'fake',
      'nonsense',
      'stupid belief',
      'waste',
      'idiotic',
      'backward',
      'foolish',
      'primitive'
    ];

    for (var phrase in disrespectfulPhrases) {
      if (commentLower.contains(phrase)) {
        flagged.add(ModerationTopic.religious);
        safety = ContentSafety.inappropriate;
        reason = 'Disrespectful language toward religious beliefs';
        confidenceScore = 0.88;
        break;
      }
    }

    return ModerationResult(
      safety: safety,
      confidenceScore: confidenceScore,
      flaggedTopics: flagged,
      reason: reason,
      requiresHumanReview: safety != ContentSafety.safe,
      details: {
        'comment': comment,
        'contextReligion': contextReligion,
        'analyzedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Check if content should be auto-blurred
  bool shouldAutoBlur(ModerationResult result) {
    return result.safety == ContentSafety.inappropriate ||
        result.safety == ContentSafety.dangerous ||
        (result.safety == ContentSafety.needsReview &&
            result.confidenceScore > 0.85);
  }

  /// Get warning label for content
  String? getWarningLabel(ModerationResult result) {
    if (result.safety == ContentSafety.safe) return null;

    if (result.flaggedTopics.contains(ModerationTopic.religious)) {
      return '⚠️ Religious Sensitivity: This content may contain religious topics that require careful consideration';
    }

    if (result.flaggedTopics.contains(ModerationTopic.violence)) {
      return '⚠️ Content Warning: This content may contain sensitive or controversial topics';
    }

    if (result.flaggedTopics.contains(ModerationTopic.misinformation)) {
      return '⚠️ Verify Claims: This content makes claims that should be independently verified';
    }

    if (result.flaggedTopics.contains(ModerationTopic.spam)) {
      return '⚠️ Promotional Content: This may contain promotional or advertising material';
    }

    return '⚠️ Review Required: This content is under review by moderators';
  }

  /// Cultural sensitivity analysis for regional context
  Future<Map<String, dynamic>> analyzeCulturalContext({
    required String content,
    required String region,
    required String festival,
  }) async {
    await Future.delayed(Duration(milliseconds: 400));

    // Regional sensitive topics
    final sensitivePhrases = {
      'Hyderabad': ['charming', 'biryani politics', 'old city tensions'],
      'Delhi': ['farmer protest', 'capital riots', 'communal'],
      'Mumbai': ['underworld', 'riots', 'demolition'],
    };

    bool isSensitive = false;
    List<String> warnings = [];

    if (sensitivePhrases.containsKey(region)) {
      final phrases = sensitivePhrases[region]!;
      for (var phrase in phrases) {
        if (content.toLowerCase().contains(phrase)) {
          isSensitive = true;
          warnings.add('Contains region-specific sensitive topic: $phrase');
        }
      }
    }

    return {
      'isCulturallySensitive': isSensitive,
      'warnings': warnings,
      'region': region,
      'festival': festival,
      'recommendHumanReview': isSensitive,
    };
  }

  /// Batch analyze multiple videos
  Future<List<ModerationResult>> batchAnalyze(
    List<Map<String, String>> videos,
  ) async {
    final results = <ModerationResult>[];

    for (var video in videos) {
      final result = await analyzeDevotionalVideo(
        title: video['title'] ?? '',
        description: video['description'] ?? '',
        deity: video['deity'] ?? '',
        religion: video['religion'] ?? '',
        hashtags: video['hashtags']?.split(','),
      );
      results.add(result);
    }

    return results;
  }

  List<String> _getReligiousKeywords() {
    return [
      // Hindu
      'god', 'goddess', 'temple', 'puja', 'mandir', 'deity', 'bhagwan',
      'shiva', 'vishnu', 'brahma', 'krishna', 'rama', 'hanuman', 'ganesh',
      'durga', 'lakshmi', 'saraswati', 'parvati',

      // Islamic
      'allah', 'prophet', 'mosque', 'quran', 'namaz', 'ramadan',

      // Christian
      'jesus', 'christ', 'church', 'bible', 'prayer', 'cross',

      // Buddhist
      'buddha', 'meditation', 'dharma', 'nirvana', 'monk',

      // Jain
      'mahavir', 'tirthankara', 'jain temple', 'ahimsa',

      // Sikh
      'guru', 'gurdwara', 'granth sahib', 'waheguru',
    ];
  }
}
