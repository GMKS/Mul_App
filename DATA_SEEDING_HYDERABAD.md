# 🌆 Data Seeding - Hyderabad, Telangana

## Overview

Comprehensive data seeding for Hyderabad including temples, alerts, events, and businesses. This provides realistic test data for development and demonstration.

---

## 🕉️ Temples (25 Major Temples)

### Famous Temples

```json
{
  "temples": [
    {
      "id": "temple_001",
      "name": "Birla Mandir (Laxmi Narayana Temple)",
      "deity": "Lord Venkateswara, Goddess Padmavathi, Goddess Lakshmi",
      "location": {
        "address": "Naubat Pahad, Khairtabad, Hyderabad",
        "latitude": 17.4066,
        "longitude": 78.4691,
        "area": "Khairtabad",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500004"
      },
      "timings": {
        "morning_opens": "07:00",
        "morning_closes": "12:00",
        "evening_opens": "15:00",
        "evening_closes": "21:00",
        "aarti_times": ["07:30", "12:00", "19:00"]
      },
      "contact": {
        "phone": "+91 40 2323 2792",
        "email": "birlamandir.hyd@gmail.com",
        "website": "https://birlamandirhyd.com"
      },
      "description": "Built entirely of white Rajasthani marble, this stunning temple sits atop a 280-foot hillock. Offers panoramic views of Hyderabad.",
      "facilities": [
        "Parking",
        "Wheelchair Access",
        "Prasadam Counter",
        "Book Store"
      ],
      "famous_for": "White marble architecture, City views, Peaceful ambiance",
      "best_time_to_visit": "Evening for sunset views",
      "entry_fee": "Free",
      "photography": "Allowed outside, restricted inside",
      "dress_code": "Traditional Indian attire preferred",
      "nearby_attractions": [
        "Hussain Sagar Lake",
        "NTR Gardens",
        "Lumbini Park"
      ],
      "images": [
        "https://example.com/birla_mandir_1.jpg",
        "https://example.com/birla_mandir_2.jpg"
      ],
      "videos": ["https://example.com/birla_mandir_tour.mp4"],
      "rating": 4.6,
      "total_reviews": 8542,
      "verified": true,
      "last_updated": "2026-01-15"
    },
    {
      "id": "temple_002",
      "name": "Chilkur Balaji Temple (Visa Balaji Temple)",
      "deity": "Lord Venkateswara (Balaji)",
      "location": {
        "address": "Chilkur Village, Hyderabad",
        "latitude": 17.3433,
        "longitude": 78.3526,
        "area": "Chilkur",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500075"
      },
      "timings": {
        "morning_opens": "06:00",
        "morning_closes": "13:00",
        "evening_opens": "15:00",
        "evening_closes": "19:00",
        "closed_on": "Monday"
      },
      "contact": {
        "phone": "+91 40 2428 0234"
      },
      "description": "Ancient temple famous for devotees offering prayers for visa approvals. No hundi, no donations - a unique temple tradition.",
      "facilities": ["Free Parking", "Water Coolers", "Rest Areas"],
      "famous_for": "Visa approvals, 108 pradakshinas tradition",
      "special_rituals": "11 pradakshinas (rounds) when making wish, 108 pradakshinas after wish fulfillment",
      "best_time_to_visit": "Early morning to avoid crowds",
      "entry_fee": "Free",
      "photography": "Limited",
      "nearby_attractions": ["Osman Sagar Lake", "Himayat Sagar Lake"],
      "images": ["https://example.com/chilkur_balaji_1.jpg"],
      "rating": 4.8,
      "total_reviews": 12534,
      "verified": true,
      "last_updated": "2026-01-18"
    },
    {
      "id": "temple_003",
      "name": "Jagannath Temple",
      "deity": "Lord Jagannath, Balabhadra, Subhadra",
      "location": {
        "address": "Road No. 12, Banjara Hills, Hyderabad",
        "latitude": 17.4127,
        "longitude": 78.448,
        "area": "Banjara Hills",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500034"
      },
      "timings": {
        "morning_opens": "07:00",
        "morning_closes": "13:00",
        "evening_opens": "16:00",
        "evening_closes": "20:30"
      },
      "contact": {
        "phone": "+91 40 2354 1144",
        "website": "https://jagannathtemple-hyd.org"
      },
      "description": "Replica of the famous Puri Jagannath Temple. Known for grand Rath Yatra celebrations.",
      "facilities": ["Parking", "Prasadam Counter", "Function Halls"],
      "famous_for": "Rath Yatra festival, Odisha-style architecture",
      "festivals": ["Rath Yatra (June-July)", "Janmashtami", "Diwali"],
      "entry_fee": "Free",
      "photography": "Allowed",
      "images": ["https://example.com/jagannath_temple_1.jpg"],
      "rating": 4.5,
      "total_reviews": 3421,
      "verified": true
    },
    {
      "id": "temple_004",
      "name": "Karmanghat Hanuman Temple",
      "deity": "Lord Hanuman",
      "location": {
        "address": "Karmanghat, Hyderabad",
        "latitude": 17.3616,
        "longitude": 78.5526,
        "area": "Karmanghat",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500079"
      },
      "timings": {
        "morning_opens": "05:00",
        "morning_closes": "22:00",
        "special_puja": "Tuesday & Saturday - Heavy rush"
      },
      "description": "Ancient temple with 11 ft tall Hanuman idol. Extremely crowded on Tuesdays and Saturdays.",
      "facilities": ["Large Parking", "Prasadam Stalls", "Queue Management"],
      "famous_for": "Ancient Hanuman idol, Wish fulfillment",
      "special_days": "Tuesday, Saturday, Hanuman Jayanti",
      "entry_fee": "Free",
      "images": ["https://example.com/karmanghat_hanuman.jpg"],
      "rating": 4.7,
      "total_reviews": 9876,
      "verified": true
    },
    {
      "id": "temple_005",
      "name": "Shree Peddamma Temple",
      "deity": "Goddess Peddamma (Village Goddess)",
      "location": {
        "address": "Jubilee Hills, Hyderabad",
        "latitude": 17.4239,
        "longitude": 78.4095,
        "area": "Jubilee Hills",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500033"
      },
      "timings": {
        "morning_opens": "06:00",
        "evening_closes": "20:00"
      },
      "description": "Ancient village goddess temple. Famous for Bonalu festival celebrations.",
      "festivals": ["Bonalu (July-August)", "Navaratri"],
      "famous_for": "Bonalu festival, Local deity worship",
      "entry_fee": "Free",
      "rating": 4.4,
      "total_reviews": 2134,
      "verified": true
    }
  ]
}
```

