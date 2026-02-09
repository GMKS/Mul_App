# 📚 Complete Database Setup for Multi-Language Support

## 1️⃣ DATABASE SETUP

### Step 1: Add Translation Columns to Supabase

Open your Supabase dashboard and run these SQL commands:

```sql
-- Add translation columns to businesses table
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
ADD COLUMN IF NOT EXISTS address_te TEXT,
ADD COLUMN IF NOT EXISTS address_hi TEXT,
ADD COLUMN IF NOT EXISTS city_te TEXT,
ADD COLUMN IF NOT EXISTS city_hi TEXT;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_businesses_name_te ON businesses(name_te);
CREATE INDEX IF NOT EXISTS idx_businesses_name_hi ON businesses(name_hi);
CREATE INDEX IF NOT EXISTS idx_businesses_is_featured ON businesses(is_featured);
CREATE INDEX IF NOT EXISTS idx_businesses_is_approved ON businesses(is_approved);
```

### Step 2: Verify Column Creation

Run this query to verify all columns exist:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'businesses'
ORDER BY column_name;
```

You should see all the `*_te` (Telugu) and `*_hi` (Hindi) columns.

---

## 2️⃣ HOW TO ADD BUSINESS IN MULTIPLE LANGUAGES

### Option A: Using the Translation Admin Tool (AUTOMATIC - RECOMMENDED)

**For Existing Businesses:**

1. **Login as Admin**
   - Email: `admin@gmail.com` or `seenaigmk@gmail.com`

2. **Open Settings** (⚙️ icon in top right)

3. **Tap "Auto Translation"** (cyan/turquoise card)

4. **Click "Start Translation"**
   - Automatically translates English → Telugu & Hindi
   - Uses Google Cloud Translation API
   - Shows real-time progress

5. **Wait for completion** (takes ~1 second per business)

6. **Restart app** to see translated content

### Option B: Manual Entry in Supabase (For New Businesses)

When adding a new business, fill in these fields:

#### English Fields (Required):
```
name: "Sri Lakshmi Jewellers"
tagline: "Premium Gold & Diamond Jewellery"
offer: "50% Off on Gold Making Charges"
description: "Best quality jewellery with certified gold"
cta_text: "Visit Store"
address: "123 Main Street, Ameerpet"
city: "Hyderabad"
category: "Jewelry"
is_featured: true
is_approved: true
is_verified: true
```

#### Telugu Fields:
```
name_te: "శ్రీ లక్ష్మీ జ్యువెలర్స్"
tagline_te: "ప్రీమియం బంగారం & వజ్రాల ఆభరణాలు"
offer_te: "బంగారం తయారీ ఖర్చులపై 50% తగ్గింపు"
description_te: "ధృవీకరించబడిన బంగారంతో ఉత్తమ నాణ్యత ఆభరణాలు"
cta_text_te: "స్టోర్ సందర్శించండి"
address_te: "123 మెయిన్ స్ట్రీట్, అమీర్పేట"
city_te: "హైదరాబాద్"
```

#### Hindi Fields:
```
name_hi: "श्री लक्ष्मी ज्वैलर्स"
tagline_hi: "प्रीमियम सोना और हीरे के आभूषण"
offer_hi: "सोने के बनाने के खर्च पर 50% छूट"
description_hi: "प्रमाणित सोने के साथ सर्वोत्तम गुणवत्ता के आभूषण"
cta_text_hi: "स्टोर पर जाएं"
address_hi: "123 मेन स्ट्रीट, अमीरपेट"
city_hi: "हैदराबाद"
```

### Option C: Using Google Translate API Programmatically

If you want to translate from your app:

```dart
import 'package:your_app/services/translation_service.dart';

// For a single business
final translations = await TranslationService.translateBusiness(
  name: "Sri Lakshmi Jewellers",
  offer: "50% Off on Gold Making Charges",
  tagline: "Premium Gold & Diamond Jewellery",
  description: "Best quality jewellery",
  ctaText: "Visit Store",
);

