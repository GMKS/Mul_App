# Quick Reference: Directions Feature Usage 🗺️

## For Users: How to Use

### 📱 Navigate to Any Local Business

#### From Local Deals Screen:

1. Open the app → Go to "Local Deals"
2. Find any deal card
3. Look for action buttons at the bottom:
   ```
   [🧭 Directions] [📞 Call] [📤 Share]
   ```
4. Tap **Directions** → Google Maps opens
5. See the business name and location
6. Start navigation!

#### From Local Shop Screen:

1. Open the app → Go to "Local Shops"
2. Find any shop card
3. Tap on the shop or look for action buttons
4. Tap **Directions** → Google Maps opens
5. Navigate to exact shop location

#### From Deal Details:

1. Tap on any deal to see full details
2. Scroll to the bottom
3. You'll see three prominent buttons:
   ```
   [Directions] [Call] [Share]
   ```
4. Tap **Directions** for instant navigation

---

## For Developers: Implementation Guide

### Quick Integration

#### 1. For Local Deals (Already Done ✅)

```dart
// In deal card widget
OutlinedButton.icon(
  onPressed: () => _openMaps(context, deal),
  icon: Icon(Icons.directions, color: Colors.blue[700]),
  label: const Text('Directions'),
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.blue[700],
    side: BorderSide(color: Colors.blue[300]!),
  ),
)
```

#### 2. For Business Contacts (Already Done ✅)

```dart
// Using the enhanced widget
BusinessContactButtons(
  phoneNumber: business.phone,
  whatsappNumber: business.whatsapp,
  businessName: business.name,
  businessAddress: business.address,
  latitude: business.latitude,
  longitude: business.longitude,
  city: business.city,
  showDirections: true, // Enable directions button
)
```

#### 3. Custom Implementation Template

```dart
Future<void> _openMaps(BuildContext context, YourBusinessModel business) async {
  String mapsUrl;

  // Priority 1: GPS Coordinates
  if (business.latitude != null && business.longitude != null) {
    final query = Uri.encodeComponent(business.name);
    mapsUrl = 'https://www.google.com/maps/dir/?api=1'
              '&destination=${business.latitude},${business.longitude}'
              '&destination_place_id=$query';
  }
  // Priority 2: Address
  else if (business.address != null && business.address!.isNotEmpty) {
    final query = Uri.encodeComponent(
        '${business.name}, ${business.address}, ${business.city}');
    mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
  }
  // Priority 3: Name + City
  else {
    final query = Uri.encodeComponent('${business.name}, ${business.city}');
    mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
  }

  final uri = Uri.parse(mapsUrl);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps. Please install Google Maps.'),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening maps: $e')),
      );
    }
  }
}
```

---

## Testing Scenarios

### ✅ Test Case 1: With GPS Coordinates

**Input:**

- Business Name: "Packing Material Shop"
- Latitude: 17.4903
- Longitude: 78.3924

**Expected Result:**

- Maps opens with exact pin at coordinates
- Business name appears as destination
- Directions can be started

### ✅ Test Case 2: With Address Only

**Input:**

- Business Name: "Sweet Shop"
- Address: "123 Main Street, Kompally"
- City: "Hyderabad"

**Expected Result:**

- Maps searches for "Sweet Shop, 123 Main Street, Kompally, Hyderabad"
- Most relevant result highlighted

### ✅ Test Case 3: Name + City Only

**Input:**

- Business Name: "Local Grocery"
- City: "Hyderabad"

**Expected Result:**

- Maps searches for "Local Grocery, Hyderabad"
- List of matching results shown

---

## UI/UX Guidelines

### Button Styling Standards

#### For Deal Cards (List View)

```dart
// Outlined buttons in a row
Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        icon: Icon(Icons.directions, size: 18, color: Colors.blue[700]),
        label: Text('Directions'),
        // ... styling
      ),
    ),
    SizedBox(width: 8),
    // ... more buttons
  ],
)
```

#### For Bottom Sheets (Details View)

```dart
// Elevated buttons (more prominent)
ElevatedButton.icon(
  icon: Icon(Icons.directions, size: 20),
  label: Text('Directions'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue[600],
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: 12),
  ),
)
```

#### For Compact Views

```dart
// Circular icon buttons
IconButton(
  icon: Icon(Icons.directions),
  color: Colors.blue[700],
  onPressed: () => _openMaps(),
)
```

---

## Color Scheme

