# How to Use Business Features - Complete Guide

## 🎯 Overview

This app has a complete **Business Approval System** where customers can submit their businesses and admins can review and approve them.

---

## 👤 For Customers (Business Owners)

### How to Submit a Business

1. **Open the App** and navigate to the **Business Directory** screen
   - Look for the "Business Directory" option in your main navigation
   - Or access it from the home screen

2. **Find the "Add Business" Button**
   - Located at the **bottom-right corner** of the screen
   - It's a blue floating action button (FAB) with text **"Add Business"**
   - Icon: 📊 (business icon)

3. **Fill Out the Submission Form**
   - **Business Name** (required)
   - **Description** (required)
   - **Category** - Select from 17 options:
     - Restaurant, Cafe, Retail Store, Grocery Store, Pharmacy, Hospital/Clinic
     - Gym/Fitness, Salon/Spa, Electronics, Fashion/Clothing, Home Services
     - Auto Services, Education/Tutoring, Real Estate, Law/Consulting
     - Entertainment, Other Services
   - **Contact Information:**
     - Phone Number (required)
     - Email (optional)
     - WhatsApp Number (optional)
   - **Location:**
     - Address (required)
     - City (required)
     - State (required)
   - **Website URL** (optional)
   - **Business Images** - Upload up to 5 photos
     - Click "Add Images" button
     - Select from gallery
     - Preview and remove unwanted images
     - Images are uploaded to Supabase Storage

4. **Submit for Review**
   - Click the blue **"Submit for Approval"** button
   - You'll see a success message with upload confirmation
   - Your business is now **pending admin review**

5. **Wait for Admin Approval**
   - Your submission goes to the admin panel
   - Admins will review your business details and images
   - You'll receive a notification when:
     - ✅ **Approved** - Your business is now live!
     - ❌ **Rejected** - You'll see the reason and can resubmit

---

## 🔧 For Admins

### Where to Find Business Submissions

1. **Open Admin Portal**
   - Go to **Settings** in the app
   - Tap **"Admin Portal"** or **"Admin Dashboard"**
   - (Requires admin role/permissions)

2. **Navigate to Business Approvals**
   - On the Admin Dashboard, look for the **"Business Approvals"** card
   - It's the **first card** in the grid (top-left position)
   - Icon: 💼 (briefcase icon)
   - Shows a badge with the count of pending submissions
   - Subtitle: "Review submissions"

3. **Review Pending Submissions**
   - You'll see a list of all pending business submissions
   - Each card shows:
     - Business name and category
     - Submission date (e.g., "2 days ago")
     - Orange "Pending" badge
     - Preview of business details

4. **View Full Details**
   - Tap any business card to see complete information:
     - All business details
     - Uploaded images (swipeable gallery)
     - Contact information
     - Location details
     - Submission timestamp

5. **Approve or Reject**
   - **To Approve:**
     - Click the green **"Approve"** button
     - Confirm in the dialog
     - Business moves to the "businesses" table
     - Owner receives "Business Approved! 🎉" notification
     - Business becomes publicly visible
   - **To Reject:**
     - Click the red **"Reject"** button
     - Enter a detailed rejection reason (required)
     - Confirm rejection
     - Business remains in submissions with "rejected" status
     - Owner receives notification with your rejection reason

### Statistics Dashboard

At the top of Business Approvals screen, you'll see:

- **Total Submissions** - All time
- **Approved** - Currently live businesses
- **Pending** - Awaiting your review
- **Rejected** - Denied submissions

### Search & Filter Options

- **Search Bar** - Search by name, description, or city
- **Category Filter** - Filter by business category (17 options)
- **Sort Options:**
  - Newest First (default)
  - Oldest First (review backlog)
  - By Name (alphabetical)
- **Clear Filters** - Reset all filters

---

## 📊 Where Data is Stored

### Supabase Database Tables

1. **business_submissions** (Pending approvals)
   - Status: `pending`, `approved`, `rejected`, `suspended`
   - Contains all submitted business data
   - Includes rejection_reason if rejected
   - Tracks reviewed_by (admin ID) and reviewed_at timestamp

2. **businesses** (Approved businesses)
   - Only approved businesses appear here
   - Visible to all app users
   - Has additional fields:
     - `is_featured` (for Featured Businesses)
     - `rating` and `review_count`
     - `subscription_plan` (free, basic, premium, enterprise)

3. **notifications** (User notifications)
   - Automatic notifications created on approve/reject
   - Users can view in-app notifications
   - Types: `business_approved`, `business_rejected`

4. **user_roles** (Admin permissions)
   - Determines who can access admin panel
   - Role types: `admin`, `moderator`, `user`

### Supabase Storage

- **Bucket:** `BUSINESS-IMAGES` (or `business-images`)
- **Structure:** `{userId}/{timestamp}.jpg`
- **Policies:**
  - Authenticated users can upload
  - Public can read/view
  - Users can delete their own images

