# 🎯 Local Deals Admin Approval & Location System

## ✅ What's Been Implemented

### 1. **Admin Approval System**

All local deals now require admin approval before being visible to users.

#### Database Changes

- Added `approval_status` column: 'pending', 'approved', 'rejected'
- Added `approved_by` column: tracks which admin approved the deal
- Added `approved_at` column: timestamp of approval
- Added `rejection_reason` column: reason if rejected

#### Flow

1. User submits a deal → Status: **'pending'**
2. Deal is NOT visible to regular users
3. Admin reviews and approves → Status: **'approved'**
4. Deal becomes visible to all users
5. If rejected → Status: **'rejected'** (with reason)

#### RLS Policies

- **Regular users**: Can only see approved deals
- **Admins**: Can see all deals (pending, approved, rejected)
- **Users**: Can create deals (automatically pending)
- **Admins**: Can approve/reject deals

### 2. **Shop Location with Google Maps**

Users can now capture their shop's exact location when adding a deal.

#### Features

- 📍 **Pick on Map**: Interactive map picker to select exact shop location
- 📱 **Use Current Location**: One-tap to use device GPS location
- ✅ **Location Display**: Shows selected coordinates and address
- 🗺️ **Draggable Marker**: Users can fine-tune location by dragging marker
- 🎯 **Visual Confirmation**: Green badge shows when location is selected

#### Location Data Stored

- `latitude`: Shop latitude coordinate
- `longitude`: Shop longitude coordinate
- `business_address`: Optional address text

---

## 📋 Files Modified

### 1. Database Schema

**File**: `supabase/migrations/20260203_add_deal_approval.sql`

- Adds approval columns to `local_deals` table
- Creates indexes for faster queries
- Sets up RLS policies for approval system
- Creates `pending_deals_view` for admin dashboard
- Auto-triggers approval timestamp

### 2. Model Updates

**File**: `lib/models/local_deal_model.dart`

- Added `approvalStatus` field
- Added `approvedBy` field
- Added `approvedAt` field
- Added `rejectionReason` field
- Updated `fromJson` and `toJson` to include approval fields

### 3. Add Deal Screen

**File**: `lib/screens/deals/add_deal_screen.dart`

- Added Google Maps imports (`google_maps_flutter`, `geolocator`)
- Added location state variables (`_latitude`, `_longitude`, `_selectedAddress`)
- Added **Shop Location** section with:
  - "Pick on Map" button → Opens interactive map
  - "Use Current Location" button → Uses GPS
  - Visual location confirmation badge
- Added `_useCurrentLocation()` method
- Added `_pickLocationOnMap()` method
- Created `_MapPickerScreen` widget for map selection
- Updated deal submission to include:
  - `approvalStatus: 'pending'`
  - `latitude` and `longitude`
  - `businessAddress`
- Updated success message to mention admin approval

### 4. Service Layer

**File**: `lib/services/local_deals_service.dart`

- Updated `getActiveDeals()` to filter `approval_status = 'approved'`
- Updated `getFeaturedDeals()` to filter `approval_status = 'approved'`
- Updated `getSponsoredDeals()` to filter `approval_status = 'approved'`

---

## 🚀 Setup Instructions

### Step 1: Run Database Migration

```sql
-- In Supabase SQL Editor, run:
-- File: supabase/migrations/20260203_add_deal_approval.sql
-- This adds all approval columns and policies
```

### Step 2: Verify Packages

The following packages are already in `pubspec.yaml`:

- ✅ `google_maps_flutter: ^2.5.0`
- ✅ `geolocator: ^10.1.0`
- ✅ `geocoding: ^2.1.1`

### Step 3: Configure Google Maps API

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest ...>
    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

#### iOS (`ios/Runner/AppDelegate.swift`)

```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

### Step 4: Location Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to help you add your shop location to deals</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to help you add your shop location to deals</string>
```

### Step 5: Test the Flow

1. Open Add Deal screen
2. Fill in deal details
3. Scroll to "Shop Location" section
4. Tap "Pick on Map" or "Use Current Location"
5. Submit the deal
6. Check Supabase: Deal should have `approval_status = 'pending'`
7. Approve via admin panel or SQL
8. Deal becomes visible to users

---

## 🎨 UI Components Added

### Shop Location Card

```dart
Card(
  child: Column(
    children: [
      // Header with icon
      "Shop Location" title

      // Location status badge (when selected)
      Container with green badge showing:
      - ✓ Location Selected
      - Latitude/Longitude
      - Address

      // Action buttons
      Row(
        "Pick on Map" button
        "Use Current Location" button
      )
    ]
  )
)
```

### Map Picker Screen

- Full-screen Google Map
- Draggable marker
- "Confirm Location" button
- Current location display
- Info card at bottom

---

## 🔐 Admin Approval Process

### For Admins to Approve Deals

#### Option 1: Via SQL (Quick)

```sql
-- Approve a deal
UPDATE public.local_deals
SET
    approval_status = 'approved',
    approved_by = (SELECT id FROM auth.users WHERE email = 'admin@example.com'),
    approved_at = NOW()
WHERE id = 'DEAL_ID_HERE';

-- Reject a deal
UPDATE public.local_deals
SET
    approval_status = 'rejected',
    rejection_reason = 'Does not meet quality standards'
WHERE id = 'DEAL_ID_HERE';
```

#### Option 2: Via Admin Dashboard (Recommended)

