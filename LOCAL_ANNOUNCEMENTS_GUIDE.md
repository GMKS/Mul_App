# 📢 Local Announcements & Community Updates Guide

Quick reference for adding local announcements, markets, events, and community updates using the Local Deals system.

## 🎯 How to Add Announcements

**Method:** Use Supabase SQL Editor

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Copy the relevant template below
3. Customize the details (title, description, area, timings)
4. Click **Run** to add
5. Users will see it immediately via real-time updates!

---

## 📝 Announcement Templates

### 1. 🥬 Vegetable/Grocery Markets

```sql
-- Daily Vegetable Market
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, state, area, expires_at, is_featured, priority_rank
) VALUES (
    '🥬 Fresh Vegetable Market Today - Vinayaka Nagar',
    'Fresh vegetables directly from farmers. Tomatoes ₹20/kg, Onions ₹30/kg, Leafy vegetables ₹10/bunch. Open 6 AM - 12 PM today.',
    'Vinayaka Nagar Farmers Market',
    'Grocery',
    '🥬',
    100.00, 50.00, 50,
    'Hyderabad', 'Telangana', 'Vinayaka Nagar',
    CURRENT_DATE + INTERVAL '18 hours',  -- Expires today evening
    true, 100
);

-- Weekly Organic Market
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🌿 Organic Vegetable Market - Every Sunday',
    'Pesticide-free organic vegetables. Available every Sunday 7 AM - 1 PM at Community Center.',
    'Kukatpally Organic Bazaar',
    'Grocery',
    '🌿',
    150.00, 100.00, 33,
    'Hyderabad', 'Kukatpally',
    NOW() + INTERVAL '7 days',
    true, 95
);
```

### 2. 🐟 Fish & Seafood Markets

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🐟 Fresh Fish Market Today',
    'Fresh catch arrived! Pomfret ₹400/kg, Rohu ₹250/kg, Prawns ₹600/kg. Open till 2 PM.',
    'Secunderabad Fish Market',
    'Food',
    '🐟',
    500.00, 350.00, 30,
    'Hyderabad', 'Secunderabad',
    CURRENT_DATE + INTERVAL '8 hours',
    true, 98
);
```

### 3. 🌺 Flower Markets

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🌺 Flower Market - Festival Special',
    'Fresh roses, jasmine, marigolds for puja. Special rates for bulk orders. Open 5 AM - 10 AM.',
    'Abids Flower Market',
    'Devotional',
    '🌺',
    200.00, 150.00, 25,
    'Hyderabad', 'Abids',
    CURRENT_DATE + INTERVAL '5 hours',
    true, 99
);
```

### 4. 🩸 Blood Donation Camps

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank,
    promo_code
) VALUES (
    '🩸 Blood Donation Camp - Save Lives Today',
    'Voluntary blood donation drive organized by Rotary Club. All donors receive health checkup and certificate. Age 18-65. Bring ID proof.',
    'Rotary Club Hyderabad',
    'Health',
    '🩸',
    0.00, 0.00, 0,
    'Hyderabad', 'Banjara Hills',
    NOW() + INTERVAL '2 days',
    true, 100,
    'SAVELIFE2026'
);
```

### 5. 🏥 Health Camps

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🏥 Free Health Checkup Camp',
    'Free BP, Sugar, Eye checkup. Doctor consultation available. Timing: 9 AM - 4 PM. No registration required.',
    'Government Health Department',
    'Health',
    '🏥',
    999.00, 0.00, 100,
    'Hyderabad', 'Miyapur',
    NOW() + INTERVAL '3 days',
    true, 100
);
```

### 6. 📚 Educational Events

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '📚 Free Career Counseling Session',
    'Expert guidance for 10th & 12th students. Engineering, Medical, Commerce streams. Register: 9876543210',
    'Ameerpet Career Academy',
    'Education',
    '📚',
    500.00, 0.00, 100,
    'Hyderabad', 'Ameerpet',
    NOW() + INTERVAL '5 days',
    true, 85
);
```

### 7. 🪷 Religious Events & Pujas

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🪷 Special Pooja & Prasad Distribution',
    'Sathyanarayana Swamy Vratham at Community Temple. Prasad distribution 11 AM onwards. All are welcome!',
    'Community Temple - Kompally',
    'Devotional',
    '🪷',
    0.00, 0.00, 0,
    'Hyderabad', 'Kompally',
    NOW() + INTERVAL '2 days',
    true, 95
);
```

