import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safetyZone/Features/chat_feature/models/chat_message_model.dart';

// A simple widget that displays the message text
class MockMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MockMessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(message.text ?? ''),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Text message displays correctly', (WidgetTester tester) async {
    // Create a test message
    final message = ChatMessage.text(
      id: '1',
      chatId: 'chat1',
      senderId: 'user1',
      text: 'Hello, World!',
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    // Build our widget
    await tester.pumpWidget(
      MockMessageBubble(
        message: message,
        isMe: true,
      ),
    );

    // Verify the message text is displayed
    expect(find.text('Hello, World!'), findsOneWidget);
  });
}
