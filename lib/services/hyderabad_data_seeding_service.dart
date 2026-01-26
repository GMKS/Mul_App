/// Hyderabad Data Seeding Service
/// Complete devotional data for Hyderabad city

import '../models/devotional_video_model.dart';

class HyderabadDataSeedingService {
  /// Temples in Hyderabad with complete details
  static List<Map<String, dynamic>> getHyderabadTemples() {
    return [
      {
        'id': 'hyd_temple_001',
        'name': 'Birla Mandir',
        'deity': 'Lord Venkateswara',
        'religion': Religion.hinduism,
        'description':
            'Stunning white marble temple atop a hillock, offering panoramic city views. Built in 1976 by the Birla family, this architectural marvel combines South Indian, Rajasthani and Utkala temple architecture.',
        'address':
            'Hill Fort Rd, Ambedkar Colony, Hussain Sagar, Hyderabad, Telangana 500063',
        'latitude': 17.4062,
        'longitude': 78.4691,
        'timings': {
          'morning': '7:00 AM - 12:00 PM',
          'evening': '3:00 PM - 9:00 PM',
          'aarti': '8:00 AM, 12:00 PM, 7:00 PM',
        },
        'contact': {
          'phone': '+91-40-2323-0435',
          'email': 'info@birlamandirhyd.com',
          'website': 'www.birlamandirhyd.com',
        },
        'facilities': [
          'Free Entry',
          'Wheelchair Accessible',
          'Parking Available',
          'Prasadam Counter',
          'Photography Allowed (Outside)',
        ],
        'dress_code': 'Traditional attire recommended',
        'nearby_attractions': [
          'Hussain Sagar Lake',
          'Lumbini Park',
          'Tank Bund',
          'NTR Gardens',
        ],
        'rating': 4.7,
        'total_reviews': 15420,
        'best_time_to_visit': 'Early morning or evening for best views',
        'festival_celebrations': [
          'Janmashtami',
          'Diwali',
          'Brahmotsavam',
          'Vaikunta Ekadasi',
        ],
      },
      {
        'id': 'hyd_temple_002',
        'name': 'Chilkur Balaji Temple',
        'deity': 'Lord Balaji (Visa God)',
        'religion': Religion.hinduism,
        'description':
            'Ancient temple famous for "Visa" blessings. Devotees perform 108 pradakshinas (circumambulation) to have their wishes fulfilled. No hundi (donation box) - runs entirely on voluntary service.',
        'address':
            'Chilkur Village, Moinabad Mandal, Hyderabad, Telangana 500075',
        'latitude': 17.3276,
        'longitude': 78.2830,
        'timings': {
          'weekdays': '6:00 AM - 8:00 PM',
          'saturday': '6:00 AM - 7:00 PM',
          'sunday': 'Closed',
          'special_darshan': 'First Saturday of month - Closed for cleaning',
        },
        'contact': {
          'phone': '+91-40-2443-0303',
          'website': 'www.chilkurbalaji.com',
        },
        'facilities': [
          'Free Entry',
          'Free Prasadam',
          'No Hundi Policy',
          'Pradakshina Path',
          'Drinking Water',
        ],
        'dress_code': 'Traditional dress mandatory',
        'unique_features': [
          '108 pradakshinas tradition',
          'No commercialization',
          'Eco-friendly temple',
          'Self-service model',
        ],
        'rating': 4.8,
        'total_reviews': 23150,
        'history': 'Built 500 years ago during Qutb Shahi period',
        'how_to_reach': '25 km from city center, best by car/taxi',
      },
      {
        'id': 'hyd_temple_003',
        'name': 'Jagannath Temple',
        'deity': 'Lord Jagannath',
        'religion': Religion.hinduism,
        'description':
            'Replica of Puri Jagannath Temple built in traditional Odisha architecture. Famous for annual Rath Yatra with three massive chariots. Serves authentic Odia mahaprasad.',
        'address': 'Banjara Hills Road No. 12, Hyderabad, Telangana 500034',
        'latitude': 17.4190,
        'longitude': 78.4476,
        'timings': {
          'morning': '6:30 AM - 12:30 PM',
          'evening': '4:00 PM - 8:30 PM',
          'mangala_aarti': '6:30 AM',
          'sandhya_aarti': '7:30 PM',
        },
        'contact': {
          'phone': '+91-40-2354-9999',
          'email': 'info@jagannathtemple.in',
          'website': 'www.jagannathtemplehyd.org',
        },
        'facilities': [
          'Free Entry',
          'Mahaprasad Available',
          'Library',
          'Cultural Center',
          'Accommodation for pilgrims',
        ],
        'special_events': [
          'Rath Yatra (June-July)',
          'Snana Yatra',
          'Chandan Yatra',
          'Janmashtami',
        ],
        'rating': 4.6,
        'total_reviews': 8920,
        'architecture': 'Authentic Kalinga style from Odisha',
      },
      {
        'id': 'hyd_temple_004',
        'name': 'Karmanghat Hanuman Temple',
        'deity': 'Lord Hanuman',
        'religion': Religion.hinduism,
        'description':
            'Ancient temple with 11-foot tall Hanuman idol in reclining posture. Famous for miraculous powers. Heavy rush on Tuesdays and Saturdays. Oil abhishekam is special offering.',
        'address': 'Karmanghat, Hyderabad, Telangana 500079',
        'latitude': 17.3616,
        'longitude': 78.5506,
        'timings': {
          'morning': '6:00 AM - 1:00 PM',
          'evening': '4:00 PM - 9:00 PM',
          'special_tuesday': '5:00 AM - 10:00 PM',
          'saturday': '5:00 AM - 10:00 PM',
        },
        'contact': {
          'phone': '+91-40-2417-7777',
        },
        'facilities': [
          'Free Entry',
          'Oil Abhishekam Available',
          'Prasadam Distribution',
          'Large Parking',
          'Queue Management',
        ],
        'offerings': [
          'Tel Abhishekam (Oil Bath)',
          'Mala (Garland)',
          'Coconut Breaking',
          'Vadamala Offering',
        ],
        'rating': 4.7,
        'total_reviews': 18650,
        'crowd_timing':
            'Very heavy on Tuesday/Saturday. Visit early morning to avoid rush.',
        'legend':
            'Believed that Lord Rama installed this idol during his exile',
      },
      {
        'id': 'hyd_temple_005',
        'name': 'Peddamma Temple',
        'deity': 'Goddess Pochamma (Peddamma)',
        'religion': Religion.hinduism,
        'description':
            'Ancient village deity temple famous for Bonalu festival. Goddess is adorned with 24-karat gold ornaments. Main celebration hub during Ashada Bonalu. Unique Telangana folk deity worship.',
        'address': 'Jubilee Hills, Hyderabad, Telangana 500033',
        'latitude': 17.4309,
        'longitude': 78.4126,
        'timings': {
          'daily': '6:00 AM - 9:00 PM',
          'bonalu_festival': '24 hours during festival',
        },
        'contact': {
          'phone': '+91-40-2354-8888',
        },
        'facilities': [
          'Free Entry',
          'Bonalu Offerings',
          'Cultural Performances',
          'Prasadam',
          'Festival Ground',
        ],
        'special_festivals': [
          'Bonalu (July-August)',
          'Navratri',
          'Dussehra',
        ],
        'rating': 4.5,
        'total_reviews': 6730,
        'cultural_significance':
            'Major center for Telangana folk traditions and Bonalu festival',
        'bonalu_info':
            'Bonalu is week-long festival where women carry pots (bonam) on head as offering',
      },
    ];
  }

