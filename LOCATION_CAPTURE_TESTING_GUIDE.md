# Location Capture - Testing Guide

## 🧪 How to Test the Feature

### Prerequisites

- ✅ App compiled and running on Android or iOS device
- ✅ Device has GPS enabled
- ✅ Location permissions allowed for the app
- ✅ You're standing outdoors with clear sky (for best GPS signal)

---

## Test Case 1: Basic Location Capture

### Steps

1. **Open the app**
   - Launch Regional Shorts App
   - Tap Menu → Add Business (or "Add Business" button)

2. **Fill Business Details**

   ```
   Name: Test Sweet Shop
   Category: Retail
   Phone: 9876543210
   Address: Plot 123, Test Road
   City: Hyderabad
   ```

3. **Scroll to "Business Location" Section**
   - See orange card with "Capture Location" button

4. **Ensure GPS is On**
   - Go to phone Settings → Location → Turn ON
   - Come back to app

5. **Tap "Capture Location"**
   - Button should respond immediately
   - Loading dialog appears: "Capturing location..."

6. **Wait for Results (3-5 seconds)**
   - GPS should acquire signal
   - Address lookup should complete
   - Green success card appears

7. **Verify Results**
   - Should see:
     ```
     ✓ Location Captured
     Lat: 17.XXXXXX
     Lng: 78.XXXXXX
     Plot 123, Test Road, Hyderabad, XXXXX
     ```

8. **Check Data**
   - Latitude should be: 17.XXXXX (Hyderabad range)
   - Longitude should be: 78.XXXXX (Hyderabad range)
   - Address should match your location

### Expected Result

✅ Location captured successfully with valid coordinates

---

## Test Case 2: Update Location

### Steps

1. **Start from Test Case 1 Result**
   - Should already have location captured
   - See green success card

2. **Move to a Different Location**
   - Walk 50-100 meters away
   - Stand outdoors

3. **Tap "Update Location" Button**
   - Button changed text from "Capture" to "Update"
   - Loading dialog appears again

4. **Wait for New Coordinates (3-5 seconds)**

5. **Verify New Location**
   - Latitude should be different
   - Longitude should be different
   - Address should reflect new location

### Expected Result

✅ Location updated with new coordinates

---

## Test Case 3: Permission Handling

### For Android

1. **Revoke Permission**
   - Go to Settings → Apps → Regional Shorts App
   - Permissions → Location → Choose "Don't allow"
   - Come back to app

2. **Try to Capture Location**
   - Tap "Capture Location"
   - Should see: "Location permission is required"
   - Error snackbar appears

3. **Grant Permission**
   - Try again
   - Permission popup should appear
   - Tap "Allow" or "Allow While Using the App"

4. **Try Again**
   - Should now capture location successfully

### For iOS

1. **Check Permission Settings**
   - Settings → Apps → Regional Shorts App
   - Location → "While Using the App"

2. **Revoke Permission (Optional Test)**
   - Change to "Never"
   - Try to capture
   - Should show error

3. **Grant Permission**
   - Change back to "While Using the App"
   - Try to capture
   - Should work

### Expected Result

✅ Permission handling works correctly with appropriate error messages

---

## Test Case 4: Location Services Disabled

### Steps

1. **Disable Location Services**
   - Settings → Location → Turn OFF

2. **Try to Capture Location**
   - Tap "Capture Location"
   - Should see: "Location services are disabled"
   - Error message appears

3. **Enable Location Services**
   - Go back to Settings
   - Location → Turn ON
   - Come back to app

4. **Try Again**
   - Should now capture location successfully

### Expected Result

✅ App detects disabled location services and shows helpful error

---

## Test Case 5: GPS Timeout

### Steps

1. **Go Indoors (No GPS Signal)**
   - Stay inside building away from windows

2. **Try to Capture Location**
   - Tap "Capture Location"
   - Wait 30 seconds (app timeout)

3. **Observe Result**
   - Should show error after 30 seconds
   - Message about unable to determine location

4. **Go Outdoors**
   - Go outside with clear sky

5. **Try Again**
   - Should now succeed with location

### Expected Result

✅ App handles GPS timeout gracefully and suggests retry

---

## Test Case 6: Database Verification

### Steps

1. **Add Business with Location**
   - Complete Test Case 1
   - Tap "Submit Business"
   - Wait for success message

2. **Open Supabase Dashboard**
   - Go to your Supabase project
   - Click "Table Editor"
   - Select "businesses" table

3. **Find the Business**
   - Search for "Test Sweet Shop"
   - Or scroll to find it in the table

4. **Check Location Columns**
   - Click on the row
   - Verify:
     ```
     latitude: 17.XXXXXX
     longitude: 78.XXXXXX
     address: "Plot 123, Test Road, Hyderabad"
     city: "Hyderabad"
     ```

5. **Confirm All Values Saved**
   - Latitude should have 6 decimal places
   - Longitude should have 6 decimal places
   - Address should be non-null

