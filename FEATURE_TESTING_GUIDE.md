# Feature Testing Guide

## Implemented Features

I've added the following location/region features to your app:

### 1. **City / Region Selection Screens** ✅

There are now TWO screens for selecting your region:

#### A) **RegionSelectionScreen** (Dropdown-based)

- Location: `lib/screens/region_selection_screen.dart`
- Used during initial onboarding
- Has dropdowns for selecting State and City
- Includes coordinates for 80+ major Indian cities
- Auto-detects your location on first load, but you can **always manually change it** using the dropdowns

#### B) **MapRegionSelectionScreen** (Map-based)

- Location: `lib/screens/map_region_selection_screen.dart`
- Can be accessed by tapping the city name in the HomeScreen AppBar
- Shows a Google Map with popular cities as options
- Saves both city name AND coordinates

### 2. **Save City + Latitude/Longitude Locally** ✅

The `RegionService` (`lib/services/region_service.dart`) now saves:

- Region (North/South/East/West/Central/Northeast)
- State
- City
- **Latitude**
- **Longitude**

All data is stored in `SharedPreferences` for persistent storage.

### 3. **App Always Knows Current City** ✅

The `HomeScreen` (`lib/screens/home_screen.dart`):

- Loads region data on startup in `initState()`
- Shows the selected city in the AppBar below "My City App"
- Displays a location icon 📍 next to the city name
- **Tapping the city name** opens the `MapRegionSelectionScreen` to change your region

### 4. **Manual Region Editing** ✅

The `RegionSelectionScreen` now:

- Shows dropdowns for State and City selection
- Allows you to change the auto-detected region
- Displays current selection with an edit icon
- Works during both initial setup and when changing regions later

---

## How to Test

### Test 1: Fresh Install (Complete Onboarding Flow)

1. **Uninstall the app** from your device:

   ```
   adb -s mbpzpr9teuojkrda uninstall com.example.regional_shorts_app
   ```

2. **Install and run** fresh:

   ```
   flutter run -d mbpzpr9teuojkrda
   ```

3. **Language Selection**:

   - You'll see the language selection screen first
   - Select your preferred language(s)
   - Click "Continue"

4. **Region Selection**:

   - The app will auto-detect your region
   - You'll see a banner showing "Current Selection: [City], [State]"
   - **Manually select different state/city** from the dropdowns if desired
   - Click "Get Started"

5. **Home Screen**:
   - Check the AppBar
   - You should see "My City App" as the title
   - **Below it**, you should see: 📍 [Your City Name]
   - Example: "📍 Hyderabad"

### Test 2: Change City from Home Screen

1. **On the Home Screen**, look at the AppBar
2. **Tap on the city name** (where it shows "📍 [City]")
3. This opens the `MapRegionSelectionScreen`
4. **Select a different city** from the popular cities list OR use the map
5. Click "Save and Continue"
6. **The AppBar should update** to show your new city

### Test 3: Verify Data Persistence

1. **Close the app** completely (swipe it away from recents)
2. **Reopen the app**
3. **Check if your selected city still appears** in the AppBar
   - If yes, data persistence is working ✅
   - If no, there's an issue with SharedPreferences

---

## Debug Logs

I've added debug logging to help trace the data flow:

- 💾 = Saving data to SharedPreferences
- 📖 = Loading data from SharedPreferences
- 🔍 = HomeScreen loading user data

To see these logs:

1. Run the app with: `flutter run -d mbpzpr9teuojkrda`
2. Watch the console output for these emoji markers
3. They'll show you exactly what's being saved and loaded

---

## Troubleshooting

### Issue: City not showing in AppBar

**Possible causes:**

1. `_currentUser` is null
2. `_currentUser.city` is empty string
3. The AppBar conditional check is failing

**Check:**

- Look for the debug logs starting with 🔍
- They will show you:
  - What region data was retrieved
  - What city value was loaded
  - Whether `_currentUser` was populated

### Issue: Dropdowns not visible

**Fixed:** Dropdowns are now ALWAYS visible on `RegionSelectionScreen`, regardless of auto-detection.

### Issue: Changes not saving

**Check:**

- Look for debug logs starting with 💾
- Verify that `RegionService.saveRegion()` is being called
- Check if SharedPreferences has permissions on your device

### Issue: Can't change city from HomeScreen

**How it should work:**

1. Tap on the city name in the AppBar (must be showing a city first)
2. This navigates to `MapRegionSelectionScreen`
3. Select a new city
4. Click "Save and Continue"
5. Returns to HomeScreen and calls `_loadUserData()` to refresh

---

## Key Files Modified

1. **lib/services/region_service.dart**

   - Added `_latitudeKey` and `_longitudeKey`
   - Updated `saveRegion()` to accept latitude/longitude
   - Updated `getStoredRegion()` to return coordinates
   - Added debug logging

2. **lib/screens/region_selection_screen.dart**

   - Complete reconstruction after corruption
   - Added 80+ city coordinates map
   - Fixed dropdown visibility (always visible now)
   - Save with coordinates when available

3. **lib/screens/map_region_selection_screen.dart**

   - Already had coordinate saving implemented
   - No changes needed

4. **lib/screens/home_screen.dart**
   - AppBar shows city with location icon
   - Tap city name opens region selection
   - `_loadUserData()` called on init
   - Added debug logging

---

## Next Steps

1. **Test the complete flow** as described above
2. **Check debug logs** in the console
3. If city is not showing in AppBar:
   - Share the debug logs (look for 🔍 📖 💾)
   - Take a screenshot of HomeScreen
4. If you can't change the region:
   - Describe exactly which step is not working
   - Share any error messages

---

## Expected Behavior

✅ **On first launch**: Auto-detect location → Show in dropdowns → User can edit → Save → Show in HomeScreen AppBar

✅ **On subsequent launches**: Load saved city → Show in HomeScreen AppBar

✅ **When changing city**: Tap city in AppBar → Select new city → Save → Update AppBar

✅ **Data persistence**: Close and reopen app → City still shows

✅ **Coordinates saved**: Both manual and map selection save lat/lng with city name