  /// Devotional Events in Hyderabad
  static List<Map<String, dynamic>> getHyderabadEvents() {
    return [
      {
        'id': 'hyd_event_001',
        'name': 'Maha Shivaratri Celebration 2026',
        'date': DateTime(2026, 2, 26),
        'temple': 'All Shiva Temples',
        'description':
            '24-hour celebration with abhishekam every hour, cultural programs, and spiritual discourses.',
        'timings': {
          'start': '6:00 AM Feb 26',
          'end': '6:00 AM Feb 27',
          'main_abhishekam': '12:00 AM (midnight)',
        },
        'schedule': [
          {'time': '6:00 AM', 'activity': 'Maha Abhishekam begins'},
          {'time': '9:00 AM', 'activity': 'Vedic chanting'},
          {'time': '12:00 PM', 'activity': 'Rudrabhishekam'},
          {'time': '6:00 PM', 'activity': 'Aarti'},
          {'time': '12:00 AM', 'activity': 'Main Maha Abhishekam'},
          {'time': '3:00 AM', 'activity': 'Special prayers'},
          {'time': '6:00 AM', 'activity': 'Culmination ceremony'},
        ],
        'registration': {
          'required': true,
          'online': 'www.shivarathri.org',
          'fee': 'Free (Voluntary)',
        },
        'expected_crowd': 'Very Heavy - 50,000+ devotees',
        'facilities': [
          'Free Prasadam',
          'Medical Camp',
          'Queue Management',
          'Parking',
          'Live Streaming',
        ],
      },
      {
        'id': 'hyd_event_002',
        'name': 'Sri Rama Navami Celebrations',
        'date': DateTime(2026, 4, 2),
        'duration': '9 days',
        'temples': ['Birla Mandir', 'Peddamma Temple', 'All Rama Temples'],
        'description':
            'Nine-day celebration of Lord Rama\'s birth with daily kalyanam, cultural programs, and procession on 9th day.',
        'schedule': [
          {'day': 1, 'activity': 'Flag hoisting, Rama Kalyanam'},
          {'day': 2, 'activity': 'Surya Puja, Vedic discourses'},
          {'day': 3, 'activity': 'Hanuman Jayanti special'},
          {'day': 4, 'activity': 'Rama Pattabhishekam enactment'},
          {'day': 5, 'activity': 'Cultural programs'},
          {'day': 6, 'activity': 'Sunderkanda parayana'},
          {'day': 7, 'activity': 'Ramayana recitation'},
          {'day': 8, 'activity': 'Special abhishekam'},
          {'day': 9, 'activity': 'Grand procession, Rathotsavam'},
        ],
        'highlights': [
          'Grand chariot procession',
          'Traditional performances',
          'Free Anna Prasadam daily',
        ],
        'expected_crowd': 'Heavy - Peak on 9th day',
      },
      {
        'id': 'hyd_event_003',
        'name': 'Hanuman Jayanti',
        'date': DateTime(2026, 4, 23),
        'temples': ['Karmanghat Hanuman Temple', 'All Hanuman Temples'],
        'description':
            'Celebration of Lord Hanuman\'s birth with special tel abhishekam, Hanuman Chalisa recitation, and cultural programs.',
        'timings': {
          'start': '4:00 AM',
          'main_puja': '11:30 AM',
          'sundarkanda': '3:00 PM',
          'aarti': '8:00 PM',
        },
        'special_offerings': [
          'Tel Abhishekam',
          'Vadamala',
          'Hanuman Chalisa 108 times',
          'Panchamrit Abhishekam',
        ],
        'expected_crowd': 'Extremely Heavy - 100,000+ at Karmanghat',
        'road_closures': [
          'Karmanghat main road 6 AM - 10 PM',
          'Diversions from LB Nagar',
        ],
      },
      {
        'id': 'hyd_event_004',
        'name': 'Jagannath Rath Yatra',
        'date': DateTime(2026, 7, 5),
        'temple': 'Jagannath Temple, Banjara Hills',
        'description':
            'Annual chariot festival with three massive chariots carrying Lord Jagannath, Balabhadra, and Subhadra through the streets.',
        'timings': {
          'start': '5:00 AM',
          'chariot_procession': '7:00 AM',
          'return': '6:00 PM',
        },
        'route':
            'Jagannath Temple → Road No. 12 → Road No. 10 → Road No. 14 → Temple',
        'highlights': [
          'Three 40-feet tall chariots',
          'Pulling chariots (voluntary)',
          'Mahaprasad distribution',
          'Cultural programs',
        ],
        'expected_crowd': 'Heavy - 25,000+ devotees',
      },
      {
        'id': 'hyd_event_005',
        'name': 'Bonalu Festival',
        'date': DateTime(2026, 7, 20),
        'duration': '7 days',
        'temple': 'Peddamma Temple (Main venue)',
        'description':
            'Telangana\'s biggest folk festival honoring Goddess Mahakali. Women carry decorated pots (bonam) on their heads, traditional dances, and processions.',
        'schedule': [
          {
            'day': 'Sunday',
            'location': 'Golconda Fort',
            'activity': 'Opening ceremony'
          },
          {
            'day': 'Monday',
            'location': 'Secunderabad',
            'activity': 'Lashkar Bonalu'
          },
          {
            'day': 'Tuesday',
            'location': 'Old City',
            'activity': 'Old City Bonalu'
          },
          {
            'day': 'Wednesday',
            'location': 'Peddamma Temple',
            'activity': 'Main Bonalu'
          },
          {
            'day': 'Thursday',
            'location': 'Ghatam procession',
            'activity': 'Pot procession'
          },
          {
            'day': 'Friday',
            'location': 'Hussain Sagar',
            'activity': 'Rangam (Oracle)'
          },
          {'day': 'Saturday', 'location': 'Various', 'activity': 'Culmination'},
        ],
        'cultural_significance': 'State festival of Telangana',
        'expected_crowd': 'Extremely Heavy - 200,000+ over week',
      },
      {
        'id': 'hyd_event_006',
        'name': 'Bhagavad Gita Discourse Series',
        'start_date': DateTime(2026, 2, 1),
        'end_date': DateTime(2026, 3, 2),
        'venue': 'Birla Mandir Auditorium',
        'description':
            '30-day comprehensive discourse on Bhagavad Gita by renowned scholars. Daily sessions covering all 18 chapters.',
        'timings': {
          'morning_session': '6:00 AM - 8:00 AM',
          'evening_session': '6:00 PM - 8:00 PM',
        },
        'speakers': [
          'Sri Chinna Jeeyar Swami',
          'Dr. Samavedam Shanmukha Sharma',
          'Pujya Swami Tejomayananda',
        ],
        'registration': {
          'required': true,
          'fee': 'Free',
          'online': 'www.gita-discourse.org',
          'capacity': '500 per session',
        },
        'facilities': [
          'Audio translation in Telugu/Hindi',
          'Books/study materials provided',
          'Prasadam after sessions',
          'Parking available',
        ],
      },
    ];
  }

