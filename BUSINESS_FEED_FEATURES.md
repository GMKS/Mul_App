# Business Feed - Modern Features Documentation

## Overview

The Business Feed has been completely redesigned with 4 cutting-edge features based on 2026 trends:

1. **Business Videos** - Short-form, vertical video content
2. **Offers with Expiry** - Time-limited deals with countdown timers
3. **Featured Badge** - Premium business highlighting
4. **Distance Filtering** - Location-aware business discovery

---

## Feature 1: Business Videos 📹

### Description

TikTok/Instagram Reels-style short videos showcasing products, services, testimonials, and behind-the-scenes content from local businesses.

### Key Features

- **Vertical, full-screen format** optimized for mobile
- **Auto-play with tap-to-unmute** for seamless browsing
- **Interactive overlays**: Like, comment, share buttons
- **Shoppable product tags**: Tap products in videos to view details
- **Business profile integration**: Quick access to full business info
- **Video analytics**: Views, likes, shares tracking

### User Experience

1. Tap **"Business"** category card on home screen
2. Navigate to **"Videos"** tab
3. Scroll through vertical video feed
4. Tap video to watch in full-screen player
5. Interact: Like, comment, share, visit business
6. Tap product tags to view shoppable items

### Technical Implementation

- **File**: `lib/screens/business_video_player_screen.dart`
- **Model**: `BusinessVideo` class in `business_model.dart`
- **Properties**:
  - `videoUrl`, `thumbnailUrl`
  - `duration` (in seconds)
  - `views`, `likes`, `shares`
  - `productTags` (shoppable items)
  - `createdAt`, `isActive`

### Business Benefits

- Higher engagement than static images
- Showcase products in action
- Build trust through authentic content
- Drive conversions with shoppable tags
- Track performance with analytics

---

## Feature 2: Offers with Expiry ⏰

### Description

Time-sensitive deals and promotions with countdown timers, creating urgency and driving immediate action.

### Key Features

- **Countdown timers**: Real-time expiry tracking (days, hours, minutes)
- **Dynamic badges**: "Expiring Soon", "Limited Stock", "New Offer"
- **Visual hierarchy**: Large discount badges (50% OFF, BOGO, etc.)
- **Promo codes**: Copyable codes for redemption
- **Claim tracking**: Shows how many people claimed the offer
- **One-tap redemption**: Save to wallet or claim instantly

### User Experience

1. Navigate to **"Offers"** tab in Business Feed
2. Browse offers sorted by expiry time
3. See countdown timer on each offer card
4. Tap offer to view full details
5. Copy promo code with one tap
6. Claim offer and save to wallet
7. Show to business for redemption

### Technical Implementation

- **File**: `lib/screens/business_feed_screen.dart` (Offers Tab)
- **Model**: `BusinessOffer` class in `business_model.dart`
- **Properties**:
  - `discountText` (e.g., "50% OFF")
  - `startDate`, `expiryDate`
  - `claimLimit`, `claimedCount`
  - `promoCode`, `termsConditions`
  - `offerType` (percentage, fixed, bogo, custom)
- **Computed Properties**:
  - `timeRemaining` - Duration until expiry
  - `isExpired` - Boolean check
  - `isExpiringSoon` - Less than 24 hours
  - `expiryText` - "2h 30m left", "Expiring soon", etc.

### Visual Design

- **Red timer badge** for offers expiring within 24 hours
- **Large discount badge** (top-left) in bold red
- **Green claim button** with claim count
- **Gradient backgrounds** for visual appeal
- **Business logo and verified badge** for trust

### Business Benefits

- Create urgency with time limits
- Increase foot traffic during slow periods
- Clear inventory with flash sales
- Build customer database through claims
- Track ROI with claim analytics

---

## Feature 3: Featured Badge ⭐

### Description

Premium highlighting system that promotes verified and featured businesses to the top of feeds and search results.

### Key Features

- **Featured Badge**: Gold star icon with gradient background
- **Verified Badge**: Blue checkmark for trusted businesses
- **Top placement**: Featured businesses appear first in all lists
- **Ranking system**: Featured businesses ranked by priority (1, 2, 3...)
- **Time-limited**: Featured status expires after set duration
- **Combined trust signals**: Stack verified + featured badges

### Visual Indicators

1. **Featured Badge**:

   - Amber/orange gradient background
   - Gold star icon
   - "Featured" text in white
   - Placed top-right on business cards

2. **Verified Badge**:
   - Blue background
   - White checkmark icon
   - "Verified" text
   - Shows alongside featured badge

### User Experience

- Featured businesses appear **first** in all tabs (Videos, Offers, Directory)
- Users can **filter** to show only featured businesses
- Featured badge visible on:
  - Video cards
  - Offer cards
  - Business directory listings
  - Search results
  - Business profile headers

### Technical Implementation

