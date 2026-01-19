# 🚀 Monetization Features - Quick Reference

## Quick Start

### 1. Access Subscription Plans

```dart
// Navigate to subscription plans screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubscriptionPlansScreen(currentBusiness: business),
  ),
);
```

### 2. Access Business Dashboard

```dart
// Navigate to business dashboard
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BusinessDashboardScreen(business: business),
  ),
);
```

### 3. Check Feature Access

```dart
// Check if a feature is unlocked
bool canUseVideos = BusinessMonetization.isFeatureUnlocked(
  business,
  'video_marketing',
);

// Get feature limit text
String limitText = BusinessMonetization.getFeatureLimitText(
  business,
  'videos',
);
// Returns: "3 videos", "Unlimited", or "Upgrade to unlock"
```

### 4. Toggle Featured Status

```dart
// Check if can toggle
bool canToggle = BusinessMonetization.canToggleFeatured(business);

// Toggle with validation
if (canToggle) {
  BusinessModel? updated = BusinessMonetization.toggleFeaturedStatus(
    business,
    true, // enable featured
  );

  if (updated != null) {
    // Success - use updated business
  } else {
    // Failed - show error
  }
}
```

### 5. Sort by Priority

```dart
// Sort businesses by priority score
List<BusinessModel> sortedBusinesses =
    BusinessMonetization.sortByPriority(allBusinesses);

// Highest priority appears first
```

---

## Subscription Plans

### Available Plans

| Plan        | Price     | Videos    | Offers    | Photos    | Featured  | Support  |
| ----------- | --------- | --------- | --------- | --------- | --------- | -------- |
| **Free**    | ₹0        | 0         | 1         | 5         | ❌        | Standard |
| **Basic**   | ₹499/mo   | 3         | 5         | 15        | 3 days/mo | Priority |
| **Premium** | ₹1,499/mo | Unlimited | Unlimited | Unlimited | Unlimited | Premium  |

### Annual Pricing (17% discount)

- Basic: ₹4,990/year (save ₹1,000)
- Premium: ₹14,990/year (save ₹3,000)

### Accessing Plans

```dart
SubscriptionPlan free = SubscriptionPlan.freePlan;
SubscriptionPlan basic = SubscriptionPlan.basicPlan;
SubscriptionPlan premium = SubscriptionPlan.premiumPlan;
```

---

## Priority Score

### Calculation Formula

```
Total Score (0-100) =
  Subscription (0-40) +
  Featured Status (0-30) +
  Engagement (0-20) +
  Verification (0-5) +
  Rating (0-5)
```

### Score Breakdown

1. **Subscription Plan**: 40 points max

   - Free: 0 points
   - Basic: 20 points
   - Premium: 40 points

2. **Featured Status**: 30 points max

   - Not featured: 0 points
   - Featured: 30 points
   - Top 3 featured: 35 points

3. **Engagement**: 20 points max

   - Based on views, clicks, reviews
   - Normalized to 0-20 scale

4. **Verification**: 5 points max

   - Verified badge: 5 points

5. **Rating**: 5 points max
   - Rating value (4.0-5.0 stars)

### Calculate Score

```dart
double score = business.calculatePriorityScore();
// Returns 0-100
```

---

## Featured Listing

### Eligibility

- ❌ Free tier: Cannot use
- ✅ Basic tier: 3 days per month
- ✅ Premium tier: Unlimited

### Toggle Featured

```dart
// In Business Dashboard
Switch(
  value: business.isFeatured,
  onChanged: canToggle ? (value) {
    final updated = BusinessMonetization.toggleFeaturedStatus(
      business,
      value,
    );
    // Handle result
  } : null,
)
```

### Visual Indicators

- Gold gradient badge with star icon
- "Featured" label
- Appears at top of search results
- Higher priority score

---

## Navigation Flow

```
Home Screen
  └─> Business Category Card
       └─> Business Feed Screen
            ├─> Videos Tab (with subscription limits)
            ├─> Offers Tab (with subscription limits)
            └─> Directory Tab (sorted by priority)
                 └─> Business Profile
                      └─> [Dashboard Button]
                           └─> Business Dashboard
                                ├─> View Current Plan
                                ├─> Toggle Featured
                                ├─> View Priority Score
                                ├─> Feature Limits
                                └─> [Upgrade Button]
                                     └─> Subscription Plans Screen
                                          ├─> Plan Comparison
                                          ├─> Monthly/Annual Toggle
                                          └─> Upgrade/Downgrade
```

---

## Common Scenarios

### Scenario 1: Free User Tries to Post Video

```dart
if (!BusinessMonetization.isFeatureUnlocked(business, 'video_marketing')) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Upgrade Required'),
      content: Text('Video marketing is available on Basic and Premium plans.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to subscription plans
          },
          child: Text('View Plans'),
        ),
      ],
    ),
  );
}
```

### Scenario 2: Basic User Toggles Featured

