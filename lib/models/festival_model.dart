// STEP 8: Festival Mode
// Detect festival dates.
// Change UI theme and highlight festival videos.
// Create festival-specific feed filter.

import 'package:flutter/material.dart';

class Festival {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> regions; // Regions where this festival is celebrated
  final String themeColor;
  final String iconEmoji;
  final String bannerUrl;
  final List<String> relatedHashtags;
  final String? religion; // Associated religion

  Festival({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.regions,
    required this.themeColor,
    required this.iconEmoji,
    this.bannerUrl = '',
    this.relatedHashtags = const [],
    this.religion,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final daysUntil = startDate.difference(now).inDays;
    return daysUntil > 0 && daysUntil <= 7;
  }

  Color get color {
    try {
      return Color(int.parse(themeColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.purple;
    }
  }

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      regions: List<String>.from(json['regions'] ?? []),
      themeColor: json['themeColor'] ?? '#9C27B0',
      iconEmoji: json['iconEmoji'] ?? '🎉',
      bannerUrl: json['bannerUrl'] ?? '',
      relatedHashtags: List<String>.from(json['relatedHashtags'] ?? []),
      religion: json['religion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'regions': regions,
      'themeColor': themeColor,
      'iconEmoji': iconEmoji,
      'bannerUrl': bannerUrl,
      'relatedHashtags': relatedHashtags,
      'religion': religion,
    };
  }

  // Predefined festivals
  static List<Festival> getPredefinedFestivals(int year) {
    return [
      // Hindu Festivals
      Festival(
        id: 'diwali_$year',
        name: 'Diwali',
        description: 'Festival of Lights',
        startDate: DateTime(year, 10, 29),
        endDate: DateTime(year, 11, 3),
        regions: ['all'],
        themeColor: '#FF9800',
        iconEmoji: '🪔',
        relatedHashtags: [
          'diwali',
          'festival_of_lights',
          'diwali_vibes',
          'happy_diwali'
        ],
        religion: 'hinduism',
      ),
      Festival(
        id: 'holi_$year',
        name: 'Holi',
        description: 'Festival of Colors',
        startDate: DateTime(year, 3, 13),
        endDate: DateTime(year, 3, 15),
        regions: ['all'],
        themeColor: '#E91E63',
        iconEmoji: '🎨',
        relatedHashtags: [
          'holi',
          'festival_of_colors',
          'holi_hai',
          'happy_holi'
        ],
        religion: 'hinduism',
      ),
      Festival(
        id: 'ganesh_chaturthi_$year',
        name: 'Ganesh Chaturthi',
        description: 'Birthday of Lord Ganesha',
        startDate: DateTime(year, 9, 6),
        endDate: DateTime(year, 9, 17),
        regions: ['Maharashtra', 'Karnataka', 'Andhra Pradesh', 'Telangana'],
        themeColor: '#FF5722',
        iconEmoji: '🐘',
        relatedHashtags: [
          'ganesh_chaturthi',
          'ganpati_bappa_morya',
          'lord_ganesha'
        ],
        religion: 'hinduism',
      ),
      Festival(
        id: 'navratri_$year',
        name: 'Navratri',
        description: 'Nine Nights Festival',
        startDate: DateTime(year, 10, 2),
        endDate: DateTime(year, 10, 11),
        regions: ['Gujarat', 'Maharashtra', 'all'],
        themeColor: '#9C27B0',
        iconEmoji: '💃',
        relatedHashtags: ['navratri', 'garba', 'dandiya', 'jai_mata_di'],
        religion: 'hinduism',
      ),
      Festival(
        id: 'janmashtami_$year',
        name: 'Janmashtami',
        description: 'Birthday of Lord Krishna',
        startDate: DateTime(year, 8, 26),
        endDate: DateTime(year, 8, 27),
        regions: ['all'],
        themeColor: '#3F51B5',
        iconEmoji: '🦚',
        relatedHashtags: ['janmashtami', 'krishna_janmashtami', 'hare_krishna'],
        religion: 'hinduism',
      ),
      Festival(
        id: 'mahashivratri_$year',
        name: 'Maha Shivratri',
        description: 'Great Night of Shiva',
        startDate: DateTime(year, 3, 8),
        endDate: DateTime(year, 3, 9),
        regions: ['all'],
        themeColor: '#607D8B',
        iconEmoji: '🔱',
        relatedHashtags: ['mahashivratri', 'shivratri', 'har_har_mahadev'],
        religion: 'hinduism',
      ),
      Festival(
        id: 'durga_puja_$year',
        name: 'Durga Puja',
        description: 'Worship of Goddess Durga',
        startDate: DateTime(year, 10, 9),
        endDate: DateTime(year, 10, 13),
        regions: ['West Bengal', 'Odisha', 'Assam'],
        themeColor: '#F44336',
        iconEmoji: '🙏',
        relatedHashtags: ['durga_puja', 'shubho_bijoya', 'maa_durga'],
        religion: 'hinduism',
      ),
      Festival(
        id: 'pongal_$year',
        name: 'Pongal',
        description: 'Harvest Festival',
        startDate: DateTime(year, 1, 14),
        endDate: DateTime(year, 1, 17),
        regions: ['Tamil Nadu', 'Andhra Pradesh', 'Telangana'],
        themeColor: '#4CAF50',
        iconEmoji: '🌾',
        relatedHashtags: ['pongal', 'happy_pongal', 'thai_pongal'],
        religion: 'hinduism',
      ),
      Festival(
        id: 'onam_$year',
        name: 'Onam',
        description: 'Harvest Festival of Kerala',
        startDate: DateTime(year, 8, 28),
        endDate: DateTime(year, 9, 8),
        regions: ['Kerala'],
        themeColor: '#FFEB3B',
        iconEmoji: '🛶',
        relatedHashtags: ['onam', 'happy_onam', 'onashamsakal'],
        religion: 'hinduism',
      ),

      // Islamic Festivals
      Festival(
        id: 'eid_ul_fitr_$year',
        name: 'Eid ul-Fitr',
        description: 'Festival of Breaking the Fast',
        startDate: DateTime(year, 4, 9),
        endDate: DateTime(year, 4, 11),
        regions: ['all'],
        themeColor: '#4CAF50',
        iconEmoji: '🌙',
        relatedHashtags: ['eid', 'eid_mubarak', 'eid_ul_fitr', 'ramadan'],
        religion: 'islam',
      ),
      Festival(
        id: 'eid_ul_adha_$year',
        name: 'Eid ul-Adha',
        description: 'Festival of Sacrifice',
        startDate: DateTime(year, 6, 16),
        endDate: DateTime(year, 6, 19),
        regions: ['all'],
        themeColor: '#009688',
        iconEmoji: '🐑',
        relatedHashtags: ['eid_ul_adha', 'bakrid', 'eid_mubarak'],
        religion: 'islam',
      ),
      Festival(
        id: 'milad_un_nabi_$year',
        name: 'Milad-un-Nabi',
        description: 'Birthday of Prophet Muhammad',
        startDate: DateTime(year, 9, 15),
        endDate: DateTime(year, 9, 16),
        regions: ['all'],
        themeColor: '#00BCD4',
        iconEmoji: '🕌',
        relatedHashtags: ['milad_un_nabi', 'mawlid', 'prophet_birthday'],
        religion: 'islam',
      ),

      // Christian Festivals
      Festival(
        id: 'christmas_$year',
        name: 'Christmas',
        description: 'Celebrating birth of Jesus Christ',
        startDate: DateTime(year, 12, 24),
        endDate: DateTime(year, 12, 26),
        regions: ['all'],
        themeColor: '#F44336',
        iconEmoji: '🎄',
        relatedHashtags: ['christmas', 'merry_christmas', 'xmas'],
        religion: 'christianity',
      ),
      Festival(
        id: 'easter_$year',
        name: 'Easter',
        description: 'Resurrection of Jesus Christ',
        startDate: DateTime(year, 4, 20),
        endDate: DateTime(year, 4, 21),
        regions: ['all'],
        themeColor: '#E1BEE7',
        iconEmoji: '🐣',
        relatedHashtags: ['easter', 'happy_easter', 'resurrection'],
        religion: 'christianity',
      ),
      Festival(
        id: 'good_friday_$year',
        name: 'Good Friday',
        description: 'Crucifixion of Jesus Christ',
        startDate: DateTime(year, 4, 18),
        endDate: DateTime(year, 4, 18),
        regions: ['all'],
        themeColor: '#795548',
        iconEmoji: '✝️',
        relatedHashtags: ['good_friday', 'holy_friday'],
        religion: 'christianity',
      ),

      // Sikh Festivals
      Festival(
        id: 'vaisakhi_$year',
        name: 'Vaisakhi',
        description: 'Sikh New Year',
        startDate: DateTime(year, 4, 14),
        endDate: DateTime(year, 4, 14),
        regions: ['Punjab', 'all'],
        themeColor: '#FF9800',
        iconEmoji: '🌾',
        relatedHashtags: ['vaisakhi', 'baisakhi', 'sikh_new_year'],
        religion: 'sikhism',
      ),
      Festival(
        id: 'guru_nanak_jayanti_$year',
        name: 'Guru Nanak Jayanti',
        description: 'Birthday of Guru Nanak',
        startDate: DateTime(year, 11, 15),
        endDate: DateTime(year, 11, 15),
        regions: ['Punjab', 'all'],
        themeColor: '#FFC107',
        iconEmoji: '🙏',
        relatedHashtags: ['guru_nanak_jayanti', 'gurpurab', 'waheguru'],
        religion: 'sikhism',
      ),

      // Buddhist Festivals
      Festival(
        id: 'buddha_purnima_$year',
        name: 'Buddha Purnima',
        description: 'Birthday of Buddha',
        startDate: DateTime(year, 5, 12),
        endDate: DateTime(year, 5, 12),
        regions: ['all'],
        themeColor: '#9C27B0',
        iconEmoji: '☸️',
        relatedHashtags: ['buddha_purnima', 'vesak', 'buddha_jayanti'],
        religion: 'buddhism',
      ),

      // General
      Festival(
        id: 'new_year_$year',
        name: 'New Year',
        description: 'New Year Celebration',
        startDate: DateTime(year, 12, 31),
        endDate: DateTime(year + 1, 1, 2),
        regions: ['all'],
        themeColor: '#2196F3',
        iconEmoji: '🎆',
        relatedHashtags: ['new_year', 'happy_new_year', 'new_year_${year + 1}'],
      ),
    ];
  }
}

// Festival theme configuration
class FestivalTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String backgroundPattern;
  final List<String> decorativeEmojis;

  FestivalTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.backgroundPattern = '',
    this.decorativeEmojis = const [],
  });

  static FestivalTheme fromFestival(Festival festival) {
    final baseColor = festival.color;
    return FestivalTheme(
      primaryColor: baseColor,
      secondaryColor: baseColor.withOpacity(0.7),
      accentColor: baseColor.withOpacity(0.3),
      decorativeEmojis: [festival.iconEmoji],
    );
  }
}
