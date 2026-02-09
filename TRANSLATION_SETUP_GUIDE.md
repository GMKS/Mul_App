# Automatic Translation Setup Guide

### English → Telugu & Hindi Translation for Featured Businesses

## 🎯 What This Does

Automatically translates all your Featured Business cards from English to Telugu and Hindi using Google Cloud Translation API. Users will see businesses in their selected language.

---

## 📋 Prerequisites

- Google Cloud account
- Credit/debit card for API billing (has free tier)
- Admin access to your app

---

## 🚀 Setup Steps

### Step 1: Get Google Cloud Translation API Key

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create or Select a Project**
   - Click "Select a project" at the top
   - Click "NEW PROJECT"
   - Name it (e.g., "MyCityApp-Translations")
   - Click "CREATE"

3. **Enable Translation API**
   - In the search bar, type "Cloud Translation API"
   - Click on "Cloud Translation API"
   - Click "ENABLE" button
   - Wait for it to enable (30 seconds)

4. **Create API Key**
   - Go to: https://console.cloud.google.com/apis/credentials
   - Click "CREATE CREDENTIALS" → "API key"
   - Copy the API key that appears
   - Click "RESTRICT KEY" (recommended)
   - Under "API restrictions", select "Restrict key"
   - Choose "Cloud Translation API" from the list
   - Click "SAVE"

### Step 2: Add API Key to Your App

1. **Open the translation service file**
   - File: `lib/services/translation_service.dart`

2. **Find this line:**

   ```dart
   static const String _apiKey = 'YOUR_GOOGLE_CLOUD_API_KEY';
   ```

3. **Replace with your actual API key:**

   ```dart
   static const String _apiKey = 'AIzaSyD...your-actual-key-here';
   ```

4. **Save the file**

### Step 3: Use the Translation Tool

1. **Run your app**

   ```bash
   flutter run -d your-device-id
   ```

2. **Login as admin**
   - Email: `admin@gmail.com`

3. **Go to Settings → Auto Translation**
   - You'll see a new cyan-colored card in admin section
   - Click on "Auto Translation"

4. **Click "Translate All Featured Businesses"**
   - Wait for translation to complete
   - Watch the status and logs

5. **Hot Reload the app**
   - Press `r` in the terminal
   - Or restart the app completely

6. **Test language switching**
   - Go to Settings → Language
   - Switch to Telugu - cards show తెలుగు text ✅
   - Switch to Hindi - cards show हिंदी text ✅
   - Switch to English - cards show English text ✅

---

## 💰 Pricing Information

**Google Cloud Translation API:**

- **Free Tier**: 500,000 characters per month
- **After Free Tier**: $20 per million characters
- **Example**: Translating 100 businesses (20 words each) = ~200,000 characters
- **Your cost**: $0 (well within free tier!)

---

## 🔧 Usage Options

### Option 1: Translate All at Once (Recommended)

```dart
// Use the Admin UI screen (already set up for you)
// Settings → Auto Translation → Translate All
```

### Option 2: Translate Single Business

```dart
// In your code:
await TranslationService.translateBusinessById('business-id-here');
```

### Option 3: Translate as You Add New Businesses

```dart
// When adding a new business:
final translations = await TranslationService.translateBusiness(
  name: 'Business Name',
  offer: 'Special Offer',
  ctaText: 'Visit Store',
);
// Then save to Supabase with translations
```

---

## 📝 What Gets Translated

For each business, these fields are translated:

- ✅ Business Name (`name` → `name_te`, `name_hi`)
- ✅ Offer/Deal (`offer` → `offer_te`, `offer_hi`)
- ✅ Tagline (`tagline` → `tagline_te`, `tagline_hi`)
- ✅ Description (`description` → `description_te`, `description_hi`)
- ✅ CTA Button Text (`cta_text` → `cta_text_te`, `cta_text_hi`)

---

## 🐛 Troubleshooting

### Error: "API key not valid"

- Check that you enabled "Cloud Translation API" in Google Cloud
- Verify you copied the API key correctly
- Make sure API restrictions allow Translation API

### Error: "Quota exceeded"

- You've used your free 500K characters for the month
- Wait for next month or upgrade to paid tier

### Translations not showing in app

- Make sure you hot reloaded after translation
- Check Supabase database to verify translations were saved
- Run this SQL to check:
  ```sql
  SELECT name, name_te, name_hi FROM businesses WHERE is_featured = true;
  ```

### Some businesses still in English

- They might not have `is_featured = true` in database
- Run translation again (it skips already-translated ones)
- Check console logs for errors

---

## ✅ Success Checklist

- [ ] Created Google Cloud project
- [ ] Enabled Cloud Translation API
- [ ] Created and restricted API key
- [ ] Added API key to `translation_service.dart`
- [ ] Ran the app as admin
- [ ] Opened Settings → Auto Translation
- [ ] Clicked "Translate All" button
- [ ] Saw success message
- [ ] Hot reloaded the app
- [ ] Tested Telugu language - shows Telugu text
- [ ] Tested Hindi language - shows Hindi text
- [ ] Tested English language - shows English text

---

## 🎉 Result

Now when users select:

- **Telugu** → Cards show: బాటా షూ స్టోర్, గోల్డ్ మేకింగ్ ఛార్జీలపై 20% తగ్గింపు
- **Hindi** → Cards show: बाटा शू शॉप, सोने के मेकिंग चार्ज पर 20% छूट
- **English** → Cards show: Bata Shoe Shop, 20% Off on Gold Making Charges

**All automatic, no manual typing needed!** 🚀

---

## 📞 Need Help?

If you face issues:

1. Check the console logs in VS Code terminal
2. Verify API key is correct
3. Check Supabase database for translated data
4. Make sure `http` package is in pubspec.yaml (already done)

---

## 🔒 Security Note

**IMPORTANT:** The API key in `translation_service.dart` will be compiled into your app. For production:

- Use environment variables
- Or move API key to a backend server
- Or use Firebase Cloud Functions to call Translation API

For now, API key restrictions are sufficient for development/testing.
