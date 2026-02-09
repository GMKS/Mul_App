# Location Capture - UI/UX Reference

## What Users Will See

### Screen 1: Add Business Form

```
┌─────────────────────────────────────┐
│  Add Your Business                  │
└─────────────────────────────────────┘

Business Name:
[____________________________________]

Category:
[Retail              ▼]

Phone Number:
[+91 ________________]

Address:
[____________________________________]

City:
[Hyderabad          ▼]

[... more fields ...]

─────────────────────────────────────
📍 BUSINESS LOCATION

"Capture your business location so
 customers can easily find you on the map."

[Capture Location 📍]

─────────────────────────────────────

[Submit Business] [Cancel]
```

---

### Screen 2: When Capturing Location

```
┌─────────────────────────────────────┐
│                                     │
│         Capturing Location...       │
│                                     │
│      (circular progress wheel)      │
│                                     │
│                                     │
└─────────────────────────────────────┘

(Dialog shows for 3-5 seconds)
```

---

### Screen 3: After Location Captured

```
┌─────────────────────────────────────┐
│  Add Your Business                  │
└─────────────────────────────────────┘

[... previous fields ...]

─────────────────────────────────────
📍 BUSINESS LOCATION

"Capture your business location so
 customers can easily find you on the map."

┌─────────────────────────────────────┐
│  ✓ Location Captured                │
│                                     │
│  Lat: 17.368521                     │
│  Lng: 78.494632                     │
│                                     │
│  Shop 123, Banjara Hills,           │
│  Hyderabad 500034                   │
└─────────────────────────────────────┘

[Update Location 📍]

─────────────────────────────────────

[Submit Business] [Cancel]
```

---

## What Happens Step by Step

### Step 1: User Sees "Capture Location" Button

- Orange card with instructions
- Button shows "Capture Location" (with location icon)

### Step 2: User Taps Button

- Loading dialog appears
- Text: "Capturing location..."
- Circular progress indicator spinning

### Step 3: GPS Gets Coordinates

- Takes 3-5 seconds
- Phone uses GPS to find exact location

### Step 4: Address is Looked Up

- Coordinates (lat, lng) sent to Google
- Google returns full address

### Step 5: Results Displayed

```
✓ Location Captured        ← Green check mark
Lat: 17.368521            ← 6 decimal precision
Lng: 78.494632            ← High accuracy
Shop 123, Banjara Hills   ← Full address
Hyderabad 500034
```

### Step 6: User Can Update

- If location is wrong, can move and tap "Update Location"
- New coordinates will replace old ones

### Step 7: User Submits

- Taps "Submit Business"
- Location coordinates saved to Supabase database

---

## UI Components

### Orange Card (Business Location Section)

```
┌─────────────────────────────────────┐ ← Orange background
│ 📍 Business Location                │
│                                     │
│ Capture your business location so  │
│ customers can easily find you on   │
│ the map.                            │
│                                     │
│ [Capture Location 📍]              │ ← Button
└─────────────────────────────────────┘
```

### Green Success Card (After Capture)

```
┌─────────────────────────────────────┐ ← Green background
│ ✓ Location Captured                 │ ← Green checkmark
│                                     │
│ Lat: 17.368521                     │ ← Latitude
│ Lng: 78.494632                     │ ← Longitude
│                                     │
│ Shop 123, Banjara Hills,            │
│ Hyderabad 500034                    │ ← Full address
└─────────────────────────────────────┘
```

### Buttons

**Before Capture**:

```
┌────────────────────┐
│ 📍 Capture Location │  ← Orange button
└────────────────────┘
```

**After Capture**:

```
┌────────────────────┐
│ 📍 Update Location  │  ← Orange button (text changed)
└────────────────────┘
```

---

## Success Messages

### When Location Captured

```
┌────────────────────────────────────────┐
│ ✓ Location captured!                   │
│   (17.368521, 78.494632)               │
└────────────────────────────────────────┘
   (Green snackbar appears at bottom)
```

### When Updating Location

```
┌────────────────────────────────────────┐
│ ✓ Location updated!                    │
│   (17.369234, 78.495012)               │
└────────────────────────────────────────┘
   (Green snackbar appears at bottom)
```