### 8. 🎉 Community Events & Festivals

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🎉 Sankranti Celebration - Community Event',
    'Traditional Sankranti festivities with cultural programs, food stalls, kite flying competition. Entry free for all families!',
    'Gachibowli Residents Association',
    'Entertainment',
    '🎉',
    0.00, 0.00, 0,
    'Hyderabad', 'Gachibowli',
    NOW() + INTERVAL '3 days',
    true, 100
);
```

### 9. 🚗 Vaccination Drives

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '💉 Free Flu Vaccination Drive',
    'Free influenza vaccination for children & senior citizens. Bring Aadhar card. Timing: 10 AM - 2 PM.',
    'Government Hospital Kukatpally',
    'Health',
    '💉',
    300.00, 0.00, 100,
    'Hyderabad', 'Kukatpally',
    NOW() + INTERVAL '4 days',
    true, 100
);
```

### 10. 🎭 Cultural Programs

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🎭 Classical Dance Performance',
    'Bharatanatyam recital by renowned artists. Free entry. Limited seating. Come early! Venue: Community Hall, 6 PM onwards.',
    'Jubilee Hills Cultural Center',
    'Entertainment',
    '🎭',
    200.00, 0.00, 100,
    'Hyderabad', 'Jubilee Hills',
    NOW() + INTERVAL '2 days',
    true, 80
);
```

### 11. 🏃 Sports Events

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🏃 Marathon for a Cause - Register Now',
    '5K & 10K run to raise awareness. Registration ₹200 (includes T-shirt & certificate). Proceeds go to charity.',
    'Hyderabad Runners Club',
    'Entertainment',
    '🏃',
    500.00, 200.00, 60,
    'Hyderabad', 'Hi-Tech City',
    NOW() + INTERVAL '15 days',
    true, 75
);
```

### 12. 🔧 Free Services

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '🔧 Free Cycle Repair Camp',
    'Get your bicycle serviced for free. Air filling, brake adjustment, chain oiling. Timing: 8 AM - 12 PM.',
    'Miyapur Cycle Stand',
    'Services',
    '🔧',
    150.00, 0.00, 100,
    'Hyderabad', 'Miyapur',
    CURRENT_DATE + INTERVAL '1 day',
    true, 90
);
```

### 13. 📱 Technology Workshops

```sql
INSERT INTO public.local_deals (
    title, description, business_name, category, emoji,
    original_price, discounted_price, discount_percent,
    city, area, expires_at, is_featured, priority_rank
) VALUES (
    '📱 Free Digital Literacy Workshop',
    'Learn smartphone basics, UPI payments, online booking. For senior citizens. Register: 98765-43210',
    'KPHB Digital Center',
    'Education',
    '📱',
    500.00, 0.00, 100,
    'Hyderabad', 'KPHB',
    NOW() + INTERVAL '7 days',
    true, 85
);
```

---

## ⚙️ Customization Options

### Timing Options

```sql
-- Today only (expires tonight)
expires_at => CURRENT_DATE + INTERVAL '1 day'

-- Expires in 6 hours
expires_at => NOW() + INTERVAL '6 hours'

-- Expires tomorrow
expires_at => NOW() + INTERVAL '1 day'

-- Weekly event (next 7 days)
expires_at => NOW() + INTERVAL '7 days'

