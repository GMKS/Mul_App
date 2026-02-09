# ✅ QUICK START GUIDE - Get Your App Fully Translated in 10 Minutes

## 🎯 Your Goal

See **ALL** text inside the app in the selected language (Telugu/Hindi/English)

---

## 📋 STEP 1: Setup Database (5 minutes)

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com
   - Login to your project

2. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New query"

3. **Copy & Paste This SQL Code:**

```sql
-- Add translation columns
ALTER TABLE businesses
ADD COLUMN IF NOT EXISTS name_te TEXT,
ADD COLUMN IF NOT EXISTS name_hi TEXT,
ADD COLUMN IF NOT EXISTS offer_te TEXT,
ADD COLUMN IF NOT EXISTS offer_hi TEXT,
ADD COLUMN IF NOT EXISTS tagline_te TEXT,
ADD COLUMN IF NOT EXISTS tagline_hi TEXT,
ADD COLUMN IF NOT EXISTS description_te TEXT,
ADD COLUMN IF NOT EXISTS description_hi TEXT,
ADD COLUMN IF NOT EXISTS cta_text_te TEXT,
ADD COLUMN IF NOT EXISTS cta_text_hi TEXT,
ADD COLUMN IF NOT EXISTS city_te TEXT,
ADD COLUMN IF NOT EXISTS city_hi TEXT;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_businesses_name_te ON businesses(name_te);
CREATE INDEX IF NOT EXISTS idx_businesses_name_hi ON businesses(name_hi);
```

4. **Click "Run"** (or press Ctrl+Enter)

5. **Verify Success**
   - You should see: "Success. No rows returned"
   - Go to Table Editor → businesses → You should now see new columns ending with `_te` and `_hi`

✅ **Done! Database is ready.**

---

## 🤖 STEP 2: Auto-Translate Existing Businesses (3 minutes)

1. **Open Your App**

2. **Login as Admin**
   - Email: `admin@gmail.com` (or `seenaigmk@gmail.com`)
   - Password: [your admin password]

3. **Go to Settings**
   - Tap the ⚙️ icon in the top-right corner

4. **Scroll Down to "Auto Translation"**
   - It's a cyan/turquoise colored card
   - Says "Translate businesses to Telugu & Hindi"

5. **Tap the Card**

6. **Click "Start Translation" Button**
   - Wait for it to complete (shows real-time progress)
   - You'll see logs like:
     ```
     🚀 Starting batch translation...
     📊 Found X featured businesses
     [0/X] Processing: Sri Lakshmi Jewellers
     🔄 Translating to Telugu and Hindi...
        Telugu (te): శ్రీ లక్ష్మీ జ్యువెలర్స్
        Hindi (hi): श्री लक्ष्मी ज्वैलर्स
     ✅ Successfully translated and saved!
     ```

7. **Wait Until You See:**

   ```
   🎉 BATCH TRANSLATION COMPLETE!
   ✅ Successfully translated: X
   ```

8. **Close the Dialog**

9. **Restart the App** (Close and reopen)

✅ **Done! All businesses are now translated.**

---

## 🧪 STEP 3: Test Language Switching (2 minutes)

1. **Switch to Hindi:**
   - Go to Settings → Language
   - Select "हिंदी (Hindi)"
   - Go back to home screen

2. **Check the Business Card:**
   - Header should say: **"फीचर्ड बिजनेस"** ✓
   - Business name should be in Hindi: **"श्री लक्ष्मी ज्वैलर्स"** ✓
   - Offer should be in Hindi: **"सोने के बनाने के खर्च पर 50% छूट"** ✓
   - Button should say: **"स्टोर पर जाएं"** ✓
   - Verified badge: **"सत्यापित"** ✓
   - Ad badge: **"विज्ञापन"** ✓
   - Map button: **"मानचित्र"** ✓

3. **Switch to Telugu:**
   - Go to Settings → Language
   - Select "తెలుగు (Telugu)"
   - Go back to home screen

4. **Check the Business Card:**
   - Header: **"ఫీచర్డ్ వ్యాపారాలు"** ✓
   - Business name: **"శ్రీ లక్ష్మీ జ్యువెలర్స్"** ✓
   - Offer: **"బంగారం తయారీ ఖర్చులపై 50% తగ్గింపు"** ✓
   - Button: **"స్టోర్ సందర్శించండి"** ✓
   - Verified badge: **"ధృవీకరించబడింది"** ✓
   - Ad badge: **"ప్రాయోజిత"** ✓
   - Map button: **"మ్యాప్"** ✓

5. **Switch Back to English:**
   - Everything should be in English

✅ **Done! Language switching is working perfectly.**

---

