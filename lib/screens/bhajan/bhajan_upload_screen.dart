/// Bhajan Upload Screen
/// Allows contributors to upload bhajans with full metadata
/// Features: AI moderation, multi-language support, category selection

import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/bhajan_model.dart';
import '../../services/bhajan_service.dart';

class BhajanUploadScreen extends StatefulWidget {
  const BhajanUploadScreen({super.key});

  @override
  State<BhajanUploadScreen> createState() => _BhajanUploadScreenState();
}

class _BhajanUploadScreenState extends State<BhajanUploadScreen> {
  final BhajanService _bhajanService = BhajanService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Selection State
  BhajanType _selectedType = BhajanType.audio;
  BhajanCategory _selectedCategory = BhajanCategory.bhakti;
  BhajanMood? _selectedMood;
  String _selectedLanguage = 'Hindi';
  String? _selectedDeity;
  String? _selectedReligion;
  String? _selectedFestival;

  // File State
  String? _selectedFilePath;
  String? _selectedCoverPath;
  String? _selectedLyricsFilePath;

  // Upload State
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadError;
  bool _agreeToTerms = false;

  // Options
  final List<String> _languages = [
    'Hindi',
    'Sanskrit',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Gujarati',
    'Bengali',
    'Punjabi',
    'English',
  ];

  final List<String> _deities = [
    'Krishna',
    'Shiva',
    'Hanuman',
    'Ganesha',
    'Durga',
    'Lakshmi',
    'Saraswati',
    'Vishnu',
    'Ram',
    'Sai Baba',
    'Shirdi Sai',
    'Other',
  ];

  final List<String> _religions = [
    'Hindu',
    'Sikh',
    'Buddhist',
    'Jain',
    'Multi-faith',
    'Universal',
  ];

