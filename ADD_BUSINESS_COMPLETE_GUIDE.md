# 🎯 Complete Guide: Add Local & Featured Business

## Step-by-Step: From Database to Multi-Language Display

This guide will help you add:

1. **1 Featured Business** (appears in carousel at top)
2. **1 Local Business** (appears in business directory)

Both will automatically display in **English**, **Hindi**, and **Telugu** based on user's language selection.

---

## 📋 STEP 1: Add Featured Business (5 minutes)

### Example: "Spice Garden Restaurant"

#### 1A: Add in Supabase Database

**Open Supabase → businesses table → Click "+ Insert row"**

Copy and paste these values into each column:

```
Column: name
Value: Spice Garden Restaurant

Column: name_te
Value: స్పైస్ గార్డెన్ రెస్టారెంట్

Column: name_hi
Value: स्पाइस गार्डन रेस्तरां

Column: offer
Value: 20% Off on All Orders Above ₹500

Column: offer_te
Value: ₹500 కంటే ఎక్కువ ఆర్డర్లపై 20% తగ్గింపు

Column: offer_hi
Value: ₹500 से अधिक के सभी ऑर्डर पर 20% छूट

Column: tagline
Value: Authentic South Indian Cuisine

Column: tagline_te
Value: నిజమైన దక్షిణ భారత వంటకాలు

Column: tagline_hi
Value: प्रामाणिक दक्षिण भारतीय व्यंजन

Column: description
Value: Family restaurant serving delicious dosas, idlis and traditional meals

Column: description_te
Value: రుచికరమైన దోసలు, ఇడ్లీలు మరియు సాంప్రదాయ భోజనాలను అందించే కుటుంబ రెస్టారెంట్

Column: description_hi
Value: स्वादिष्ट डोसा, इडली और पारंपरिक भोजन परोसने वाला पारिवारिक रेस्तरां

Column: cta_text
Value: Order Now

Column: cta_text_te
Value: ఇప్పుడు ఆర్డర్ చేయండి

Column: cta_text_hi
Value: अभी ऑर्डर करें

Column: category
Value: Restaurant

Column: city
Value: Hyderabad

Column: city_te
Value: హైదరాబాద్

Column: city_hi
Value: हैदराबाद

Column: address
Value: Shop 15, Jubilee Hills, Road No. 36

Column: phone
Value: 9876543210

Column: is_featured
Value: true

Column: is_approved
Value: true

Column: is_verified
Value: true

Column: is_ad
Value: false

Column: rating
Value: 4.5

Column: review_count
Value: 156
```

**Click "Save"**

---

## 📋 STEP 2: Add Local Business (5 minutes)

### Example: "Fresh Mart Grocery"

#### 2A: Add in Supabase Database

**Still in Supabase → businesses table → Click "+ Insert row" again**

Copy and paste these values:

```
Column: name
Value: Fresh Mart Grocery

Column: name_te
Value: ఫ్రెష్ మార్ట్ గ్రోసరీ

Column: name_hi
Value: फ्रेश मार्ट किराना

Column: offer
Value: Free Home Delivery on Orders Above ₹300

Column: offer_te
Value: ₹300 కంటే ఎక్కువ ఆర్డర్లపై ఉచిత హోం డెలివరీ

Column: offer_hi
Value: ₹300 से अधिक के ऑर्डर पर मुफ्त होम डिलीवरी

Column: tagline
Value: Fresh Fruits & Vegetables Daily

Column: tagline_te
Value: ప్రతిరోజు తాజా పండ్లు & కూరగాయలు

Column: tagline_hi
Value: प्रतिदिन ताजे फल और सब्जियां

Column: description
Value: Your neighborhood grocery store with fresh produce and daily essentials

Column: description_te
Value: తాజా ఉత్పత్తులు మరియు రోజువారీ అవసరాలతో మీ పొరుగు కిరాణా దుకాణం

Column: description_hi
Value: ताजा उत्पाद और दैनिक आवश्यकताओं वाली आपकी पड़ोस की किराना दुकान

Column: cta_text
Value: Shop Now

Column: cta_text_te
Value: ఇప్పుడు షాపింగ్ చేయండి

Column: cta_text_hi
Value: अभी खरीदें

Column: category
Value: Grocery

Column: city
Value: Hyderabad

Column: city_te
Value: హైదరాబాద్

Column: city_hi
Value: हैदराबाद

Column: address
Value: Shop 42, Banjara Hills Main Road

Column: phone
Value: 9123456789

Column: is_featured
Value: false

Column: is_approved
Value: true

Column: is_verified
Value: false

Column: is_ad
Value: false

Column: rating
Value: 4.2

Column: review_count
Value: 89
```

**Click "Save"**

---

## ✅ STEP 3: Verify in Database (1 minute)

1. Go to Supabase → Table Editor → businesses
2. You should see **2 new rows**:
   - **Spice Garden Restaurant** (is_featured = true)
   - **Fresh Mart Grocery** (is_featured = false)
