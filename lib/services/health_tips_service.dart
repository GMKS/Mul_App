/// Health Tips Service
/// Provides health tips, alerts, and personalized recommendations
/// Includes mock data for testing

import '../models/health_tips_model.dart';

class HealthTipsService {
  // Singleton pattern
  static final HealthTipsService _instance = HealthTipsService._internal();
  factory HealthTipsService() => _instance;
  HealthTipsService._internal();

  // Local state
  final Set<String> _savedTipIds = {};
  final Map<String, bool> _feedbackMap = {}; // tipId -> isHelpful

  // ==================== PUBLIC METHODS ====================

  /// Get all health tips with optional filters
  Future<List<HealthTip>> getTips({
    HealthCategory? category,
    String? city,
    AgeGroup? ageGroup,
    bool includeAlerts = true,
    int limit = 20,
    int offset = 0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var tips = _getMockTips();

    // Apply filters
    if (category != null) {
      tips = tips.where((t) => t.category == category).toList();
    }
    if (city != null) {
      tips = tips
          .where((t) =>
              t.city == null || t.city == city || t.cities.contains(city))
          .toList();
    }
    if (ageGroup != null) {
      tips = tips
          .where(
              (t) => t.targetAgeGroup == null || t.targetAgeGroup == ageGroup)
          .toList();
    }
    if (!includeAlerts) {
      tips = tips.where((t) => !t.isAlert).toList();
    }

    // Sort by priority and pinned status
    tips.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      if (a.isTipOfTheDay && !b.isTipOfTheDay) return -1;
      if (!a.isTipOfTheDay && b.isTipOfTheDay) return 1;
      return b.priority.level.compareTo(a.priority.level);
    });

