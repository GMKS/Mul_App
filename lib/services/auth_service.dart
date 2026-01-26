import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // Anonymous Sign In
  static Future<AuthResponse?> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();
      debugPrint('✅ Anonymous sign in successful: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('❌ Anonymous sign in error: $e');
      return null;
    }
  }

  // Phone Sign In - Send OTP
  static Future<bool> signInWithPhone(String phoneNumber) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
      debugPrint('✅ OTP sent to $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('❌ Phone sign in error: $e');
      return false;
    }
  }

  // Verify OTP
  static Future<AuthResponse?> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: token,
      );
      debugPrint('✅ OTP verification successful: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('❌ OTP verification error: $e');
      return null;
    }
  }

  // Sign Out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  // Auto Sign In (for anonymous users)
  static Future<void> ensureUserSignedIn() async {
    if (!isLoggedIn) {
      await signInAnonymously();
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // Email Sign In (for admin users)
  static Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Email sign in successful: ${response.user?.id}');
      debugPrint('✅ User email: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('❌ Email sign in error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Email Sign Up (for creating admin accounts)
  static Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint(
          '🔵 Attempting sign up for: $email with password length: ${password.length}');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Skip email confirmation for testing
      );
      debugPrint('✅ Email sign up successful: ${response.user?.id}');
      debugPrint('✅ User email: ${response.user?.email}');
      debugPrint('✅ Session exists: ${response.session != null}');
      return response;
    } catch (e) {
      debugPrint('❌ Email sign up error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}
