import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/chat_model.dart';
import '../models/chat_message_model.dart';
import 'chat_states.dart';

class ChatCubit extends Cubit<ChatStates> {
  ChatCubit() : super(ChatInitialState());

  // Mock data for demonstration
  final List<Chat> _mockChats = [
      Chat(
      id: '1',
      name: 'Support Team',
      lastMessage: 'Hello! How can we help you today?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      participants: ['support', 'user'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
      Chat(
      id: '2',
      name: 'John Doe',
      lastMessage: 'Thanks for your message!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      participants: ['john', 'user'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // Mock messages for demonstration
  final Map<String, List<ChatMessage>> _mockMessages = {
    '1': [
      ChatMessage(
        id: '1',
        chatId: '1',
        senderId: 'support',
        text: 'Hello! How can we help you today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: MessageStatus.read,
      ),
    ],
    '2': [
      ChatMessage(
        id: '2',
        chatId: '2',
        senderId: 'john',
        text: 'Hi there!',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '3',
        chatId: '2',
        senderId: 'user',
        text: 'Hello John!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: '4',
        chatId: '2',
        senderId: 'john',
        text: 'Thanks for your message!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: MessageStatus.read,
      ),
    ],
  };

  // Fetch all chats
  Future<void> fetchChats() async {
    try {
      emit(ChatLoadingState());
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(ChatsLoadedState(chats: _mockChats));
    } catch (e) {
      emit(ChatErrorState('Failed to load chats: $e'));
    }
  }

  // Fetch messages for a specific chat
  Future<void> fetchMessages({
    required String chatId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      emit(ChatMessagesLoading(isFirstFetch: page == 1));
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final messages = _mockMessages[chatId] ?? [];
      
      // In a real app, you would implement pagination here
      final paginatedMessages = messages.take(limit).toList();
      
      emit(
        ChatMessagesLoaded(
          messages: paginatedMessages,
          hasReachedMax: paginatedMessages.length < limit,
          isFirstFetch: page == 1,
        ),
      );
    } catch (e) {
      emit(ChatErrorState('Failed to load messages: $e'));
    }
  }

  // Load more messages for pagination
  Future<void> loadMoreMessages({
    required String chatId,
    required int page,
    required int limit,
  }) async {
    try {
      // In a real app, you would fetch the next page of messages from the API
      // For now, we'll just return an empty list as we have limited mock data
      await Future.delayed(const Duration(milliseconds: 300));
      
      final currentState = state;
      if (currentState is ChatMessagesLoaded) {
        emit(
          currentState.copyWith(
            hasReachedMax: true, // No more messages to load
          ),
        );
      }
    } catch (e) {
      emit(ChatErrorState('Failed to load more messages: $e'));
    }
  }

  // Send a new message
  Future<void> sendMessage({
    required String chatId,
    required ChatMessage message,
  }) async {
    // Use the provided message but ensure it has the correct chatId and status
    final newMessage = message.copyWith(
      chatId: chatId,
      status: MessageStatus.sending,
    );

    try {
      // Emit sending state
      emit(MessageSending(newMessage));

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update message status to sent
      final sentMessage = newMessage.copyWith(
        status: MessageStatus.sent,
      );

      // In a real app, you would send the message to your backend here
      _mockMessages[chatId] = [..._mockMessages[chatId] ?? [], sentMessage];

      // Update chat's last message
      final chatIndex = _mockChats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        _mockChats[chatIndex] = _mockChats[chatIndex].copyWith(
          lastMessage: sentMessage.text,
          lastMessageTime: sentMessage.timestamp,
          unreadCount: _mockChats[chatIndex].unreadCount + 1,
        );
      }

      emit(MessageSentState(sentMessage));
      
      // Simulate a reply after a delay
      if (chatId == '1') {
        await Future.delayed(const Duration(seconds: 1));
        
        final replyMessage = ChatMessage(
          id: '${DateTime.now().millisecondsSinceEpoch + 1}',
          chatId: chatId,
          senderId: 'support',
          text: 'Thank you for your message. Our team will get back to you shortly!',
          timestamp: DateTime.now(),
          status: MessageStatus.delivered,
        );
        
        _mockMessages[chatId] = [..._mockMessages[chatId]!, replyMessage];
        
        // Update chat's last message
        if (chatIndex != -1) {
          _mockChats[chatIndex] = _mockChats[chatIndex].copyWith(
            lastMessage: replyMessage.text,
            lastMessageTime: replyMessage.timestamp,
            unreadCount: _mockChats[chatIndex].unreadCount + 1,
          );
        }
        
        emit(NewMessageReceived(replyMessage));
      }
    } catch (e) {
      emit(MessageSendFailed(
        message: newMessage,
        error: 'Failed to send message: $e',
      ));
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String messageId) async {
    try {
      // In a real app, you would update the message status on the backend
      final chatIndex = _mockChats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1 && _mockChats[chatIndex].unreadCount > 0) {
        _mockChats[chatIndex] = _mockChats[chatIndex].copyWith(
          unreadCount: 0,
        );
      }

      // Update message status to read
      if (_mockMessages[chatId] != null) {
        final messageIndex = _mockMessages[chatId]!
            .indexWhere((message) => message.id == messageId);
        if (messageIndex != -1) {
          _mockMessages[chatId]![messageIndex] =
              _mockMessages[chatId]![messageIndex].copyWith(
            status: MessageStatus.read,
          );
        }
      }

      emit(MessageStatusUpdated(
        messageId: messageId,
        status: MessageStatus.read,
      ));
    } catch (e) {
      emit(ChatErrorState('Failed to mark message as read: $e'));
    }
  }

  // Create a new chat
  Future<void> createChat(String recipientId) async {
    try {
      // In a real app, you would create a new chat on the backend
      final newChat = Chat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'New Chat',
        lastMessage: null,
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        participants: [recipientId, 'user'], // Replace 'user' with actual user ID
        createdAt: DateTime.now(),
      );

      _mockChats.insert(0, newChat);
      _mockMessages[newChat.id] = [];

      final currentState = state;
      if (currentState is ChatsLoadedState) {
        emit(currentState.copyWith(chats: List.from(_mockChats)));
      }
    } catch (e) {
      emit(ChatErrorState('Failed to create chat: $e'));
    }
  }

  // Delete a message from a chat
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    try {
      emit(ChatLoadingState());
      
      // Check if chat exists
      if (!_mockMessages.containsKey(chatId)) {
        throw Exception('Chat not found');
      }
      
      // Find and remove the message
      final messages = _mockMessages[chatId]!;
      final initialLength = messages.length;
      messages.removeWhere((message) => message.id == messageId);
      
      if (messages.length == initialLength) {
        // No message was removed
        throw Exception('Message not found');
      }
      
      // Update the last message in the chat if needed
      if (messages.isNotEmpty) {
        final chatIndex = _mockChats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          final lastMessage = messages.last;
          _mockChats[chatIndex] = _mockChats[chatIndex].copyWith(
            lastMessage: lastMessage.text,
            lastMessageTime: lastMessage.timestamp,
          );
        }
      } else {
        // If no messages left, update the chat to have no last message
        final chatIndex = _mockChats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          _mockChats[chatIndex] = _mockChats[chatIndex].copyWith(
            lastMessage: null,
            lastMessageTime: null,
          );
        }
      }
      
      // Update the UI by emitting the new state
      final currentState = state;
      if (currentState is ChatMessagesLoaded) {
        emit(ChatMessagesLoaded(
          messages: List.from(messages),
          hasReachedMax: currentState.hasReachedMax,
          isFirstFetch: currentState.isFirstFetch,
        ));
      }
      
      // Also update the chats list if it's currently loaded
      if (currentState is ChatsLoadedState) {
        emit(currentState.copyWith(chats: List.from(_mockChats)));
      }
    } catch (e) {
      emit(ChatErrorState('Failed to delete message: $e'));
      rethrow;
    }
  }
}
