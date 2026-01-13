// BUSINESS FEATURE 2: Business Profile Creation Screen
// Business onboarding screen for BUSINESS users

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';
import '../../services/business_verification_service.dart';

class BusinessOnboardingScreen extends StatefulWidget {
  final UserProfile? existingProfile;
  final Function(UserProfile) onComplete;

  const BusinessOnboardingScreen({
    super.key,
    this.existingProfile,
    required this.onComplete,
  });

  @override
  State<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState extends State<BusinessOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();

  String? _selectedCategory;
  String? _selectedState;
  bool _sameAsPhone = true;
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _verificationId;
  final _otpController = TextEditingController();

  final List<String> _states = [
    'Andhra Pradesh',
    'Karnataka',
    'Kerala',
    'Maharashtra',
    'Tamil Nadu',
    'Telangana',
    'Gujarat',
    'Rajasthan',
    'West Bengal',
    'Punjab',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _businessNameController.text = widget.existingProfile!.businessName ?? '';
      _phoneController.text = widget.existingProfile!.phoneNumber ?? '';
      _whatsappController.text = widget.existingProfile!.whatsappNumber ?? '';
      _cityController.text = widget.existingProfile!.city;
      _areaController.text = widget.existingProfile!.area ?? '';
      _selectedCategory = widget.existingProfile!.businessCategory;
      _selectedState = widget.existingProfile!.state;
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _pageController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await BusinessVerificationService.sendOtp(
        _phoneController.text,
      );

      if (result['success']) {
        _verificationId = result['verificationId'];
        _showOtpDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to send OTP')),
        );
      }
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the OTP sent to +91 ${_phoneController.text}'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '000000',
                counterText: '',
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _otpController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _verifyOtp(context),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp(BuildContext dialogContext) async {
    if (_otpController.text.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final result = await BusinessVerificationService.verifyOtp(
        _verificationId!,
        _otpController.text,
      );

      if (result['success']) {
        Navigator.pop(dialogContext);
        _submitProfile(isVerified: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Invalid OTP')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      _otpController.clear();
    }
  }

  Future<void> _submitProfile({bool isVerified = false}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = UserProfile(
        id: widget.existingProfile?.id ??
            'business_${DateTime.now().millisecondsSinceEpoch}',
        name: _businessNameController.text,
        email: widget.existingProfile?.email ?? '',
        userType: UserType.business,
        businessName: _businessNameController.text,
        businessCategory: _selectedCategory,
        phoneNumber: _phoneController.text,
        whatsappNumber:
            _sameAsPhone ? _phoneController.text : _whatsappController.text,
        state: _selectedState ?? '',
        city: _cityController.text,
        area: _areaController.text,
        planType: BusinessPlanType.free,
        isVerified: isVerified,
        verifiedAt: isVerified ? DateTime.now() : null,
        createdAt: widget.existingProfile?.createdAt ?? DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      widget.onComplete(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isVerified ? Icons.verified : Icons.check_circle,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(isVerified
                    ? 'Business profile verified and saved!'
                    : 'Business profile saved!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildBusinessInfoPage(),
                  _buildContactPage(),
                  _buildLocationPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_currentPage < 2) {
                                if (_validateCurrentPage()) {
                                  _nextPage();
                                }
                              } else {
                                _submitProfile();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentPage < 2 ? 'Continue' : 'Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        if (_businessNameController.text.isEmpty) {
          _showError('Please enter your business name');
          return false;
        }
        if (_selectedCategory == null) {
          _showError('Please select a business category');
          return false;
        }
        return true;
      case 1:
        if (_phoneController.text.length != 10) {
          _showError('Please enter a valid 10-digit phone number');
          return false;
        }
        if (!_sameAsPhone && _whatsappController.text.length != 10) {
          _showError('Please enter a valid WhatsApp number');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildBusinessInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your business',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Business name
          TextFormField(
            controller: _businessNameController,
            decoration: InputDecoration(
              labelText: 'Business/Shop Name *',
              hintText: 'Enter your business name',
              prefixIcon: const Icon(Icons.store),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          // Category dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Business Category *',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: BusinessCategory.categories.map((cat) {
              return DropdownMenuItem(
                value: cat.id,
                child: Row(
                  children: [
                    Icon(cat.icon, size: 20, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(cat.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) => value == null ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How can customers reach you?',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // Phone number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: '9876543210',
              prefixIcon: const Icon(Icons.phone),
              prefixText: '+91 ',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _isVerifying
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : TextButton(
                      onPressed: _sendOtp,
                      child: const Text('Verify'),
                    ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) =>
                value?.length != 10 ? 'Enter valid phone number' : null,
          ),
          const SizedBox(height: 16),

          // Same as phone checkbox
          CheckboxListTile(
            value: _sameAsPhone,
            onChanged: (value) => setState(() => _sameAsPhone = value!),
            title: const Text('WhatsApp number is same as phone'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),

          // WhatsApp number (if different)
          if (!_sameAsPhone) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _whatsappController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'WhatsApp Number *',
                hintText: '9876543210',
                prefixIcon: const Icon(Icons.chat, color: Colors.green),
                prefixText: '+91 ',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) =>
                  value?.length != 10 ? 'Enter valid WhatsApp number' : null,
            ),
          ],

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Verify your phone number to get a verified badge on your business profile.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Location',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where is your business located?',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),

          // State dropdown
          DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: InputDecoration(
              labelText: 'State *',
              prefixIcon: const Icon(Icons.map),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _states.map((state) {
              return DropdownMenuItem(value: state, child: Text(state));
            }).toList(),
            onChanged: (value) => setState(() => _selectedState = value),
            validator: (value) => value == null ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          // City
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City *',
              hintText: 'Enter your city',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          // Area
          TextFormField(
            controller: _areaController,
            decoration: InputDecoration(
              labelText: 'Area/Locality',
              hintText: 'Enter your area or locality',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Local Visibility',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your business videos will be prioritized for users in your city and nearby areas.',
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
