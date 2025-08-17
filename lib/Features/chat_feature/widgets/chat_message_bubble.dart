import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/constants/colors.dart';
import '../models/chat_message_model.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  late VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoadingVideo = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void didUpdateWidget(covariant ChatMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.mediaUrl != widget.message.mediaUrl) {
      _disposeMedia();
      _initializeMedia();
    }
  }

  void _initializeMedia() {
    if (widget.message.isVideo && widget.message.mediaUrl != null) {
      _initializeVideoPlayer();
    } else if (widget.message.isVoice && widget.message.mediaUrl != null) {
      _initializeAudioPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    setState(() => _isLoadingVideo = true);
    try {
      _videoController = widget.message.mediaUrl!.startsWith('http')
          ? VideoPlayerController.network(widget.message.mediaUrl!)
          : VideoPlayerController.file(File(widget.message.mediaUrl!));

      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: false,
        showControls: true,
        placeholder: Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Failed to load video',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error initializing video player: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingVideo = false);
      }
    }
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.message.mediaUrl!);
      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  Future<void> _toggleAudioPlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void _disposeMedia() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _audioPlayer.dispose();
  }

  @override
  void dispose() {
    _disposeMedia();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message Content
          GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: widget.isMe
                    ? (widget.isSelected
                        ? theme.primaryColor.withOpacity(0.3)
                        : theme.primaryColor)
                    : (widget.isSelected
                        ? Colors.grey.withOpacity(0.3)
                        : isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200]),
                borderRadius: BorderRadius.circular(16.0),
                border: widget.isSelected
                    ? Border.all(color: theme.primaryColor, width: 2.0)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media Content
                  if (widget.message.isImage)
                    _buildImageContent()
                  else if (widget.message.isVideo)
                    _buildVideoContent()
                  else if (widget.message.isVoice)
                    _buildVoiceContent()
                  else if (widget.message.isDocument)
                    _buildDocumentContent(),

                  // Text Content
                  if (widget.message.hasCaption)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        widget.message.text!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.isMe ? Colors.white : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
            child: Text(
              _formatTime(widget.message.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 10.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: widget.message.mediaUrl!,
        placeholder: (context, url) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
        fit: BoxFit.cover,
        width: 200,
        height: 150,
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoadingVideo) {
      return Container(
        width: 200,
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_chewieController == null) {
      return GestureDetector(
        onTap: () {
          // Try to open the video in an external player if the built-in one fails
          if (widget.message.mediaUrl != null) {
            launchUrl(Uri.file(widget.message.mediaUrl!));
          }
        },
        child: Container(
          width: 200,
          height: 150,
          color: Colors.grey[300],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tap to play video'),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: 200,
      height: 150,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildVoiceContent() {
    return GestureDetector(
      onTap: _toggleAudioPlayback,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: widget.isMe
              ? Colors.blue[700]
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]
                  : Colors.grey[300]),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: widget.isMe ? Colors.white : null,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _formatDuration(widget.message.duration ?? Duration.zero),
                style: TextStyle(
                  color: widget.isMe ? Colors.white : null,
                ),
              ),
            ),
            if (widget.message.fileSize != null)
              Text(
                _formatFileSize(widget.message.fileSize!),
                style: TextStyle(
                  fontSize: 12.0,
                  color: widget.isMe ? Colors.white70 : Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    final fileName = widget.message.fileName ?? 'Document';
    final fileExt = path.extension(fileName).toLowerCase();
    
    IconData icon;
    switch (fileExt) {
      case '.pdf':
        icon = Icons.picture_as_pdf;
        break;
      case '.doc':
      case '.docx':
        icon = Icons.description;
        break;
      case '.xls':
      case '.xlsx':
        icon = Icons.table_chart;
        break;
      case '.ppt':
      case '.pptx':
        icon = Icons.slideshow;
        break;
      case '.txt':
        icon = Icons.text_snippet;
        break;
      default:
        icon = Icons.insert_drive_file;
    }

    return GestureDetector(
      onTap: () {
        if (widget.message.mediaUrl != null) {
          launchUrl(Uri.file(widget.message.mediaUrl!));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.message.fileSize != null)
                    Text(
                      _formatFileSize(widget.message.fileSize!),
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[500],
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
