// Mock data for devotional videos - used for testing
class DevotionalVideosMock {
  static const List<Map<String, dynamic>> videos = [
    {
      "id": "dv_001",
      "title": "Morning Aarti - Sri Rama Temple",
      "deity": "Lord Rama",
      "temple_name": "Sri Rama Temple",
      "video_url": "https://cdn.mylocalapp.com/devotional/ram_aarti.mp4",
      "thumbnail_url": "https://cdn.mylocalapp.com/thumbnails/ram.jpg",
      "language": "telugu",
      "festival_tags": ["ram_navami"],
      "location": {"lat": 17.536, "lng": 78.441},
      "distance_category": "0-100",
      "is_verified": true,
      "created_at": "2026-01-10"
    },
    {
      "id": "dv_002",
      "title": "Evening Bhajan - Hanuman Temple",
      "deity": "Lord Hanuman",
      "temple_name": "Hanuman Temple",
      "video_url": "https://cdn.mylocalapp.com/devotional/hanuman_bhajan.mp4",
      "thumbnail_url": "https://cdn.mylocalapp.com/thumbnails/hanuman.jpg",
      "language": "telugu",
      "festival_tags": ["hanuman_jayanti"],
      "location": {"lat": 17.540, "lng": 78.445},
      "distance_category": "0-100",
      "is_verified": true,
      "created_at": "2026-01-12"
    },
    {
      "id": "dv_003",
      "title": "Ganesha Pooja - Local Temple",
      "deity": "Lord Ganesha",
      "temple_name": "Vinayaka Temple",
      "video_url": "https://cdn.mylocalapp.com/devotional/ganesha_pooja.mp4",
      "thumbnail_url": "https://cdn.mylocalapp.com/thumbnails/ganesha.jpg",
      "language": "telugu",
      "festival_tags": ["ganesh_chaturthi"],
      "location": {"lat": 17.538, "lng": 78.442},
      "distance_category": "0-100",
      "is_verified": true,
      "created_at": "2026-01-15"
    },
  ];
}
