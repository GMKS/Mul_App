# 🔐 Admin Login & Business Submission Guide

## Problem Fixed ✅

The "anonymous_user UUID error" has been resolved. The app now properly checks if you're signed in before allowing business submission.

---

## 🚀 Quick Start: Access Admin Dashboard

### Step 1: Open Settings

1. Tap the **Settings** tab at the bottom (4th icon)

### Step 2: Activate Admin Login Dialog

1. Tap the **version text** (v1.0.0) at the bottom **7 times**
2. An **Admin Login dialog** will appear

### Step 3: Sign In as Admin

**Default credentials (pre-filled):**

- **Email:** `admin@gmail.com`
- **Password:** `admin123`

Click **Sign In** button.

---

## ⚠️ Important: Create Admin Account in Supabase

The admin account must exist in your Supabase project:

### Option 1: Via Supabase Dashboard (Recommended)

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **Authentication → Users**
4. Click **Add user** → **Create new user**
5. Enter:
   - **Email:** `admin@gmail.com`
   - **Password:** `admin123`
   - ✅ Check **Auto Confirm User**
6. Click **Create user**

### Option 2: Via App Sign Up (If enabled)

If you've enabled email sign-up in your app, you can register from the login screen.

---

## 📱 How to Submit a Business (For Users)

### Before Submitting

**You must be signed in** (not anonymous). The app will show an error if you're not authenticated.

### Sign In Options:

1. **Phone OTP** (default method)
2. **Email/Password** (for admin)
3. **DO NOT** use anonymous sign-in for business submission

### Submit Business Steps:

1. Go to **Business** tab
2. Tap **➕ Add Business** button
3. Fill in the form:
   - Business name
   - Description
   - Category
   - Phone number (required)
   - Address, City, State
   - WhatsApp (optional)
   - Email (optional)
   - Website (optional)
   - Upload images (optional, up to 5)
4. Tap **Submit for Approval**

The business will go to **Pending** status and wait for admin approval.

---

## 👨‍💼 Admin Features (After Login)

Once signed in as admin, you'll see the **Admin Dashboard** card in Settings:

### Admin Actions:

1. **View Pending Businesses** - See all submissions waiting for approval
2. **Approve Businesses** - Accept and publish businesses
3. **Reject Businesses** - Decline with reason
4. **View Statistics:**
   - Total businesses
   - Pending approvals
   - Approved count
   - Rejected count
5. **View Rejected List** - See all previously rejected businesses

### Approve/Reject Flow:

1. Tap **Admin Dashboard** in Settings
2. Review each business submission
3. Tap ✅ **Approve** or ❌ **Reject**
4. For rejections, provide a reason
5. Stats update in real-time

---

## 🐛 Troubleshooting

### "Invalid input syntax for type uuid: anonymous_user"

**Solution:** You're not signed in. Sign in with email or phone OTP first.

### Admin Dashboard Not Showing

**Possible causes:**

1. Not signed in as admin@gmail.com
2. Admin account doesn't exist in Supabase
3. Didn't tap version text 7 times

**Solution:**

1. Sign out (if needed)
2. Tap version text 7 times in Settings
3. Sign in with admin@gmail.com / admin123
4. Admin section should appear

### Can't Sign In as Admin

**Solution:**

1. Check if admin account exists in Supabase (see "Create Admin Account" above)
2. Verify email and password are correct
3. Check Supabase console logs for auth errors

### Business Submission Fails

**Common issues:**

1. **Not signed in** - Must use real authentication (not anonymous)
2. **Missing required fields** - Name, category, phone are required
3. **Invalid phone format** - Must start with +91 for India

---

## 🔧 Technical Details

### Files Modified:

- `lib/screens/settings_screen.dart` - Added admin login dialog
- `lib/services/auth_service.dart` - Added email authentication
- `lib/screens/business/submit_business_screen_enhanced.dart` - Fixed auth check
- `lib/services/business_service_supabase.dart` - Fixed database columns

### Database Tables:

- `business_submissions` - Pending businesses (status: pending/approved/rejected)
- `businesses` - Approved businesses (live directory)

### Admin Email Check:

The app checks if the signed-in user's email matches:

- `admin@gmail.com`
- `admin@example.com`

To add more admin emails, modify `_checkAdminStatus()` in settings_screen.dart.

---

## 📊 Feature Summary

| Feature             | Status     | How to Use                        |
| ------------------- | ---------- | --------------------------------- |
| Admin Login         | ✅ Fixed   | Tap version 7x → Sign in          |
| Business Submission | ✅ Fixed   | Must be signed in (not anonymous) |
| Approval System     | ✅ Working | Admin Dashboard → Approve/Reject  |
| Statistics          | ✅ Working | Auto-updates after actions        |
| Rejected Viewer     | ✅ Added   | See all rejected businesses       |
| Email Auth          | ✅ Added   | For admin access                  |

---

## 🎯 Next Steps

1. ✅ Create admin account in Supabase
2. ✅ Test admin login (tap version 7x)
3. ✅ Sign in as regular user (phone OTP)
4. ✅ Submit test business
5. ✅ Switch to admin account
6. ✅ Approve/reject test business
7. ✅ Verify statistics update correctly

---

## 💡 Pro Tips

- **For Testing:** Use developer mode (7-tap) to quickly switch between admin and regular user
- **For Production:** Set up proper admin emails and disable developer mode
- **Security:** Change default admin password immediately in production
- **Database:** Add index on `status` column in business_submissions for faster queries

---

Need help? Check the error logs in the app or Supabase dashboard logs.