Create an admin panel screen with:

- List of pending deals
- Preview of deal details
- "Approve" and "Reject" buttons
- Filter by status

Example query for admin dashboard:

```dart
Future<List<LocalDeal>> getPendingDeals() async {
  final response = await _supabase
      .from('local_deals')
      .select()
      .eq('approval_status', 'pending')
      .order('created_at', ascending: false);

  return (response as List)
      .map((json) => LocalDeal.fromJson(json))
      .toList();
}
```

---

## 📊 Database Views

### `pending_deals_view`

Pre-created view for admin dashboard showing:

- All pending deals
- Creator email
- Creator name
- Sorted by creation date (newest first)

```sql
SELECT * FROM pending_deals_view;
```

---

## 🧪 Testing Checklist

### Admin Approval Testing

- [ ] Submit a new deal
- [ ] Verify it has `approval_status = 'pending'` in database
- [ ] Verify deal is NOT visible in Local Deals widget
- [ ] Approve the deal via SQL or admin panel
- [ ] Verify deal becomes visible immediately
- [ ] Test rejection flow

### Location Testing

- [ ] Tap "Use Current Location" button
- [ ] Grant location permission
- [ ] Verify GPS coordinates are captured
- [ ] Tap "Pick on Map" button
- [ ] Verify map opens with current location
- [ ] Tap on map to change location
- [ ] Drag marker to fine-tune
- [ ] Tap "Confirm Location"
- [ ] Verify coordinates are saved
- [ ] Submit deal with location
- [ ] Check database: `latitude` and `longitude` should be populated

### Permission Testing

- [ ] Test when location permission is denied
- [ ] Test when location permission is permanently denied
- [ ] Verify proper error messages are shown
- [ ] Test on device without GPS
- [ ] Test on device with poor GPS signal

---

## 🎯 User Experience Flow

### User Submits Deal

1. Opens "Add Local Deal" screen
2. Fills in business name, category, prices, etc.
3. Scrolls to "Shop Location" section
4. Chooses location method:
   - **Pick on Map**: Opens interactive map, selects precise location
   - **Use Current**: Automatically uses device GPS
5. Sees green confirmation badge with coordinates
6. Fills remaining fields (expiry date, promo code, etc.)
7. Taps "Submit Deal"
8. Sees success message: "Deal submitted! It will be visible after admin approval."

### Admin Reviews Deal

1. Logs into admin panel
2. Sees list of pending deals
3. Reviews deal details (including location on map)
4. Approves or rejects with reason
5. Deal immediately becomes visible to users (if approved)

### User Sees Approved Deal

1. Opens Local Deals screen
2. Sees only approved, active deals
3. Can see deal location on map
4. Can get directions to shop
5. Can claim the deal

---

## 🔧 Troubleshooting

### Issue: Deals not showing after approval

**Solution**: Check RLS policies. Run this query:

```sql
-- Check if RLS is blocking
SELECT * FROM public.local_deals
WHERE approval_status = 'approved' AND is_active = true;
```

### Issue: Location permission denied

**Solution**:

1. Check manifest files have location permissions
2. User must grant permission when prompted
3. If permanently denied, guide user to Settings

### Issue: Map not loading

**Solution**:

1. Verify Google Maps API key is set
2. Check API key has Maps SDK for Android/iOS enabled
3. Check billing is enabled on Google Cloud Console

### Issue: GPS not accurate

**Solution**:

1. Use `LocationAccuracy.high` for better accuracy
2. Test outdoors with clear sky view
3. Allow a few seconds for GPS to lock

---

## 📈 Future Enhancements

### Phase 1 (Current) ✅

- [x] Admin approval system
- [x] Location capture with map picker
- [x] GPS current location
- [x] RLS policies

### Phase 2 (Next)

- [ ] Admin dashboard UI for approvals
- [ ] Email notifications for approval/rejection
- [ ] Bulk approval actions
- [ ] Deal location display on map in deal details
- [ ] Nearby deals based on user location
- [ ] Direction navigation to shop

### Phase 3 (Future)

- [ ] Auto-approval for trusted businesses
- [ ] Deal analytics (views, claims by location)
- [ ] Geofencing (show deals only within radius)
- [ ] Location-based push notifications
- [ ] Multiple shop locations per business

---

## 📝 Summary

### Key Changes

1. ✅ **Admin Approval**: All deals pending by default, require admin approval
2. ✅ **Location Capture**: Interactive map picker + GPS current location
3. ✅ **Database**: New approval columns and RLS policies
4. ✅ **Service Layer**: Filters to show only approved deals
5. ✅ **UI**: Beautiful location card with visual feedback

### Benefits

- **Quality Control**: Admins can review deals before publication
- **Location Accuracy**: Users can precisely mark their shop location
- **Better UX**: Visual map interface instead of typing coordinates
- **Security**: RLS policies ensure proper access control
- **Scalability**: Ready for admin dashboard integration

### Next Steps

1. Run the database migration
2. Configure Google Maps API keys
3. Test the approval flow
4. Test location capture
5. Build admin dashboard (optional)

---

## 🎉 Success!

Your Local Deals system now has:

- ✅ Full admin approval workflow
- ✅ Google Maps integration
- ✅ Location capture with visual feedback
- ✅ Proper security via RLS policies
- ✅ Real-time updates

Users can now submit quality deals with precise locations, and admins can ensure only appropriate deals are shown!
