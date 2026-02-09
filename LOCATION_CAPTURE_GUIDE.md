# Location Capture Feature - Complete Guide

## Overview

Users can now capture their real-time GPS location when adding a business. This allows customers to easily find the business on a map.

---

## What's Been Added

### 1. **Packages & Dependencies**

- ✅ `geolocator: ^10.1.0` - For GPS location capture
- ✅ `geocoding: ^2.1.1` - For converting coordinates to addresses

Both are already in your `pubspec.yaml`.

### 2. **Android Permissions**

Location permissions already added to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

### 3. **iOS Permissions**

Location permissions added to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to help you add a business with accurate GPS coordinates...</string>
```

### 4. **Location Capture Method**

Updated `_captureLocation()` in `submit_business_screen_enhanced.dart` to:

- ✅ Check if location services are enabled
- ✅ Request location permissions from user
- ✅ Get current GPS coordinates (latitude & longitude)
- ✅ Reverse geocode to get human-readable address
- ✅ Store coordinates in database
- ✅ Display captured location on UI

---

## How to Use

### Step 1: Open Add Business Screen

- Navigate to: **Main Menu → Add Business**
- Or tap the **"Add Business"** floating action button

### Step 2: Fill in Business Details

- Name
- Category
- Phone
- Address
- City
- etc.

### Step 3: Scroll to "Business Location" Section

You'll see an orange card with:

- Description: "Capture your business location so customers can easily find you..."
- A button: **"Capture Location"** (or **"Update Location"** if already captured)

### Step 4: Tap "Capture Location"

1. A loading dialog will appear
2. Your phone will get the current GPS location
3. The app will show a confirmation with:
   - ✓ Location captured
   - Latitude (6 decimal places)
   - Longitude (6 decimal places)
   - Full address (auto-fetched from coordinates)

### Step 5: Review & Update (Optional)

- If the location is not accurate, you can:
  - Move to the exact spot and tap **"Update Location"** again
  - Or manually edit the address field

### Step 6: Submit Business

- Tap **"Submit"** button
- Location will be saved to Supabase with latitude & longitude

---

## What Happens Behind the Scenes

### Permission Flow

```
User taps "Capture Location"
    ↓
Check if location services enabled
    ↓
Check location permissions
    ↓
Request permission (if not granted)
    ↓
Get GPS coordinates (lat, lng)
    ↓
Reverse geocode (coords → address)
    ↓
