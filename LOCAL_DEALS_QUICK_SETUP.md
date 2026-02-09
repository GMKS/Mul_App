# 🚀 Quick Setup - Admin Approval & Location System

## ⚡ 3-Minute Setup

### Step 1: Run Database Migration (1 min)

Open your **Supabase SQL Editor** and run this file:

```
supabase/migrations/20260203_add_deal_approval.sql
```

This adds:

- ✅ `approval_status` column (pending/approved/rejected)
- ✅ Approval tracking columns
- ✅ RLS policies for security
- ✅ Admin view for pending deals

### Step 2: Add Google Maps API Key (1 min)

#### Android

Edit: `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

#### iOS

Edit: `ios/Runner/AppDelegate.swift`

Add at top:

```swift
import GoogleMaps
```

Add in `application` method:

```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

**Get API Key**: https://console.cloud.google.com/google/maps-apis
(Enable: Maps SDK for Android + Maps SDK for iOS)

### Step 3: Test It! (1 min)

1. Run your app
2. Go to Add Local Deal screen
3. Scroll to "Shop Location" section
4. Tap "Use Current Location" (grant permission)
5. Fill in deal details
6. Submit

**Result**:

- Deal saved with location ✅
- Status: "pending" (needs admin approval) ✅
- Not visible to users yet ✅

---

## 🔧 Approve Your First Deal

### Quick SQL Approval

```sql
-- See pending deals
SELECT id, title, business_name, created_at
FROM local_deals
WHERE approval_status = 'pending';

-- Approve a deal (replace DEAL_ID)
UPDATE local_deals
SET approval_status = 'approved', approved_at = NOW()
WHERE id = 'YOUR_DEAL_ID';
```

**Result**: Deal immediately visible to all users! 🎉

---

## ✅ What Works Now

### When User Adds Deal

- ✅ Can pick shop location on interactive map
- ✅ Can use GPS for instant location
- ✅ Sees visual confirmation with coordinates
- ✅ Deal submits with `approval_status = 'pending'`
- ✅ Gets message: "Deal submitted! It will be visible after admin approval"

### After Admin Approves

- ✅ Deal appears in Local Deals widget
- ✅ Deal appears in Local Deals screen
- ✅ Location data saved (latitude/longitude)
- ✅ Real-time update broadcasts to all users

### Security

- ✅ Regular users see only approved deals
- ✅ Admins can see all deals (pending/approved/rejected)
- ✅ RLS policies protect data

---

## 🧪 Quick Test

### Test Admin Approval Flow

```bash
1. Add a deal (it goes to pending)
2. Check database: approval_status = 'pending'
3. Check app: deal NOT visible
4. Run SQL approval (above)
5. Check app: deal IS visible now
```

### Test Location Capture

```bash
1. Open Add Deal screen
2. Tap "Use Current Location"
3. Grant location permission
4. See green badge with coordinates
5. Submit deal
6. Check database: latitude & longitude populated
```

---

## 🎯 Common Scenarios

### Scenario 1: Approve All Pending Deals

```sql
UPDATE local_deals
SET approval_status = 'approved', approved_at = NOW()
WHERE approval_status = 'pending';
```

### Scenario 2: Reject a Deal

```sql
UPDATE local_deals
SET
    approval_status = 'rejected',
    rejection_reason = 'Incomplete information'
WHERE id = 'DEAL_ID';
```

### Scenario 3: See Admin Dashboard Data

```sql
SELECT * FROM pending_deals_view;
```

---

## 🆘 Troubleshooting

### No Deals Showing?

Check: Are they approved?

```sql
SELECT approval_status, COUNT(*) FROM local_deals GROUP BY approval_status;
```

### Location Permission Denied?

- Android: Check AndroidManifest.xml has location permissions
- iOS: Check Info.plist has location usage strings
- Grant permission when app prompts

### Map Not Loading?

- Check Google Maps API key is set
- Enable Maps SDK in Google Cloud Console
- Enable billing (free tier available)

---

## 📚 Full Documentation

See [LOCAL_DEALS_APPROVAL_AND_LOCATION.md](LOCAL_DEALS_APPROVAL_AND_LOCATION.md) for:

- Complete implementation details
- Admin dashboard setup
- Advanced features
- Future enhancements

---

## 🎉 You're Done!

Your Local Deals now has:

- ✅ Admin approval system
- ✅ Google Maps location picker
- ✅ GPS current location
- ✅ Proper security

**Next**: Build an admin dashboard UI for approving deals!
