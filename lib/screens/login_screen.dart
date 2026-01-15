import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String _phoneNumber = '';

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    String input = _phoneController.text.trim();
    if (input.startsWith('+91') && input.length == 13) {
      _phoneNumber = input;
    } else if (input.startsWith('91') && input.length == 12) {
      _phoneNumber = '+$input';
    } else if (input.length == 10 && input.startsWith('9')) {
      _phoneNumber = '+91$input';
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Indian mobile number')),
      );
      return;
    }
    final otpSent = await AuthService.signInWithPhone(_phoneNumber);
    setState(() => _isLoading = false);
    if (otpSent) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to $_phoneNumber')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);
    final otpCode = _otpController.text.trim();
    final response =
        await AuthService.verifyOTP(phone: _phoneNumber, token: otpCode);
    setState(() => _isLoading = false);
    if (response != null && response.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  void _resendOtp() async {
    if (_phoneNumber.isNotEmpty) {
      setState(() => _isLoading = true);
      final otpSent = await AuthService.signInWithPhone(_phoneNumber);
      setState(() => _isLoading = false);
      if (otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP resent to $_phoneNumber')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP')),
        );
      }
    }
  }

  void _loginWithSocial(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Social login with $provider not implemented')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6B4CE6),
              Color(0xFF5A3CC4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/login_illustration.png',
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person,
                            size: 80, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Hello',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please Login to Your Account',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_otpSent) ...[
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'OTP',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: _otpSent
                              ? TextButton(
                                  onPressed: _isLoading ? null : _resendOtp,
                                  child: const Text('Resend OTP'),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _otpSent
                                    ? _verifyOtp
                                    : _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4CE6),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(_otpSent ? 'Login' : 'Send OTP',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Or Login using Social Media Account'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.facebook,
                                  color: Colors.blue),
                              onPressed: () => _loginWithSocial('Facebook'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.g_mobiledata,
                                  color: Colors.red),
                              onPressed: () => _loginWithSocial('Google'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.linked_camera,
                                  color: Colors.green),
                              onPressed: () => _loginWithSocial('LinkedIn'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
