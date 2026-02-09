# 🏷️ Local Deals Feature - Complete Setup Guide

## Overview

The Local Deals feature allows businesses to post special offers and discounts that all users in the area can see in real-time. When you add a deal from the Supabase dashboard, all users will automatically receive the update!

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Run the SQL Migration

1. Go to your **Supabase Dashboard** → **SQL Editor**
2. Copy and paste the entire contents of `supabase/migrations/20260128_local_deals_schema.sql`
3. Click **Run**

This creates:

- ✅ `local_deals` table - Stores all deals
- ✅ `deal_claims` table - Tracks who claimed which deals
- ✅ `deal_categories` table - Categories with colors/icons
- ✅ RLS policies - Security rules
- ✅ Real-time subscription - Live updates to all users
- ✅ Sample deals for Hyderabad

### Step 2: Enable Real-time (Important!)

1. Go to **Database** → **Replication**
2. Find the `local_deals` table
3. Toggle **ON** for real-time
4. This enables instant updates to all users!

---

## 📊 Adding Deals from Supabase Dashboard

### Method 1: Using Table Editor (Easy)

1. Go to **Table Editor** → **local_deals**
2. Click **Insert Row**
3. Fill in the fields:

| Field              | Description          | Example                           |
| ------------------ | -------------------- | --------------------------------- |
| `title`            | Deal headline        | "50% Off on First Order"          |
| `description`      | Detailed description | "Fresh vegetables delivered free" |
| `business_name`    | Business name        | "Raitu Bazaar"                    |
| `category`         | Category name        | "Grocery", "Food", "Health"       |
| `emoji`            | Display emoji        | "🥬", "🍕", "🏥"                  |
| `original_price`   | Original price       | 500.00                            |
| `discounted_price` | Sale price           | 250.00                            |
| `discount_percent` | Discount %           | 50                                |
| `city`             | Target city          | "Hyderabad"                       |
| `expires_at`       | Expiry datetime      | "2026-02-15 23:59:59"             |
| `is_active`        | Is deal live?        | true                              |
| `is_sponsored`     | Paid promotion?      | false                             |
| `is_featured`      | Featured deal?       | true                              |

### Method 2: Using SQL (Advanced)

```sql
-- Insert a new deal
INSERT INTO public.local_deals (
    title,
    description,
    business_name,
    category,
    emoji,
    original_price,
    discounted_price,
    discount_percent,
    city,
    state,
    area,
    expires_at,
    is_active,
    is_sponsored,
    is_featured,
    priority_rank,
    promo_code
) VALUES (
    'Grand Opening - 40% Off!',
    'Celebrate our new store opening with massive discounts on all items',
    'New Fashion Store',
    'Fashion',
    '👗',
    2000.00,
    1200.00,
    40,
    'Hyderabad',
    'Telangana',
    'Banjara Hills',
    NOW() + INTERVAL '30 days',
    true,
    true,
    true,
    100,
    'GRAND40'
);
```

---

## 📱 Categories Available

| Category      | Emoji | Color       |
| ------------- | ----- | ----------- |
| Grocery       | 🥬    | Green       |
| Food          | 🍕    | Orange      |
| Health        | 🏥    | Pink        |
| Services      | 🔧    | Blue        |
| Devotional    | 🪷    | Purple      |
| Electronics   | 📱    | Cyan        |
| Fashion       | 👗    | Deep Orange |
| Beauty        | 💄    | Pink        |
| Education     | 📚    | Brown       |
| Travel        | ✈️    | Indigo      |
| Entertainment | 🎬    | Grey        |
| Home          | 🏠    | Light Green |

---

## 🔥 Real-time Updates - How It Works

When you add/update/delete a deal in Supabase:

1. **Supabase** broadcasts the change via WebSocket
2. **App** receives the update instantly
3. **UI** refreshes automatically
4. **All users** see the new deal within seconds!

### Enabling Real-time

```sql
-- This is already in the migration, but if needed:
ALTER PUBLICATION supabase_realtime ADD TABLE public.local_deals;
```

---

## 📈 Prioritizing Deals

Deals appear in this order:

1. **Featured** deals first (`is_featured = true`)
2. **Sponsored** deals next (`is_sponsored = true`)
3. **Priority rank** (higher number = appears first)
4. **Expiry** (deals expiring soon appear first)

### Making a Deal Featured:

