import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import 'package:safetyZone/core/localization/app_localizations.dart';
import 'package:safetyZone/core/utils/constants/colors.dart';
import 'package:safetyZone/core/utils/permissions/app_permissions.dart';

class ChatScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const ChatScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final Record _audioRecorder = Record();
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  // Sample messages data
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'مرحباً! كيف يمكنني مساعدتك اليوم؟',
      'isMe': false,
      'time': '10:30 ص',
      'type': 'text',
    },
    {
      'id': '2',
      'text': 'أريد الاستفسار عن عرض السعر الذي أرسلته',
      'isMe': true,
      'time': '10:32 ص',
      'type': 'text',
    },
    {
      'id': '3',
      'text': 'نعم، يمكنني مساعدتك في ذلك. ما هو استفسارك بالتحديد؟',
      'isMe': false,
      'time': '10:33 ص',
      'type': 'text',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _stopRecording();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': _messageController.text,
        'isMe': true,
        'time': _getFormattedTime(),
        'type': 'text',
      });
      _messageController.clear();
    });

    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    try {
      // Check and request storage/gallery permission
      final hasPermission = await _checkAndRequestMediaPermission();
      if (!hasPermission) {
        _showPermissionDeniedDialog(context);
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length() / (1024 * 1024); // Convert to MB

        if (fileSize > 10) {
          // 10MB limit
          if (context.mounted) {
            _showFileTooLargeDialog(context);
          }
          return;
        }

        if (mounted) {
          setState(() {
            _messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'path': image.path,
              'isMe': true,
              'time': _getFormattedTime(),
              'type': 'image',
            });
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        _showErrorDialog(
            context, 'Error', 'Failed to pick image. Please try again.');
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      // Check and request storage/gallery permission
      final hasPermission = await _checkAndRequestMediaPermission();
      if (!hasPermission) {
        _showPermissionDeniedDialog(context);
        return;
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2), // 2 minutes max duration
      );

      if (video != null) {
        final file = File(video.path);
        final fileSize = await file.length() / (1024 * 1024); // Convert to MB

        if (fileSize > 20) {
          // 20MB limit
          if (context.mounted) {
            _showFileTooLargeDialog(context, isVideo: true);
          }
          return;
        }

        if (mounted) {
          setState(() {
            _messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'path': video.path,
              'isMe': true,
              'time': _getFormattedTime(),
              'type': 'video',
              'thumbnail': '', // You can generate a thumbnail here
            });
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      if (context.mounted) {
        _showErrorDialog(
            context, 'Error', 'Failed to pick video. Please try again.');
      }
    }
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final period = now.hour >= 12 ? 'م' : 'ص';
    return '$hour:${now.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

/* <<<<<<<<<<<<<<  ✨ Windsurf Command ⭐ >>>>>>>>>>>>>>>> */

  /// Starts recording an audio message.
  ///
  /// If the app has permission to access the microphone, it starts recording and
  /// updates the recording duration state. It also starts a timer to update the
  /// recording duration every second. If the app does not have permission to access
  /// the microphone, it shows a permission denied dialog. If an error occurs during
  /// recording, it shows an error dialog.
  ///
  /// Returns a [Future<void>] representing the asynchronous operation of starting
  /// recording.
/* <<<<<<<<<<  dc3d4779-f883-4a9a-9a47-e811fbe4717c  >>>>>>>>>>> */
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          path: path,
          encoder: AudioEncoder.aacLc, // or other encoder
          bitRate: 128000, // 128 kbps
          samplingRate: 44100, // 44.1 kHz
        );

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
        });

        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordingDuration++;
            });
          }
        });
      } else {
        _showPermissionDeniedDialog(context);
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        _showErrorDialog(context, 'Error', 'Failed to start recording');
      }
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    if (_isRecording) {
      try {
        final path = await _audioRecorder.stop();
        if (path != null && mounted) {
          setState(() {
            _messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'type': 'audio',
              'path': path,
              'duration': _recordingDuration,
              'isMe': true,
              'time':
                  '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
            });
          });
          _scrollToBottom();
        }
      } catch (e) {
        debugPrint('Error stopping recording: $e');
        if (mounted) {
          _showErrorDialog(context, 'Error', 'Failed to stop recording');
        }
      }
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingDuration = 0;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isArabic = localizations.isArabic();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CColors.secondary,
        leading: SizedBox.shrink(),
        // Hide the default back button
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Provider's avatar
            Container(
              width: 32.w,
              height: 32.w,
              margin: EdgeInsets.only(left: 8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                image: DecorationImage(
                  image: AssetImage('assets/logo/logo.png'),
                  // Default avatar image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Provider's name
            Flexible(
              child: Text(
                widget.providerName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Almarai',
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24.sp,
              textDirection: !isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isArabic);
              },
            ),
          ),

          // Message input
          Container(
            margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: Icon(Icons.attach_file,
                      color: CColors.secondary, size: 24.sp),
                  onPressed: _showAttachmentOptions,
                ),

                // Voice message button or recording indicator
                if (_isRecording) ...[
                  // Recording indicator
                  GestureDetector(
                    onTap: _stopRecording,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatDuration(_recordingDuration),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Almarai',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ] else ...[
                  // Voice message button
                  GestureDetector(
                    onLongPress: _startRecording,
                    onLongPressUp: _stopRecording,
                    onTap: () {
                      // If user taps instead of long-press, show a hint
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.translate('pressAndHoldToRecord'),
                            style: const TextStyle(fontFamily: 'Almarai'),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.mic_none,
                      color: CColors.secondary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],

                // Message text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Almarai'),
                    decoration: InputDecoration(
                      hintText: localizations.translate('typeMessage'),
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                        fontFamily: 'Almarai',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Send or attachment button
                if (_messageController.text.trim().isNotEmpty)
                  IconButton(
                    icon:
                        Icon(Icons.send, color: CColors.secondary, size: 24.sp),
                    onPressed: _sendMessage,
                  )
                else
                  IconButton(
                    icon: Icon(Icons.attach_file,
                        color: CColors.secondary, size: 24.sp),
                    onPressed: _showAttachmentOptions,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Update the _showPermissionDeniedDialog method
  void _showPermissionDeniedDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.translate('permissionRequired'),
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        content: Text(
          localizations.translate('grantMediaPermission'),
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.translate('cancel'),
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppPermissions.openAppSettings();
            },
            child: Text(
              localizations.translate('openSettings'),
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
          ),
        ],
      ),
    );
  }

// Update the _showFileTooLargeDialog method
  void _showFileTooLargeDialog(BuildContext context, {bool isVideo = false}) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.translate('fileTooLarge'),
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        content: Text(
          isVideo
              ? localizations.translate('videoSizeLimit')
              : localizations.translate('imageSizeLimit'),
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.translate('ok'),
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
          ),
        ],
      ),
    );
  }