    return tips.skip(offset).take(limit).toList();
  }

  /// Get tip of the day
  Future<HealthTip?> getTipOfTheDay() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final tips = _getMockTips();
    return tips.firstWhere(
      (t) => t.isTipOfTheDay,
      orElse: () => tips.first,
    );
  }

  /// Get active health alerts
  Future<List<HealthAlert>> getActiveAlerts({String? city}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockAlerts()
        .where((a) => a.city == null || a.city == city)
        .where(
            (a) => a.expiresAt == null || a.expiresAt!.isAfter(DateTime.now()))
        .toList();
  }

  /// Get tips by category
  Future<List<HealthTip>> getTipsByCategory(HealthCategory category) async {
    return getTips(category: category);
  }

  /// Search tips
  Future<List<HealthTip>> searchTips(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowerQuery = query.toLowerCase();
    return _getMockTips()
        .where((t) =>
            t.title.toLowerCase().contains(lowerQuery) ||
            t.shortDescription.toLowerCase().contains(lowerQuery) ||
            t.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Get personalized recommendations
  Future<List<HealthTip>> getRecommendations({
    AgeGroup? ageGroup,
    String? gender,
    List<HealthCategory>? preferredCategories,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var tips = _getMockTips();

    // Filter by preferences
    if (preferredCategories != null && preferredCategories.isNotEmpty) {
      tips =
          tips.where((t) => preferredCategories.contains(t.category)).toList();
    }
    if (ageGroup != null) {
      tips = tips
          .where(
              (t) => t.targetAgeGroup == null || t.targetAgeGroup == ageGroup)
          .toList();
    }
    if (gender != null) {
      tips = tips
          .where((t) => t.targetGender == null || t.targetGender == gender)
          .toList();
    }

    // Sort by trust score
    tips.sort((a, b) => b.trustScore.compareTo(a.trustScore));

    return tips.take(10).toList();
  }

  /// Get weather-based alerts
  Future<List<HealthTip>> getWeatherBasedTips({
    required double temperature,
    required int aqi,
    required String weatherCondition,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final tips = <HealthTip>[];

    // AQI-based tips
    if (aqi > 150) {
      tips.addAll(_getMockTips().where((t) =>
          t.alertTrigger == AlertTrigger.aqi ||
          t.tags.contains('air-quality') ||
          t.tags.contains('pollution')));
    }

    // Temperature-based tips
    if (temperature > 38) {
      tips.addAll(_getMockTips().where((t) =>
          t.tags.contains('heatwave') ||
          t.tags.contains('summer') ||
          t.category == HealthCategory.seasonal));
    } else if (temperature < 10) {
      tips.addAll(_getMockTips()
          .where((t) => t.tags.contains('cold') || t.tags.contains('winter')));
    }

    return tips.toSet().toList();
  }

  // ==================== USER ACTIONS ====================

  /// Save a tip
  Future<void> saveTip(String tipId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedTipIds.add(tipId);
  }

  /// Unsave a tip
  Future<void> unsaveTip(String tipId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _savedTipIds.remove(tipId);
  }

  /// Check if tip is saved
  bool isTipSaved(String tipId) => _savedTipIds.contains(tipId);

  /// Get saved tips
  Future<List<HealthTip>> getSavedTips() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockTips().where((t) => _savedTipIds.contains(t.id)).toList();
  }

  /// Submit feedback
  Future<void> submitFeedback(String tipId, bool isHelpful,
      {String? comment}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _feedbackMap[tipId] = isHelpful;
  }

  /// Get feedback for a tip
  bool? getFeedback(String tipId) => _feedbackMap[tipId];

  /// Record view
  Future<void> recordView(String tipId) async {
    // In real implementation, this would update the backend
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Record share
  Future<void> recordShare(String tipId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // ==================== PREFERENCES ====================

  /// Get user preferences
  Future<HealthPreferences?> getPreferences(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Return mock preferences
    return HealthPreferences(
      userId: userId,
      ageGroup: AgeGroup.youngAdult,
      preferredCategories: [HealthCategory.general, HealthCategory.fitness],
      dailyReminder: true,
      reminderTime: '08:00',
      emergencyAlerts: true,
      preferredLanguage: 'en',
      updatedAt: DateTime.now(),
    );
  }

  /// Update preferences
  Future<void> updatePreferences(HealthPreferences preferences) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, this would save to backend
  }

  // ==================== MOCK DATA ====================

  List<HealthTip> _getMockTips() {
    final now = DateTime.now();
    return [
      // Tip of the Day
      HealthTip(
        id: 'tip_1',
        title: 'Stay Hydrated This Summer',
        shortDescription:
            'Drink at least 8 glasses of water daily to stay healthy during hot weather.',
        fullContent: '''
## Why Hydration Matters

During summer, your body loses more water through sweat. Proper hydration helps:

- **Regulate body temperature**
- **Maintain energy levels**
- **Support kidney function**
- **Improve skin health**

### Tips for Better Hydration

1. Start your day with a glass of water
2. Carry a water bottle everywhere
3. Eat water-rich fruits (watermelon, cucumber)
4. Set reminders to drink water
5. Limit caffeine and alcohol

### Signs of Dehydration
- Dark yellow urine
- Dry mouth and lips
- Fatigue and dizziness
- Headaches

**Note:** This is for general awareness. Consult a doctor for personalized advice.
        ''',
        category: HealthCategory.seasonal,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=800',
        verificationSource: VerificationSource.doctorVerified,
        verifiedBy: 'Dr. Priya Sharma, MBBS',
        verifiedAt: now.subtract(const Duration(days: 2)),
        trustScore: 95,
        city: 'Hyderabad',
        tags: ['hydration', 'summer', 'water', 'heat'],
        priority: TipPriority.high,
        validFrom: now.subtract(const Duration(days: 30)),
        validTo: now.add(const Duration(days: 60)),
        isTipOfTheDay: true,
        isPinned: true,
        viewCount: 15234,
        saveCount: 2341,
        shareCount: 892,
        helpfulCount: 1823,
        notHelpfulCount: 45,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),

      // AQI Alert
      HealthTip(
        id: 'tip_2',
        title: '⚠️ AQI Alert: Wear Masks Outdoors',
        shortDescription:
            'Air quality is poor today. Take precautions when going outside.',
        fullContent: '''
## Current Air Quality Alert

The Air Quality Index (AQI) in your area has crossed 150, which is considered unhealthy.

### Recommended Actions

1. **Wear N95 masks** when going outside
2. **Avoid outdoor exercise** especially in the morning
3. **Keep windows closed** at home
4. **Use air purifiers** if available
5. **Stay hydrated** - pollution can cause dehydration

### Who Should Be Extra Careful?

- Children and elderly
- People with asthma or respiratory conditions
- Heart disease patients
- Pregnant women

### Indoor Tips
- Use wet mopping instead of dry sweeping
- Keep indoor plants that purify air
- Avoid smoking indoors

**This is an auto-generated alert based on local AQI data.**
        ''',
        category: HealthCategory.seasonal,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1569096651661-820d0de8b4ab?w=800',
        verificationSource: VerificationSource.govtHealth,
        verifiedBy: 'Telangana Health Department',
        trustScore: 98,
        city: 'Hyderabad',
        tags: ['aqi', 'pollution', 'masks', 'air-quality'],
        isAlert: true,
        alertTrigger: AlertTrigger.aqi,
        alertCondition: 'AQI > 150',
        priority: TipPriority.urgent,
        validFrom: now.subtract(const Duration(hours: 6)),
        validTo: now.add(const Duration(hours: 18)),
        isPinned: true,
        viewCount: 8567,
        saveCount: 567,
        shareCount: 1234,
        helpfulCount: 2456,
        notHelpfulCount: 23,
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now,
      ),

      // Mental Wellness
      HealthTip(
        id: 'tip_3',
        title: '5 Minutes of Mindfulness Daily',
        shortDescription:
            'Simple breathing exercises can reduce stress and improve mental clarity.',
        fullContent: '''
## The Power of 5-Minute Mindfulness

Taking just 5 minutes daily for mindfulness can significantly improve your mental health.

### Simple Breathing Exercise

1. **Sit comfortably** in a quiet place
2. **Close your eyes** and relax your shoulders
3. **Breathe in slowly** for 4 counts
4. **Hold** for 4 counts
5. **Exhale slowly** for 6 counts
6. **Repeat** 5-10 times

### Benefits

- Reduces anxiety and stress
- Improves focus and concentration
- Better sleep quality
- Lower blood pressure
- Enhanced emotional regulation

### Best Times to Practice

- Morning after waking up
- During lunch break
- Before important meetings
- Before bedtime

**Remember:** Mental health is as important as physical health. Seek professional help if needed.
        ''',
        category: HealthCategory.mentalWellness,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
        verificationSource: VerificationSource.doctorVerified,
        verifiedBy: 'Dr. Ananya Reddy, Psychiatrist',
        trustScore: 92,
        tags: [
          'mental-health',
          'mindfulness',
          'stress',
          'meditation',
          'breathing'
        ],
        priority: TipPriority.normal,
        validFrom: now.subtract(const Duration(days: 60)),
        viewCount: 12456,
        saveCount: 4567,
        shareCount: 2345,
        helpfulCount: 5678,
        notHelpfulCount: 89,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),

      // Women & Child Care
      HealthTip(
        id: 'tip_4',
        title: 'Essential Nutrients During Pregnancy',
        shortDescription:
            'Key vitamins and minerals every expecting mother needs.',
        fullContent: '''
## Nutrition Guide for Expecting Mothers

Proper nutrition during pregnancy is crucial for both mother and baby.

### Essential Nutrients

1. **Folic Acid (400-800 mcg/day)**
   - Prevents neural tube defects
   - Found in leafy greens, fortified cereals

2. **Iron (27 mg/day)**
   - Prevents anemia
   - Found in red meat, spinach, beans

3. **Calcium (1000 mg/day)**
   - Builds baby's bones
   - Found in dairy, fortified foods

4. **DHA Omega-3**
   - Brain development
   - Found in fish, walnuts

5. **Vitamin D**
   - Bone health
   - Sunlight exposure, supplements

### Foods to Avoid
- Raw or undercooked meat/fish
- Unpasteurized dairy
- Excessive caffeine
- Alcohol

**Always consult your gynecologist for personalized advice.**
        ''',
        category: HealthCategory.womenChild,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1493894473891-10fc1e5dbd22?w=800',
        verificationSource: VerificationSource.doctorVerified,
        verifiedBy: 'Dr. Lakshmi Devi, Gynecologist',
        trustScore: 96,
        targetGender: 'female',
        tags: ['pregnancy', 'nutrition', 'prenatal', 'women-health'],
        priority: TipPriority.normal,
        validFrom: now.subtract(const Duration(days: 90)),
        viewCount: 8934,
        saveCount: 3456,
        shareCount: 1567,
        helpfulCount: 4532,
        notHelpfulCount: 34,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),

      // Senior Care
      HealthTip(
        id: 'tip_5',
        title: 'Joint Health for Seniors',
        shortDescription:
            'Simple exercises and tips to maintain mobility and reduce joint pain.',
        fullContent: '''
## Maintaining Joint Health After 55

As we age, joint health becomes increasingly important for maintaining quality of life.

### Daily Exercises

1. **Gentle Walking** (20-30 mins)
2. **Chair Yoga** stretches
3. **Water Aerobics** (low impact)
4. **Range of motion** exercises

### Diet Tips

- Include **omega-3 fatty acids** (fish, walnuts)
- Eat **anti-inflammatory foods** (turmeric, ginger)
- Maintain **healthy weight**
- Stay **hydrated**

### Warning Signs to Watch

- Persistent joint pain
- Swelling or redness
- Difficulty moving
- Morning stiffness lasting > 30 mins

### Home Remedies

- Warm/cold compresses
- Epsom salt baths
- Gentle massage
- Turmeric milk

**Consult an orthopedic specialist for chronic pain.**
        ''',
        category: HealthCategory.seniorCare,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1447452001602-7090c7ab2db3?w=800',
        verificationSource: VerificationSource.doctorVerified,
        verifiedBy: 'Dr. Rajesh Kumar, Orthopedic',
        trustScore: 94,
        targetAgeGroup: AgeGroup.senior,
        tags: ['senior', 'joints', 'arthritis', 'mobility', 'exercise'],
        priority: TipPriority.normal,
        validFrom: now.subtract(const Duration(days: 45)),
        viewCount: 6789,
        saveCount: 2345,
        shareCount: 987,
        helpfulCount: 3456,
        notHelpfulCount: 56,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),

      // Fitness
      HealthTip(
        id: 'tip_6',
        title: '7-Minute Home Workout',
        shortDescription:
            'Quick and effective workout you can do anywhere, no equipment needed.',
        fullContent: '''
## The 7-Minute Scientific Workout

This high-intensity circuit training workout is backed by research and requires no equipment.

### The Routine (30 sec each, 10 sec rest)

1. **Jumping Jacks**
2. **Wall Sit**
3. **Push-ups**
4. **Crunches**
5. **Step-ups** (use a chair)
6. **Squats**
7. **Tricep Dips** (chair)
8. **Plank**
9. **High Knees**
10. **Lunges**
11. **Push-up with Rotation**
12. **Side Plank**

### Benefits

- Burns calories efficiently
- Improves cardiovascular health
- Builds muscle strength
- Boosts metabolism
- Can be done anywhere

### Tips

- Warm up before starting
- Stay hydrated
- Listen to your body
- Increase intensity gradually

**Disclaimer: Consult a doctor before starting any exercise program.**
        ''',
        category: HealthCategory.fitness,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
        verificationSource: VerificationSource.communityTested,
        trustScore: 88,
        tags: ['fitness', 'workout', 'home-exercise', 'hiit', 'no-equipment'],
        priority: TipPriority.normal,
        validFrom: now.subtract(const Duration(days: 30)),
        viewCount: 23456,
        saveCount: 8765,
        shareCount: 4321,
        helpfulCount: 9876,
        notHelpfulCount: 123,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),

      // Nutrition
      HealthTip(
        id: 'tip_7',
        title: 'Building a Balanced Plate',
        shortDescription:
            'Visual guide to creating nutritious meals with proper portions.',
        fullContent: '''
## The Balanced Plate Method

A simple way to ensure you're getting proper nutrition at every meal.

### Plate Division

- **50% Vegetables & Fruits**
  - Colorful variety
  - Raw or lightly cooked
  
- **25% Protein**
  - Lean meats, fish
  - Legumes, tofu
  - Eggs, dairy

- **25% Whole Grains**
  - Brown rice
  - Whole wheat roti
  - Millets

### Portion Tips

- Use smaller plates
- Fill vegetables first
- Eat slowly, chew well
- Stop when 80% full

### Healthy Additions

- Handful of nuts daily
- 2-3 servings of fruits
- 2L water minimum
- Limited processed foods

**This is general guidance. For specific dietary needs, consult a nutritionist.**
        ''',
        category: HealthCategory.nutrition,
        contentType: TipContentType.infographic,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
        verificationSource: VerificationSource.doctorVerified,
        verifiedBy: 'Dr. Sunitha Rao, Dietitian',
        trustScore: 93,
        tags: [
          'nutrition',
          'diet',
          'balanced-meal',
          'portions',
          'healthy-eating'
        ],
        priority: TipPriority.normal,
        validFrom: now.subtract(const Duration(days: 60)),
        viewCount: 18765,
        saveCount: 6543,
        shareCount: 3210,
        helpfulCount: 7654,
        notHelpfulCount: 87,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),

      // First Aid
      HealthTip(
        id: 'tip_8',
        title: 'First Aid for Burns',
        shortDescription:
            'Immediate steps to take when you or someone gets burned.',
        fullContent: '''
## Burn First Aid Guide

Quick action can minimize damage from burns. Here's what to do:

### For Minor Burns (1st Degree)

1. **Cool the burn** under cool (not cold) running water for 10-20 minutes
2. **Do NOT apply ice** or butter
3. **Cover** with sterile, non-stick bandage
4. **Take pain reliever** if needed
5. **Keep clean** and watch for infection

### For Serious Burns (2nd/3rd Degree)

1. **Call emergency services** immediately
2. **Do NOT remove** stuck clothing
3. **Cover loosely** with clean cloth
4. **Keep person warm** to prevent shock
5. **Do NOT apply** any creams or ointments

### Warning Signs - Seek Medical Help

- Burns larger than 3 inches
- Burns on face, hands, feet, groin
- Deep burns (white/charred skin)
- Signs of infection
- Difficulty breathing (inhalation burns)

**Emergency Numbers:**
- Ambulance: 108
- Fire: 101

**This is emergency guidance. Always seek professional medical care.**
        ''',
        category: HealthCategory.firstAid,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=800',
        verificationSource: VerificationSource.govtHealth,
        trustScore: 97,
        tags: ['first-aid', 'burns', 'emergency', 'safety'],
        priority: TipPriority.high,
        validFrom: now.subtract(const Duration(days: 120)),
        viewCount: 34567,
        saveCount: 12345,
        shareCount: 5678,
        helpfulCount: 15678,
        notHelpfulCount: 45,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),

      // Hygiene
      HealthTip(
        id: 'tip_9',
        title: 'Proper Hand Washing Technique',
        shortDescription:
            'WHO-recommended 20-second hand washing method to prevent infections.',
        fullContent: '''
## The 6-Step Hand Washing Technique

Proper hand washing can prevent 80% of common infections.

### Steps (20 seconds minimum)

1. **Wet hands** with clean water
2. **Apply soap** and lather
3. **Rub palms** together
4. **Interlace fingers** and rub
5. **Clean thumb** by rotating
6. **Rub fingertips** on palm
7. **Clean wrists**
8. **Rinse thoroughly**
9. **Dry with clean towel**

### When to Wash

- Before eating
- After using toilet
- After touching animals
- After coughing/sneezing
- Before/after caring for sick person
- After handling garbage

### Key Points

- Use soap, not just water
- Scrub for at least 20 seconds
- Don't forget under nails
- Use hand sanitizer (60% alcohol) when soap unavailable

**Simple habit, big impact on health!**
        ''',
        category: HealthCategory.hygiene,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1584515933487-779824d29309?w=800',
        verificationSource: VerificationSource.whoApproved,
        verifiedBy: 'World Health Organization',
        trustScore: 99,
        tags: ['hygiene', 'handwashing', 'infection-prevention', 'who'],
        priority: TipPriority.normal,
        validFrom: now.subtract(const Duration(days: 180)),
        viewCount: 45678,
        saveCount: 15678,
        shareCount: 8901,
        helpfulCount: 23456,
        notHelpfulCount: 34,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),

      // Sponsored Tip
      HealthTip(
        id: 'tip_10',
        title: 'Free Health Checkup Camp',
        shortDescription:
            'Apollo Hospitals organizing free health screening this weekend.',
        fullContent: '''
## Free Health Checkup Camp

**Apollo Hospitals** is organizing a comprehensive free health screening camp.

### Details

- **Date:** This Saturday & Sunday
- **Time:** 8 AM - 6 PM
- **Venue:** Apollo Hospitals, Jubilee Hills
- **Registration:** Walk-in or call 040-23456789

### Tests Included

- Blood pressure check
- Blood sugar (fasting)
- BMI calculation
- Vision screening
- Basic cardiac check
- Dental checkup

### Who Should Attend

- Adults above 30 years
- Those with family history of diabetes/heart disease
- Anyone who hasn't had a checkup in 1+ year

### What to Bring

- Aadhar card or ID proof
- Previous medical reports (if any)
- Empty stomach for blood tests

**Sponsored by Apollo Hospitals - Your Health Partner**
        ''',
        category: HealthCategory.general,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1551076805-e1869033e561?w=800',
        verificationSource: VerificationSource.doctorVerified,
        trustScore: 85,
        city: 'Hyderabad',
        tags: ['health-camp', 'free-checkup', 'screening', 'apollo'],
        priority: TipPriority.normal,
        validFrom: now.subtract(const Duration(days: 3)),
        validTo: now.add(const Duration(days: 4)),
        isSponsored: true,
        sponsorName: 'Apollo Hospitals',
        sponsorLogo: 'https://example.com/apollo-logo.png',
        viewCount: 5678,
        saveCount: 2345,
        shareCount: 1234,
        helpfulCount: 2567,
        notHelpfulCount: 123,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
      ),

      // Monsoon Health
      HealthTip(
        id: 'tip_11',
        title: 'Monsoon Health Precautions',
        shortDescription:
            'Protect yourself from waterborne diseases during rainy season.',
        fullContent: '''
## Stay Healthy During Monsoon

The rainy season brings relief from heat but also increases risk of infections.

### Common Monsoon Diseases

- Dengue & Malaria (mosquito-borne)
- Typhoid & Cholera (waterborne)
- Viral fever & cold
- Skin infections

### Prevention Tips

1. **Drink safe water** - Boil or filter
2. **Avoid street food** - Eat freshly cooked
3. **Use mosquito repellent** - Apply regularly
4. **Keep surroundings dry** - No stagnant water
5. **Wash vegetables** thoroughly
6. **Stay dry** - Change wet clothes immediately

### Boost Immunity

- Vitamin C rich foods
- Turmeric milk
- Ginger tea
- Seasonal fruits

### Warning Signs

- High fever > 3 days
- Severe headache
- Body rash
- Vomiting/diarrhea

**Seek immediate medical attention if symptoms persist.**
        ''',
        category: HealthCategory.seasonal,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=800',
        verificationSource: VerificationSource.govtHealth,
        verifiedBy: 'Municipal Health Department',
        trustScore: 94,
        tags: ['monsoon', 'rainy-season', 'dengue', 'waterborne', 'prevention'],
        priority: TipPriority.high,
        validFrom: now.subtract(const Duration(days: 15)),
        viewCount: 12345,
        saveCount: 4567,
        shareCount: 2345,
        helpfulCount: 5678,
        notHelpfulCount: 67,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),

      // Children's Health
      HealthTip(
        id: 'tip_12',
        title: 'Vaccination Schedule for Children',
        shortDescription:
            'Complete immunization guide for children from birth to 5 years.',
        fullContent: '''
## National Immunization Schedule

Vaccines protect children from serious diseases. Follow this schedule:

### Birth
- BCG (Tuberculosis)
- Hepatitis B (1st dose)
- OPV (0 dose)

### 6 Weeks
- DPT (1st dose)
- Hepatitis B (2nd dose)
- OPV (1st dose)
- Hib (1st dose)
- Rotavirus (1st dose)
- PCV (1st dose)

### 10 Weeks
- DPT (2nd dose)
- OPV (2nd dose)
- Hib (2nd dose)
- Rotavirus (2nd dose)
- PCV (2nd dose)

### 14 Weeks
- DPT (3rd dose)
- Hepatitis B (3rd dose)
- OPV (3rd dose)
- Hib (3rd dose)
- Rotavirus (3rd dose)
- PCV (3rd dose)

### 9-12 Months
- Measles/MR (1st dose)
- Vitamin A (1st dose)

### Keep Records
- Maintain vaccination card
- Set reminders for next dose
- Don't skip or delay vaccines

**Free vaccines available at government hospitals.**
        ''',
        category: HealthCategory.womenChild,
        contentType: TipContentType.text,
        imageUrl:
            'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=800',
        verificationSource: VerificationSource.govtHealth,
        verifiedBy: 'Ministry of Health',
        trustScore: 99,
        targetAgeGroup: AgeGroup.child,
        tags: ['vaccination', 'immunization', 'children', 'babies', 'schedule'],
        priority: TipPriority.high,
        validFrom: now.subtract(const Duration(days: 365)),
        viewCount: 67890,
        saveCount: 23456,
        shareCount: 12345,
        helpfulCount: 34567,
        notHelpfulCount: 89,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  List<HealthAlert> _getMockAlerts() {
    final now = DateTime.now();
    return [
      HealthAlert(
        id: 'alert_1',
        title: '⚠️ High AQI Alert',
        message:
            'AQI in Hyderabad has crossed 180. Wear masks outdoors and avoid strenuous activities.',
        trigger: AlertTrigger.aqi,
        priority: TipPriority.urgent,
        tipId: 'tip_2',
        city: 'Hyderabad',
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(hours: 12)),
      ),
      HealthAlert(
        id: 'alert_2',
        title: '🌡️ Heatwave Warning',
        message:
            'Temperature expected to reach 44°C. Stay hydrated and avoid outdoor activities between 11 AM - 4 PM.',
        trigger: AlertTrigger.weather,
        priority: TipPriority.high,
        tipId: 'tip_1',
        city: 'Hyderabad',
        createdAt: now.subtract(const Duration(hours: 6)),
        expiresAt: now.add(const Duration(days: 2)),
      ),
      HealthAlert(
        id: 'alert_3',
        title: '🦟 Dengue Alert',
        message:
            'Dengue cases rising in the city. Use mosquito repellent and eliminate stagnant water.',
        trigger: AlertTrigger.outbreak,
        priority: TipPriority.high,
        city: 'Hyderabad',
        createdAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 14)),
      ),
    ];
  }
}
