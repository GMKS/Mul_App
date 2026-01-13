import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  String _phoneNumber = '';
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    String input = _phoneController.text.trim();
    // Validate and format Indian phone number
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_otpSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+91 ',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                child:
                    _isLoading ? CircularProgressIndicator() : Text('Send OTP'),
              ),
            ] else ...[
              Text('OTP sent to $_phoneNumber'),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Verify OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
