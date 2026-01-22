/// Report Button Widget
/// Reusable button for reporting content

import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/moderation_service.dart';

class ReportButton extends StatelessWidget {
  final String contentId;
  final ReportedContentType contentType;
  final String contentTitle;
  final String contentOwnerId;
  final String contentOwnerName;
  final String? contentDescription;
  final String? contentThumbnail;
  final Color? iconColor;
  final bool showLabel;

  const ReportButton({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentTitle,
    required this.contentOwnerId,
    required this.contentOwnerName,
    this.contentDescription,
    this.contentThumbnail,
    this.iconColor,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return showLabel
        ? TextButton.icon(
            onPressed: () => _showReportDialog(context),
            icon: Icon(Icons.flag_outlined, color: iconColor),
            label: const Text('Report'),
          )
        : IconButton(
            icon: Icon(Icons.flag_outlined, color: iconColor),
            onPressed: () => _showReportDialog(context),
            tooltip: 'Report content',
          );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentId: contentId,
        contentType: contentType,
        contentTitle: contentTitle,
        contentOwnerId: contentOwnerId,
        contentOwnerName: contentOwnerName,
        contentDescription: contentDescription,
        contentThumbnail: contentThumbnail,
      ),
    );
  }
}

class ReportDialog extends StatefulWidget {
  final String contentId;
  final ReportedContentType contentType;
  final String contentTitle;
  final String contentOwnerId;
  final String contentOwnerName;
  final String? contentDescription;
  final String? contentThumbnail;

  const ReportDialog({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentTitle,
    required this.contentOwnerId,
    required this.contentOwnerName,
    this.contentDescription,
    this.contentThumbnail,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportCategory? _selectedCategory;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1a1a2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFef4444).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Color(0xFFef4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Content',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Help us keep the community safe',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Content preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a3e),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (widget.contentThumbnail != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          widget.contentThumbnail!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: const Color(0xFF3a3a4e),
                              child: const Icon(Icons.image,
                                  color: Colors.white54),
                            );
                          },
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.contentTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'By ${widget.contentOwnerName}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category selection
              const Text(
                'Why are you reporting this?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              ...ReportCategory.values.map((category) {
                return _buildCategoryOption(category);
              }).toList(),

              const SizedBox(height: 20),

              // Optional comment
              const Text(
                'Additional details (optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Add any additional context...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF2a2a3e),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  counterStyle: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 20),

              // Privacy note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3b82f6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF3b82f6).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: Color(0xFF3b82f6),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your identity will remain confidential. Only moderators will review your report.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedCategory == null || _isSubmitting
                          ? null
                          : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFef4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit Report'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption(ReportCategory category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFef4444).withOpacity(0.2)
              : const Color(0xFF2a2a3e),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFef4444) : const Color(0xFF3a3a4e),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFef4444),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null) return;

    setState(() => _isSubmitting = true);

    final success = await ModerationService.submitReport(
      contentId: widget.contentId,
      contentType: widget.contentType,
      category: _selectedCategory!,
      contentTitle: widget.contentTitle,
      contentOwnerId: widget.contentOwnerId,
      contentOwnerName: widget.contentOwnerName,
      additionalComment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      contentDescription: widget.contentDescription,
      contentThumbnail: widget.contentThumbnail,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        _showSuccessMessage(context);
      } else {
        setState(() => _isSubmitting = false);
        _showErrorMessage(context);
      }
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Report submitted',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Thank you for helping keep our community safe! 🙏',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10b981),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to submit report. Please try again.'),
        backgroundColor: Color(0xFFef4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