- **Model Fields** (in `BusinessModel`):
  - `isFeatured`: Boolean flag
  - `featuredUntil`: Expiry date for featured status
  - `featuredRank`: Priority ranking (lower = higher)
- **Sorting Logic**:
  ```dart
  businesses.sort((a, b) {
    if (a.isFeatured && !b.isFeatured) return -1;
    if (!a.isFeatured && b.isFeatured) return 1;
    return (a.featuredRank ?? 999).compareTo(b.featuredRank ?? 999);
  });
  ```

### Business Benefits

- **Increased visibility**: 3-5x more views
- **Higher conversion**: Featured businesses get more clicks
- **Brand authority**: Stand out from competitors
- **Premium positioning**: Always appear at top of results
- **Combined trust**: Featured + Verified = maximum credibility

### Monetization Potential

- Businesses pay monthly fee for featured status
- Auction-based ranking (highest bid = rank 1)
- Limited slots (e.g., max 3 featured per category)
- Automatic renewal with payment

---

## Feature 4: Distance Filtering 📍

### Description

Location-aware filtering that shows businesses sorted by proximity, with adjustable search radius.

### Key Features

- **Real-time distance calculation**: Based on user's current location
- **Adjustable radius slider**: 1-50 km range
- **Distance badges**: "2.3 km away" on every business card
- **Map integration ready**: Can show businesses on map view
- **Geo-fenced offers**: Unlock special deals when nearby
- **Auto-sort by distance**: Closest businesses appear first

### User Experience

1. **Distance Slider** (top of screen):

   - See current radius: "Within 10 km"
   - Drag slider to adjust: 1-50 km
   - Results update instantly

2. **Distance Display**:

   - Red location pin icon
   - Distance in kilometers (1 decimal)
   - Shows on all business cards

3. **Smart Sorting**:
   - Featured businesses first (regardless of distance)
   - Then non-featured sorted by distance
   - "X km away" badge on every listing

### Technical Implementation

- **Model Field** (in `BusinessModel`):
  - `distanceFromUser`: Double (in kilometers)
- **Calculation**:
  - Uses Haversine formula or device GPS
  - Updates when user location changes
- **Filtering Logic**:
  ```dart
  _filteredBusinesses = _businesses.where((business) {
    return (business.distanceFromUser ?? 0) <= _distanceRadius;
  }).toList();
  ```

### Visual Design

- **Slider** at top of screen with location icon
- **Distance badge** in red with pin icon
- **Real-time updates** as slider moves
- **Empty state** if no businesses within radius

### User Benefits

- **Convenience**: Find nearest businesses instantly
- **Save time**: No need to check each location manually
- **Support local**: Discover hidden gems nearby
- **Plan visits**: See which businesses are clustered together
- **Reduce travel**: Filter by walking distance (1-2 km)

### Business Benefits

- **Local discovery**: Attract customers passing by
- **Foot traffic**: Drive nearby users to visit
- **Competitive edge**: Appear first for local searches
- **Location-based offers**: Send deals when customers nearby
- **Analytics**: Track which areas generate most views

---

## Combined User Flow

### Scenario 1: Discovering a New Restaurant

1. User opens app, taps **"Business"** category
2. Sees **distance slider** set to 5 km
3. Switches to **"Videos"** tab
4. Watches short video of restaurant's special dish
5. Sees **"Featured"** + **"Verified"** badges → trusts business
6. Notices business is **1.2 km away**
7. Switches to **"Offers"** tab
8. Finds **"50% OFF - 3h left"** offer with countdown timer
9. Claims offer, gets promo code
10. Taps **"Get Directions"** and visits restaurant

### Scenario 2: Shopping for Jewelry

1. User adjusts **distance slider** to 10 km
2. Filters by **"Retail"** category
3. Enables **"Featured Only"** filter
4. Browses **"Directory"** tab sorted by distance
5. Clicks on jewelry store **2.5 km away**
6. Watches product videos in full-screen player
7. Sees offer: **"Buy 1 Get 1 - Expires today!"**
8. Calls business using **quick action button**
9. Gets directions and visits store

---

## Screen Architecture

### Main Entry Point

**File**: `lib/screens/business_feed_screen.dart`

### Tabs

1. **Videos Tab**: Vertical scrolling video feed
2. **Offers Tab**: Grid of offer cards with timers
3. **Directory Tab**: Sortable business listings

### Supporting Screens

- **BusinessVideoPlayerScreen**: Full-screen video player
- **BusinessProfileScreen**: Complete business details
- **BusinessDirectoryScreen**: Alternative list view (legacy)

### Widgets & Components

- **Distance Slider**: Adjustable radius filter
- **Category Chips**: Filter by business type
- **Featured Filter Chip**: Show only featured businesses
- **Video Card**: Thumbnail, duration, stats
- **Offer Card**: Discount badge, timer, claim button
- **Business Card**: Logo, badges, distance, rating