// Update the _showErrorDialog method
  void _showErrorDialog(BuildContext context, String title, String message) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          localizations.translate(title.toLowerCase()) ?? title,
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.translate('ok'),
              style: const TextStyle(fontFamily: 'Almarai'),
            ),
          ),
        ],
      ),
    );
  }

// Update the _showAttachmentOptions method
  void _showAttachmentOptions() {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.blue),
                title: Text(localizations.translate('image'),
                    style: const TextStyle(fontFamily: 'Almarai')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.red),
                title: Text(localizations.translate('video'),
                    style: const TextStyle(fontFamily: 'Almarai')),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _checkAndRequestMediaPermission() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      // On Android, we need to request storage permission
      return await AppPermissions.requestStoragePermission();
    } else {
      // On iOS, we need to request photos permission
      return await AppPermissions.requestPhotosPermission();
    }
  }

  Widget _buildAudioMessageBubble(
      Map<String, dynamic> message, bool isMe, int duration, bool isArabic) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement audio playback
        debugPrint('Play audio: ${message['path']}');
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isMe ? CColors.secondary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: isMe ? Colors.white : Colors.black87,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14.sp,
                fontFamily: 'Almarai',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isArabic) {
    final isMe = message['isMe'] as bool;

    // Handle audio message
    if (message['type'] == 'audio') {
      final duration = message['duration'] as int? ?? 0;
      return _buildAudioMessageBubble(message, isMe, duration, isArabic);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message content
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isMe ? CColors.secondary : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                  bottomLeft: Radius.circular(isMe ? 12.r : 4.r),
                  bottomRight: Radius.circular(isMe ? 4.r : 12.r),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message['type'] == 'text')
                    Text(
                      message['text'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 14.sp,
                        fontFamily: 'Almarai',
                      ),
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  if (message['type'] == 'image')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        File(message['path']),
                        width: double.infinity,
                        height: 200.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (message['type'] == 'video')
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200.h,
                            color: Colors.black,
                            child: const Center(
                                child: Icon(Icons.play_circle_filled,
                                    size: 50, color: Colors.white)),
                          ),
                          Positioned.fill(
                            child: VideoThumbnail(videoPath: message['path']),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Time
            Padding(
              padding: EdgeInsets.only(top: 2.h, right: 8.w, left: 8.w),
              child: Text(
                message['time'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10.sp,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoThumbnail extends StatefulWidget {
  final String videoPath;

  const VideoThumbnail({super.key, required this.videoPath});

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));
    await _controller.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VideoPlayerScreen(videoPath: widget.videoPath),
          ),
        );
      },
      child: VideoPlayer(_controller),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _isPlaying = true;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    if (!_isPlaying)
                      const Icon(
                        Icons.play_circle_filled,
                        size: 70,
                        color: Colors.white,
                      ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