```dart
bool canToggle = BusinessMonetization.canToggleFeatured(business);
int daysRemaining = business.featuredDaysRemaining;

if (canToggle && daysRemaining > 0) {
  // Allow toggle
} else if (canToggle && daysRemaining == 0) {
  // Show "No days remaining" message
} else {
  // Show "Upgrade required" message
}
```

### Scenario 3: Display Business with Badges

```dart
Widget buildBusinessCard(BusinessModel business) {
  return Card(
    child: Column(
      children: [
        Text(business.name),

        // Show subscription badge
        if (business.subscriptionPlan?.tier != SubscriptionTier.free)
          Badge(
            label: Text(business.subscriptionPlan!.tierName),
            color: business.subscriptionPlan!.tier == SubscriptionTier.premium
                ? Colors.purple
                : Colors.blue,
          ),

        // Show featured badge
        if (business.isFeatured)
          Badge(label: Text('Featured'), color: Colors.amber),

        // Show priority score
        Text('Priority: ${business.priorityScore.toStringAsFixed(0)}'),
      ],
    ),
  );
}
```

---

## Testing Checklist

### Subscription Plans

- [ ] View all three plans (Free, Basic, Premium)
- [ ] Toggle between monthly and annual pricing
- [ ] View feature comparison table
- [ ] Simulate upgrade from Free to Basic
- [ ] Simulate upgrade from Basic to Premium
- [ ] Check current plan indicator
- [ ] Verify pricing calculations

### Featured Listing

- [ ] Toggle ON with Basic plan (should work if days remaining)
- [ ] Toggle OFF featured status
- [ ] Try toggle with Free plan (should show upgrade prompt)
- [ ] Check featured badge displays
- [ ] Verify featured businesses appear first
- [ ] Check days remaining counter

### Priority Score

- [ ] Verify score calculation is correct
- [ ] Check score updates when plan changes
- [ ] Check score updates when featured changes
- [ ] Verify sorting by priority works
- [ ] Check score breakdown in dashboard
- [ ] Verify progress indicator displays

### Dashboard

- [ ] Access dashboard from profile screen
- [ ] View current subscription plan
- [ ] Toggle featured status
- [ ] View priority score breakdown
- [ ] Check feature limits display
- [ ] Navigate to subscription plans
- [ ] View quick stats

---

## Key Classes & Methods

### BusinessModel

```dart
// Fields
subscriptionPlan: SubscriptionPlan?
subscriptionExpiryDate: DateTime?
isSubscriptionActive: bool
priorityScore: double
engagementScore: int
canToggleFeatured: bool
featuredDaysRemaining: int

// Methods
calculatePriorityScore() → double
get canSetFeatured → bool
get hasActiveSubscription → bool
get subscriptionDaysRemaining → int
copyWith(...) → BusinessModel
```

### SubscriptionPlan

```dart
// Static Plans
SubscriptionPlan.freePlan
SubscriptionPlan.basicPlan
SubscriptionPlan.premiumPlan

// Fields
tier: SubscriptionTier
price: double
features: SubscriptionFeatures
highlights: List<String>

// Methods
get tierName → String
get annualSavingsPercent → double?
```

### BusinessMonetization

```dart
// Static Methods
calculatePriorityScore(BusinessModel) → double
sortByPriority(List<BusinessModel>) → List<BusinessModel>
canToggleFeatured(BusinessModel) → bool
toggleFeaturedStatus(BusinessModel, bool) → BusinessModel?
getUpgradeRecommendation(BusinessModel) → SubscriptionPlan?
isFeatureUnlocked(BusinessModel, String) → bool
getFeatureLimitText(BusinessModel, String) → String
```

---

## Files Created/Modified

### New Files

1. `lib/screens/subscription_plans_screen.dart` - Subscription plans UI
2. `lib/screens/business_dashboard_screen.dart` - Business dashboard
3. `MONETIZATION_FEATURES.md` - Full implementation guide
4. `MONETIZATION_QUICK_REFERENCE.md` - This file

### Modified Files

1. `lib/models/business_model.dart` - Added monetization models & logic
2. `lib/screens/business_feed_screen.dart` - Priority sorting & badges
3. `lib/screens/business_profile_screen.dart` - Dashboard button

---

## Support & Troubleshooting

### Common Issues

**Q: Featured toggle not working?**
A: Check if business has active Basic or Premium subscription and featured days remaining.

**Q: Priority score seems wrong?**
A: Verify all score components are calculated correctly. Recalculate using `business.calculatePriorityScore()`.

**Q: Can't see subscription badge?**
A: Badge only shows for Basic and Premium tiers. Free tier has no badge.

**Q: Upgrade button not working?**
A: This is demo logic. Real implementation requires payment gateway integration.

---

## Next Steps

1. ✅ Monetization features implemented
2. ⏳ Integrate payment gateway (Razorpay/Stripe)
3. ⏳ Add backend API for plan management
4. ⏳ Implement analytics tracking
5. ⏳ Add email notifications for expiry
6. ⏳ Create admin panel for plan management

---

**Version**: 1.0.0  
**Last Updated**: January 19, 2026  
**Status**: Ready for Testing ✅