---

## 🚨 Alerts (Current Alerts for Hyderabad)

### Alert Types: Traffic, Weather, Events, Emergency, Maintenance

```json
{
  "alerts": [
    {
      "id": "alert_001",
      "type": "traffic",
      "severity": "high",
      "title": "Heavy Traffic on Outer Ring Road",
      "description": "Major traffic congestion reported from Gachibowli to BHEL junction due to metro construction work.",
      "location": {
        "area": "Outer Ring Road",
        "from": "Gachibowli",
        "to": "BHEL",
        "latitude": 17.4401,
        "longitude": 78.3489
      },
      "issued_at": "2026-01-20T08:30:00Z",
      "expires_at": "2026-01-20T19:00:00Z",
      "source": "Hyderabad Traffic Police",
      "alternative_routes": [
        "Take Biodiversity junction via Madhapur",
        "Use Nanakramguda Road via Financial District"
      ],
      "affected_temples": ["temple_002", "temple_004"],
      "status": "active",
      "icon": "traffic",
      "color": "#FF5722"
    },
    {
      "id": "alert_002",
      "type": "weather",
      "severity": "medium",
      "title": "Thunderstorm Alert",
      "description": "Moderate to heavy rainfall with thunderstorms expected in Hyderabad from 4 PM to 8 PM today.",
      "location": {
        "area": "All Hyderabad",
        "city": "Hyderabad"
      },
      "issued_at": "2026-01-20T12:00:00Z",
      "expires_at": "2026-01-20T20:00:00Z",
      "source": "IMD Hyderabad",
      "recommendations": [
        "Carry umbrellas",
        "Avoid low-lying areas",
        "Check temple timings before visiting"
      ],
      "status": "active",
      "icon": "weather_rainy",
      "color": "#FFA726"
    },
    {
      "id": "alert_003",
      "type": "event",
      "severity": "low",
      "title": "Bonalu Festival Preparations",
      "description": "Special darshan arrangements at Peddamma Temple for Bonalu festival. Expect heavy rush on weekends.",
      "location": {
        "temple_id": "temple_005",
        "area": "Jubilee Hills"
      },
      "issued_at": "2026-01-15T00:00:00Z",
      "expires_at": "2026-07-31T23:59:59Z",
      "special_timings": {
        "weekday": "06:00-22:00",
        "weekend": "05:00-23:00"
      },
      "status": "active",
      "icon": "celebration",
      "color": "#4CAF50"
    },
    {
      "id": "alert_004",
      "type": "maintenance",
      "severity": "medium",
      "title": "Birla Mandir Renovation Work",
      "description": "Partial renovation of marble flooring. East wing closed for visitors till Jan 31.",
      "location": {
        "temple_id": "temple_001",
        "affected_area": "East Wing"
      },
      "issued_at": "2026-01-10T00:00:00Z",
      "expires_at": "2026-01-31T23:59:59Z",
      "impact": "West wing and main shrine open as usual",
      "status": "active",
      "icon": "construction",
      "color": "#9E9E9E"
    },
    {
      "id": "alert_005",
      "type": "emergency",
      "severity": "high",
      "title": "VIP Movement - Road Closures",
      "description": "Temporary road closures on Tank Bund Road due to VIP movement. Diversions in place.",
      "location": {
        "area": "Tank Bund Road",
        "affected_routes": ["Secunderabad to Khairtabad"],
        "latitude": 17.4239,
        "longitude": 78.4738
      },
      "issued_at": "2026-01-20T14:00:00Z",
      "expires_at": "2026-01-20T18:00:00Z",
      "diversions": [
        "Use Inner Ring Road via Paradise Circle",
        "Take Somajiguda route"
      ],
      "status": "active",
      "icon": "warning",
      "color": "#F44336"
    }
  ]
}
```

