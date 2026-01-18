/// Temple Model
/// Model for temples and sacred places

class Temple {
  final String id;
  final String name;
  final String religion;
  final String? deity;
  final String description;
  final String address;
  final String city;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final List<String> images;
  final String? timings;
  final String? history;
  final bool isVerified;
  final double? rating;
  final int? reviewCount;
  final List<String> festivalTags;
  final double? distanceKm; // Calculated based on user location

  Temple({
    required this.id,
    required this.name,
    required this.religion,
    this.deity,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    this.country = 'India',
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.images = const [],
    this.timings,
    this.history,
    this.isVerified = false,
    this.rating,
    this.reviewCount,
    this.festivalTags = const [],
    this.distanceKm,
  });

  factory Temple.fromJson(Map<String, dynamic> json) {
    return Temple(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      religion: json['religion'] ?? '',
      deity: json['deity'],
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'India',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      images: List<String>.from(json['images'] ?? []),
      timings: json['timings'],
      history: json['history'],
      isVerified: json['is_verified'] ?? false,
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      festivalTags: List<String>.from(json['festival_tags'] ?? []),
      distanceKm: json['distance_km']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'religion': religion,
      'deity': deity,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'images': images,
      'timings': timings,
      'history': history,
      'is_verified': isVerified,
      'rating': rating,
      'review_count': reviewCount,
      'festival_tags': festivalTags,
      'distance_km': distanceKm,
    };
  }

  Temple copyWith({
    String? id,
    String? name,
    String? religion,
    String? deity,
    String? description,
    String? address,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? images,
    String? timings,
    String? history,
    bool? isVerified,
    double? rating,
    int? reviewCount,
    List<String>? festivalTags,
    double? distanceKm,
  }) {
    return Temple(
      id: id ?? this.id,
      name: name ?? this.name,
      religion: religion ?? this.religion,
      deity: deity ?? this.deity,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      timings: timings ?? this.timings,
      history: history ?? this.history,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      festivalTags: festivalTags ?? this.festivalTags,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceKm == null) return 'Unknown';
    if (distanceKm! < 1) return '${(distanceKm! * 1000).toInt()} m';
    if (distanceKm! < 10) return '${distanceKm!.toStringAsFixed(1)} km';
    return '${distanceKm!.toInt()} km';
  }