  /// Devotional Alerts for Hyderabad
  static List<Map<String, dynamic>> getHyderabadAlerts() {
    return [
      {
        'id': 'alert_001',
        'type': 'Traffic',
        'severity': 'High',
        'title': 'Heavy Traffic Expected at Karmanghat Temple',
        'description':
            'Tuesday - Hanuman temple will see heavy crowds. Expect 2-hour delays. Alternative route via LB Nagar recommended.',
        'affected_temples': ['Karmanghat Hanuman Temple'],
        'active_from': DateTime.now(),
        'active_until': DateTime.now().add(Duration(days: 1)),
        'recommendations': [
          'Visit early morning (before 8 AM)',
          'Use public transport',
          'Book online darshan',
        ],
      },
      {
        'id': 'alert_002',
        'type': 'Weather',
        'severity': 'Medium',
        'title': 'Thunderstorm Alert - Evening Prayers',
        'description':
            'Heavy thunderstorms expected 4-8 PM today. Evening aarti may be affected at hilltop temples.',
        'affected_temples': ['Birla Mandir', 'Chilkur Balaji'],
        'active_until': DateTime.now().add(Duration(hours: 8)),
        'safety_tips': [
          'Avoid visiting hilltop temples',
          'Check temple status before leaving',
          'Carry umbrellas',
        ],
      },
      {
        'id': 'alert_003',
        'type': 'Event',
        'severity': 'Info',
        'title': 'Bonalu Festival Preparations',
        'description':
            'Peddamma Temple undergoing decorations. Some areas restricted. Main darshan unaffected.',
        'affected_temples': ['Peddamma Temple'],
        'active_until': DateTime(2026, 7, 19),
        'note': 'Festival starts July 20',
      },
      {
        'id': 'alert_004',
        'type': 'Maintenance',
        'severity': 'Low',
        'title': 'Birla Mandir East Wing Closed',
        'description':
            'Renovation work on east wing. Main temple open as usual. Some photo spots unavailable.',
        'active_until': DateTime(2026, 3, 15),
      },
      {
        'id': 'alert_005',
        'type': 'Emergency',
        'severity': 'High',
        'title': 'Road Closures - VIP Movement',
        'description':
            'Roads near Birla Mandir closed 3-6 PM today due to VIP visit. Plan accordingly.',
        'affected_areas': ['Khairatabad', 'Lakdikapul', 'Ambedkar Statue'],
        'active_until': DateTime.now().add(Duration(hours: 5)),
      },
    ];
  }