3. Verify all `*_te` and `*_hi` columns have values

---

## 📱 STEP 4: Test in App (3 minutes)

### 4A: Restart Your App

- Close the app completely
- Reopen it

### 4B: Test Featured Business (English)

1. **Stay in English** (or set language to English in Settings)
2. **Scroll to top** of home screen
3. **Look for Featured Businesses carousel** (should have yellow/gold card)
4. **You should see:**

   ```
   💼 Featured Businesses         Explore

   ┌──────────────────────────────────┐
   │ 🍽️  [✓ Verified]                │
   │                                   │
   │ Spice Garden Restaurant          │
   │ 20% Off on All Orders Above ₹500 │
   │ 📍 Hyderabad              [Map]  │
   │                                   │
   │ 4.5 ⭐ (156)      [Order Now]    │
   └──────────────────────────────────┘
   ```

### 4C: Test Featured Business (Hindi)

1. **Go to Settings** (⚙️ icon)
2. **Tap Language** → Select **"हिंदी (Hindi)"**
3. **Go back to home screen**
4. **Featured card should now show:**

   ```
   💼 फीचर्ड बिजनेस              खोजें

   ┌──────────────────────────────────┐
   │ 🍽️  [✓ सत्यापित]               │
   │                                   │
   │ स्पाइस गार्डन रेस्तरां           │
   │ ₹500 से अधिक के सभी ऑर्डर पर 20% छूट │
   │ 📍 हैदराबाद           [मानचित्र] │
   │                                   │
   │ 4.5 ⭐ (156)    [अभी ऑर्डर करें] │
   └──────────────────────────────────┘
   ```

### 4D: Test Featured Business (Telugu)

1. **Go to Settings** → Language → Select **"తెలుగు (Telugu)"**
2. **Go back to home screen**
3. **Featured card should now show:**

   ```
   💼 ఫీచర్డ్ వ్యాపారాలు          అన్వేషించండి

   ┌──────────────────────────────────┐
   │ 🍽️  [✓ ధృవీకరించబడింది]         │
   │                                   │
   │ స్పైస్ గార్డెన్ రెస్టారెంట్      │
   │ ₹500 కంటే ఎక్కువ ఆర్డర్లపై 20% తగ్గింపు │
   │ 📍 హైదరాబాద్              [మ్యాప్] │
   │                                   │
   │ 4.5 ⭐ (156)  [ఇప్పుడు ఆర్డర్ చేయండి] │
   └──────────────────────────────────┘
   ```

### 4E: Test Local Business

1. **Tap the "Business" card** on home screen OR
2. **Tap "Explore" button** on Featured carousel
3. **You'll see Business Directory**
4. **Scroll through list** - you should see:

**In English:**

```
Fresh Mart Grocery
Fresh Fruits & Vegetables Daily
⭐ 4.2 (89) | 📍 Hyderabad
[Shop Now]
```

**In Hindi:**

```
फ्रेश मार्ट किराना
प्रतिदिन ताजे फल और सब्जियां
⭐ 4.2 (89) | 📍 हैदराबाद
[अभी खरीदें]
```

**In Telugu:**

```
ఫ్రెష్ మార్ట్ గ్రోసరీ
ప్రతిదినం తాజా పండ్లు & కూరగాయలు
⭐ 4.2 (89) | 📍 హైదరాబాద్
[ఇప్పుడు షాపింగ్ చేయండి]
```

---

## 🎨 Visual Comparison

### What You Should See:

#### Home Screen (English):

```
┌─────────────────────────────────────┐
│    📱 My City App        ⚙️ 🔔 ⋮   │
├─────────────────────────────────────┤
│                                      │
│ 💼 Featured Businesses    [Explore] │
│ ┌──────────────────────────────┐   │
│ │ 🍽️ [✓ Verified]             │   │
│ │ Spice Garden Restaurant      │   │
│ │ 20% Off on Orders Above ₹500│   │
│ │ 📍 Hyderabad         [Map]   │   │
│ │ 4.5 ⭐ (156)   [Order Now]   │   │
│ └──────────────────────────────┘   │
│ ●●○○○                               │
└─────────────────────────────────────┘
```

#### Home Screen (Hindi):

```
┌─────────────────────────────────────┐
│    📱 My City App        ⚙️ 🔔 ⋮   │
├─────────────────────────────────────┤
│                                      │
│ 💼 फीचर्ड बिजनेस        [खोजें]   │
│ ┌──────────────────────────────┐   │
│ │ 🍽️ [✓ सत्यापित]            │   │
│ │ स्पाइस गार्डन रेस्तरां      │   │
│ │ ₹500 से अधिक पर 20% छूट     │   │
│ │ 📍 हैदराबाद    [मानचित्र]   │   │
│ │ 4.5 ⭐ (156) [ऑर्डर करें]   │   │
│ └──────────────────────────────┘   │
│ ●●○○○                               │
└─────────────────────────────────────┘
```

