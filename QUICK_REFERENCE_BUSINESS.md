# 🚀 QUICK REFERENCE CARD - Business Features

## 👤 FOR CUSTOMERS

### How to Submit a Business (3 Simple Steps)

```
1️⃣ Open "Business Directory"
2️⃣ Tap blue "Add Business" button (bottom-right)
3️⃣ Fill form → Upload photos → Submit
```

**What You Need:**

- ✅ Business name & description
- ✅ Category (Restaurant, Retail, etc.)
- ✅ Phone number
- ✅ Address, city, state
- ✅ Up to 5 photos (optional but recommended)

**What Happens Next:**

- Your business goes to "pending" status
- Admin reviews within 24-48 hours
- You get notification: Approved ✅ or Rejected ❌

---

## 🔧 FOR ADMINS

### How to Review Submissions (4 Simple Steps)

```
1️⃣ Settings → Admin Portal
2️⃣ Tap "Business Approvals" (first card)
3️⃣ Tap any pending business to view details
4️⃣ Approve ✅ or Reject ❌ (with reason)
```

**What You See:**

- 📊 Statistics: Total, Approved, Pending, Rejected
- 🔍 Search by name/city/description
- 📂 Filter by category
- ⬇️ Sort by date or name

**Your Actions:**

- ✅ **Approve** → Business goes live, owner notified
- ❌ **Reject** → Owner gets your feedback, can resubmit

---

## 📍 QUICK NAVIGATION

### Customer Path:

```
Home → Business Directory → Add Business (🔵 button)
```

### Admin Path:

```
Settings → Admin Portal → Business Approvals (💼 first card)
```

---

## 📊 WHERE DATA LIVES

| What                | Where                        | Who Can See       |
| ------------------- | ---------------------------- | ----------------- |
| Pending submissions | `business_submissions` table | Owner + Admins    |
| Approved businesses | `businesses` table           | Everyone          |
| Images              | `BUSINESS-IMAGES` storage    | Everyone (public) |
| Notifications       | `notifications` table        | Owner only        |
| Admin roles         | `user_roles` table           | Admins only       |

---

## 🔔 NOTIFICATIONS

**Customer Gets:**

- ✅ "Business Approved! 🎉" → Your business is live!
- ❌ "Needs Revision" → Admin feedback + reason

**Where to View:**

- Future: Notification bell in app
- Current: Check `notifications` table in Supabase

---

## 🎨 FEATURED BUSINESSES

**How to Mark Featured:**

1. Open Supabase Dashboard
2. Go to `businesses` table
3. Find approved business
4. Set `is_featured = true`
5. Optional: Set `featured_rank` (1 = top)

**Note:** Only admins can mark businesses as featured.

---

## ⚠️ TROUBLESHOOTING

| Problem                               | Solution                                              |
| ------------------------------------- | ----------------------------------------------------- |
| Can't see "Add Business" button       | Make sure you're on **Business Directory** screen     |
| Admin Portal shows "Access Denied"    | You need admin role in `user_roles` table             |
| Images won't upload                   | Check file size < 5MB, format: JPG/PNG/WEBP           |
| Business not appearing after approval | Check `businesses` table, verify `is_approved = true` |
| Overflow error on admin cards         | Already fixed! Text now has ellipsis                  |

---

## 📞 NEED HELP?

**Documentation:**

- 📘 `HOW_TO_USE_BUSINESS_FEATURES.md` - Complete guide
- 📊 `BUSINESS_FLOW_VISUAL_GUIDE.md` - Visual diagrams
- 🔧 `BUSINESS_APPROVAL_FULL_IMPLEMENTATION.md` - Technical details

**Database Setup:**

- 💾 `supabase/business_approval_setup.sql` - Run this first!

---

## ✅ TODAY'S FIXES (Jan 24, 2026)

1. ✅ **Fixed overflow errors** on admin dashboard cards
   - Added `maxLines` and `overflow: TextOverflow.ellipsis`
   - "Content Management" and "Reports & Feedback" no longer overflow

2. ✅ **Clarified business submission flow**
   - Created comprehensive documentation
   - Added visual flow diagrams
   - Explained where admins receive submissions

3. ✅ **Fixed Admin Portal crash**
   - Added null check for empty user names
   - Admin dashboard now loads without RangeError

---

**Remember:**

- 👤 Customers submit → 🔧 Admins approve → 🌍 Everyone sees
- All submissions go to **Business Approvals** in Admin Portal
- Maximum 5 images per business
- Approval creates notification automatically

---

**Last Updated:** January 24, 2026
**Version:** 1.0.1