-- Month-long campaign
expires_at => NOW() + INTERVAL '30 days'
```

### Priority Levels

- **100**: Emergency/Critical (blood donation, health camps)
- **95-99**: Time-sensitive markets (vegetable, fish markets)
- **85-94**: Important events (festivals, cultural programs)
- **70-84**: Regular events
- **Below 70**: Low priority announcements

### Free vs Paid Events

**Free Events:**

```sql
original_price => 0.00,
discounted_price => 0.00,
discount_percent => 0
```

**Discounted Events:**

```sql
original_price => 500.00,    -- Regular price
discounted_price => 200.00,  -- Special price
discount_percent => 60       -- Auto-calculated or manual
```

---

## 🎨 Category & Emoji Guide

| Category          | Emoji Options | Use For                   |
| ----------------- | ------------- | ------------------------- |
| **Grocery**       | 🥬🌿🥕🍅🌽    | Vegetable, fruit markets  |
| **Food**          | 🍕🐟🍗🥘      | Fish markets, food events |
| **Health**        | 🏥💉🩸💊      | Health camps, donations   |
| **Devotional**    | 🪷🌺🙏🕉️      | Religious events, pujas   |
| **Education**     | 📚📱💻🎓      | Workshops, training       |
| **Entertainment** | 🎉🎭🏃🎬      | Cultural, sports events   |
| **Services**      | 🔧🚗🔌        | Free repair camps         |
| **Beauty**        | 💄💅          | Beauty workshops          |
| **Home**          | 🏠🪴          | Home improvement          |

---

## 📊 Quick Add Commands

### Market Opening Today

```sql
INSERT INTO public.local_deals (title, description, business_name, category, emoji, original_price, discounted_price, discount_percent, city, area, expires_at, is_featured, priority_rank)
VALUES ('🥬 Vegetable Market Today - [AREA NAME]', 'Fresh vegetables. Open 6 AM - 12 PM', '[Area] Market', 'Grocery', '🥬', 100.00, 50.00, 50, 'Hyderabad', '[AREA]', CURRENT_DATE + INTERVAL '18 hours', true, 100);
```

### Free Event

```sql
INSERT INTO public.local_deals (title, description, business_name, category, emoji, original_price, discounted_price, discount_percent, city, area, expires_at, is_featured, priority_rank)
VALUES ('📢 [EVENT NAME]', '[Description]', '[Organizer]', 'Entertainment', '🎉', 0.00, 0.00, 0, 'Hyderabad', '[AREA]', NOW() + INTERVAL '3 days', true, 90);
```

---

## 🔍 Verification

After adding, verify with:

```sql
-- Check latest announcements
SELECT title, area, expires_at, is_featured
FROM public.local_deals
ORDER BY created_at DESC
LIMIT 5;

-- Check active announcements by area
SELECT title, category, area
FROM public.local_deals
WHERE city = 'Hyderabad'
  AND is_active = true
  AND expires_at > NOW()
ORDER BY priority_rank DESC;

-- Check today's events
SELECT title, area, expires_at
FROM public.local_deals
WHERE DATE(expires_at) = CURRENT_DATE
  AND is_active = true;
```

---

## 💡 Pro Tips

1. **Use descriptive titles**: Include location and timing in title
2. **Add contact info**: Include phone numbers in description for registrations
3. **Set accurate expiry**: Markets expire same day, events when they end
4. **Use high priority**: For urgent announcements (90-100)
5. **Enable featured**: `is_featured = true` for prominent display
6. **Add promo codes**: For tracking (MARKET2026, EVENT2026)
7. **Update daily**: Fresh announcements keep users engaged

---

## 📱 How Users See It

- ✅ Appears in **Local Deals** section on home screen
- ✅ Shows in **Featured** tab if `is_featured = true`
- ✅ Real-time updates - no app restart needed
- ✅ Filtered by user's city/area
- ✅ Expires automatically at set time
- ✅ Push notifications (if enabled)

---

## 🆘 Need Help?

**Common Issues:**

- Not showing? Check `is_active = true` and `expires_at > NOW()`
- Wrong area? Update `area` field to match user's location
- Low visibility? Increase `priority_rank` to 95-100
- Already expired? Set `expires_at` to future date

**Quick Fixes:**

```sql
-- Reactivate expired announcement
UPDATE public.local_deals
SET expires_at = NOW() + INTERVAL '1 day', is_active = true
WHERE title LIKE '%Vegetable Market%';

-- Change priority
UPDATE public.local_deals
SET priority_rank = 100, is_featured = true
WHERE id = '[DEAL_ID]';
```

---

**Made with ❤️ for your community!**
