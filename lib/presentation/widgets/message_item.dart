import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final bool sentByMe;
  final String message;
  const MessageItem({
    super.key,
    required this.sentByMe,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    Color purple = const Color(0xff6c5ce7);
    Color white = Colors.white;
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          color: sentByMe ? purple : white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 18, color: sentByMe ? white : purple),
            ),
            const SizedBox(width: 5),
            Text(
              '1:10 AM',
              style: TextStyle(
                fontSize: 10,
                color: (sentByMe ? white : purple).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