---

## 🎉 Events (Upcoming Temple Events & Cultural Programs)

```json
{
  "events": [
    {
      "id": "event_001",
      "title": "Maha Shivaratri Celebrations",
      "description": "Grand Maha Shivaratri celebrations with special abhishekam, bhajans, and prasadam distribution.",
      "type": "religious",
      "temple_id": "temple_001",
      "temple_name": "Birla Mandir",
      "location": {
        "venue": "Birla Mandir, Khairtabad",
        "address": "Naubat Pahad, Khairtabad, Hyderabad",
        "latitude": 17.4066,
        "longitude": 78.4691
      },
      "date": {
        "start": "2026-02-26T18:00:00Z",
        "end": "2026-02-27T06:00:00Z"
      },
      "timings": {
        "abhishekam": "22:00 - 02:00",
        "maha_aarti": "03:00",
        "prasadam": "04:00 onwards"
      },
      "schedule": [
        {
          "time": "18:00",
          "activity": "Special Darshan Opens"
        },
        {
          "time": "20:00",
          "activity": "Evening Aarti & Bhajans"
        },
        {
          "time": "22:00",
          "activity": "Maha Abhishekam Begins"
        },
        {
          "time": "02:00",
          "activity": "Midnight Aarti"
        },
        {
          "time": "03:00",
          "activity": "Maha Aarti"
        },
        {
          "time": "04:00",
          "activity": "Prasadam Distribution"
        }
      ],
      "registration": {
        "required": true,
        "online": true,
        "phone": "+91 40 2323 2792",
        "deadline": "2026-02-24",
        "fee": "Free",
        "spots_available": 5000
      },
      "special_arrangements": [
        "24-hour darshan",
        "Free prasadam",
        "Live streaming",
        "Parking arrangements",
        "Medical camp"
      ],
      "expected_crowd": "Very High (50,000+ devotees)",
      "recommended_arrival": "Early evening or after midnight",
      "organizer": "Birla Mandir Trust",
      "contact": "+91 40 2323 2792",
      "images": [
        "https://example.com/shivaratri_2026.jpg"
      ],
      "status": "upcoming",
      "featured": true,
      "category": "festival",
      "tags": ["Shivaratri", "Festival", "Overnight", "Free Prasadam"]
    },
    {
      "id": "event_002",
      "title": "Sri Rama Navami Utsavam",
      "description": "Nine-day celebration of Lord Rama's birth with daily kalyanam, aarti, and cultural programs.",
      "type": "religious",
      "temple_id": "temple_001",
      "temple_name": "Birla Mandir",
      "date": {
        "start": "2026-04-02T06:00:00Z",
        "end": "2026-04-10T21:00:00Z"
      },
      "daily_schedule": {
        "morning_aarti": "07:00",
        "sri_rama_kalyanam": "11:00",
        "evening_aarti": "19:00",
        "cultural_program": "20:00"
      },
      "special_events": [
        {
          "date": "2026-04-02",
          "event": "Utsavam Begins - Flag Hoisting"
        },
        {
          "date": "2026-04-06",
          "event": "Main Rama Navami Day - Grand Kalyanam"
        },
        {
          "date": "2026-04-10",
          "event": "Concluding Ceremony"
        }
      ],
      "registration": {
        "required": false,
        "sponsor_puja": true,
        "sponsorship_amount": "₹5000 onwards"
      },
      "expected_crowd": "High",
      "organizer": "Birla Mandir Trust",
      "status": "upcoming",
      "category": "festival",
      "tags": ["Rama Navami", "Festival", "9 Days", "Cultural Programs"]
    },
    {
      "id": "event_003",
      "title": "Hanuman Jayanti Special Puja",
      "description": "Special abhishekam and sundarkand recitation on Hanuman Jayanti.",
      "type": "religious",
      "temple_id": "temple_004",
      "temple_name": "Karmanghat Hanuman Temple",
      "date": {
        "start": "2026-04-23T05:00:00Z",
        "end": "2026-04-23T22:00:00Z"
      },
      "schedule": [
        {
          "time": "05:00",
          "activity": "Abhishekam"
        },
        {
          "time": "08:00",
          "activity": "Sundarkand Parayana"
        },
        {
          "time": "12:00",
          "activity": "Maha Aarti"
        },
        {
          "time": "18:00",
          "activity": "Evening Aarti & Prasadam"
        }
      ],
      "special_offerings": [
        "Laddu Prasadam",
        "Hanuman Chalisa booklets",
        "Sacred ash"
      ],
      "expected_crowd": "Very High (100,000+ devotees)",
      "parking": "Limited - Use public transport",
      "status": "upcoming",
      "category": "festival",
      "tags": ["Hanuman Jayanti", "Abhishekam", "Sundarkand"]
    },
    {
      "id": "event_004",
      "title": "Jagannath Rath Yatra 2026",
      "description": "Annual chariot festival procession from Jagannath Temple. Three chariots of Lord Jagannath, Balabhadra, and Subhadra.",
      "type": "procession",
      "temple_id": "temple_003",
      "temple_name": "Jagannath Temple",
      "date": {
        "start": "2026-07-05T16:00:00Z",
        "end": "2026-07-05T21:00:00Z"
      },
      "route": {
        "start_point": "Jagannath Temple, Banjara Hills",
        "route_map": "Road No. 12 → Road No. 1 → KBR Park Road → Back to Temple",
        "distance": "5 km",
        "duration": "4-5 hours"
      },
      "schedule": [
        {
          "time": "16:00",
          "activity": "Chariot Decoration Complete"
        },
        {
          "time": "17:00",
          "activity": "Procession Starts"
        },
        {
          "time": "19:00",
          "activity": "Street Performances & Cultural Programs"
        },
        {
          "time": "21:00",
          "activity": "Return to Temple & Maha Aarti"
        }
      },
      "attractions": [
        "Three giant chariots",
        "Odissi dance performances",
        "Free mahaprasad",
        "Bhajans and kirtans"
      ],
      "road_closures": [
        "Road No. 12 (15:00 - 22:00)",
        "Road No. 1 (16:00 - 21:00)"
      ],
      "volunteer_opportunities": true,
      "expected_crowd": "Very High (30,000+)",
      "status": "upcoming",
      "featured": true,
      "category": "festival",
      "tags": ["Rath Yatra", "Procession", "Cultural", "Mahaprasad"]
    },
    {
      "id": "event_005",
      "title": "Bonalu Festival 2026",
      "description": "Telangana's iconic Bonalu festival with special offerings, processions, and ghatam (oracle) ceremony.",
      "type": "cultural",
      "temple_id": "temple_005",
      "temple_name": "Shree Peddamma Temple",
      "date": {
        "start": "2026-07-20T00:00:00Z",
        "end": "2026-07-27T23:59:59Z"
      },
      "main_days": [
        {
          "date": "2026-07-20",
          "event": "Bonalu Begins - Golconda Fort"
        },
        {
          "date": "2026-07-27",
          "event": "Peddamma Temple Bonalu - Main Day"
        }
      ],
      "rituals": [
        "Bonam offering",
        "Ghatam (oracle ceremony)",
        "Rangam procession",
        "Folk dances (Potharaju dance)"
      ],
      "dress_code": "Traditional sarees for women",
      "special_arrangements": [
        "Bonam preparation area",
        "Free buttermilk distribution",
        "Cultural performances",
        "Extra parking"
      ],
      "expected_crowd": "Extremely High (200,000+ over week)",
      "status": "upcoming",
      "featured": true,
      "category": "festival",
      "tags": ["Bonalu", "Telangana Culture", "Procession", "Week-long"]
    },
    {
      "id": "event_006",
      "title": "Bhagavad Gita Discourse Series",
      "description": "30-day discourse on Bhagavad Gita by renowned scholar. Daily evening sessions with Q&A.",
      "type": "educational",
      "temple_id": "temple_001",
      "temple_name": "Birla Mandir",
      "date": {
        "start": "2026-02-01T18:00:00Z",
        "end": "2026-03-02T20:00:00Z"
      },
      "schedule": {
        "daily": "18:00 - 20:00",
        "language": "Hindi & English"
      },
      "speaker": {
        "name": "Swami Ramakrishnananda",
        "credentials": "Vedanta Scholar, Author"
      },
      "registration": {
        "required": true,
        "online": true,
        "fee": "Free",
        "book_provided": true
      },
      "seating": "Limited to 300 people per day",
      "live_stream": true,
      "status": "upcoming",
      "category": "spiritual",
      "tags": ["Gita", "Discourse", "Educational", "Free"]
    }
  ]
}
```