  final List<String> _festivals = [
    'Diwali',
    'Holi',
    'Navratri',
    'Janmashtami',
    'Ganesh Chaturthi',
    'Maha Shivaratri',
    'Ram Navami',
    'Hanuman Jayanti',
    'Guru Purnima',
    'Karwa Chauth',
    'None / Everyday',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _lyricsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Bhajan'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _saveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: _isUploading ? _buildUploadingState() : _buildForm(),
    );
  }

  Widget _buildUploadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _uploadProgress,
                    strokeWidth: 8,
                    backgroundColor: Colors.orange[100],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
                Text(
                  '${(_uploadProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Uploading your Bhajan...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we process your file',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            if (_uploadProgress > 0.7) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'AI Moderation in progress...',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guidelines Banner
            _buildGuidelinesBanner(),
            const SizedBox(height: 24),

            // Media Upload Section
            _buildSectionTitle('Media', Icons.cloud_upload),
            _buildMediaUploadCard(),
            const SizedBox(height: 24),

            // Type Selection
            _buildSectionTitle('Type', Icons.music_note),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Basic Info
            _buildSectionTitle('Basic Information', Icons.info),
            _buildBasicInfoFields(),
            const SizedBox(height: 24),

            // Categorization
            _buildSectionTitle('Categorization', Icons.category),
            _buildCategorizationFields(),
            const SizedBox(height: 24),

            // Lyrics
            _buildSectionTitle('Lyrics (Optional)', Icons.lyrics),
            _buildLyricsSection(),
            const SizedBox(height: 24),

            // Tags
            _buildSectionTitle('Tags', Icons.tag),
            _buildTagsField(),
            const SizedBox(height: 24),

            // Terms
            _buildTermsCheckbox(),
            const SizedBox(height: 16),

            // Error Message
            if (_uploadError != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreeToTerms ? _submitUpload : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Submit for Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info about moderation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI-Powered Moderation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your upload will be reviewed by our AI moderation system and then by human moderators. This usually takes 24-48 hours.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelinesBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[400]!, Colors.orange[300]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Guidelines',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Only upload original or properly licensed content. Devotional music that respects all traditions.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showGuidelines,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaUploadCard() {
    return GestureDetector(
      onTap: _pickMediaFile,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedFilePath != null ? Colors.green : Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedFilePath != null
            ? _buildSelectedFileCard()
            : _buildUploadPrompt(),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _selectedType == BhajanType.video ? Icons.videocam : Icons.audiotrack,
          size: 48,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to select ${_selectedType == BhajanType.video ? 'video' : 'audio'} file',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _selectedType == BhajanType.video
              ? 'MP4, MOV • Max 500MB • Up to 4K'
              : 'MP3, WAV, FLAC • Max 100MB • High Quality',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFileCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _selectedType == BhajanType.video
                  ? Icons.videocam
                  : Icons.audiotrack,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedFilePath!.split('/').last,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '15.2 MB • 5:32 duration',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Ready to upload',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => setState(() => _selectedFilePath = null),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeOption(
            type: BhajanType.audio,
            icon: Icons.audiotrack,
            label: 'Audio',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTypeOption(
            type: BhajanType.video,
            icon: Icons.videocam,
            label: 'Video',
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required BhajanType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.orange[800] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        // Title
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title *',
            hintText: 'e.g., Om Namah Shivaya - Morning Chant',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Tell listeners about this bhajan...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 48),
              child: Icon(Icons.description),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Cover Image
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickCoverImage,
                icon: const Icon(Icons.image),
                label: Text(
                  _selectedCoverPath != null
                      ? 'Cover Selected ✓'
                      : 'Add Cover Image',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorizationFields() {
    return Column(
      children: [
        // Category Dropdown
        DropdownButtonFormField<BhajanCategory>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: 'Category *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.category),
          ),
          items: BhajanCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(_categoryDisplayName(category)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedCategory = value);
          },
        ),
        const SizedBox(height: 16),

        // Mood Dropdown
        DropdownButtonFormField<BhajanMood>(
          value: _selectedMood,
          decoration: InputDecoration(
            labelText: 'Mood',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.mood),
          ),
          items: BhajanMood.values.map((mood) {
            return DropdownMenuItem(
              value: mood,
              child: Text(_moodDisplayName(mood)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedMood = value),
        ),
        const SizedBox(height: 16),

        // Language & Deity Row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: 'Language *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _languages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedLanguage = value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDeity,
                decoration: InputDecoration(
                  labelText: 'Deity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _deities.map((deity) {
                  return DropdownMenuItem(value: deity, child: Text(deity));
                }).toList(),
                onChanged: (value) => setState(() => _selectedDeity = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Religion & Festival Row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedReligion,
                decoration: InputDecoration(
                  labelText: 'Tradition',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _religions.map((religion) {
                  return DropdownMenuItem(
                      value: religion, child: Text(religion));
                }).toList(),
                onChanged: (value) => setState(() => _selectedReligion = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFestival,
                decoration: InputDecoration(
                  labelText: 'Festival',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _festivals.map((festival) {
                  return DropdownMenuItem(
                      value: festival, child: Text(festival));
                }).toList(),
                onChanged: (value) => setState(() => _selectedFestival = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLyricsSection() {
    return Column(
      children: [
        TextFormField(
          controller: _lyricsController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Lyrics Text',
            hintText:
                'Paste or type lyrics here...\n\nॐ जय जगदीश हरे\nस्वामी जय जगदीश हरे',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickLyricsFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _selectedLyricsFilePath != null
                      ? 'Lyrics File Added ✓'
                      : 'Upload Lyrics File (.txt, .lrc)',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            labelText: 'Tags',
            hintText: 'morning, peaceful, meditation, shiva',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.tag),
            helperText: 'Separate tags with commas',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['morning', 'devotional', 'peaceful', 'meditation', 'aarti']
              .map((tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () {
                      final current = _tagsController.text;
                      if (!current.contains(tag)) {
                        _tagsController.text =
                            current.isEmpty ? tag : '$current, $tag';
                      }
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      value: _agreeToTerms,
      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
      title: const Text(
        'I confirm this content is original or I have permission to upload',
        style: TextStyle(fontSize: 14),
      ),
      subtitle: GestureDetector(
        onTap: _showTerms,
        child: const Text(
          'Read Terms & Content Guidelines',
          style: TextStyle(
            color: Colors.orange,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ==================== ACTIONS ====================

  void _pickMediaFile() async {
    // In real app, use file_picker package
    setState(() {
      _selectedFilePath = '/mock/path/bhajan_audio.mp3';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File selected successfully')),
    );
  }

  void _pickCoverImage() async {
    setState(() {
      _selectedCoverPath = '/mock/path/cover.jpg';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cover image selected')),
    );
  }

  void _pickLyricsFile() async {
    setState(() {
      _selectedLyricsFilePath = '/mock/path/lyrics.lrc';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lyrics file selected')),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📝 Draft saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _submitUpload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFilePath == null) {
      setState(() => _uploadError = 'Please select a media file to upload');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    // Simulate upload progress
    for (var i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() => _uploadProgress = i / 100);
      }
    }

    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await _bhajanService.uploadBhajan(
        title: _titleController.text,
        mediaUrl: _selectedFilePath!,
        type: _selectedType,
        language: _selectedLanguage.toLowerCase(),
        uploadedBy: 'current_user_id',
        category: _selectedCategory,
        tags: tags,
        deity: _selectedDeity,
        religion: _selectedReligion,
        description: _descriptionController.text,
        lyricsText:
            _lyricsController.text.isNotEmpty ? _lyricsController.text : null,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Upload Successful!'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your bhajan has been submitted for review.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  '🤖 AI Moderation: Processing\n'
                  '👤 Human Review: Pending\n'
                  '⏱️ Estimated Time: 24-48 hours',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                Text(
                  'You will be notified once your bhajan is approved.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadError = 'Upload failed. Please try again.';
        });
      }
    }
  }

  void _showGuidelines() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Guidelines',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildGuidelineItem(
                '✅',
                'Original Content',
                'Upload bhajans you have created or have explicit permission to share.',
              ),
              _buildGuidelineItem(
                '✅',
                'High Quality',
                'Audio: 128kbps minimum, 320kbps recommended\nVideo: 720p minimum, 4K supported',
              ),
              _buildGuidelineItem(
                '✅',
                'Proper Metadata',
                'Include accurate title, language, deity, and category information.',
              ),
              _buildGuidelineItem(
                '✅',
                'Respectful Content',
                'Content should be respectful to all faiths and traditions.',
              ),
              _buildGuidelineItem(
                '❌',
                'No Copyright Violation',
                'Do not upload copyrighted content without permission.',
              ),
              _buildGuidelineItem(
                '❌',
                'No Political Content',
                'Bhajans should focus on devotion, not politics.',
              ),
              _buildGuidelineItem(
                '❌',
                'No Offensive Material',
                'Content that demeans any religion or community is prohibited.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content Guidelines & Terms'),
        content: const SingleChildScrollView(
          child: Text(
            '1. You must own or have rights to upload the content.\n\n'
            '2. Content must be devotional and respectful.\n\n'
            '3. No copyrighted material without permission.\n\n'
            '4. All uploads are subject to moderation.\n\n'
            '5. We reserve the right to remove content.\n\n'
            '6. By uploading, you grant us license to distribute.\n\n'
            '7. You are responsible for the accuracy of metadata.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  String _categoryDisplayName(BhajanCategory category) {
    switch (category) {
      case BhajanCategory.morning:
        return '🌅 Morning';
      case BhajanCategory.evening:
        return '🌆 Evening';
      case BhajanCategory.aarti:
        return '🪔 Aarti';
      case BhajanCategory.chalisa:
        return '📿 Chalisa';
      case BhajanCategory.mantra:
        return '🕉️ Mantra';
      case BhajanCategory.kirtan:
        return '🎤 Kirtan';
      case BhajanCategory.stotram:
        return '📜 Stotram';
      case BhajanCategory.bhakti:
        return '🙏 Bhakti';
      case BhajanCategory.meditation:
        return '🧘 Meditation';
      case BhajanCategory.festival:
        return '🎉 Festival';
      case BhajanCategory.general:
        return '📁 General';
    }
  }

  String _moodDisplayName(BhajanMood mood) {
    switch (mood) {
      case BhajanMood.peaceful:
        return '🕊️ Peaceful';
      case BhajanMood.energetic:
        return '⚡ Energetic';
      case BhajanMood.devotional:
        return '🙏 Devotional';
      case BhajanMood.meditative:
        return '🧘 Meditative';
      case BhajanMood.celebratory:
        return '🎉 Celebratory';
      case BhajanMood.soulful:
        return '💫 Soulful';
      case BhajanMood.uplifting:
        return '✨ Uplifting';
    }
  }
}