```sql
UPDATE public.local_deals
SET is_featured = true, priority_rank = 100
WHERE title LIKE '%Grand Opening%';
```

---

## 🎯 Location Targeting

Deals can be targeted by:

- **City** (required): "Hyderabad", "Bangalore", etc.
- **State** (optional): "Telangana", "Karnataka"
- **Area** (optional): "Kompally", "Banjara Hills"
- **Radius** (optional): 10 km, 25 km, etc.

### Example: Target specific area

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, state, area, radius_km,
    expires_at, is_active
) VALUES (
    'Local Store Special',
    'Special offer for Kompally residents',
    'Kompally Mart',
    'Grocery',
    '🛒',
    1000.00, 700.00, 30,
    'Hyderabad', 'Telangana', 'Kompally', 5,
    NOW() + INTERVAL '7 days', true
);
```

---

## ⏰ Managing Deal Expiry

### Extending a deal:

```sql
UPDATE public.local_deals
SET expires_at = expires_at + INTERVAL '7 days'
WHERE id = 'deal-uuid-here';
```

### Deactivating a deal:

```sql
UPDATE public.local_deals
SET is_active = false
WHERE id = 'deal-uuid-here';
```

### Finding expiring deals:

```sql
SELECT title, business_name, expires_at
FROM public.local_deals
WHERE is_active = true
  AND expires_at < NOW() + INTERVAL '24 hours'
ORDER BY expires_at;
```

---

## 📊 Analytics & Tracking

### View deal statistics:

```sql
SELECT
    title,
    business_name,
    views_count,
    claims_count,
    CASE WHEN views_count > 0
         THEN ROUND((claims_count::decimal / views_count) * 100, 2)
         ELSE 0
    END as conversion_rate
FROM public.local_deals
WHERE is_active = true
ORDER BY claims_count DESC;
```

### Most popular deals:

```sql
SELECT title, business_name, claims_count
FROM public.local_deals
ORDER BY claims_count DESC
LIMIT 10;
```

---

## 🔐 Security (RLS Policies)

The following policies are automatically set:

| Who             | Can Do                             |
| --------------- | ---------------------------------- |
| Anyone          | View active, non-expired deals     |
| Business owners | Create/Edit/Delete their own deals |
| Admins          | Full access to all deals           |
| Users           | Claim deals, view their claims     |

---

## 🧪 Testing the Feature

### 1. Add a test deal:

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, expires_at, is_active, is_featured
) VALUES (
    'TEST DEAL - Delete After Testing',
    'This is a test deal to verify the feature works',
    'Test Business',
    'Food',
    '🧪',
    100.00, 50.00, 50,
    'Hyderabad',
    NOW() + INTERVAL '1 hour',
    true, true
);
```

### 2. Open the app

The deal should appear in the "Local Deals" section on the home screen.

### 3. Delete the test deal:

```sql
DELETE FROM public.local_deals
WHERE title LIKE '%TEST DEAL%';
```

---

## 📁 Files Created/Modified

| File                                                  | Purpose           |
| ----------------------------------------------------- | ----------------- |
| `supabase/migrations/20260128_local_deals_schema.sql` | Database schema   |
| `lib/models/local_deal_model.dart`                    | Dart model class  |
| `lib/services/local_deals_service.dart`               | Supabase service  |
| `lib/widgets/local_deals_widget.dart`                 | Updated UI widget |

---

## 🛠️ Troubleshooting

### Deals not showing?

1. Check if `is_active = true`
2. Check if `expires_at > NOW()`
3. Check if city matches user's location
4. Verify RLS policies are correct

### Real-time not working?

1. Go to Database → Replication
2. Ensure `local_deals` table has real-time enabled
3. Check browser console for WebSocket errors

### Permission denied errors?

```sql
-- Grant necessary permissions
GRANT SELECT ON public.local_deals TO anon;
GRANT SELECT ON public.local_deals TO authenticated;
GRANT SELECT ON public.active_deals_view TO anon;
GRANT SELECT ON public.active_deals_view TO authenticated;
```

---

## 🎉 Success!

Once set up, you can:

1. ✅ Add deals from Supabase Dashboard
2. ✅ All users see deals instantly (real-time)
3. ✅ Users can claim deals with promo codes
4. ✅ Track views and claims
5. ✅ Target deals by location
6. ✅ Feature and sponsor deals

**Every deal you add will automatically appear for all users in that city!** 🚀
