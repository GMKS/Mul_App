// STEP 11: Report Content Dialog
// Content reporting UI
// NOTE: This is the OLD report dialog. Use report_button_widget.dart instead for new implementations.

import 'package:flutter/material.dart';
// import '../models/moderation_model.dart'; // Commented out - causes conflict with new report_model.dart
import '../models/report_model.dart'; // Using new model
import '../services/moderation_service.dart';

class ReportContentDialog extends StatefulWidget {
  final String contentId;
  final String contentType;
  final String reporterId;

  const ReportContentDialog({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.reporterId,
  });

  @override
  State<ReportContentDialog> createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<ReportContentDialog> {
  ReportCategory?
      _selectedReason; // Changed from ReportReason to ReportCategory
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ModerationService.reportContent(
        contentId: widget.contentId,
        contentType: widget.contentType,
        reporterId: widget.reporterId,
        reason: _selectedReason!,
        description: _descriptionController.text,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Report submitted. Thank you for helping keep our community safe.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reasons = ModerationService.getReportReasons();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Report Content',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Why are you reporting this?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Report reasons
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: reasons.length,
                itemBuilder: (context, index) {
                  final reason = reasons[index];
                  final isSelected = _selectedReason == reason['reason'];

                  return ListTile(
                    leading: Text(reason['icon'],
                        style: const TextStyle(fontSize: 20)),
                    title: Text(reason['text']),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.red)
                        : null,
                    selected: isSelected,
                    selectedTileColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      setState(() => _selectedReason = reason['reason']);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Additional details
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Additional details (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick report button for videos
class ReportButton extends StatelessWidget {
  final String contentId;
  final String contentType;
  final String reporterId;
  final Color? color;

  const ReportButton({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.reporterId,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ReportContentDialog(
            contentId: contentId,
            contentType: contentType,
            reporterId: reporterId,
          ),
        );
      },
      icon: Icon(
        Icons.flag_outlined,
        color: color ?? Colors.white,
      ),
      tooltip: 'Report',
    );
  }
}