Display on UI & save to state
```

### Accuracy

- **Accuracy Level**: `LocationAccuracy.best`
- **Time Limit**: 30 seconds to get location
- **Decimal Precision**: 6 decimal places (about 0.1 meter accuracy)

### Storage

Saved in `businesses` table in Supabase:

```
| Column    | Value Example       |
|-----------|---------------------|
| latitude  | 17.385044          |
| longitude | 78.486671          |
| address   | Shop 21, Main Road  |
| city      | Hyderabad          |
```

---

## Example Workflow

### Scenario: Adding "Sweet Shop" at Banjara Hills

1. **Open Add Business**
   - Name: "Sweet Shop"
   - Category: "Retail"
   - Phone: "9876543210"
   - Address: "Plot 123, Banjara Hills"
   - City: "Hyderabad"

2. **Scroll to Location Section**
   - See orange card with "Capture Location" button

3. **Stand at the Shop**
   - Make sure you're physically at the shop location
   - Ensure GPS is enabled on your phone

4. **Tap "Capture Location"**
   - Dialog: "Capturing location..."
   - After 3-5 seconds: Location confirmed

5. **See Results**

   ```
   ✓ Location Captured
   Lat: 17.368521
   Lng: 78.494632
   Shop 123, Banjara Hills, Hyderabad 500034
   ```

6. **Update if Needed**
   - Move a few meters away
   - Tap "Update Location" button
   - New coordinates will be captured

7. **Submit Business**
   - All data saved including coordinates
   - Users can now find Sweet Shop on the map!

---

## Common Issues & Solutions

### Issue 1: "Location services are disabled"

**Solution**:

- Go to phone Settings
- Enable Location services
- Come back to the app and try again

### Issue 2: "Location permission is required"

**Solution**:

- You'll see a popup asking permission
- Tap "Allow" or "Allow While Using App"
- Try capturing location again

### Issue 3: "Location permission is permanently denied"

**Solution**:

- Go to phone Settings → Apps → Regional Shorts App
- Find "Permissions" → "Location"
- Change from "Never" to "Allow While Using the App"
- Come back and try again

### Issue 4: "Could not determine location"

**Solution**:

- Make sure GPS is enabled on your phone
- Go outdoors (GPS works better with clear sky)
- Wait 30 seconds for phone to lock onto satellite
- Try capturing location again
- If still failing, manually enter coordinates (optional)

---

## Testing the Feature

### Test Case 1: Fresh Business with Location

1. Add new business with all details
2. Tap "Capture Location" while at a specific spot
3. Verify coordinates appear on UI
4. Submit business
5. Check Supabase → businesses table → verify latitude & longitude are saved

### Test Case 2: Update Location

1. Open existing business for editing (if edit feature available)
2. Tap "Update Location"
3. Move to a different spot
4. Verify new coordinates appear
5. Save changes

### Test Case 3: View on Map

(Future feature) When viewing a business:

1. Should show "Get Directions" button
2. Tapping it opens Google Maps
3. Shows the exact location where business was captured

---

## Database Fields

### Businesses Table

| Field     | Type   | Purpose                             |
| --------- | ------ | ----------------------------------- |
| latitude  | DOUBLE | Latitude coordinate (e.g., 17.385)  |
| longitude | DOUBLE | Longitude coordinate (e.g., 78.486) |
| address   | TEXT   | Full address (auto-fetched)         |
| city      | TEXT   | City name                           |

### Example Record

```sql
SELECT id, name, latitude, longitude, address, city
FROM businesses
WHERE name = 'Sweet Shop';

-- Result:
id: uuid-123
name: Sweet Shop
latitude: 17.368521
longitude: 78.494632
address: Shop 123, Banjara Hills, Hyderabad 500034
city: Hyderabad
```

---

## For Customers

When customers view a business with captured location:

✅ **See Exact Location** - Business pinpointed on map  
✅ **Get Directions** - One-tap directions to the shop  
✅ **Check Distance** - See how far the shop is from their location  
✅ **Save Location** - Can save address to contacts

---

## Technical Details

### Code Changes Made

**File**: `lib/screens/business/submit_business_screen_enhanced.dart`

**Imports Added**:

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
```

**Method**: `_captureLocation()`

- Handles all permission checks
- Gets GPS coordinates
- Reverse geocodes to address
- Updates UI with results
- Shows user-friendly error messages

**State Variables**:

```dart
double? _latitude;      // Captured latitude
double? _longitude;     // Captured longitude
String? _locationAddress;  // Human-readable address
```

**UI Section**: Lines 450-550

- Orange card showing location status
- "Capture Location" / "Update Location" button
- Displays: Latitude, Longitude, Address

---

## Next Steps

### Optional Enhancements

1. **Map Preview**
   - Show Google Map with captured location before submit
   - Allow user to drag pin to adjust location

2. **Autocomplete Address**
   - Use Google Places API for address suggestions
   - Sync address field with coordinates

3. **Distance Calculation**
   - Show users "X km away from your location"
   - Filter businesses by distance

4. **Favorite Locations**
   - Save frequently used business locations
   - Quick-fill when adding new business

---

## Summary

✅ Location capture is now fully functional  
✅ GPS coordinates saved to Supabase  
✅ Android & iOS permissions configured  
✅ User-friendly UI with error handling  
✅ Automatic address lookup from coordinates

**Users can now add businesses with exact GPS locations!**

Stand at your business → Tap "Capture Location" → Location is saved → Customers can find you! 📍