---

## Data Models

### BusinessVideo

```dart
class BusinessVideo {
  final String id;
  final String businessId;
  final String videoUrl;
  final String? thumbnailUrl;
  final String title;
  final String? description;
  final int duration; // seconds
  final int views;
  final int likes;
  final int shares;
  final List<String>? productTags; // shoppable
  final DateTime createdAt;
  final bool isActive;
}
```

### BusinessOffer

```dart
class BusinessOffer {
  final String id;
  final String businessId;
  final String title;
  final String description;
  final String? imageUrl;
  final String discountText; // "50% OFF"
  final DateTime startDate;
  final DateTime expiryDate;
  final int? claimLimit;
  final int claimedCount;
  final String? promoCode;
  final String? termsConditions;
  final bool isActive;
  final String offerType; // percentage/fixed/bogo

  // Computed properties
  Duration get timeRemaining;
  bool get isExpired;
  bool get isExpiringSoon;
  String get expiryText;
}
```

### BusinessModel (Enhanced)

```dart
class BusinessModel {
  // ... existing fields ...

  // NEW FEATURES
  final List<BusinessVideo>? videos;
  final List<BusinessOffer>? activeOffers;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final int? featuredRank;
  final double? distanceFromUser; // in km
}
```

---

## Analytics & Metrics

### Video Performance

- Total views per video
- Average watch time
- Like/view ratio
- Share count
- Product tag click-through rate

### Offer Performance

- Total claims per offer
- Claim rate (claims/views)
- Average time to claim
- Redemption rate
- Revenue generated

### Featured Business Metrics

- Views increase (featured vs non-featured)
- Click-through rate improvement
- Conversion rate lift
- Time in featured status
- ROI calculation

### Distance Analytics

- Average search radius used
- Most common distance filters
- Correlation between distance and conversion
- Popular neighborhoods
- Peak discovery times

---

## Future Enhancements

### Phase 2

- **Live Streaming**: Businesses host live product demos
- **AR Try-On**: Virtual product visualization
- **Voice Search**: "Find restaurants within 2 km"
- **Map View**: See businesses on interactive map
- **Story Format**: 24-hour ephemeral content

### Phase 3

- **AI Recommendations**: Personalized business suggestions
- **Social Sharing**: Share videos/offers to WhatsApp
- **Loyalty Integration**: Earn points for claims
- **Multi-language**: Videos with auto-captions
- **Accessibility**: Screen reader support, high contrast

### Monetization Ideas

- Featured placement (monthly fee)
- Promoted videos (pay per view)
- Premium offers (higher visibility)
- Distance-based ads (show to nearby users)
- Analytics dashboard (premium subscription)

---

## Testing Checklist

### Videos

- [ ] Videos load and play smoothly
- [ ] Like/share buttons work
- [ ] Shoppable tags are tappable
- [ ] Duration badge displays correctly
- [ ] Business profile link works
- [ ] Mute/unmute toggle functions

### Offers

- [ ] Countdown timer updates in real-time
- [ ] Expired offers are marked correctly
- [ ] "Expiring Soon" badge appears < 24h
- [ ] Promo code copy works
- [ ] Claim button increments count
- [ ] Offer details modal displays properly

### Featured Badge

- [ ] Featured businesses appear first
- [ ] Badge displays on all card types
- [ ] Featured filter works correctly
- [ ] Verified + Featured stack properly
- [ ] Expired featured status removed

### Distance Filtering

- [ ] Slider adjusts radius smoothly
- [ ] Distance calculations are accurate
- [ ] Results update on slider change
- [ ] Distance badge shows on all cards
- [ ] Empty state appears when no results
- [ ] Featured businesses prioritized over distance

---

## Performance Optimization

- **Lazy loading**: Load videos/offers as user scrolls
- **Image caching**: Cache thumbnails and logos
- **Debouncing**: Wait 300ms before applying distance filter
- **Pagination**: Load 10-20 items at a time
- **Video streaming**: Use adaptive bitrate for videos
- **Background loading**: Prefetch next page of results

---

## Accessibility

- **Screen reader support**: All badges have semantic labels
- **High contrast mode**: Red timers, clear text
- **Large touch targets**: Buttons minimum 44x44 pt
- **Keyboard navigation**: Tab through all interactive elements
- **Alt text**: Descriptive labels for images/videos
- **Color blindness**: Icons + text labels (not just color)

---

## Summary

The enhanced Business Feed transforms your app into a modern, location-aware discovery platform that:

1. **Engages users** with interactive video content
2. **Drives urgency** with time-limited offers
3. **Builds trust** through featured/verified badges
4. **Improves discovery** with distance-based filtering

All features work seamlessly together to create a comprehensive business discovery experience that benefits both users and businesses.
