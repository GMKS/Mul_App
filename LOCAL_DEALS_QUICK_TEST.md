# 🧪 Local Deals - Quick Test Guide

## ⚡ Quick Test in 5 Minutes

### Step 1: Run App (30 seconds)

```bash
flutter run
```

### Step 2: Navigate to Add Deal (20 seconds)

**Option A:** Home Screen → Local Deals → Tap **[+]** icon
**Option B:** Home Screen → Local Deals → "See All" → Tap **[+]** icon (top right)

### Step 3: Fill Test Data (2 minutes)

Copy and paste these test values:

```
Deal Title: Test Deal - Fresh Fruits
Description: Get fresh seasonal fruits delivered
Business Name: Fresh Fruits Market
Category: Grocery (from dropdown)
Original Price: 400
Discounted Price: 200
Promo Code: FRUIT50
City: Hyderabad
State: Telangana
Area: Kompally
Expiry Date: (Select any future date)
```

### Step 4: Submit (10 seconds)

- Tap "Submit Deal"
- Wait for success message
- Tap back arrow

### Step 5: Verify (1 minute)

- Go back to Home Screen
- Scroll to Local Deals section
- **Your deal should appear!** 🎉

---

## ✅ What to Check

### Visual Verification:

- [ ] Deal card shows "Test Deal - Fresh Fruits"
- [ ] Shows "Fresh Fruits Market" business name
- [ ] Displays "50% OFF" badge
- [ ] Shows ₹400 crossed out, ₹200 highlighted
- [ ] Has "Grab Now" button
- [ ] Location shows "Kompally"

### Functional Verification:

- [ ] Tapping card shows more details
- [ ] "Grab Now" button works
- [ ] Deal appears in "All Deals" tab
- [ ] Deal appears in search results

---

## 🐛 Common Issues & Fixes

### Issue 1: "Please login to create deals"

**Fix:** User must be logged in

```
Solution: Login first, then add deal
```

### Issue 2: Deal doesn't appear

**Fix:** Pull to refresh

```
Solution: Swipe down on home screen to refresh
```

### Issue 3: Validation errors

**Fix:** Check all required fields

```
Solution: Fill all fields marked with *
```

---

## 📊 Database Check (Optional)

If you want to verify in database:

1. Go to Supabase Dashboard
2. Navigate to Table Editor
3. Select `local_deals` table
4. Find your test deal in the list

---

## 🎯 Expected Result

After submitting, you should see:

```
┌─────────────────────────────────┐
│ 🥬            [50% OFF]         │
│                                 │
│ Test Deal - Fresh Fruits        │
│ Fresh Fruits Market             │
│                                 │
│ ₹400  ₹200                      │
│                                 │
│ [Sponsored] [Featured]          │
│            [Grab Now]           │
│                                 │
│ 📍 Kompally  ⏰ 7d left         │
└─────────────────────────────────┘
```

---

## 🚀 Multiple User Test

To test real-time updates:

### Device 1:

1. Open app
2. Navigate to Local Deals

### Device 2:

1. Open app
2. Add a new deal
3. Submit

### Device 1:

1. Pull down to refresh
2. **New deal should appear!** ✨

---

## 📝 Sample Test Data Sets

### Test 1: Grocery Deal

```
Title: 50% Off Organic Vegetables
Business: Green Grocery
Category: Grocery
Original: 300
Sale: 150
City: Hyderabad
```

### Test 2: Food Deal

```
Title: Buy 1 Get 1 Pizza
Business: Pizza Corner
Category: Food
Original: 500
Sale: 250
City: Hyderabad
```

### Test 3: Health Deal

```
Title: Free Health Checkup
Business: City Clinic
Category: Health
Original: 1000
Sale: 0
City: Hyderabad
```

---

## ✅ Success Checklist

After testing, verify these work:

- [ ] Can open Add Deal screen from widget
- [ ] Can open Add Deal screen from full screen
- [ ] Form validation works (try submitting empty)
- [ ] Discount % calculates automatically
- [ ] Category dropdown shows emojis
- [ ] Date picker opens
- [ ] Submit button shows loading
- [ ] Success message appears
- [ ] Deal appears in home feed
- [ ] Deal appears in "See All" screen
- [ ] Can search for the deal
- [ ] Can filter by category
- [ ] Deal card shows all info correctly

---

## 🎉 Test Complete!

If all checks pass, the feature is working perfectly!

**Next:** Try adding multiple deals and see them all appear in real-time! 🚀