| Action     | Color  | Hex     | Usage                   |
| ---------- | ------ | ------- | ----------------------- |
| Directions | Orange | #FF9800 | Navigation/maps related |
| Call       | Blue   | #2196F3 | Phone/calling actions   |
| WhatsApp   | Green  | #4CAF50 | Messaging actions       |
| Share      | Orange | #FF5722 | Social sharing          |

---

## Troubleshooting

### Common Issues & Solutions

#### 1. "Maps not opening"

**Solution:**

- Ensure `url_launcher` package is in `pubspec.yaml`
- Add Android permissions in `AndroidManifest.xml`:
  ```xml
  <queries>
    <intent>
      <action android:name="android.intent.action.VIEW" />
      <data android:scheme="geo" />
    </intent>
  </queries>
  ```

#### 2. "Wrong location shown"

**Solution:**

- Verify GPS coordinates in database are correct
- Check lat/lng are not swapped
- Ensure coordinates are in decimal degrees format

#### 3. "Business name not appearing"

**Solution:**

- Use `destination_place_id` parameter with business name
- Ensure business name is properly URI encoded
- Check Maps API version compatibility

---

## Best Practices

### ✅ Do's

- Always provide GPS coordinates when available
- Use `LaunchMode.externalApplication` for Maps
- Handle errors gracefully with user-friendly messages
- Check `context.mounted` before showing snackbars
- Encode special characters in URLs
- Test on both Android and iOS devices

### ❌ Don'ts

- Don't rely solely on business names for navigation
- Don't ignore null/empty location data
- Don't forget error handling
- Don't hardcode coordinates in code
- Don't skip user feedback (snackbars/toasts)

---

## Performance Tips

1. **Lazy Load:** Load maps data only when needed
2. **Cache:** Cache frequently accessed location data
3. **Async:** Always use async/await for URL launching
4. **Background:** Don't block UI while opening Maps
5. **Minimal Data:** Only pass essential location info

---

## Accessibility

### Ensuring Accessible Navigation

```dart
// Add semantic labels
Semantics(
  label: 'Get directions to ${business.name}',
  button: true,
  child: OutlinedButton.icon(
    icon: Icon(Icons.directions),
    label: Text('Directions'),
    onPressed: () => _openMaps(),
  ),
)
```

### Screen Reader Support

- Buttons announce: "Directions button. Get directions to [Business Name]"
- Icons have proper semantic labels
- Error messages are read aloud

---

## Analytics Tracking (Optional)

```dart
// Track when users use Directions
void _openMaps(BuildContext context, Business business) async {
  // Log analytics event
  await FirebaseAnalytics.instance.logEvent(
    name: 'directions_clicked',
    parameters: {
      'business_name': business.name,
      'business_id': business.id,
      'has_gps': business.latitude != null,
      'source_screen': 'local_deals',
    },
  );

  // Open maps
  // ... rest of implementation
}
```

---

## Quick Command Reference

### For Flutter Development

```bash
# Install url_launcher package
flutter pub add url_launcher

# Check for errors
flutter analyze

# Format code
flutter format lib/

# Run app
flutter run

# Hot reload
# Press 'r' in terminal

# Hot restart
# Press 'R' in terminal
```

---

## File Locations

### Core Implementation Files

```
lib/
├── screens/
│   └── local_deals_screen.dart        ← Deal cards + Directions
├── widgets/
│   ├── local_deals_widget.dart        ← Deal widget + Directions
│   └── business_contact_buttons.dart  ← Business Directions button
└── models/
    └── local_deal_model.dart          ← Deal data structure
```

### Documentation Files

```
DIRECTIONS_FEATURE_IMPLEMENTATION.md   ← Full technical docs
DIRECTIONS_QUICK_REFERENCE.md          ← This file (quick guide)
```

---

## Support

### Need Help?

1. Check this quick reference
2. Read full implementation docs
3. Review code comments
4. Test with sample data
5. Check Flutter/url_launcher docs

### Reporting Issues

Include:

- Device type (Android/iOS)
- Flutter version
- Error message
- Steps to reproduce
- Expected vs actual behavior

---

**Last Updated:** February 4, 2026  
**Feature Status:** ✅ Production Ready  
**Version:** 1.0.0

---

## Quick Checklist

Before deploying to production:

- [ ] Test on Android device
- [ ] Test on iOS device
- [ ] Verify GPS coordinates work
- [ ] Verify address fallback works
- [ ] Test with no location data
- [ ] Check error messages display correctly
- [ ] Verify business names appear in Maps
- [ ] Test with different maps apps
- [ ] Confirm button styling is consistent
- [ ] Validate accessibility features

---

**Happy Navigating! 🗺️✨**
