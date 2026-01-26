/// Settings Screen
/// Display FCM Token, Religion settings, and other app settings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/religion_service.dart';
import '../services/auth_service.dart';
import '../models/devotional_video_model.dart';
import '../models/user_model.dart';
import '../providers/localization_provider.dart';
import 'devotional/religion_selection_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'business/business_approval_screen_enhanced.dart';
import 'moderation/safety_center_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _fcmToken;
  bool _isLoading = true;
  Religion? _selectedReligion;
  UserProfile? _currentUser;
  bool _isAdmin = false;
  int _debugTapCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
    _loadReligion();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    // Check if user is admin
    try {
      final user = Supabase.instance.client.auth.currentUser;
      debugPrint('🔍 Checking admin status for user: ${user?.email}');

      if (user != null) {
        // Check if user email is admin email
        final isAdminEmail = user.email == 'admin@gmail.com' ||
            user.email == 'admin@example.com' ||
            user.email == 'seenaigmk@gmail.com';

        debugPrint('✅ User email: ${user.email}, Is Admin: $isAdminEmail');

        // Create user profile
        _currentUser = UserProfile(
          id: user.id,
          name: user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          userType: isAdminEmail ? UserType.admin : UserType.user,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
        setState(() {
          _isAdmin = isAdminEmail;
        });
        debugPrint('📋 Admin status set to: $_isAdmin');
      } else {
        debugPrint('❌ No user logged in');
      }
    } catch (e) {
      debugPrint('❌ Error checking admin status: $e');
      // Silently fail - user is not admin
      setState(() {
        _isAdmin = false;
      });
    }
  }

  Future<void> _loadFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');

      setState(() {
        _fcmToken = token ?? NotificationService().fcmToken;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _fcmToken = NotificationService().fcmToken;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReligion() async {
    final religion = await ReligionService.getSelectedReligion();
    setState(() {
      _selectedReligion = religion;
    });
  }

  Future<void> _changeReligion() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReligionSelectionScreen(),
      ),
    );
    if (result != null && result is Religion) {
      setState(() {
        _selectedReligion = result;
      });
    }
  }

  void _copyToClipboard() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF16213e),
      ),
      backgroundColor: const Color(0xFF1a1a2e),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                print('🔄 Building Settings Screen - _isAdmin: $_isAdmin');
                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Debug: Show current user status
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login Status:',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Email: ${_currentUser?.email ?? "Not logged in"}',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          Text(
                            'Admin: ${_isAdmin ? "YES ✅" : "NO ❌"}',
                            style: TextStyle(
                              color:
                                  _isAdmin ? Colors.greenAccent : Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isAdmin && _currentUser != null)
                            Text(
                              'Note: Only admin@gmail.com gets admin access',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),

                    // Admin Panel Access (only for admins)
                    if (_isAdmin) ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BusinessApprovalScreenEnhanced(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8b5cf6), Color(0xFF6366f1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8b5cf6).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Business Approvals',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Manage pending business submissions',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Safety Center Section (for all users)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SafetyCenterScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9B59B6), Color(0xFF8e44ad)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9B59B6).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.shield,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Safety Center',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Reports, guidelines & safety tools',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Language Preference Section
                    _buildSection(
                      title: 'Language Preference',
                      icon: Icons.language,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select your preferred app language',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _showLanguageSelection,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.translate,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Consumer<LocalizationProvider>(
                                      builder: (context, provider, _) {
                                        return Text(
                                          provider.getLanguageName(
                                              provider.locale.languageCode),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Religion Section
                    _buildSection(
                      title: 'Religion Preference',
                      icon: Icons.self_improvement,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your selected religion for devotional content',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _changeReligion,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  if (_selectedReligion != null) ...[
                                    Text(
                                      _selectedReligion!.icon,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedReligion!.displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white54,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'Select Religion',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // FCM Token Section
                    _buildSection(
                      title: 'FCM Token (For API Testing)',
                      icon: Icons.key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Use this token to send test notifications from Firebase Console or your backend API.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_fcmToken != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: SelectableText(
                                _fcmToken!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _copyToClipboard,
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy Token'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                              ),
                            ),
                          ] else
                            const Text(
                              'FCM Token not available. Please restart the app.',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Instructions
                    _buildSection(
                      title: 'How to Use FCM Token',
                      icon: Icons.info_outline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstruction(
                            '1',
                            'Copy the token using the button above',
                          ),
                          _buildInstruction(
                            '2',
                            'Go to Firebase Console > Cloud Messaging',
                          ),
                          _buildInstruction(
                            '3',
                            'Click "Send your first message"',
                          ),
                          _buildInstruction(
                            '4',
                            'Paste your token in the "FCM registration token" field',
                          ),
                          _buildInstruction(
                            '5',
                            'Send test notification!',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Developer Mode Toggle (for testing)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _debugTapCount++;
                        });

                        // 7 taps = show login dialog
                        if (_debugTapCount >= 7 && _debugTapCount < 10) {
                          _showAdminLoginDialog();
                          setState(() {
                            _debugTapCount = 0;
                          });
                        }

                        // 10 taps = force admin mode (for testing)
                        if (_debugTapCount >= 10) {
                          setState(() {
                            _isAdmin = !_isAdmin;
                            _debugTapCount = 0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isAdmin
                                  ? '🔓 ADMIN MODE ENABLED (Testing)\nScroll up to see Admin Dashboard'
                                  : '🔒 Admin Mode Disabled'),
                              backgroundColor:
                                  _isAdmin ? Colors.green : Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                          // Scroll to top to show admin panel
                          if (_isAdmin && _scrollController.hasClients) {
                            _scrollController.animateTo(
                              0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          }
                        }
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'v1.0.0 ${_isAdmin ? "• ADMIN MODE" : ""}',
                            style: TextStyle(
                              color: _isAdmin
                                  ? Colors.greenAccent
                                  : Colors.white54,
                              fontSize: 12,
                              fontWeight: _isAdmin
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
    );
  }

  void _showAdminLoginDialog() {
    final emailController = TextEditingController(text: 'admin@gmail.com');
    final passwordController = TextEditingController(text: 'admin123');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings,
                  color: Colors.greenAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'Admin Login',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor:
                      Color(0xFF22242A), // dark background for visibility
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor:
                      Color(0xFF22242A), // dark background for visibility
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Default: admin@gmail.com / admin123',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() => isLoading = true);

                        try {
                          print(
                              '🔵 Creating account for: ${emailController.text.trim()}');
                          print(
                              '🔵 Password: ${passwordController.text.isNotEmpty ? "***" : "EMPTY!"}');

                          final response = await AuthService.signUpWithEmail(
                            email: emailController.text.trim(),
                            password: passwordController.text,
                          );

                          if (response?.user != null) {
                            print(
                                '✅ Account created successfully: ${response?.user?.id}');
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '✅ Admin account created!\nEmail: ${response?.user?.email}\nNow click Sign In'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 4),
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '⚠️ Account might exist already. Try Sign In'),
                                backgroundColor: Colors.orange,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          print('❌ Account creation error: $e');
                          String errorMsg = 'Account creation failed';
                          if (e.toString().contains('already registered')) {
                            errorMsg = 'Account exists! Use Sign In button';
                          } else if (e.toString().contains('password')) {
                            errorMsg = 'Password too short (min 6 characters)';
                          } else {
                            errorMsg = e.toString();
                          }
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ $errorMsg'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } finally {
                          setDialogState(() => isLoading = false);
                        }
                      },
                child: const Text(
                  'Create Admin Account',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);

                      try {
                        final response = await AuthService.signInWithEmail(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );

                        if (response?.user != null) {
                          print(
                              '✅ Login successful! User: ${response?.user?.email}');
                          Navigator.pop(context);

                          // Wait a bit for dialog to close, then refresh admin status
                          await Future.delayed(Duration(milliseconds: 100));
                          await _checkAdminStatus();

                          // Scroll to top to show admin panel
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          }

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isAdmin
                                  ? '🔓 Admin Login Successful!\n👆 Scroll up to see Admin Dashboard'
                                  : '✅ Logged in as ${response?.user?.email}'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '❌ Invalid credentials - User may not exist'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (e) {
                        print('🔴 Admin login error details: $e');
                        String errorMsg = 'Login failed';
                        if (e
                            .toString()
                            .contains('Invalid login credentials')) {
                          errorMsg =
                              'Wrong email or password. Check Supabase dashboard';
                        } else if (e
                            .toString()
                            .contains('Email not confirmed')) {
                          errorMsg =
                              'Email not confirmed. Check Supabase dashboard';
                        } else if (e.toString().contains('User not found')) {
                          errorMsg =
                              'User does not exist. Create account first';
                        } else {
                          errorMsg = e.toString();
                        }
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ $errorMsg'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      } finally {
                        setDialogState(() => isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelection() {
    final provider = Provider.of<LocalizationProvider>(context, listen: false);
    final languages = [
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'te', 'name': 'తెలుగు (Telugu)', 'flag': '🇮🇳'},
      {'code': 'hi', 'name': 'हिंदी (Hindi)', 'flag': '🇮🇳'},
      {'code': 'ta', 'name': 'தமிழ் (Tamil)', 'flag': '🇮🇳'},
      {'code': 'kn', 'name': 'ಕನ್ನಡ (Kannada)', 'flag': '🇮🇳'},
      {'code': 'ml', 'name': 'മലയാളം (Malayalam)', 'flag': '🇮🇳'},
      {'code': 'bn', 'name': 'বাংলা (Bengali)', 'flag': '🇮🇳'},
      {'code': 'mr', 'name': 'मराठी (Marathi)', 'flag': '🇮🇳'},
      {'code': 'gu', 'name': 'ગુજરાતી (Gujarati)', 'flag': '🇮🇳'},
      {'code': 'pa', 'name': 'ਪੰਜਾਬੀ (Punjabi)', 'flag': '🇮🇳'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: languages.map((lang) {
                    final isSelected =
                        provider.locale.languageCode == lang['code'];
                    return ListTile(
                      leading: Text(
                        lang['flag'] ?? '',
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        lang['name'] ?? '',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Color(0xFF6C63FF))
                          : null,
                      onTap: () {
                        provider.setLocale(Locale(lang['code']!));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Language changed to ${lang['name']!}'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6C63FF)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
