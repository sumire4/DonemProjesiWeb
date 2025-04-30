import 'package:flutter/material.dart';
import 'package:donemprojesi/ekranlar/chat_message.dart';
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: message.isUser ? const Color.fromARGB(255, 75, 132, 178) : const Color.fromARGB(255, 123, 138, 155),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(message.text),
      ),
    );
  }
}