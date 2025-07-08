import 'package:agrihub_dashboard/widgets/chatbot/agribot.dart';
import 'package:flutter/material.dart';

class FloatingStackChatbot extends StatelessWidget {
  final Widget child;
  const FloatingStackChatbot({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Use Overlay in the widget tree so Draggable finds it!
        Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Agribot(
                primaryColor: Colors.deepPurple,
                backgroundColor: Colors.white,
                greetingMessage: "Hello! Need any help?",
                chatButtonSize: 56,
                chatIcon: Icons.support_agent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
