# Google Maps API Setup Instructions

To complete the map-based region selection feature, you need to set up a Google Maps API key.

## Steps to Get Google Maps API Key:

### 1. Go to Google Cloud Console

- Visit: https://console.cloud.google.com/

### 2. Create or Select a Project

- Create a new project or select an existing one

### 3. Enable Required APIs

Enable the following APIs for your project:

- **Maps SDK for Android**
- **Maps SDK for iOS** (if targeting iOS)
- **Geocoding API**
- **Geolocation API**

To enable:

1. Go to "APIs & Services" > "Library"
2. Search for each API
3. Click "Enable"

### 4. Create API Key

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key

### 5. Restrict API Key (Recommended)

For security, restrict your API key:

1. Click on your API key in the Credentials page
2. Under "Application restrictions", select "Android apps"
3. Add your app's package name: `com.example.regional_shorts_app`
4. Add your SHA-1 certificate fingerprint (get it using: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)

### 6. Update AndroidManifest.xml

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in `android/app/src/main/AndroidManifest.xml` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### 7. For iOS (if needed)

Add your API key to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

## Testing the Map

After adding the API key:

1. Run `flutter clean`
2. Run `flutter pub get`
3. Run the app: `flutter run`

The map should now load properly in the region selection screen.

## Features Implemented:

### 1. Map-Based Region Selection

- Interactive Google Map for selecting location
- Automatic location detection using GPS
- Manual city selection from popular cities list
- Location details (city, state, region) displayed
- Tap anywhere on map to select that location

### 2. Cab Services Screen (Expandable Cards)

- Clean rectangular card design for each cab service
- Clickable cards that expand to show ride types
- Right arrow icon indicates expandable state
- Each service shows:
  - Service icon and name
  - Available ride types (Mini, Sedan, SUV, etc.)
  - "Open" button to launch the cab app
- Services: Ola, Uber, Rapido, BluSmart, Namma Yatri

### 3. Integration with Regional Widget

- Cab services automatically shown when Regional category selected
- Services scoped to user's selected city
- Seamless navigation between map selection and cab services

## Usage Flow:

1. User opens app
2. Clicks "Change" button to select region
3. Map screen opens with current location (or Bangalore default)
4. User can:
   - Tap anywhere on map to select location
   - Select from popular cities list
   - Use "Detect" button to auto-detect location
5. Click "Get Started" to save selection
6. Back on home screen, select "Regional" category
7. Cab services screen shows with all available services
8. Click any service to see ride types and launch app

## Notes:

- The app requires location permissions for auto-detection
- Without a valid Google Maps API key, the map will show a blank screen
- All other features (cab services expansion, location storage) work without the API key