#### Home Screen (Telugu):

```
┌─────────────────────────────────────┐
│    📱 My City App        ⚙️ 🔔 ⋮   │
├─────────────────────────────────────┤
│                                      │
│ 💼 ఫీచర్డ్ వ్యాపారాలు   [అన్వేషించండి] │
│ ┌──────────────────────────────┐   │
│ │ 🍽️ [✓ ధృవీకరించబడింది]       │   │
│ │ స్పైస్ గార్డెన్ రెస్టారెంట్   │   │
│ │ ₹500 పై 20% తగ్గింపు         │   │
│ │ 📍 హైదరాబాద్         [మ్యాప్]│   │
│ │ 4.5 ⭐ (156) [ఆర్డర్ చేయండి]  │   │
│ └──────────────────────────────┘   │
│ ●●○○○                               │
└─────────────────────────────────────┘
```

---

## 🔍 Troubleshooting

### Issue 1: Featured business not showing

**Solution:**

- Verify `is_featured = true` AND `is_approved = true`
- Restart the app
- Pull down to refresh on home screen

### Issue 2: Local business not showing

**Solution:**

- Verify `is_approved = true`
- Go to Business Directory (tap "Business" card or "Explore")
- Pull down to refresh

### Issue 3: Still showing English in Hindi/Telugu

**Solution:**

- Check that all `*_te` and `*_hi` columns have values
- Restart the app after adding translations
- Verify language is correctly selected in Settings

### Issue 4: Translations look wrong

**Solution:**

- Use Google Translate to verify translations
- Or use the Auto Translation tool:
  - Settings → Auto Translation → Start Translation

---

## 📊 Quick Reference Table

| Field                 | English                          | Telugu                                  | Hindi                   |
| --------------------- | -------------------------------- | --------------------------------------- | ----------------------- |
| **Featured Business** |                                  |                                         |                         |
| Name                  | Spice Garden Restaurant          | స్పైస్ గార్డెన్ రెస్టారెంట్             | स्पाइस गार्डन रेस्तरां  |
| Offer                 | 20% Off on All Orders Above ₹500 | ₹500 కంటే ఎక్కువ ఆర్డర్లపై 20% తగ్గింపు | ₹500 से अधिक पर 20% छूट |
| CTA                   | Order Now                        | ఇప్పుడు ఆర్డర్ చేయండి                   | अभी ऑर्डर करें          |
| **Local Business**    |                                  |                                         |                         |
| Name                  | Fresh Mart Grocery               | ఫ్రెష్ మార్ట్ గ్రోసరీ                   | फ्रेश मार्ट किराना      |
| Offer                 | Free Home Delivery               | ఉచిత హోం డెలివరీ                        | मुफ्त होम डिलीवरी       |
| CTA                   | Shop Now                         | షాపింగ్ చేయండి                          | अभी खरीदें              |

---

## 🎯 Summary Checklist

After completing all steps, verify:

- [ ] ✅ Added "Spice Garden Restaurant" with `is_featured = true`
- [ ] ✅ Added "Fresh Mart Grocery" with `is_featured = false`
- [ ] ✅ Both have English, Telugu, and Hindi translations
- [ ] ✅ Featured business appears in carousel at home screen top
- [ ] ✅ Local business appears in Business Directory
- [ ] ✅ English mode shows all English text
- [ ] ✅ Hindi mode shows all Hindi text (including badges)
- [ ] ✅ Telugu mode shows all Telugu text (including badges)
- [ ] ✅ Can tap on businesses to view full details
- [ ] ✅ Language switching works instantly

---

## 🚀 Next Steps

### Add More Businesses:

1. **Use the same template** above
2. **Change the business details** (name, offer, address, etc.)
3. **Translate to Telugu & Hindi** using:
   - Google Translate, OR
   - Settings → Auto Translation tool
4. **Set `is_featured`**:
   - `true` = Shows in carousel (max 10-15 recommended)
   - `false` = Shows only in directory

### Automate Translation:

Instead of manually translating each field:

1. Add businesses in **English only**
2. Set `is_featured` and `is_approved` to `true`
3. Use **Settings → Auto Translation**
4. Click "Start Translation"
5. Restart app

---

## 📞 Need Help?

If businesses don't appear:

1. Check database: both `is_featured` and `is_approved` must be `true`
2. Restart app completely
3. Pull down to refresh on home screen
4. Check language selection in Settings

If translations don't work:

1. Verify all `*_te` and `*_hi` columns have values
2. Run Auto Translation tool
3. Clear app cache and restart

---

## ✅ Success!

You now have:

- ✅ **1 Featured Business** (Spice Garden Restaurant) in carousel
- ✅ **1 Local Business** (Fresh Mart Grocery) in directory
- ✅ Both display in **English, Hindi, and Telugu**
- ✅ All UI elements translated (Verified, Map, buttons, etc.)

**Your app is now fully multi-lingual! 🎉**
