import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/devotional_upload_service.dart';
import '../../services/region_service.dart';
import '../../services/religion_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

/// Screen for users to upload devotional videos
class UploadDevotionalVideoScreen extends StatefulWidget {
  const UploadDevotionalVideoScreen({super.key});

  @override
  State<UploadDevotionalVideoScreen> createState() =>
      _UploadDevotionalVideoScreenState();
}

class _UploadDevotionalVideoScreenState
    extends State<UploadDevotionalVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uploadService = DevotionalUploadService();

  // Form fields
  final _titleController = TextEditingController();
  final _templeNameController = TextEditingController();

  String? _selectedReligion;
  String _selectedDeity = 'Lord Rama';
  String _selectedLanguage = 'telugu';
  List<String> _selectedTags = [];

  File? _videoFile;
  File? _thumbnailFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Religion-specific data
  Map<String, Map<String, dynamic>> _religionData = {
    'Hinduism': {
      'deities': [
        'Lord Rama',
        'Lord Hanuman',
        'Lord Ganesha',
        'Lord Shiva',
        'Lord Vishnu',
        'Goddess Durga',
        'Goddess Lakshmi',
        'Lord Krishna',
        'Goddess Saraswati',
        'Lord Murugan',
      ],
      'festivals': [
        'ram_navami',
        'hanuman_jayanti',
        'ganesh_chaturthi',
        'maha_shivaratri',
        'diwali',
        'navaratri',
        'krishna_janmashtami',
        'holi',
        'ugadi',
        'pongal',
      ],
    },
    'Islam': {
      'deities': [
        'Allah',
        'Prophet Muhammad',
      ],
      'festivals': [
        'eid_ul_fitr',
        'eid_ul_adha',
        'ramadan',
        'mawlid',
        'shab_e_barat',
      ],
    },
    'Christianity': {
      'deities': [
        'Jesus Christ',
        'Mother Mary',
        'Saint Joseph',
        'Saint Peter',
        'Saint Paul',
      ],
      'festivals': [
        'christmas',
        'easter',
        'good_friday',
        'pentecost',
        'epiphany',
        'all_saints_day',
      ],
    },
    'Sikhism': {
      'deities': [
        'Guru Nanak',
        'Guru Gobind Singh',
        'Guru Granth Sahib',
      ],
      'festivals': [
        'guru_nanak_jayanti',
        'vaisakhi',
        'guru_gobind_singh_jayanti',
        'martyrdom_of_guru_arjan',
      ],
    },
    'Buddhism': {
      'deities': [
        'Buddha',
        'Bodhisattva',
        'Avalokiteshvara',
      ],
      'festivals': [
        'vesak',
        'bodhi_day',
        'nirvana_day',
        'asalha_puja',
      ],
    },
    'Jainism': {
      'deities': [
        'Mahavira',
        'Rishabhanatha',
        'Parshvanatha',
      ],
      'festivals': [
        'mahavir_jayanti',
        'paryushana',
        'diwali',
        'mauna_agyaras',
      ],
    },
  };

  // Current deity and festival options based on religion
  List<String> get _currentDeities =>
      _religionData[_selectedReligion]?['deities'] ?? ['Lord Rama'];

  List<String> get _currentFestivals =>
      _religionData[_selectedReligion]?['festivals'] ?? ['ram_navami'];

  @override
  void initState() {
    super.initState();
    _loadSelectedReligion();
  }

  Future<void> _loadSelectedReligion() async {
    final religion = await ReligionService.getSelectedReligion();
    setState(() {
      _selectedReligion = religion?.displayName ?? 'Hinduism';
      // Set default deity for selected religion
      _selectedDeity = _currentDeities.first;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _templeNameController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final video = await _uploadService.pickVideo();
    if (video != null) {
      setState(() => _videoFile = video);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Video selected!')),
      );
    }
  }

  Future<void> _recordVideo() async {
    final video = await _uploadService.recordVideo();
    if (video != null) {
      setState(() => _videoFile = video);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Video recorded!')),
      );
    }
  }

  Future<void> _pickThumbnail() async {
    final thumbnail = await _uploadService.pickThumbnail();
    if (thumbnail != null) {
      setState(() => _thumbnailFile = thumbnail);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Thumbnail selected!')),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please select a video')),
      );
      return;
    }

    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please select a thumbnail')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Ensure user is authenticated (sign in anonymously if not)
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        print('🔐 No user logged in, signing in anonymously...');
        await AuthService.signInAnonymously();
        print('✅ Anonymous sign-in successful');
      } else {
        print('✅ User already authenticated: ${currentUser.id}');
      }

      // Get user's location
      final regionData = await RegionService.getStoredRegion();
      final latitude = regionData['latitude'] ?? 0.0;
      final longitude = regionData['longitude'] ?? 0.0;

      // Upload video
      final uploadedVideo = await _uploadService.uploadDevotionalVideo(
        title: _titleController.text,
        deity: _selectedDeity,
        templeName: _templeNameController.text,
        videoFile: _videoFile!,
        thumbnailFile: _thumbnailFile!,
        language: _selectedLanguage,
        festivalTags: _selectedTags,
        latitude: latitude,
        longitude: longitude,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Video uploaded! Pending verification.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, uploadedVideo);
      }
    } catch (e) {
      print('❌ Upload error: $e');
      if (mounted) {
        String errorMessage = '❌ Upload failed: ';

        // Provide user-friendly error messages
        if (e.toString().contains('Bucket not found')) {
          errorMessage += 'Storage not configured. Please contact admin.';
        } else if (e.toString().contains('StorageException')) {
          errorMessage += 'Storage error. Check your connection.';
        } else if (e.toString().contains('NetworkException')) {
          errorMessage += 'Network error. Check your internet connection.';
        } else {
          errorMessage += e.toString().replaceAll('Exception:', '').trim();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _uploadVideo,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Upload Devotional Video',
          style: AppTextStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: _isUploading
          ? _buildUploadingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildVideoSection(),
                    const SizedBox(height: 24),
                    _buildThumbnailSection(),
                    const SizedBox(height: 24),
                    _buildFormFields(),
                    const SizedBox(height: 32),
                    _buildUploadButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUploadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Uploading your video...',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait, this may take a few minutes',
            style: AppTextStyles.body.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Video', style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            if (_videoFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_library, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _videoFile!.path.split('/').last,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Select Video'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _recordVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Record'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thumbnail', style: AppTextStyles.headline3),
            const SizedBox(height: 12),
            if (_thumbnailFile != null)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_thumbnailFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickThumbnail,
              icon: const Icon(Icons.image),
              label: const Text('Select Thumbnail'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Video Details', style: AppTextStyles.headline3),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Morning Aarti - Sri Rama Temple',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _templeNameController,
              decoration: const InputDecoration(
                labelText: 'Temple Name *',
                hintText: 'e.g., Sri Rama Temple',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter temple name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _currentDeities.contains(_selectedDeity)
                  ? _selectedDeity
                  : _currentDeities.first,
              decoration: InputDecoration(
                labelText: 'Deity *',
                border: const OutlineInputBorder(),
                helperText: 'Based on $_selectedReligion',
              ),
              items: _currentDeities.map((deity) {
                return DropdownMenuItem(value: deity, child: Text(deity));
              }).toList(),
              onChanged: (value) => setState(() => _selectedDeity = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Language *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'telugu', child: Text('Telugu')),
                DropdownMenuItem(value: 'hindi', child: Text('Hindi')),
                DropdownMenuItem(value: 'tamil', child: Text('Tamil')),
                DropdownMenuItem(value: 'kannada', child: Text('Kannada')),
              ],
              onChanged: (value) => setState(() => _selectedLanguage = value!),
            ),
            const SizedBox(height: 16),
            Text('Festival Tags (Optional)',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            Text(
              'Select festivals related to $_selectedReligion',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _currentFestivals.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag.replaceAll('_', ' ')),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadVideo,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Upload Video',
        style: AppTextStyles.button.copyWith(color: Colors.white),
      ),
    );
  }
}