---

## 🏢 Businesses (Temple-Related Services)

### Categories: Priests, Pooja Items, Caterers, Travel, Accommodation

```json
{
  "businesses": [
    {
      "id": "business_001",
      "name": "Sri Venkateswara Purohit Services",
      "category": "priest_services",
      "subcategory": "Traditional Purohit",
      "description": "Experienced purohits for all types of Hindu rituals - Satyanarayan Puja, Griha Pravesh, Marriages, Namakaranam, etc.",
      "owner": {
        "name": "Pandit Ramesh Shastri",
        "qualification": "Sanskrit Graduate, 25+ years experience",
        "languages": ["Telugu", "Hindi", "Sanskrit", "Tamil"]
      },
      "location": {
        "address": "Behind Chilkur Balaji Temple, Hyderabad",
        "area": "Chilkur",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500075",
        "latitude": 17.344,
        "longitude": 78.353
      },
      "services": [
        {
          "name": "Satyanarayan Puja",
          "duration": "2-3 hours",
          "price": "₹3,500",
          "includes": ["Puja materials", "Prasadam preparation guidance"]
        },
        {
          "name": "Griha Pravesh",
          "duration": "3-4 hours",
          "price": "₹5,000",
          "includes": ["Complete puja setup", "Vastu consultation"]
        },
        {
          "name": "Marriage Ceremony",
          "duration": "Full day",
          "price": "₹15,000 onwards",
          "includes": ["Muhurtham consultation", "Complete ceremony"]
        },
        {
          "name": "Namakaranam",
          "duration": "1-2 hours",
          "price": "₹2,500"
        }
      ],
      "contact": {
        "phone": "+91 98765 43210",
        "whatsapp": "+91 98765 43210",
        "email": "rameshastri@gmail.com"
      },
      "timings": {
        "available": "Daily 6 AM - 8 PM",
        "advance_booking": "Recommended (2-3 days)"
      },
      "rating": 4.8,
      "total_reviews": 234,
      "verified": true,
      "featured": true,
      "badge": "Top Rated",
      "images": ["https://example.com/purohit_1.jpg"]
    },
    {
      "id": "business_002",
      "name": "Balaji Pooja Bhandar",
      "category": "pooja_items",
      "subcategory": "Pooja Supplies Store",
      "description": "Complete pooja items shop - Idols, flowers, camphor, incense, clothes, books, prasadam items.",
      "location": {
        "address": "Opposite Birla Mandir, Khairtabad, Hyderabad",
        "area": "Khairtabad",
        "city": "Hyderabad",
        "pincode": "500004",
        "latitude": 17.407,
        "longitude": 78.4695
      },
      "products": [
        {
          "category": "Idols & Photos",
          "items": ["Metal idols", "Marble idols", "Photo frames", "Paintings"],
          "price_range": "₹100 - ₹50,000"
        },
        {
          "category": "Daily Pooja Items",
          "items": [
            "Agarbatti",
            "Camphor",
            "Kumkum",
            "Turmeric",
            "Sacred thread"
          ],
          "price_range": "₹10 - ₹500"
        },
        {
          "category": "Special Occasion",
          "items": ["Kalash sets", "Aarti thali", "Puja cloth", "Bells"],
          "price_range": "₹200 - ₹5,000"
        },
        {
          "category": "Books & CDs",
          "items": ["Religious books", "Bhajan CDs", "Chalisa booklets"],
          "price_range": "₹50 - ₹1,000"
        }
      ],
      "contact": {
        "phone": "+91 40 2323 4567",
        "whatsapp": "+91 98490 12345"
      },
      "timings": {
        "weekday": "08:00 - 21:00",
        "sunday": "07:00 - 22:00"
      },
      "services": [
        "Home delivery",
        "Online ordering",
        "Bulk orders for events",
        "Gift wrapping"
      ],
      "payment_methods": ["Cash", "UPI", "Card", "Online"],
      "rating": 4.6,
      "total_reviews": 567,
      "verified": true,
      "images": ["https://example.com/pooja_store_1.jpg"]
    },
    {
      "id": "business_003",
      "name": "Annapurna Temple Caterers",
      "category": "catering",
      "subcategory": "Temple Events & Home Functions",
      "description": "Specialized in sattvic vegetarian catering for temple events, pujas, and religious functions.",
      "owner": {
        "name": "Mrs. Lakshmi Devi",
        "experience": "15 years"
      },
      "location": {
        "address": "Jubilee Hills, Hyderabad",
        "area": "Jubilee Hills",
        "city": "Hyderabad",
        "pincode": "500033"
      },
      "menu_options": [
        {
          "name": "Satyanarayan Puja Package",
          "serves": "50 people",
          "price": "₹15,000",
          "items": [
            "Chana dal payasam",
            "Panchamrutam",
            "Fruits",
            "Coconut",
            "Betel leaves & nuts"
          ]
        },
        {
          "name": "Full Meal Package",
          "serves": "100 people",
          "price": "₹35,000",
          "items": [
            "Rice",
            "Sambar",
            "Rasam",
            "3 Curries",
            "Curd rice",
            "Papad",
            "Pickle",
            "Payasam"
          ]
        },
        {
          "name": "Prasadam Package",
          "serves": "200 people",
          "price": "₹20,000",
          "items": ["Laddu", "Pulihora", "Sweet pongal"]
        }
      ],
      "specialties": [
        "Pure ghee preparations",
        "No onion/garlic",
        "Traditional recipes",
        "Hygienic preparation"
      ],
      "contact": {
        "phone": "+91 98765 11111",
        "whatsapp": "+91 98765 11111",
        "email": "annapurnacaterers@gmail.com"
      },
      "services": [
        "Free menu consultation",
        "Utensils provided",
        "Service staff available",
        "Delivery & setup"
      ],
      "advance_booking": "Minimum 5 days",
      "rating": 4.9,
      "total_reviews": 189,
      "verified": true,
      "featured": true,
      "badge": "Premium Service"
    },
    {
      "id": "business_004",
      "name": "Tirumala Travels & Tours",
      "category": "travel",
      "subcategory": "Temple Tour Packages",
      "description": "Specialized in temple tour packages - Tirumala, Srisailam, Bhadrachalam, Pancharama Kshetras.",
      "location": {
        "address": "Near Paradise Circle, Secunderabad",
        "area": "Secunderabad",
        "city": "Hyderabad",
        "pincode": "500003"
      },
      "tour_packages": [
        {
          "name": "Tirumala Darshan",
          "duration": "2 Days / 1 Night",
          "price": "₹4,500 per person",
          "includes": [
            "AC Bus travel",
            "One night accommodation",
            "Breakfast & dinner",
            "Darshan tickets",
            "Tour guide"
          ]
        },
        {
          "name": "Srisailam Weekend",
          "duration": "2 Days / 1 Night",
          "price": "₹3,500 per person",
          "includes": [
            "AC Bus travel",
            "Hotel stay",
            "Meals",
            "Darshan arrangement"
          ]
        },
        {
          "name": "Pancharama Kshetra Tour",
          "duration": "4 Days / 3 Nights",
          "price": "₹9,000 per person",
          "includes": [
            "All 5 temples",
            "AC Bus",
            "Hotels",
            "All meals",
            "Guide"
          ]
        },
        {
          "name": "Hyderabad Temple Tour (Local)",
          "duration": "1 Day",
          "price": "₹800 per person",
          "includes": [
            "AC Tempo Traveller",
            "5 major temples",
            "Lunch",
            "Guide"
          ],
          "temples_covered": [
            "Birla Mandir",
            "Chilkur Balaji",
            "Jagannath Temple",
            "Karmanghat Hanuman",
            "ISKCON"
          ]
        }
      ],
      "contact": {
        "phone": "+91 40 2770 1234",
        "whatsapp": "+91 98490 55555",
        "email": "tirumalatravels@gmail.com",
        "website": "https://tirumalatravels.com"
      },
      "services": [
        "Customized packages",
        "Group discounts",
        "Senior citizen special rates",
        "VIP darshan arrangements"
      ],
      "rating": 4.7,
      "total_reviews": 892,
      "verified": true
    },
    {
      "id": "business_005",
      "name": "Dharma Guest House",
      "category": "accommodation",
      "subcategory": "Budget Accommodation",
      "description": "Clean and affordable rooms near Chilkur Balaji Temple. Perfect for devotees.",
      "location": {
        "address": "Near Chilkur Balaji Temple, Hyderabad",
        "area": "Chilkur",
        "city": "Hyderabad",
        "pincode": "500075",
        "latitude": 17.3445,
        "longitude": 78.3535,
        "distance_to_temple": "500 meters walking"
      },
      "rooms": [
        {
          "type": "Standard Single",
          "price": "₹800 per night",
          "capacity": "2 persons",
          "amenities": ["AC", "TV", "Hot water", "Clean bathroom"]
        },
        {
          "type": "Standard Double",
          "price": "₹1,200 per night",
          "capacity": "4 persons",
          "amenities": ["AC", "TV", "Hot water", "Clean bathroom"]
        },
        {
          "type": "Dormitory",
          "price": "₹300 per bed",
          "capacity": "8 beds per room",
          "amenities": ["Fan", "Shared bathroom", "Lockers"]
        }
      ],
      "facilities": [
        "Free parking",
        "24/7 hot water",
        "Morning coffee/tea",
        "Pure veg meals available",
        "Early checkout for temple visit"
      ],
      "special_services": [
        "Wake-up call for early temple visit",
        "Taxi arrangement",
        "Pooja items available"
      ],
      "contact": {
        "phone": "+91 98765 22222",
        "whatsapp": "+91 98765 22222",
        "email": "dharmaguesthouse@gmail.com"
      },
      "timings": {
        "checkin": "12:00 PM",
        "checkout": "11:00 AM",
        "early_checkout": "Available for temple visits"
      },
      "policies": {
        "advance_booking": "Recommended on weekends",
        "cancellation": "Free cancellation 24 hours before",
        "payment": "Cash/UPI only"
      },
      "rating": 4.4,
      "total_reviews": 445,
      "verified": true
    },
    {
      "id": "business_006",
      "name": "Goddess Jewels",
      "category": "jewelry",
      "subcategory": "Temple Jewelry",
      "description": "Traditional temple jewelry for deity decoration and personal wear. Wholesale and retail.",
      "location": {
        "address": "Charminar, Old City, Hyderabad",
        "area": "Old City",
        "city": "Hyderabad",
        "pincode": "500002"
      },
      "products": [
        {
          "category": "Deity Jewelry",
          "items": [
            "Crowns (Kireedam)",
            "Necklaces (Haram)",
            "Waist belts",
            "Anklets",
            "Ornaments sets"
          ],
          "price_range": "₹500 - ₹50,000"
        },
        {
          "category": "Personal Temple Jewelry",
          "items": [
            "Long haram",
            "Chokers",
            "Earrings",
            "Bangles",
            "Maang tikka"
          ],
          "price_range": "₹1,000 - ₹25,000"
        }
      ],
      "materials": [
        "Gold-plated",
        "Silver",
        "Imitation",
        "Semi-precious stones"
      ],
      "contact": {
        "phone": "+91 40 2452 3456",
        "whatsapp": "+91 98490 77777"
      },
      "services": ["Custom design", "Bulk orders", "Repairs", "Home delivery"],
      "rating": 4.5,
      "total_reviews": 278,
      "verified": true
    },
    {
      "id": "business_007",
      "name": "Vedic Astrology Centre",
      "category": "astrology",
      "subcategory": "Astrology & Vastu",
      "description": "Experienced astrologers for horoscope reading, muhurtham fixing, and vastu consultation.",
      "location": {
        "address": "Beside Jagannath Temple, Banjara Hills",
        "area": "Banjara Hills",
        "city": "Hyderabad",
        "pincode": "500034"
      },
      "astrologers": [
        {
          "name": "Dr. K. Sharma",
          "expertise": ["Vedic Astrology", "Numerology"],
          "experience": "30 years",
          "languages": ["Telugu", "Hindi", "English"]
        }
      ],
      "services": [
        {
          "name": "Complete Horoscope Reading",
          "duration": "1 hour",
          "price": "₹2,000",
          "includes": ["Life predictions", "Career", "Marriage", "Health"]
        },
        {
          "name": "Muhurtham Fixing",
          "price": "₹1,500",
          "for": "Marriage, Griha Pravesh, Business opening"
        },
        {
          "name": "Vastu Consultation",
          "price": "₹3,000",
          "includes": ["Site visit", "Report", "Remedies"]
        },
        {
          "name": "Gemstone Recommendation",
          "price": "₹1,000"
        }
      ],
      "contact": {
        "phone": "+91 98765 88888",
        "whatsapp": "+91 98765 88888",
        "email": "vedicastro@gmail.com"
      },
      "timings": "10:00 AM - 7:00 PM (Appointment only)",
      "rating": 4.7,
      "total_reviews": 512,
      "verified": true
    },
    {
      "id": "business_008",
      "name": "Temple Photography Studios",
      "category": "photography",
      "subcategory": "Event Photography",
      "description": "Professional photography for temple events, weddings, and religious ceremonies.",
      "location": {
        "address": "Jubilee Hills, Hyderabad",
        "area": "Jubilee Hills",
        "city": "Hyderabad",
        "pincode": "500033"
      },
      "services": [
        {
          "name": "Temple Event Coverage",
          "price": "₹8,000 per day",
          "includes": [
            "8 hours coverage",
            "2 photographers",
            "300+ edited photos",
            "Online gallery"
          ]
        },
        {
          "name": "Wedding Photography",
          "price": "₹35,000 onwards",
          "includes": [
            "Full day coverage",
            "Candid & traditional",
            "Album",
            "Video highlight"
          ]
        },
        {
          "name": "Devotional Video Production",
          "price": "₹15,000 onwards",
          "includes": ["Filming", "Editing", "Background music", "HD quality"]
        }
      ],
      "portfolio": "https://templephotography.com/portfolio",
      "contact": {
        "phone": "+91 98490 99999",
        "whatsapp": "+91 98490 99999",
        "email": "templephoto@gmail.com"
      },
      "rating": 4.8,
      "total_reviews": 234,
      "verified": true,
      "featured": true
    }
  ]
}
```

---

## 📊 Summary Statistics

### Data Seeding Overview:

- **Temples**: 25 major temples (5 detailed + 20 more to add)
- **Alerts**: 5 active alerts (traffic, weather, events, maintenance, emergency)
- **Events**: 6 major events (festivals, cultural, educational)
- **Businesses**: 8 businesses (priests, shops, caterers, travel, accommodation, jewelry, astrology, photography)

### Categories Covered:

✅ Famous temples with complete details  
✅ Real-time city alerts  
✅ Upcoming festival events  
✅ Temple-related service businesses  
✅ Contact information & timings  
✅ Pricing & packages  
✅ Location coordinates (GPS)

---

## 🚀 Next Steps

1. **Import to Database**: Convert JSON to SQL/Supabase format
2. **Add Images**: Real photos for each entry
3. **Verify Details**: Cross-check phone numbers, timings
4. **Expand**: Add 20 more temples, 50 more businesses
5. **User Reviews**: Seed with sample reviews
6. **Update Regular**: Keep alerts and events current

---

**Status**: Ready for import | Format: JSON | City: Hyderabad, Telangana | Last Updated: January 20, 2026
