/// Local Shop Service
/// Handles operations for hyperlocal marketplace

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/local_shop_model.dart';
import 'region_service.dart';

class LocalShopService {
  static final _supabase = Supabase.instance.client;

  /// Get shops by category and locality
  Future<List<LocalShop>> getShops({
    ShopCategory? category,
    String? locality,
    String? city,
    String? searchQuery,
    bool featuredOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    return LocalShopService.getShopsStatic(
      category: category,
      locality: locality,
      city: city,
      searchQuery: searchQuery,
      featuredOnly: featuredOnly,
      limit: limit,
      offset: offset,
    );
  }

  /// Static version - Get shops by category and locality
  static Future<List<LocalShop>> getShopsStatic({
    ShopCategory? category,
    String? locality,
    String? city,
    String? searchQuery,
    bool featuredOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // Get user's locality if not provided
      // NOTE: We'll fetch shops from ALL cities, not just user's city
      // This way users can see all approved businesses
      if (locality == null && city == null) {
        final regionData = await RegionService.getStoredRegion();
        locality = regionData['village'];
        city = regionData['city'];
      }

      // Fetch from both local_shops and approved businesses
      List<LocalShop> allShops = [];

      // 1. Get from local_shops table (without city filter for now)
      try {
        var query =
            _supabase.from('local_shops').select().eq('is_active', true);

        if (category != null && category != ShopCategory.all) {
          query = query.eq('category', category.value);
        }

        // Removed city filter - show all shops
        // if (city != null && city.isNotEmpty) {
        //   query = query.eq('city', city);
        // }

        if (featuredOnly) {
          query = query.eq('is_featured', true);
        }

        final response = await query
            .order('is_featured', ascending: false)
            .order('rating', ascending: false);

        allShops.addAll((response as List)
            .map((json) => LocalShop.fromJson(json))
            .toList());
      } catch (e) {
        print('⚠️ Error fetching from local_shops: $e');
      }

      // 2. Get from business_submissions table (approved submissions should also appear in Shop Local)
      try {
        var query = _supabase.from('business_submissions').select();
        query = query.eq('status', 'approved');

        // Removed city filter - show all approved businesses from all cities
        // if (city != null && city.isNotEmpty) {
        //   query = query.eq('city', city);
        // }

        final response = await query.order('submitted_at', ascending: false);

        print(
            '📦 DEBUG: Fetched ${(response as List).length} approved business submissions');

        // Convert business submissions to LocalShop
        for (final submission in (response as List)) {
          print(
              '📦 DEBUG: Processing submission - ${submission['name']} (${submission['category']})');
          allShops.add(LocalShop(
            id: submission['id'],
            name: submission['name'] ?? 'Unknown',
            description: submission['description'] ?? '',
            category: _parseCategoryFromString(submission['category']),
            logoUrl: null,
            address: submission['address'] ?? '',
            locality: submission['locality'] ?? '',
            city: submission['city'] ?? '',
            phone: submission['phone_number'] ?? '',
            whatsapp: submission['whatsapp_number'] ??
                submission['phone_number'] ??
                '',
            offer: submission['offer'] ?? '',
            rating: 4.0, // Default rating for new submissions
            reviewCount: 0,
            isVerified: submission['is_verified'] ?? false,
            isFeatured: submission['is_featured'] ?? false,
            isOpen: true,
            workingHours: {},
            tags: [],
            createdAt: submission['submitted_at'] != null
                ? DateTime.tryParse(submission['submitted_at']) ??
                    DateTime.now()
                : DateTime.now(),
          ));
        }
      } catch (e) {
        print('⚠️ Error fetching from business_submissions: $e');
      }

      // Remove duplicates and sort
      allShops = _removeDuplicateShops(allShops);
      print('📦 DEBUG: Total shops after dedup: ${allShops.length}');
      for (final shop in allShops) {
        print('📦 DEBUG: Shop in list - ${shop.name} (${shop.category})');
      }

      allShops.sort((a, b) {
        if (a.isFeatured != b.isFeatured) {
          return b.isFeatured ? 1 : -1;
        }
        return (b.rating ?? 0).compareTo(a.rating ?? 0);
      });

      // Apply limit and offset
      print(
          '📦 DEBUG: Returning ${allShops.skip(offset).take(limit).toList().length} shops to UI');
      return allShops.skip(offset).take(limit).toList();
    } catch (e) {
      print('❌ Error fetching shops: $e');
      return _getMockShops(category);
    }
  }

  /// Helper: Parse category from string
  static ShopCategory _parseCategoryFromString(String? categoryStr) {
    if (categoryStr == null || categoryStr.isEmpty) {
      return ShopCategory.all;
    }
    try {
      return ShopCategory.values.firstWhere(
        (e) => e.value.toLowerCase() == categoryStr.toLowerCase(),
        orElse: () => ShopCategory.all,
      );
    } catch (e) {
      return ShopCategory.all;
    }
  }

  /// Helper: Remove duplicate shops
  static List<LocalShop> _removeDuplicateShops(List<LocalShop> shops) {
    final seen = <String>{};
    return shops.where((shop) => seen.add(shop.id)).toList();
  }

  /// Get shop by ID
  static Future<LocalShop?> getShopById(String id) async {
    try {
      final response =
          await _supabase.from('local_shops').select().eq('id', id).single();

      return LocalShop.fromJson(response);
    } catch (e) {
      print('❌ Error fetching shop: $e');
      return null;
    }
  }

  /// Search shops
  static Future<List<LocalShop>> searchShops(String query) async {
    try {
      List<LocalShop> results = [];

      // Search in local_shops table
      try {
        final response = await _supabase
            .from('local_shops')
            .select()
            .eq('is_active', true)
            .or('name.ilike.%$query%,tags.cs.{$query}')
            .order('rating', ascending: false)
            .limit(20);

        results.addAll((response as List)
            .map((json) => LocalShop.fromJson(json))
            .toList());
      } catch (e) {
        print('⚠️ Error searching local_shops: $e');
      }

      // Search in business_submissions table
      try {
        final response = await _supabase
            .from('business_submissions')
            .select()
            .eq('status', 'approved')
            .or('name.ilike.%$query%,description.ilike.%$query%')
            .order('submitted_at', ascending: false)
            .limit(20);

        for (final submission in (response as List)) {
          results.add(LocalShop(
            id: submission['id'],
            name: submission['name'] ?? 'Unknown',
            description: submission['description'] ?? '',
            category: _parseCategoryFromString(submission['category']),
            logoUrl: null,
            address: submission['address'] ?? '',
            locality: submission['locality'] ?? '',
            city: submission['city'] ?? '',
            phone: submission['phone_number'] ?? '',
            whatsapp: submission['whatsapp_number'] ??
                submission['phone_number'] ??
                '',
            offer: submission['offer'] ?? '',
            rating: 4.0,
            reviewCount: 0,
            isVerified: submission['is_verified'] ?? false,
            isFeatured: submission['is_featured'] ?? false,
            isOpen: true,
            workingHours: {},
            tags: [],
            createdAt: submission['submitted_at'] != null
                ? DateTime.tryParse(submission['submitted_at']) ??
                    DateTime.now()
                : DateTime.now(),
          ));
        }
      } catch (e) {
        print('⚠️ Error searching business_submissions: $e');
      }

      // Remove duplicates
      results = _removeDuplicateShops(results);
      return results;
    } catch (e) {
      print('❌ Error searching shops: $e');
      return [];
    }
  }

  /// Get featured shops - static version
  static Future<List<LocalShop>> getFeaturedShopsStatic() async {
    return getShopsStatic(featuredOnly: true, limit: 10);
  }

  /// Get featured shops - instance version
  Future<List<LocalShop>> getFeaturedShops() async {
    return getFeaturedShopsStatic();
  }

  /// Get mock shops for testing
  static List<LocalShop> _getMockShops(ShopCategory? category) {
    final allShops = [
      LocalShop(
        id: 'shop_1',
        name: 'Fresh Mart Grocery',
        description:
            'Your neighborhood grocery store with fresh vegetables, fruits, and daily essentials.',
        category: ShopCategory.grocery,
        logoUrl: null,
        address: '123 Main Street, Ameerpet',
        locality: 'Ameerpet',
        city: 'Hyderabad',
        phone: '9876543210',
        whatsapp: '9876543210',
        offer: '10% off on first order',
        rating: 4.5,
        reviewCount: 245,
        isVerified: true,
        isFeatured: true,
        isOpen: true,
        workingHours: {
          'Mon-Sat': '7:00 AM - 10:00 PM',
          'Sun': '8:00 AM - 9:00 PM',
        },
        tags: ['grocery', 'vegetables', 'fruits', 'daily needs'],
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      LocalShop(
        id: 'shop_2',
        name: 'Royal Bakery',
        description:
            'Fresh baked goods, cakes, pastries, and bread. Custom cakes for all occasions.',
        category: ShopCategory.bakery,
        address: '45 Food Street, Kukatpally',
        locality: 'Kukatpally',
        city: 'Hyderabad',
        phone: '9876543211',
        whatsapp: '9876543211',
        offer: 'Free delivery above ₹300',
        rating: 4.7,
        reviewCount: 189,
        isVerified: true,
        isFeatured: true,
        isOpen: true,
        workingHours: {
          'Mon-Sun': '6:00 AM - 9:00 PM',
        },
        tags: ['bakery', 'cakes', 'pastries', 'bread'],
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      LocalShop(
        id: 'shop_3',
        name: 'HealthPlus Pharmacy',
        description:
            '24x7 pharmacy with all medicines. Home delivery available.',
        category: ShopCategory.pharmacy,
        address: '78 Health Avenue, Gachibowli',
        locality: 'Gachibowli',
        city: 'Hyderabad',
        phone: '9876543212',
        whatsapp: '9876543212',
        offer: '15% off on OTC medicines',
        rating: 4.8,
        reviewCount: 567,
        isVerified: true,
        isFeatured: true,
        isOpen: true,
        workingHours: {
          'Mon-Sun': 'Open 24 Hours',
        },
        tags: ['pharmacy', 'medicines', '24x7', 'delivery'],
        createdAt: DateTime.now().subtract(const Duration(days: 500)),
      ),
      LocalShop(
        id: 'shop_4',
        name: 'Quick Fix Services',
        description:
            'AC repair, plumbing, electrical work, and home maintenance services.',
        category: ShopCategory.services,
        address: '12 Service Lane, Madhapur',
        locality: 'Madhapur',
        city: 'Hyderabad',
        phone: '9876543213',
        whatsapp: '9876543213',
        offer: 'AC service at ₹299',
        rating: 4.4,
        reviewCount: 123,
        isVerified: true,
        isFeatured: false,
        isOpen: true,
        workingHours: {
          'Mon-Sat': '8:00 AM - 8:00 PM',
          'Sun': '9:00 AM - 5:00 PM',
        },
        tags: ['services', 'ac repair', 'plumbing', 'electrician'],
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
      ),
      LocalShop(
        id: 'shop_5',
        name: 'Spice Garden Restaurant',
        description:
            'Authentic South Indian cuisine. Dine-in, takeaway, and delivery.',
        category: ShopCategory.restaurant,
        address: '56 Food Court, Banjara Hills',
        locality: 'Banjara Hills',
        city: 'Hyderabad',
        phone: '9876543214',
        whatsapp: '9876543214',
        offer: '20% off on family meals',
        rating: 4.6,
        reviewCount: 890,
        isVerified: true,
        isFeatured: true,
        isOpen: true,
        workingHours: {
          'Mon-Sun': '11:00 AM - 11:00 PM',
        },
        tags: ['restaurant', 'south indian', 'biryani', 'dosa'],
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
      ),
      LocalShop(
        id: 'shop_6',
        name: 'Tech World Electronics',
        description: 'Mobile phones, accessories, repairs, and electronics.',
        category: ShopCategory.electronics,
        address: '89 Tech Park, Hitech City',
        locality: 'Hitech City',
        city: 'Hyderabad',
        phone: '9876543215',
        whatsapp: '9876543215',
        offer: 'Free screen guard on purchase',
        rating: 4.3,
        reviewCount: 234,
        isVerified: true,
        isFeatured: false,
        isOpen: true,
        workingHours: {
          'Mon-Sat': '10:00 AM - 9:00 PM',
          'Sun': '11:00 AM - 7:00 PM',
        },
        tags: ['electronics', 'mobile', 'repair', 'accessories'],
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
      LocalShop(
        id: 'shop_7',
        name: 'Style Studio Fashion',
        description: 'Latest fashion trends for men, women, and kids.',
        category: ShopCategory.fashion,
        address: '34 Fashion Street, Jubilee Hills',
        locality: 'Jubilee Hills',
        city: 'Hyderabad',
        phone: '9876543216',
        whatsapp: '9876543216',
        offer: 'Buy 2 Get 1 Free',
        rating: 4.5,
        reviewCount: 456,
        isVerified: true,
        isFeatured: true,
        isOpen: true,
        workingHours: {
          'Mon-Sun': '10:00 AM - 10:00 PM',
        },
        tags: ['fashion', 'clothes', 'ethnic', 'western'],
        createdAt: DateTime.now().subtract(const Duration(days: 250)),
      ),
      LocalShop(
        id: 'shop_8',
        name: 'Glow Beauty Salon',
        description:
            'Complete beauty services - haircut, facial, makeup, and spa.',
        category: ShopCategory.beauty,
        address: '67 Beauty Lane, Kondapur',
        locality: 'Kondapur',
        city: 'Hyderabad',
        phone: '9876543217',
        whatsapp: '9876543217',
        offer: '30% off on first visit',
        rating: 4.7,
        reviewCount: 345,
        isVerified: true,
        isFeatured: false,
        isOpen: true,
        workingHours: {
          'Mon-Sun': '9:00 AM - 9:00 PM',
        },
        tags: ['beauty', 'salon', 'haircut', 'spa'],
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
    ];

    if (category != null && category != ShopCategory.all) {
      return allShops.where((shop) => shop.category == category).toList();
    }
    return allShops;
  }
}