// Save to database
await TranslationService.updateBusinessTranslations(
  businessId, 
  translations
);
```

---

## 3️⃣ TRANSLATION MAPPING

### Common Business Terms

| English | Telugu (te) | Hindi (hi) |
|---------|-------------|-----------|
| Visit Store | స్టోర్ సందర్శించండి | स्टोर पर जाएं |
| Book Now | ఇప్పుడు బుక్ చేయండి | अभी बुक करें |
| Order Now | ఇప్పుడు ఆర్డర్ చేయండి | अभी ऑर्डर करें |
| Call Now | ఇప్పుడు కాల్ చేయండి | अभी कॉल करें |
| View Menu | మెను చూడండి | मेन्यू देखें |
| Book Appointment | అపాయింట్మెంట్ బుక్ చేయండి | अपॉइंटमेंट बुक करें |
| Verified | ధృవీకరించబడింది | सत्यापित |
| Featured | ఫీచర్డ్ | फीचर्ड |
| Sponsored | ప్రాయోజిత | प्रायोजित |
| Map | మ్యాప్ | मानचित्र |
| Explore | అన్వేషించండి | खोजें |

### Categories

| English | Telugu | Hindi |
|---------|--------|-------|
| Jewelry | ఆభరణాలు | आभूषण |
| Restaurant | రెస్టారెంట్ | रेस्तरां |
| Cafe | కేఫ్ | कैफे |
| Grocery | కిరాణా | किराना |
| Pharmacy | ఫార్మసీ | फार्मेसी |
| Hospital | ఆసుపత్రి | अस्पताल |
| Salon | సెలూన్ | सैलून |
| Gym | జిమ్ | जिम |
| Education | విద్య | शिक्षा |
| Electronics | ఎలక్ట్రానిక్స్ | इलेक्ट्रॉनिक्स |

---

## 4️⃣ TESTING YOUR TRANSLATIONS

### Test Checklist:

1. **English Mode**
   - [ ] Header shows "Featured Businesses"
   - [ ] All business cards show English names
   - [ ] Offers/taglines in English
   - [ ] "Visit Store" button in English
   - [ ] "Verified" and "Ad" badges in English

2. **Telugu Mode**
   - [ ] Header shows "ఫీచర్డ్ వ్యాపారాలు"
   - [ ] Business names in Telugu (or English if not translated)
   - [ ] Offers/taglines in Telugu
   - [ ] CTA button in Telugu
   - [ ] "ధృవీకరించబడింది" and "ప్రాయోజిత" badges

3. **Hindi Mode**
   - [ ] Header shows "फीचर्ड बिजनेस"
   - [ ] Business names in Hindi (or English if not translated)
   - [ ] Offers/taglines in Hindi
   - [ ] CTA button in Hindi
   - [ ] "सत्यापित" and "प्रायोजित" badges

---

## 5️⃣ SAMPLE BUSINESS DATA

Here's a complete example you can copy-paste into Supabase:

```json
{
  "id": "uuid-generated-automatically",
  "name": "Sri Lakshmi Jewellers",
  "name_te": "శ్రీ లక్ష్మీ జ్యువెలర్స్",
  "name_hi": "श्री लक्ष्मी ज्वैलर्स",
  
  "tagline": "Premium Gold & Diamond Jewellery",
  "tagline_te": "ప్రీమియం బంగారం & వజ్రాల ఆభరణాలు",
  "tagline_hi": "प्रीमियम सोना और हीरे के आभूषण",
  
  "offer": "50% Off on Gold Making Charges",
  "offer_te": "బంగారం తయారీ ఖర్చులపై 50% తగ్గింపు",
  "offer_hi": "सोने के बनाने के खर्च पर 50% छूट",
  
  "description": "Best quality jewellery with certified gold",
  "description_te": "ధృవీకరించబడిన బంగారంతో ఉత్తమ నాణ్యత ఆభరణాలు",
  "description_hi": "प्रमाणित सोने के साथ सर्वोत्तम गुणवत्ता के आभूषण",
  
  "cta_text": "Visit Store",
  "cta_text_te": "స్టోర్ సందర్శించండి",
  "cta_text_hi": "स्टोर पर जाएं",
  
  "city": "Hyderabad",
  "city_te": "హైదరాబాద్",
  "city_hi": "हैदराबाद",
  
  "address": "123 Main Street, Ameerpet",
  "address_te": "123 మెయిన్ స్ట్రీట్, అమీర్పేట",
  "address_hi": "123 मेन स्ट्रीट, अमीरपेट",
  
  "category": "Jewelry",
  "is_featured": true,
  "is_approved": true,
  "is_verified": true,
  "is_ad": true,
  "rating": 4.8,
  "review_count": 234
}
```

---

## 6️⃣ TROUBLESHOOTING

**Q: Translations not showing?**
- A: Restart the app after adding translations
- A: Check that `is_featured` and `is_approved` are both `true`
- A: Verify column names match exactly (case-sensitive)

**Q: Still seeing English in Telugu/Hindi mode?**
- A: That business doesn't have translations yet
- A: Run the Auto Translation tool from Settings
- A: Or manually add `*_te` and `*_hi` fields in database

**Q: How to test without restarting?**
- A: Pull down to refresh on the home screen
- A: The app should reload with new translations

**Q: Can I use other languages?**
- A: Yes! Add columns like `name_ta` (Tamil), `name_kn` (Kannada)
- A: Update the translation service to support new languages

---

## 7️⃣ NEXT STEPS

1. ✅ Run the SQL commands above to create database columns
2. ✅ Use the Auto Translation tool to translate existing businesses
3. ✅ For new businesses, add all 3 language versions (en, te, hi)
4. ✅ Test by switching languages in the app
5. ✅ Verify all text appears in the selected language

**Need help?** Check the app's translation logs in Settings → Auto Translation
