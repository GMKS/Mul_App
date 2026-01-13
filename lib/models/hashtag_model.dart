// STEP 10: Local Hashtags & Discoverability
// Extract hashtags from captions.
// Group videos by regional hashtags.
// Enable hashtag-based feed filtering.

class Hashtag {
  final String tag;
  final int usageCount;
  final String? region; // Null if global
  final List<String> relatedTags;
  final bool isTrending;
  final DateTime lastUsedAt;

  Hashtag({
    required this.tag,
    this.usageCount = 0,
    this.region,
    this.relatedTags = const [],
    this.isTrending = false,
    required this.lastUsedAt,
  });

  // Normalize hashtag for consistency
  String get normalizedTag => tag.toLowerCase().replaceAll('#', '');

  factory Hashtag.fromJson(Map<String, dynamic> json) {
    return Hashtag(
      tag: json['tag'] ?? '',
      usageCount: json['usageCount'] ?? 0,
      region: json['region'],
      relatedTags: List<String>.from(json['relatedTags'] ?? []),
      isTrending: json['isTrending'] ?? false,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'usageCount': usageCount,
      'region': region,
      'relatedTags': relatedTags,
      'isTrending': isTrending,
      'lastUsedAt': lastUsedAt.toIso8601String(),
    };
  }

  // Extract hashtags from text
  static List<String> extractHashtags(String text) {
    final RegExp hashtagRegex = RegExp(
        r'#[\w\u0900-\u097F\u0980-\u09FF\u0A00-\u0A7F\u0B00-\u0B7F\u0C00-\u0C7F\u0D00-\u0D7F]+');
    final matches = hashtagRegex.allMatches(text);
    return matches.map((match) => match.group(0)!).toList();
  }

  // Predefined regional hashtags
  static Map<String, List<String>> get regionalHashtags => {
        'Maharashtra': [
          '#Mumbai',
          '#Pune',
          '#Maharashtra',
          '#MarathiMulgi',
          '#JayMaharashtra'
        ],
        'Tamil Nadu': [
          '#Chennai',
          '#Tamil',
          '#Kollywood',
          '#TamilNadu',
          '#Madras'
        ],
        'Karnataka': [
          '#Bangalore',
          '#Karnataka',
          '#Kannada',
          '#Sandalwood',
          '#NammaBengaluru'
        ],
        'Telangana': [
          '#Hyderabad',
          '#Telangana',
          '#Telugu',
          '#Tollywood',
          '#CityOfPearls'
        ],
        'Andhra Pradesh': [
          '#AndhraPradesh',
          '#Telugu',
          '#Vizag',
          '#Vijayawada'
        ],
        'Kerala': [
          '#Kerala',
          '#Malayalam',
          '#Mollywood',
          '#GodsOwnCountry',
          '#Kochi'
        ],
        'West Bengal': [
          '#Kolkata',
          '#Bengal',
          '#Bengali',
          '#Tollywood',
          '#CityOfJoy'
        ],
        'Gujarat': ['#Gujarat', '#Ahmedabad', '#Gujarati', '#Surat', '#Garba'],
        'Rajasthan': [
          '#Rajasthan',
          '#Jaipur',
          '#PinkCity',
          '#Rajasthani',
          '#Udaipur'
        ],
        'Punjab': [
          '#Punjab',
          '#Punjabi',
          '#Chandigarh',
          '#Amritsar',
          '#Bhangra'
        ],
        'Delhi': [
          '#Delhi',
          '#DelhiNCR',
          '#DilWalonKiDilli',
          '#Noida',
          '#Gurgaon'
        ],
        'Uttar Pradesh': [
          '#UttarPradesh',
          '#Lucknow',
          '#UP',
          '#Varanasi',
          '#Agra'
        ],
      };

  // Category hashtags
  static Map<String, List<String>> get categoryHashtags => {
        'Regional': [
          '#Regional',
          '#LocalNews',
          '#MyState',
          '#LocalTalent',
          '#Desi'
        ],
        'Business': [
          '#Business',
          '#Startup',
          '#Entrepreneur',
          '#Money',
          '#Finance',
          '#Investment'
        ],
        'Devotional': [
          '#Devotional',
          '#Spiritual',
          '#Prayer',
          '#Temple',
          '#Bhajan',
          '#Mantra'
        ],
      };
}

// Hashtag group for discovery
class HashtagGroup {
  final String name;
  final List<String> hashtags;
  final String? region;
  final int totalVideos;
  final bool isPromoted;

  HashtagGroup({
    required this.name,
    required this.hashtags,
    this.region,
    this.totalVideos = 0,
    this.isPromoted = false,
  });

  factory HashtagGroup.fromJson(Map<String, dynamic> json) {
    return HashtagGroup(
      name: json['name'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      region: json['region'],
      totalVideos: json['totalVideos'] ?? 0,
      isPromoted: json['isPromoted'] ?? false,
    );
  }
}