---

## 🔔 Notification System

### When Notifications Are Sent

1. **Business Approved:**

   ```
   Title: "Business Approved! 🎉"
   Message: "Your business '{name}' has been approved and is now live!"
   ```

2. **Business Rejected:**
   ```
   Title: "Business Submission Update"
   Message: "Your business '{name}' needs revision. Reason: {admin_reason}"
   ```

### How to View Notifications

- Notifications are stored in the `notifications` table
- Users can query their notifications via the app
- Unread notifications show `read = false`
- Future enhancement: Push notifications via FCM

---

## 🎨 Featured Businesses

### How to Mark a Business as Featured

Only admins can mark businesses as featured:

1. **Via Supabase Dashboard:**
   - Go to `businesses` table
   - Find the approved business
   - Set `is_featured = true`
   - Optionally set `featured_rank` for ordering (1 = top)

2. **Via App (Future Enhancement):**
   - Add a "Mark as Featured" button in Business Approvals
   - Allow admins to promote businesses to featured status

### Featured Business Benefits

- Appears in "Featured Businesses" section
- Higher visibility to customers
- Can be part of premium/paid subscription plans

---

## 🚀 Quick Navigation Guide

### For Customers:

```
Home Screen
  → Business Directory
    → "Add Business" button (bottom-right)
      → Fill form
        → Submit
          → Wait for approval
```

### For Admins:

```
Settings
  → Admin Portal
    → Business Approvals (first card)
      → View pending list
        → Tap business card
          → Approve or Reject
```

---

## 🔒 Security Features

### Row Level Security (RLS)

1. **Submissions:**
   - Users can only view/insert their own submissions
   - Admins can view/update all submissions
   - Only admins can change status to approved/rejected

2. **Businesses:**
   - Anyone can view approved businesses
   - Owners can view/update their own businesses
   - Admins have full access

3. **Images:**
   - Authenticated users can upload
   - Public can view (public bucket)
   - Users can delete only their own images

### Admin Authentication

- Admin access requires `user_roles` table entry
- Role must be `admin` or `moderator`
- Without admin role, Admin Portal shows "Access Denied"

---

## 📝 Common Questions

### Q: Why can't customers see the "Submit Business" button?

**A:** Make sure you're on the **Business Directory** screen. The button is a floating action button at the bottom-right.

### Q: Where do I see businesses I submitted?

**A:** Future enhancement - add "My Businesses" screen. Currently, you can check the `business_submissions` table in Supabase filtered by your `owner_id`.

### Q: Can customers approve their own businesses?

**A:** No, only admins can approve businesses. This ensures quality control.

### Q: How do I become an admin?

**A:** An existing admin must add your user ID to the `user_roles` table with `role = 'admin'`.

### Q: What happens to rejected businesses?

**A:** They remain in `business_submissions` with `status = 'rejected'`. The owner can see the reason and resubmit a new application.

### Q: Can approved businesses be edited?

**A:** Yes, business owners can update their business details. Admins can also edit any business.

### Q: How many images can I upload?

**A:** Maximum 5 images per business. Each image must be under 5MB.

---

## 🎯 Testing Checklist

### Customer Flow:

- [ ] Navigate to Business Directory
- [ ] Find "Add Business" button (bottom-right)
- [ ] Fill all required fields
- [ ] Upload 1-5 images
- [ ] Submit successfully
- [ ] See success confirmation

### Admin Flow:

- [ ] Open Admin Portal from Settings
- [ ] Click "Business Approvals" card
- [ ] See pending business in list
- [ ] Click to view full details
- [ ] View uploaded images
- [ ] Approve business
- [ ] Check business appears in `businesses` table
- [ ] Verify notification created

### Database Verification:

- [ ] Check `business_submissions` table has new entry
- [ ] After approval, check `businesses` table
- [ ] Check `notifications` table has approval notification
- [ ] Verify images in Storage bucket

---

## 💡 Future Enhancements

1. **My Businesses Screen** - Let users view their submitted/approved businesses
2. **Edit Business** - Let owners update their business details
3. **Business Analytics** - Show views, clicks, rating for each business
4. **Featured Business Request** - Let owners request featured status (paid)
5. **Bulk Operations** - Let admins approve/reject multiple businesses at once
6. **Advanced Search** - Search by location, rating, distance
7. **Push Notifications** - Real-time notifications via Firebase Cloud Messaging
8. **Business Reviews** - Let customers rate and review businesses
9. **Business Dashboard** - Analytics for business owners
10. **Subscription Plans** - Paid features for businesses

---

## 📞 Support

For issues or questions:

1. Check this guide thoroughly
2. Review the Supabase tables and policies
3. Check app logs for errors
4. Verify user has correct permissions

---

**Last Updated:** January 24, 2026
**Version:** 1.0
