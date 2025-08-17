import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_message_model.dart';

class MessageInputField extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) onSendMessage;
  final Function(
    String,
    MessageType, {
    String? caption,
    Duration? duration,
    String? fileName,
    int? fileSize,
  }) onSendMedia;
  final bool isRecording;
  final bool isUploading;
  final String? currentVoicePath;
  final Duration? recordingDuration;
  final VoidCallback? onStopRecording;
  final VoidCallback? onStartRecording;
  final VoidCallback? onCancelRecording;

  const MessageInputField({
    Key? key,
    required this.textController,
    required this.onSendMessage,
    required this.onSendMedia,
    this.isRecording = false,
    this.isUploading = false,
    this.currentVoicePath,
    this.recordingDuration,
    this.onStopRecording,
    this.onStartRecording,
    this.onCancelRecording,
  }) : super(key: key);

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Duration _recordingDuration = Duration.zero;
  String? _currentVoicePath;

  @override
  void initState() {
    super.initState();
    _isRecording = widget.isRecording;
    _currentVoicePath = widget.currentVoicePath;
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _requestMicrophonePermission()) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath =
            path.join(tempDir.path, 'voice_message_$timestamp.m4a');

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordingStartTime = DateTime.now();
          _currentVoicePath = filePath;
          _recordingDuration = Duration.zero;
        });

        // Update duration every second
        while (_isRecording) {
          await Future.delayed(const Duration(seconds: 1));
          if (mounted && _recordingStartTime != null) {
            setState(() {
              _recordingDuration =
                  DateTime.now().difference(_recordingStartTime!);
            });
          }
        }
      }
    } catch (e) {
      print('Error starting recording: $e');
      _stopRecording();
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (_currentVoicePath != null && _recordingDuration.inSeconds >= 1) {
        widget.onSendMedia?.call(
          _currentVoicePath!,
          MessageType.voice,
          duration: _recordingDuration,
          fileName: path.basename(_currentVoicePath!),
          fileSize: await File(_currentVoicePath!).length(),
        );
      } else if (_currentVoicePath != null) {
        // Delete the recording if it's too short
        await File(_currentVoicePath!).delete();
      }
    } catch (e) {
      print('Error stopping recording: $e');
    } finally {
      _resetRecording();
    }
  }

  void _resetRecording() {
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordingDuration = Duration.zero;
        _currentVoicePath = null;
      });
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileName = path.basename(file.path);
        final fileSize = await file.length();

        widget.onSendMedia?.call(
          pickedFile.path,
          MessageType.image,
          fileName: fileName,
          fileSize: fileSize,
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileName = path.basename(file.path);
        final fileSize = await file.length();

        widget.onSendMedia?.call(
          pickedFile.path,
          MessageType.video,
          fileName: fileName,
          fileSize: fileSize,
        );
      }
    } catch (e) {
      print('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick video')),
        );
      }
    }
  }

  void _handleSendMessage() {
    final text = widget.textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      widget.textController.clear();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return _buildRecordingUI();
    }

    return _buildInputField();
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Media Picker Button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed:
                widget.isUploading ? null : () => _showMediaPicker(context),
          ),

          // Text Field
          Expanded(
            child: TextField(
              controller: widget.textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[200]
                    : Colors.grey[800],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              minLines: 1,
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),

          // Send/Record Button
          if (widget.textController.text.trim().isNotEmpty)
            IconButton(
              icon: const Icon(Icons.send, size: 28),
              onPressed: widget.isUploading ? null : _handleSendMessage,
            )
          else
            IconButton(
              icon: const Icon(Icons.mic_none, size: 28),
              onPressed: widget.isUploading ? null : _startRecording,
            ),
        ],
      ),
    );
  }

  Widget _buildRecordingUI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          // Cancel Button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              _resetRecording();
              widget.onCancelRecording?.call();
            },
          ),

          // Timer
          Expanded(
            child: Center(
              child: Text(
                _formatDuration(_recordingDuration),
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          // Stop Button
          IconButton(
            icon: const Icon(Icons.stop_circle, color: Colors.red, size: 36.0),
            onPressed: _stopRecording,
          ),
        ],
      ),
    );
  }

  void _showMediaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video Library'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text('Document'),
              onTap: () async {
                Navigator.pop(context);
                await _pickDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt'
        ],
      );

      if (result != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final fileName = path.basename(filePath);
        final fileSize = await file.length();

        widget.onSendMedia?.call(
          filePath,
          MessageType.document,
          fileName: fileName,
          fileSize: fileSize,
        );
      }
    } catch (e) {
      print('Error picking document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick document')),
        );
      }
    }
  }
}

