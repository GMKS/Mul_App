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
    };
  }

  // Predefined festivals
  static List<Festival> getPredefinedFestivals(int year) {
    return [
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
          '#Diwali',
          '#FestivalOfLights',
          '#DiwaliVibes',
          '#HappyDiwali'
        ],
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
          '#Holi',
          '#FestivalOfColors',
          '#HoliHai',
          '#HappyHoli'
        ],
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
        relatedHashtags: ['#Pongal', '#HappyPongal', '#ThaiPongal'],
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
        relatedHashtags: ['#Onam', '#HappyOnam', '#Onashamsakal'],
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
        relatedHashtags: ['#DurgaPuja', '#ShubhoBijoya', '#MaaDurga'],
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
          '#GaneshChaturthi',
          '#GanpatiBappaMorya',
          '#LordGanesha'
        ],
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
        relatedHashtags: ['#Navratri', '#Garba', '#Dandiya', '#JaiMataDi'],
      ),
      Festival(
        id: 'eid_$year',
        name: 'Eid',
        description: 'Festival of Breaking the Fast',
        startDate: DateTime(year, 4, 9),
        endDate: DateTime(year, 4, 11),
        regions: ['all'],
        themeColor: '#4CAF50',
        iconEmoji: '🌙',
        relatedHashtags: ['#Eid', '#EidMubarak', '#EidAlFitr'],
      ),
      Festival(
        id: 'christmas_$year',
        name: 'Christmas',
        description: 'Festival celebrating birth of Jesus',
        startDate: DateTime(year, 12, 24),
        endDate: DateTime(year, 12, 26),
        regions: ['all'],
        themeColor: '#F44336',
        iconEmoji: '🎄',
        relatedHashtags: ['#Christmas', '#MerryChristmas', '#Xmas'],
      ),
      Festival(
        id: 'new_year_$year',
        name: 'New Year',
        description: 'New Year Celebration',
        startDate: DateTime(year, 12, 31),
        endDate: DateTime(year + 1, 1, 2),
        regions: ['all'],
        themeColor: '#2196F3',
        iconEmoji: '🎆',
        relatedHashtags: ['#NewYear', '#HappyNewYear', '#NewYear${year + 1}'],
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