---

## Error Messages

### Location Services Disabled

```
┌────────────────────────────────────────┐
│ ❌ Location services are disabled.     │
│    Please enable them.                 │
└────────────────────────────────────────┘
   (Red snackbar appears at bottom)
```

### Permission Denied

```
┌────────────────────────────────────────┐
│ ❌ Location permission is required to  │
│    capture location                    │
└────────────────────────────────────────┘
   (Red snackbar appears at bottom)
```

### Could Not Get Location

```
┌────────────────────────────────────────┐
│ ❌ Error capturing location:           │
│    [specific error message]            │
└────────────────────────────────────────┘
   (Red snackbar appears at bottom)
```

---

## User Flow Diagram

```
┌──────────────────┐
│  Open Add        │
│  Business        │
└────────┬─────────┘
         │
         ▼
┌──────────────────────┐
│ Fill Business Form   │
│ (Name, Phone, etc)   │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ Scroll to Location   │
│ Section (Orange)     │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ Tap "Capture        │
│ Location"            │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ Permission Dialog    │
│ "Allow Location?"    │
└────────┬─────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
 [Allow]   [Deny]
    │         │
    │         ▼
    │     ┌──────────────┐
    │     │ Error: Perm  │
    │     │ Denied       │
    │     └──────────────┘
    │
    ▼
┌──────────────────────┐
│ Loading Dialog       │
│ "Getting location..."│
│ (3-5 seconds)        │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ GPS Coordinates +    │
│ Address Fetched      │
└────────┬─────────────┘
         │
         ▼
┌──────────────────────┐
│ Display Results:     │
│ ✓ Location Captured  │
│ Lat: 17.368521       │
│ Lng: 78.494632       │
│ Address: ...         │
└────────┬─────────────┘
         │
    ┌────┴──────────────────┐
    │                       │
    ▼                       ▼
[Submit]              [Update Location]
    │                       │
    └───────────┬───────────┘
                │
                ▼
         ┌────────────────┐
         │ Save to        │
         │ Supabase       │
         │ (Complete!)    │
         └────────────────┘
```

---

## Real-World Example

### Scenario: Adding "Sweet Shop" at Banjara Hills

**User sees:**

1. Add Business form with all fields
2. Orange "Business Location" card
3. Button: "Capture Location"
4. User stands at Sweet Shop
5. Taps "Capture Location"
6. Dialog: "Capturing location..."
7. After 5 seconds, dialog closes
8. Green success box appears:
   ```
   ✓ Location Captured
   Lat: 17.368521
   Lng: 78.494632
   Plot 123, Banjara Hills, Hyderabad 500034
   ```
9. User taps "Submit Business"
10. Database saved with coordinates ✓

---

## Color Scheme

| Element                  | Color      | Hex Code |
| ------------------------ | ---------- | -------- |
| Location Card Background | Orange 50  | #FFF3E0  |
| Location Card Text       | Orange 700 | #F57C00  |
| Success Card Background  | Green 50   | #E8F5E9  |
| Success Card Text        | Green 700  | #388E3C  |
| Checkmark Icon           | Green      | #4CAF50  |
| Error Snackbar           | Red        | #F44336  |
| Button                   | Orange 700 | #F57C00  |
| Button Text              | White      | #FFFFFF  |

---

## Responsive Design

### Mobile (Portrait)

```
Full width form, stacked components
Button spans full width
Location card full width
```

### Tablet (Landscape)

```
Wider form with better spacing
Button remains full width or constrained
Location card centered with max-width
```

---

## Accessibility Features

- ✓ Text labels clearly identify location section
- ✓ Icon + text on button for clarity
- ✓ Checkmark indicates successful capture
- ✓ Clear error messages in plain English
- ✓ Loading indicator during capture
- ✓ Success/error snackbars for feedback

---

## Summary

Users will see a simple, intuitive flow:

1. Orange card with "Capture Location" button
2. Tap button
3. Wait 3-5 seconds for GPS
4. Green success card with coordinates & address
5. Tap Submit
6. Done! Location saved ✓

**Simple, fast, and user-friendly!** 📍
