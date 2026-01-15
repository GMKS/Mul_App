/// Feed Filter Models for Regional Video Feed
/// Handles language, city, district, and tab filters

/// Feed tab types
enum RegionalFeedTab {
  latest,
  trending,
}

/// Location filter priority levels
enum LocationPriority {
  city, // Same city - highest priority
  district, // Same district
  state, // Same state - fallback
  region, // Same region - wider fallback
}

/// Regional feed filter configuration
class RegionalFeedFilter {
  final String? language;
  final String? city;
  final String? district;
  final String? state;
  final String? region;
  final RegionalFeedTab tab;
  final LocationPriority priority;

  const RegionalFeedFilter({
    this.language,
    this.city,
    this.district,
    this.state,
    this.region,
    this.tab = RegionalFeedTab.latest,
    this.priority = LocationPriority.city,
  });

  /// Create filter with all location data
  factory RegionalFeedFilter.fromLocation({
    required String city,
    required String state,
    String? district,
    String? region,
    String? language,
    RegionalFeedTab tab = RegionalFeedTab.latest,
  }) {
    return RegionalFeedFilter(
      city: city,
      district: district,
      state: state,
      region: region,
      language: language,
      tab: tab,
      priority: LocationPriority.city,
    );
  }

  /// Copy with modifications
  RegionalFeedFilter copyWith({
    String? language,
    String? city,
    String? district,
    String? state,
    String? region,
    RegionalFeedTab? tab,
    LocationPriority? priority,
  }) {
    return RegionalFeedFilter(
      language: language ?? this.language,
      city: city ?? this.city,
      district: district ?? this.district,
      state: state ?? this.state,
      region: region ?? this.region,
      tab: tab ?? this.tab,
      priority: priority ?? this.priority,
    );
  }

  /// Check if filter has minimum required location data
  bool get hasLocationData => city != null || state != null || region != null;

  /// Get display string for current filter
  String get locationDisplayString {
    if (city != null && district != null) {
      return '$city, $district';
    } else if (city != null) {
      return city!;
    } else if (state != null) {
      return state!;
    } else if (region != null) {
      return '$region Region';
    }
    return 'All Locations';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionalFeedFilter &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          city == other.city &&
          district == other.district &&
          state == other.state &&
          region == other.region &&
          tab == other.tab &&
          priority == other.priority;

  @override
  int get hashCode =>
      language.hashCode ^
      city.hashCode ^
      district.hashCode ^
      state.hashCode ^
      region.hashCode ^
      tab.hashCode ^
      priority.hashCode;
}

/// Language option for filter dropdown
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  /// Available Indian languages
  static const List<LanguageOption> indianLanguages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    LanguageOption(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    LanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    LanguageOption(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    LanguageOption(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    LanguageOption(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    LanguageOption(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    LanguageOption(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    LanguageOption(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    LanguageOption(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    LanguageOption(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া'),
    LanguageOption(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
  ];

  /// Get language by code
  static LanguageOption? getByCode(String code) {
    try {
      return indianLanguages.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Get default language for a state
  static String getDefaultLanguageForState(String state) {
    final stateLanguageMap = {
      'Andhra Pradesh': 'te',
      'Telangana': 'te',
      'Tamil Nadu': 'ta',
      'Karnataka': 'kn',
      'Kerala': 'ml',
      'Maharashtra': 'mr',
      'Gujarat': 'gu',
      'West Bengal': 'bn',
      'Punjab': 'pa',
      'Odisha': 'or',
      'Assam': 'as',
      'Bihar': 'hi',
      'Uttar Pradesh': 'hi',
      'Madhya Pradesh': 'hi',
      'Rajasthan': 'hi',
      'Haryana': 'hi',
      'Delhi': 'hi',
    };
    return stateLanguageMap[state] ?? 'hi';
  }
}

/// City option for location filter
class CityOption {
  final String name;
  final String state;
  final String? district;
  final String region;

  const CityOption({
    required this.name,
    required this.state,
    this.district,
    required this.region,
  });

  String get displayName => district != null ? '$name, $district' : name;
}