### Expected Result

✅ Database contains accurate location data

---

## Test Case 7: Multiple Captures in Sequence

### Steps

1. **Capture Location 1**
   - Add Business 1: "Test Shop A"
   - Capture location at Location A
   - Submit

2. **Capture Location 2**
   - Add Business 2: "Test Shop B"
   - Move to Location B (at least 1 km away)
   - Capture location at Location B
   - Submit

3. **Capture Location 3**
   - Add Business 3: "Test Shop C"
   - Move to Location C (different area)
   - Capture location at Location C
   - Submit

4. **Verify in Database**
   - Check all 3 businesses have different coordinates
   - Each has correct address for its location

### Expected Result

✅ App handles multiple sequential captures without issues

---

## Test Case 8: Rapid Button Clicks

### Steps

1. **Try Rapid Taps**
   - Tap "Capture Location" button multiple times quickly
   - App should handle gracefully (not crash)

2. **Expected Behavior**
   - First tap initiates capture
   - Button should be disabled during capture
   - Subsequent taps should be ignored or queued

3. **Verify**
   - Only one location capture happens
   - No duplicate captures

### Expected Result

✅ App handles rapid clicks gracefully

---

## Test Case 9: Address Lookup Accuracy

### Steps

1. **Capture at Known Location**
   - E.g., Hyderabad Hi-Tech City
   - Capture location there

2. **Check Returned Address**
   - Should show:
     - Street name
     - Area/Locality name
     - City name
     - Postal code (if available)

3. **Verify Against Google Maps**
   - Open Google Maps
   - Search coordinates: (lat, lng)
   - Compare address

4. **Confirm Match**
   - Returned address should match Google Maps

### Expected Result

✅ Address lookup is accurate and matches Google Maps

---

## Test Case 10: Different Android Devices/Versions

### Steps

1. **Test on Android 9 or Earlier**
   - Install and run app
   - Test location capture
   - Verify works correctly

2. **Test on Android 10+**
   - Different permission handling
   - Verify location capture works
   - Test permission flows

3. **Document Results**
   - Note any device-specific issues
   - Record Android version tested

### Expected Result

✅ Works on multiple Android versions

---

## Performance Testing

### Metrics to Monitor

1. **Time to Capture**
   - Outdoors, clear sky: 3-5 seconds
   - Indoors or cloudy: 10-30 seconds
   - Timeout after 30 seconds

2. **Accuracy**
   - Decimal precision: 6 places (±0.1 meter)
   - Typical error: 10-20 meters

3. **Battery Impact**
   - GPS is active only during capture
   - Brief capture shouldn't drain battery significantly

---

## Error Scenarios to Test

| Scenario                | Expected Behavior                         |
| ----------------------- | ----------------------------------------- |
| GPS off                 | Show "Enable Location Services" error     |
| No permission           | Show permission request dialog            |
| Permission denied       | Show "Permission required" error          |
| Permission revoked      | Show "Permission required" error          |
| GPS timeout             | Show "Could not determine location" error |
| No GPS signal (indoors) | Timeout after 30 seconds                  |
| Poor GPS signal         | Longer wait time (10-30s)                 |
| Address lookup fails    | Show coordinates anyway                   |
| Internet off            | Show offline error                        |

---

## Checklist for Complete Testing

- [ ] Location captures successfully outdoors
- [ ] Location updates work correctly
- [ ] Coordinates saved to Supabase database
- [ ] Latitude has 6 decimal places
- [ ] Longitude has 6 decimal places
- [ ] Address is non-null
- [ ] Android permissions handled correctly
- [ ] iOS permissions handled correctly
- [ ] GPS timeout works (30 seconds)
- [ ] Permission denied shows error
- [ ] Location services disabled shows error
- [ ] Multiple captures work in sequence
- [ ] No crashes on rapid clicks
- [ ] Address lookup matches Google Maps
- [ ] Works on Android 9+
- [ ] Works on iOS 12+

---

## Bug Reporting Template

If you find an issue:

```
**Issue Title**: [Brief description]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**:
[What should happen]

**Actual Result**:
[What actually happened]

**Device Info**:
- OS: Android/iOS
- Version: [e.g., Android 12]
- Device: [e.g., Samsung Galaxy S21]

**Error Message**:
[If any error appears]

**Screenshot**:
[If applicable]
```

---

## Summary

✅ **10 comprehensive test cases**  
✅ **Permission handling verified**  
✅ **Database storage confirmed**  
✅ **Error scenarios covered**  
✅ **Performance benchmarks**

**After testing all cases, the feature is ready for production!**

---

## Quick Test Checklist

**For Quick Verification** (5 minutes):

1. ✅ Open Add Business
2. ✅ Tap "Capture Location"
3. ✅ Wait for coordinates
4. ✅ See green success card
5. ✅ Submit Business
6. ✅ Check Supabase database
7. ✅ Verify lat/lng saved

**All good?** → Feature is working! 🎉
