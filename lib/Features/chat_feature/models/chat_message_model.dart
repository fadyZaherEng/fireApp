import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum MessageType { text, image, video, voice, document }

class ChatMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String? text;
  final DateTime timestamp;
  final MessageStatus status;
  final String? mediaUrl;
  final MessageType type;
  final Duration? duration;
  final String? fileName;
  final int? fileSize; // in bytes

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.mediaUrl,
    this.type = MessageType.text,
    this.duration,
    this.fileName,
    this.fileSize,
  });

  // Factory for text message
  factory ChatMessage.text({
    required String id,
    required String chatId,
    required String senderId,
    required String text,
    required DateTime timestamp,
    MessageStatus status = MessageStatus.sent,
  }) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      status: status,
      type: MessageType.text,
    );
  }

  // Factory for image message
  factory ChatMessage.image({
    required String id,
    required String chatId,
    required String senderId,
    required String imageUrl,
    String? caption,
    required DateTime timestamp,
    MessageStatus status = MessageStatus.sent,
    String? fileName,
    int? fileSize,
  }) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: caption,
      timestamp: timestamp,
      status: status,
      mediaUrl: imageUrl,
      type: MessageType.image,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  // Factory for video message
  factory ChatMessage.video({
    required String id,
    required String chatId,
    required String senderId,
    required String videoUrl,
    String? caption,
    required DateTime timestamp,
    MessageStatus status = MessageStatus.sent,
    String? fileName,
    int? fileSize,
  }) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: caption,
      timestamp: timestamp,
      status: status,
      mediaUrl: videoUrl,
      type: MessageType.video,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  // Factory for voice message
  factory ChatMessage.voice({
    required String id,
    required String chatId,
    required String senderId,
    required String audioUrl,
    required Duration duration,
    required DateTime timestamp,
    MessageStatus status = MessageStatus.sent,
    String? fileName,
    int? fileSize,
  }) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderId: senderId,
      timestamp: timestamp,
      status: status,
      mediaUrl: audioUrl,
      type: MessageType.voice,
      duration: duration,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final type = MessageType.values.firstWhere(
      (e) => e.toString() == 'MessageType.${json['type']}',
      orElse: () => MessageType.text,
    );

    final message = ChatMessage(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
      mediaUrl: json['mediaUrl'] as String?,
      type: type,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
    );

    return message;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      if (text != null) 'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (duration != null) 'duration': duration!.inMilliseconds,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
    String? mediaUrl,
    MessageType? type,
    Duration? duration,
    String? fileName,
    int? fileSize,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        text,
        timestamp,
        status,
        mediaUrl,
        type,
        duration,
        fileName,
        fileSize,
      ];

  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isVideo => type == MessageType.video;
  bool get isVoice => type == MessageType.voice;
  bool get isDocument => type == MessageType.document;
  bool get hasMedia => mediaUrl != null;
  bool get hasCaption => text?.isNotEmpty == true;
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