  /// Business services related to devotional needs
  static List<Map<String, dynamic>> getDevotionalBusinesses() {
    return [
      {
        'id': 'biz_001',
        'name': 'Sri Venkateswara Purohit Services',
        'type': 'Priest Services',
        'owner': 'Pandit Ramakrishna Sharma',
        'services': [
          'Griha Pravesh',
          'Satyanarayan Puja',
          'Marriage Ceremony',
          'Namakaran',
          'Thread Ceremony',
          'Vastu Puja',
        ],
        'pricing': {
          'griha_pravesh': '₹5,001',
          'marriage': '₹15,001 - ₹25,001',
          'satyanarayan': '₹2,501',
        },
        'contact': {
          'phone': '+91-98765-43210',
          'whatsapp': '+91-98765-43210',
          'email': 'purohit.ramakrishna@gmail.com',
        },
        'experience': '25 years',
        'languages': ['Telugu', 'Sanskrit', 'Hindi'],
        'rating': 4.8,
        'verification': 'Verified Purohit',
      },
      {
        'id': 'biz_002',
        'name': 'Hyderabad Pooja Bhandar',
        'type': 'Pooja Items Store',
        'description':
            'Complete range of pooja items, idols, books, and devotional articles',
        'products': [
          'God Idols (Brass, Panchaloha, Marble)',
          'Pooja Thalis',
          'Incense & Camphor',
          'Religious Books',
          'Rudraksha',
          'Yajna Materials',
        ],
        'location': 'Near Birla Mandir',
        'contact': {
          'phone': '+91-40-2323-1111',
          'whatsapp': '+91-98765-11111',
        },
        'timings': '9:00 AM - 9:00 PM',
        'delivery': 'Available in Hyderabad',
        'rating': 4.6,
      },
      {
        'id': 'biz_003',
        'name': 'Divine Temple Caterers',
        'type': 'Prasadam & Catering',
        'specialization': 'Sattvic vegetarian temple-style food',
        'services': [
          'Temple Prasadam',
          'Event Catering',
          'Anna Prasad',
          'Festival Food',
        ],
        'capacity': 'Up to 10,000 people',
        'contact': {
          'phone': '+91-98765-22222',
          'email': 'divine.caterers@gmail.com',
        },
        'rating': 4.7,
      },
      {
        'id': 'biz_004',
        'name': 'Tirumala Travels & Tours',
        'type': 'Pilgrimage Tours',
        'packages': [
          'Tirupati One Day',
          'Srisailam Weekend',
          'Hyderabad Temple Circuit',
          'Pancha Narasimha Yatra',
        ],
        'pricing': {
          'tirupati_1day': '₹1,500 per person',
          'srisailam_2days': '₹3,500 per person',
        },
        'includes': [
          'AC Transport',
          'Darshan Tickets',
          'Accommodation',
          'Meals',
        ],
        'contact': {
          'phone': '+91-98765-33333',
          'website': 'www.tirumalatravels.com',
        },
        'rating': 4.5,
      },
      {
        'id': 'biz_005',
        'name': 'Dharma Guest House',
        'type': 'Accommodation',
        'location': 'Near Birla Mandir',
        'room_types': [
          'Dormitory - ₹300/bed',
          'Standard Room - ₹1,200/night',
          'Deluxe Room - ₹2,000/night',
        ],
        'facilities': [
          'Pure Veg Kitchen',
          'Temple Transportation',
          'Early Morning Arrangements',
          'Pooja Room',
        ],
        'contact': {
          'phone': '+91-40-2323-4444',
          'email': 'dharmaguesthouse@gmail.com',
        },
        'rating': 4.3,
      },
      {
        'id': 'biz_006',
        'name': 'Sri Lakshmi Temple Jewelry',
        'type': 'Religious Jewelry',
        'products': [
          'Deity Ornaments',
          'Silver/Gold Jewelry',
          'Temple Crowns',
          'Personal Religious Jewelry',
        ],
        'customization': 'Available',
        'contact': {
          'phone': '+91-98765-44444',
        },
        'location': 'Begum Bazaar',
        'rating': 4.6,
      },
      {
        'id': 'biz_007',
        'name': 'Jyotish Kendra - Astrology Centre',
        'type': 'Astrology Services',
        'services': [
          'Horoscope Analysis',
          'Muhurtham Selection',
          'Vastu Consultation',
          'Gemstone Recommendation',
        ],
        'astrologer': 'Dr. Venkata Subramanian',
        'experience': '30 years',
        'consultation_fee': '₹1,500',
        'contact': {
          'phone': '+91-98765-55555',
          'email': 'jyotish.kendra@gmail.com',
        },
        'rating': 4.7,
        'advance_booking': 'Required',
      },
      {
        'id': 'biz_008',
        'name': 'Divine Moments Photography',
        'type': 'Event Photography',
        'specialization': 'Religious ceremonies and temple events',
        'services': [
          'Temple Event Coverage',
          'Wedding Photography',
          'Ritual Documentation',
          'Video Editing',
        ],
        'packages': {
          'basic': '₹15,000',
          'premium': '₹35,000',
          'platinum': '₹75,000',
        },
        'contact': {
          'phone': '+91-98765-66666',
          'website': 'www.divinemoments.in',
        },
        'portfolio': 'Available online',
        'rating': 4.8,
      },
    ];
  }
}
