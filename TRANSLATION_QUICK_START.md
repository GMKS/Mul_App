# 🚀 Quick Start: Auto-Translation in 5 Minutes

## What You Get

✅ Automatic English → Telugu + Hindi translation  
✅ One-click translation for all businesses  
✅ Works with your existing language selector  
✅ FREE (Google gives 500K characters/month)

---

## Setup (One-time, 5 minutes)

### 1️⃣ Get API Key (3 minutes)

```
1. Go to: https://console.cloud.google.com/
2. Create project → Enable "Cloud Translation API"
3. Create API key → Copy it
```

### 2️⃣ Add to Your App (1 minute)

```dart
// File: lib/services/translation_service.dart
// Line 10: Replace this:
static const String _apiKey = 'YOUR_GOOGLE_CLOUD_API_KEY';

// With your actual key:
static const String _apiKey = 'AIzaSyD...your-key-here';
```

### 3️⃣ Run Translation (1 minute)

```
1. Run app: flutter run -d your-device
2. Login as admin@gmail.com
3. Settings → Auto Translation
4. Click "Translate All"
5. Wait 30 seconds
6. Hot reload: press 'r'
```

---

## Usage

**In the app UI:**

- Settings → Auto Translation → Translate All button

**In code (for new businesses):**

```dart
final translations = await TranslationService.translateBusiness(
  name: 'Business Name',
  offer: 'Special Offer',
);
// Returns: {name_te: 'తెలుగు', name_hi: 'हिंदी', ...}
```

---

## Test It

1. Settings → Language → Telugu ✅ Shows తెలుగు text
2. Settings → Language → Hindi ✅ Shows हिंदी text
3. Settings → Language → English ✅ Shows English text

---

## Files Created

✅ `lib/services/translation_service.dart` - Translation engine  
✅ `lib/screens/admin/translation_admin_screen.dart` - Admin UI  
✅ Settings screen updated - Added translation button  
✅ `TRANSLATION_SETUP_GUIDE.md` - Full documentation

---

## Need Help?

📖 Full guide: `TRANSLATION_SETUP_GUIDE.md`  
🔧 Troubleshooting: Check console logs in VS Code  
💰 Cost: $0 (free tier covers ~100 businesses/month)

---

## Example Result

**Before:**

- Telugu selected → Shows "Bata Shoe Shop" (English)

**After:**

- Telugu selected → Shows "బాటా షూ స్టోర్" (Telugu)
- Hindi selected → Shows "बाटा शू शॉप" (Hindi)

**All automatic!** 🎉
