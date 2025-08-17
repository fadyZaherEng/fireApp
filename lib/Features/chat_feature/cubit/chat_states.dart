import 'package:equatable/equatable.dart';
import 'package:safetyZone/Features/chat_feature/models/chat_message_model.dart';
import 'package:safetyZone/Features/chat_feature/models/chat_model.dart';

abstract class ChatStates extends Equatable {
  const ChatStates();

  @override
  List<Object> get props => [];
}

class ChatInitialState extends ChatStates {}

class ChatLoadingState extends ChatStates {
  final bool isFirstFetch;

  const ChatLoadingState({this.isFirstFetch = true});

  @override
  List<Object> get props => [isFirstFetch];
}

class ChatsLoadedState extends ChatStates {
  final List<Chat> chats;
  final bool hasReachedMax;

  const ChatsLoadedState({
    required this.chats,
    this.hasReachedMax = false,
  });

  ChatsLoadedState copyWith({
    List<Chat>? chats,
    bool? hasReachedMax,
  }) {
    return ChatsLoadedState(
      chats: chats ?? this.chats,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [chats, hasReachedMax];
}

class ChatMessagesLoaded extends ChatStates {
  final List<ChatMessage> messages;
  final bool hasReachedMax;
  final bool isFirstFetch;

  const ChatMessagesLoaded({
    required this.messages,
    this.hasReachedMax = false,
    this.isFirstFetch = false,
  });

  ChatMessagesLoaded copyWith({
    List<ChatMessage>? messages,
    bool? hasReachedMax,
    bool? isFirstFetch,
  }) {
    return ChatMessagesLoaded(
      messages: messages ?? this.messages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFirstFetch: isFirstFetch ?? this.isFirstFetch,
    );
  }

  @override
  List<Object> get props => [messages, hasReachedMax, isFirstFetch];
}

class MessageSentState extends ChatStates {
  final ChatMessage message;

  const MessageSentState(this.message);

  @override
  List<Object> get props => [message];
}

class ChatErrorState extends ChatStates {
  final String message;

  const ChatErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// Additional states for message status updates
class MessageStatusUpdated extends ChatStates {
  final String messageId;
  final MessageStatus status;

  const MessageStatusUpdated({
    required this.messageId,
    required this.status,
  });

  @override
  List<Object> get props => [messageId, status];
}

// State for when a new message is received
class NewMessageReceived extends ChatStates {
  final ChatMessage message;

  const NewMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

// State for when messages are being loaded
class ChatMessagesLoading extends ChatStates {
  final bool isFirstFetch;

  const ChatMessagesLoading({this.isFirstFetch = false});

  @override
  List<Object> get props => [isFirstFetch];
}

// State for when a message is being sent
class MessageSending extends ChatStates {
  final ChatMessage message;

  const MessageSending(this.message);

  @override
  List<Object> get props => [message];
}

// State for when a message fails to send
class MessageSendFailed extends ChatStates {
  final ChatMessage message;
  final String error;

  const MessageSendFailed({
    required this.message,
    required this.error,
  });

  @override
  List<Object> get props => [message, error];
}
