import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:gal/gal.dart';
import 'package:dio/dio.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/constants/colors.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_states.dart';
import '../models/chat_message_model.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/message_input_field.dart';

class ChatView extends StatefulWidget {
  final String chatId;
  final String? recipientName;
  final String? recipientAvatarUrl;

  const ChatView({
    Key? key,
    required this.chatId,
    this.recipientName,
    this.recipientAvatarUrl,
  }) : super(key: key);

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isUploading = false;
  int _page = 1;
  final int _limit = 20;
  final String _currentUserId =
      'current_user_id'; // Replace with actual user ID from auth

  // For handling media uploads
  final List<String> _uploadQueue = [];

  bool get _isUploadingMedia => _uploadQueue.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  void _loadMessages() {
    context.read<ChatCubit>().fetchMessages(
          chatId: widget.chatId,
          page: _page,
          limit: _limit,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMessages();
    }
  }

  void _loadMoreMessages() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    await context.read<ChatCubit>().loadMoreMessages(
          chatId: widget.chatId,
          page: _page,
          limit: _limit,
        );
    setState(() => _isLoadingMore = false);
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final message = ChatMessage.text(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: widget.chatId,
        senderId: 'current_user_id',
        // TODO: Replace with actual user ID from auth
        text: messageText,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      context.read<ChatCubit>().sendMessage(
            chatId: widget.chatId,
            message: message,
          );
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Handle sending text message
  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = ChatMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: widget.chatId,
      senderId: 'current_user_id',
      // TODO: Replace with actual user ID from auth
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    context.read<ChatCubit>().sendMessage(
          chatId: widget.chatId,
          message: message,
        );
  }

