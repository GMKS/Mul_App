import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VoiceCommentSheet extends StatefulWidget {
  final String videoId;
  final Function(String) onRecordComplete;

  const VoiceCommentSheet({
    super.key,
    required this.videoId,
    required this.onRecordComplete,
  });

  @override
  State<VoiceCommentSheet> createState() => _VoiceCommentSheetState();
}

class _VoiceCommentSheetState extends State<VoiceCommentSheet>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecording = false;
  int _recordingDuration = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });
    _pulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    // Simulate recording timer
    _updateRecordingDuration();
  }

  void _updateRecordingDuration() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration++;
        });
        if (_recordingDuration < 60) {
          _updateRecordingDuration();
        } else {
          _stopRecording();
        }
      }
    });
  }

  void _stopRecording() {
    _pulseController.stop();
    setState(() {
      _isRecording = false;
      _hasRecording = _recordingDuration > 0;
    });
    HapticFeedback.lightImpact();
  }

  void _cancelRecording() {
    _pulseController.stop();
    setState(() {
      _isRecording = false;
      _hasRecording = false;
      _recordingDuration = 0;
    });
  }

  void _sendRecording() {
    widget.onRecordComplete('voice_${DateTime.now().millisecondsSinceEpoch}');
    Navigator.pop(context);
    HapticFeedback.heavyImpact();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Voice Comment',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording
                ? 'Recording...'
                : _hasRecording
                    ? 'Recording complete'
                    : 'Tap the mic to start recording',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          // Recording duration
          Text(
            _formatDuration(_recordingDuration),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: _isRecording ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 32),

          // Record button
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRecording ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else if (!_hasRecording) {
                      _startRecording();
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Colors.red.shade100,
                      shape: BoxShape.circle,
                      boxShadow: _isRecording
                          ? [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 40,
                      color: _isRecording ? Colors.white : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Action buttons
          if (_hasRecording && !_isRecording)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                OutlinedButton.icon(
                  onPressed: _cancelRecording,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),

                // Play button (simulated)
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Playing voice comment...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),

                // Send button
                ElevatedButton.icon(
                  onPressed: _sendRecording,
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),

          // Max duration note
          const SizedBox(height: 16),
          Text(
            'Max duration: 60 seconds',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