## ➕ STEP 4: How to Add New Business in Multiple Languages

### Option A: Add in English, Let App Translate

1. **Add business in Supabase** (only English fields):

   ```
   name: "Your Business Name"
   tagline: "Your Tagline"
   offer: "Your Special Offer"
   is_featured: true
   is_approved: true
   ```

2. **Run Auto Translation** (Settings → Auto Translation → Start)

3. **Restart App**

✅ **Done! Business appears in all languages.**

---

### Option B: Add All Languages Manually

1. **Open Supabase → businesses table**

2. **Click "+ Insert row"**

3. **Fill in ALL these fields:**

**English (Required):**

```
name = "Sri Lakshmi Jewellers"
offer = "50% Off on Gold Making Charges"
tagline = "Premium Gold & Diamond Jewellery"
cta_text = "Visit Store"
city = "Hyderabad"
category = "Jewelry"
is_featured = true
is_approved = true
is_verified = true
```

**Telugu:**

```
name_te = "శ్రీ లక్ష్మీ జ్యువెలర్స్"
offer_te = "బంగారం తయారీ ఖర్చులపై 50% తగ్గింపు"
tagline_te = "ప్రీమియం బంగారం & వజ్రాల ఆభరణాలు"
cta_text_te = "స్టోర్ సందర్శించండి"
city_te = "హైదరాబాద్"
```

**Hindi:**

```
name_hi = "श्री लक्ष्मी ज्वैलर्स"
offer_hi = "सोने के बनाने के खर्च पर 50% छूट"
tagline_hi = "प्रीमियम सोना और हीरे के आभूषण"
cta_text_hi = "स्टोर पर जाएं"
city_hi = "हैदराबाद"
```

4. **Click "Save"**

5. **Restart App**

✅ **Done! Business shows in all languages.**

---

## 📱 What You'll See in Each Language

### English Mode

```
┌─────────────────────────────────┐
│ 💼 Featured Businesses  Explore │
├─────────────────────────────────┤
│  💎  [✓ Verified] [Ad]         │
│                                  │
│  Sri Lakshmi Jewellers          │
│  50% Off on Gold Making Charges │
│  📍 Hyderabad            [Map]  │
│                                  │
│  4.8 (234)        [Visit Store] │
└─────────────────────────────────┘
```

### Hindi Mode (हिंदी)

```
┌─────────────────────────────────┐
│ 💼 फीचर्ड बिजनेस      खोजें   │
├─────────────────────────────────┤
│  💎  [✓ सत्यापित] [विज्ञापन]  │
│                                  │
│  श्री लक्ष्मी ज्वैलर्स         │
│  सोने के बनाने के खर्च पर 50% छूट │
│  📍 हैदराबाद        [मानचित्र] │
│                                  │
│  4.8 (234)  [स्टोर पर जाएं]    │
└─────────────────────────────────┘
```

### Telugu Mode (తెలుగు)

```
┌─────────────────────────────────┐
│ 💼 ఫీచర్డ్ వ్యాపారాలు అన్వేషించండి │
├─────────────────────────────────┤
│  💎  [✓ ధృవీకరించబడింది] [ప్రాయోజిత] │
│                                  │
│  శ్రీ లక్ష్మీ జ్యువెలర్స్        │
│  బంగారం తయారీ ఖర్చులపై 50% తగ్గింపు │
│  📍 హైదరాబాద్           [మ్యాప్]  │
│                                  │
│  4.8 (234)  [స్టోర్ సందర్శించండి] │
└─────────────────────────────────┘
```

---

## 🐛 Troubleshooting

| Problem                       | Solution                                                         |
| ----------------------------- | ---------------------------------------------------------------- |
| Still seeing English text     | Run Auto Translation tool from Settings                          |
| "Column does not exist" error | Run the SQL commands from Step 1                                 |
| Translation tool not working  | Check Google API key in `translation_service.dart`               |
| Only 2 cards showing          | Those are the only ones with translations - run Auto Translation |
| Badges still in English       | Update app (code changes applied)                                |
| App not refreshing            | Close and reopen the app                                         |

---

## 📞 Need Translation for Other Text?

If you see any other text in English that should be translated:

1. Check `lib/l10n/app_en.arb` (English)
2. Check `lib/l10n/app_hi.arb` (Hindi)
3. Check `lib/l10n/app_te.arb` (Telugu)

Make sure the same key exists in all three files with translated text.

---

## ✅ Summary

You've now:

1. ✅ Setup database with translation columns
2. ✅ Auto-translated all existing businesses
3. ✅ Updated UI to show all text in selected language
4. ✅ Learned how to add new businesses in multiple languages

**Your app is now fully multi-lingual! 🎉**
