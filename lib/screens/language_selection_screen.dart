// STEP 1: Language Selection Screen
// Create a language selection screen shown on first login.
// Allow selecting primary and secondary languages.
// Save selection locally and in backend user profile.

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/language_service.dart';
import 'region_selection_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isInitialSetup;
  final VoidCallback? onComplete;

  const LanguageSelectionScreen({
    super.key,
    this.isInitialSetup = true,
    this.onComplete,
  });

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _primaryLanguage;
  String? _secondaryLanguage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  Future<void> _loadExistingPreferences() async {
    final primary = await LanguageService.getPrimaryLanguage();
    final secondary = await LanguageService.getSecondaryLanguage();
    setState(() {
      _primaryLanguage = primary;
      _secondaryLanguage = secondary;
    });
  }

  Future<void> _saveAndContinue() async {
    if (_primaryLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a primary language')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await LanguageService.saveLanguagePreferences(
        primaryLanguage: _primaryLanguage!,
        secondaryLanguage: _secondaryLanguage,
      );

      if (widget.isInitialSetup) {
        // Navigate to region selection
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegionSelectionScreen(
                isInitialSetup: true,
                onComplete: widget.onComplete,
              ),
            ),
          );
        }
      } else {
        widget.onComplete?.call();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade700],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.language,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose Your Language',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your preferred languages for a personalized experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Language selection
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Language
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Text(
                        'Primary Language *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildLanguageGrid(
                      selectedLanguage: _primaryLanguage,
                      onSelect: (code) {
                        setState(() {
                          _primaryLanguage = code;
                          // Clear secondary if same as primary
                          if (_secondaryLanguage == code) {
                            _secondaryLanguage = null;
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Secondary Language
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: Row(
                        children: [
                          const Text(
                            'Secondary Language',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildLanguageGrid(
                      selectedLanguage: _secondaryLanguage,
                      excludeLanguage: _primaryLanguage,
                      onSelect: (code) {
                        setState(() {
                          _secondaryLanguage =
                              _secondaryLanguage == code ? null : code;
                        });
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Continue button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageGrid({
    required String? selectedLanguage,
    String? excludeLanguage,
    required Function(String) onSelect,
  }) {
    final languages = AppLanguage.supportedLanguages
        .where((lang) => lang.code != excludeLanguage)
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final language = languages[index];
        final isSelected = selectedLanguage == language.code;

        return GestureDetector(
          onTap: () => onSelect(language.code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.red : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.nativeName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.red : Colors.black87,
                      ),
                    ),
                    Text(
                      language.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.red,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