  // Handle sending media message
  Future<void> _handleSendMedia(
    String filePath,
    MessageType type, {
    String? caption,
    Duration? duration,
    String? fileName,
    int? fileSize,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final fileExtension = path.extension(filePath).toLowerCase();
    final uniqueId = const Uuid().v4();
    final targetFileName =
        '${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    final targetPath = path.join(tempDir.path, targetFileName);

    try {
      setState(() {
        _isUploading = true;
        _uploadQueue.add(targetPath);
      });

      // In a real app, you would upload the file to your server here
      // For now, we'll just copy it to a temporary location
      final file = File(filePath);
      await file.copy(targetPath);

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Create the appropriate message type
      ChatMessage message;
      final now = DateTime.now();

      switch (type) {
        case MessageType.image:
          message = ChatMessage.image(
            id: uniqueId,
            chatId: widget.chatId,
            senderId: _currentUserId,
            imageUrl: targetPath,
            // In real app, this would be the URL from your server
            caption: caption,
            timestamp: now,
            status: MessageStatus.sent,
            fileName: fileName,
            fileSize: fileSize,
          );
          break;

        case MessageType.video:
          message = ChatMessage.video(
            id: uniqueId,
            chatId: widget.chatId,
            senderId: _currentUserId,
            videoUrl: targetPath,
            // In real app, this would be the URL from your server
            caption: caption,
            timestamp: now,
            status: MessageStatus.sent,
            fileName: fileName,
            fileSize: fileSize,
          );
          break;

        case MessageType.voice:
          message = ChatMessage.voice(
            id: uniqueId,
            chatId: widget.chatId,
            senderId: _currentUserId,
            audioUrl: targetPath,
            // In real app, this would be the URL from your server
            duration: duration ?? Duration.zero,
            timestamp: now,
            status: MessageStatus.sent,
            fileName: fileName,
            fileSize: fileSize,
          );
          break;

        case MessageType.document:
          message = ChatMessage(
            id: uniqueId,
            chatId: widget.chatId,
            senderId: _currentUserId,
            timestamp: now,
            status: MessageStatus.sent,
            mediaUrl: targetPath,
            // In real app, this would be the URL from your server
            type: MessageType.document,
            fileName: fileName,
            fileSize: fileSize,
          );
          break;

        default:
          return; // Unsupported media type
      }

      // Send the message
      if (mounted) {
        context.read<ChatCubit>().sendMessage(
              chatId: widget.chatId,
              message: message,
            );
      }
    } catch (e) {
      print('Error sending media: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send media')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _uploadQueue.remove(targetPath);
          _isUploading = _uploadQueue.isNotEmpty;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 15.r,
              backgroundImage: widget.recipientAvatarUrl != null
                  ? NetworkImage(widget.recipientAvatarUrl!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            SizedBox(width: 8.w),
            Text(
              widget.recipientName ??
                  AppLocalizations.of(context)!.translate('chat_default_title'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show chat info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatStates>(
              builder: (context, state) {
                if (state is ChatMessagesLoading && state.isFirstFetch) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = state is ChatMessagesLoaded
                    ? state.messages
                    : <ChatMessage>[];

                if (messages.isEmpty && state is! ChatMessagesLoading) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate('no_messages'),
                      style:
                          TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(vertical: 8.r),
                  itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final message = messages[messages.length - 1 - index];
                    final isMe = message.senderId == _currentUserId;
                    final showDate = _shouldShowDate(index, messages);

                    return Column(
                      children: [
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _formatDate(message.timestamp),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ChatMessageBubble(
                          key: ValueKey(message.id),
                          message: message,
                          isMe: isMe,
                          onTap: () {
                            // Handle tap on message
                          },
                          onLongPress: () {
                            // Handle long press (e.g., show options)
                            _showMessageOptions(context, message, isMe);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // Message input field
          MessageInputField(
            textController: _messageController,
            onSendMessage: _handleSendMessage,
            onSendMedia: _handleSendMedia,
            isUploading: _isUploading,
          ),
        ],
      ),
    );
  }

  // Helper method to format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // Helper method to determine if we should show the date for a message
  bool _shouldShowDate(int index, List<ChatMessage> messages) {
    if (index == messages.length - 1) return true;

    final current = messages[messages.length - 1 - index];
    final previous = messages[messages.length - 2 - index];

    return !DateUtils.isSameDay(current.timestamp, previous.timestamp);
  }

  // Show message options when long-pressed
  void _showMessageOptions(
      BuildContext context, ChatMessage message, bool isMe) {
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
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                if (message.text != null) {
                  // Copy text to clipboard
                  // Clipboard.setData(ClipboardData(text: message.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message copied')),
                  );
                }
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement delete message
                  _deleteMessage(message);
                },
              ),
            if (message.isImage ||
                message.isVideo ||
                message.isVoice ||
                message.isDocument)
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text('Save to device'),
                onTap: () {
                  Navigator.pop(context);
                  // _saveMediaToDevice(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareMessage(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Delete a message
  void _deleteMessage(ChatMessage message) {
    // TODO: Implement delete message in cubit
    context.read<ChatCubit>().deleteMessage(
          chatId: widget.chatId,
          messageId: message.id,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message deleted')),
    );
  }

  // Save media to device using gal package
  // Future<void> _saveMediaToDevice(ChatMessage message) async {
  //   if (message.mediaUrl == null) return;
  //   //
  //   // try {
  //   //   // Show loading indicator
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     const SnackBar(content: Text('Saving media...')),
  //   //   );
  //   //
  //   //   final url = message.mediaUrl!;
  //   //   bool? result;
  //   //
  //   //   if (message.isImage) {
  //   //     // For images, use gal to save to gallery
  //   //     result = await Gal.putImage(
  //   //       url,
  //   //       album: 'SafetyZone',
  //   //     );
  //   //   } else if (message.isVideo) {
  //   //     // For videos, use gal to save to gallery
  //   //     result = await Gal.putVideo(
  //   //       url,
  //   //       album: 'SafetyZone',
  //   //     );
  //   //   } else if (message.isDocument) {
  //   //     // For documents, save to downloads
  //   //     final response = await Dio().get(
  //   //       url,
  //   //       options: Options(responseType: ResponseType.bytes),
  //   //     );
  //   //
  //   //     final fileName = url.split('/').last;
  //   //     final directory = await getApplicationDocumentsDirectory();
  //   //     final filePath = '${directory.path}/$fileName';
  //   //
  //   //     final file = File(filePath);
  //   //     await file.writeAsBytes(response.data);
  //   //
  //   //     // Save to downloads using gal
  //   //     result = await Gal.putFile(
  //   //       file.path,
  //   //       album: 'SafetyZone',
  //   //     );
  //   //   }
  //   //
  //   //   if (result == true) {
  //   //     if (mounted) {
  //   //       ScaffoldMessenger.of(context).showSnackBar(
  //   //         const SnackBar(content: Text('Media saved successfully')),
  //   //       );
  //   //     }
  //   //   } else {
  //   //     throw Exception('Failed to save media');
  //   //   }
  //   // } catch (e) {
  //   //   ScaffoldMessenger.of(context).showSnackBar(
  //   //     const SnackBar(content: Text('Failed to save media')),
  //   //   );
  //   // }
  // }

  // Share message
  void _shareMessage(ChatMessage message) {
    // TODO: Implement share functionality
    // You can use the share_plus package for this
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality not implemented yet')),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isMe ? CColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r),
            topRight: Radius.circular(12.r),
            bottomLeft: Radius.circular(isMe ? 12.r : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12.r),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('h:mm a').format(message.timestamp),
              style: TextStyle(
                fontSize: 10.sp,
                color: isMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