  /// Get predefined temples for mock data
  static List<Temple> getPredefinedTemples() {
    return [
      // Hindu Temples
      Temple(
        id: 'temple_1',
        name: 'Tirupati Balaji Temple',
        religion: 'hinduism',
        deity: 'Vishnu',
        description: 'One of the most visited religious sites in the world',
        address: 'Tirumala Hills',
        city: 'Tirupati',
        state: 'Andhra Pradesh',
        latitude: 13.6833,
        longitude: 79.3474,
        imageUrl: 'https://picsum.photos/400/300?random=101',
        timings: '3:00 AM - 12:00 AM',
        isVerified: true,
        rating: 4.9,
        reviewCount: 125000,
        festivalTags: ['brahmotsavam', 'vaikuntha_ekadashi'],
      ),
      Temple(
        id: 'temple_2',
        name: 'Kashi Vishwanath Temple',
        religion: 'hinduism',
        deity: 'Shiva',
        description: 'One of the twelve Jyotirlingas dedicated to Lord Shiva',
        address: 'Vishwanath Gali',
        city: 'Varanasi',
        state: 'Uttar Pradesh',
        latitude: 25.3109,
        longitude: 83.0107,
        imageUrl: 'https://picsum.photos/400/300?random=102',
        timings: '3:00 AM - 11:00 PM',
        isVerified: true,
        rating: 4.8,
        reviewCount: 85000,
        festivalTags: ['mahashivratri', 'shravan'],
      ),
      Temple(
        id: 'temple_3',
        name: 'Siddhivinayak Temple',
        religion: 'hinduism',
        deity: 'Ganesha',
        description: 'One of the richest temples in Mumbai',
        address: 'S.K. Bole Road, Prabhadevi',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 19.0168,
        longitude: 72.8302,
        imageUrl: 'https://picsum.photos/400/300?random=103',
        timings: '5:30 AM - 9:50 PM',
        isVerified: true,
        rating: 4.7,
        reviewCount: 65000,
        festivalTags: ['ganesh_chaturthi'],
      ),
      Temple(
        id: 'temple_4',
        name: 'ISKCON Temple',
        religion: 'hinduism',
        deity: 'Krishna',
        description: 'International Society for Krishna Consciousness',
        address: 'Hare Krishna Hill',
        city: 'Bangalore',
        state: 'Karnataka',
        latitude: 13.0104,
        longitude: 77.5513,
        imageUrl: 'https://picsum.photos/400/300?random=104',
        timings: '4:15 AM - 8:30 PM',
        isVerified: true,
        rating: 4.8,
        reviewCount: 45000,
        festivalTags: ['janmashtami', 'holi'],
      ),
      Temple(
        id: 'temple_5',
        name: 'Meenakshi Amman Temple',
        religion: 'hinduism',
        deity: 'Parvati',
        description: 'Historic Hindu temple in the temple city of Madurai',
        address: 'Madurai Main',
        city: 'Madurai',
        state: 'Tamil Nadu',
        latitude: 9.9195,
        longitude: 78.1193,
        imageUrl: 'https://picsum.photos/400/300?random=105',
        timings: '5:00 AM - 12:30 PM, 4:00 PM - 9:30 PM',
        isVerified: true,
        rating: 4.8,
        reviewCount: 55000,
        festivalTags: ['chithirai', 'navratri'],
      ),

      // Islamic Places
      Temple(
        id: 'mosque_1',
        name: 'Jama Masjid',
        religion: 'islam',
        description: 'One of the largest mosques in India',
        address: 'Jama Masjid Road',
        city: 'Delhi',
        state: 'Delhi',
        latitude: 28.6507,
        longitude: 77.2334,
        imageUrl: 'https://picsum.photos/400/300?random=106',
        timings: '7:00 AM - 12:00 PM, 1:30 PM - 6:30 PM',
        isVerified: true,
        rating: 4.7,
        reviewCount: 35000,
        festivalTags: ['eid', 'ramadan'],
      ),
      Temple(
        id: 'mosque_2',
        name: 'Haji Ali Dargah',
        religion: 'islam',
        description: 'Famous mosque and dargah in the middle of the sea',
        address: 'Haji Ali, Worli',
        city: 'Mumbai',
        state: 'Maharashtra',
        latitude: 18.9827,
        longitude: 72.8089,
        imageUrl: 'https://picsum.photos/400/300?random=107',
        timings: '5:30 AM - 10:00 PM',
        isVerified: true,
        rating: 4.6,
        reviewCount: 28000,
        festivalTags: ['eid', 'milad_un_nabi'],
      ),

      // Christian Churches
      Temple(
        id: 'church_1',
        name: 'Basilica of Bom Jesus',
        religion: 'christianity',
        deity: 'Jesus Christ',
        description:
            'UNESCO World Heritage Site containing remains of St. Francis Xavier',
        address: 'Old Goa',
        city: 'Goa',
        state: 'Goa',
        latitude: 15.5009,
        longitude: 73.9116,
        imageUrl: 'https://picsum.photos/400/300?random=108',
        timings: '9:00 AM - 6:30 PM',
        isVerified: true,
        rating: 4.8,
        reviewCount: 22000,
        festivalTags: ['christmas', 'easter'],
      ),
      Temple(
        id: 'church_2',
        name: 'Velankanni Church',
        religion: 'christianity',
        deity: 'Mother Mary',
        description: 'Basilica of Our Lady of Good Health',
        address: 'Velankanni Main Road',
        city: 'Nagapattinam',
        state: 'Tamil Nadu',
        latitude: 10.6833,
        longitude: 79.8500,
        imageUrl: 'https://picsum.photos/400/300?random=109',
        timings: '6:00 AM - 8:00 PM',
        isVerified: true,
        rating: 4.7,
        reviewCount: 18000,
        festivalTags: ['christmas', 'feast_of_our_lady'],
      ),

      // Sikh Gurudwaras
      Temple(
        id: 'gurudwara_1',
        name: 'Golden Temple',
        religion: 'sikhism',
        deity: 'Waheguru',
        description:
            'The holiest Gurdwara and the most important pilgrimage site of Sikhism',
        address: 'Golden Temple Road',
        city: 'Amritsar',
        state: 'Punjab',
        latitude: 31.6200,
        longitude: 74.8765,
        imageUrl: 'https://picsum.photos/400/300?random=110',
        timings: 'Open 24 hours',
        isVerified: true,
        rating: 4.9,
        reviewCount: 95000,
        festivalTags: ['vaisakhi', 'gurpurab', 'diwali'],
      ),
      Temple(
        id: 'gurudwara_2',
        name: 'Bangla Sahib',
        religion: 'sikhism',
        deity: 'Waheguru',
        description: 'One of the most prominent Sikh gurdwaras in Delhi',
        address: 'Ashoka Road, Connaught Place',
        city: 'Delhi',
        state: 'Delhi',
        latitude: 28.6264,
        longitude: 77.2090,
        imageUrl: 'https://picsum.photos/400/300?random=111',
        timings: 'Open 24 hours',
        isVerified: true,
        rating: 4.8,
        reviewCount: 42000,
        festivalTags: ['vaisakhi', 'gurpurab'],
      ),

      // Buddhist Sites
      Temple(
        id: 'buddhist_1',
        name: 'Mahabodhi Temple',
        religion: 'buddhism',
        deity: 'Buddha',
        description:
            'UNESCO World Heritage Site - Place of Buddha\'s enlightenment',
        address: 'Bodh Gaya Main',
        city: 'Bodh Gaya',
        state: 'Bihar',
        latitude: 24.6961,
        longitude: 84.9911,
        imageUrl: 'https://picsum.photos/400/300?random=112',
        timings: '5:00 AM - 9:00 PM',
        isVerified: true,
        rating: 4.9,
        reviewCount: 38000,
        festivalTags: ['buddha_purnima', 'vesak'],
      ),
      Temple(
        id: 'buddhist_2',
        name: 'Dhamek Stupa',
        religion: 'buddhism',
        deity: 'Buddha',
        description: 'Where Buddha gave his first sermon after enlightenment',
        address: 'Sarnath',
        city: 'Varanasi',
        state: 'Uttar Pradesh',
        latitude: 25.3814,
        longitude: 83.0227,
        imageUrl: 'https://picsum.photos/400/300?random=113',
        timings: '9:00 AM - 5:00 PM',
        isVerified: true,
        rating: 4.7,
        reviewCount: 15000,
        festivalTags: ['buddha_purnima', 'dharma_chakra_day'],
      ),
    ];
  }
}
