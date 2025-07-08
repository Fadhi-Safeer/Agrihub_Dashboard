import 'package:flutter/material.dart';

class Agribot extends StatefulWidget {
  final Function(String)? onMessageSent;
  final Color? primaryColor;
  final Color? backgroundColor;
  final String? greetingMessage;
  final double? chatButtonSize;
  final IconData? chatIcon;

  const Agribot({
    Key? key,
    this.onMessageSent,
    this.primaryColor,
    this.backgroundColor,
    this.greetingMessage,
    this.chatButtonSize,
    this.chatIcon,
  }) : super(key: key);

  @override
  State<Agribot> createState() => _AgribotState();
}

class _AgribotState extends State<Agribot> with TickerProviderStateMixin {
  bool _isChatOpen = false;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late AnimationController _animationController;
  Offset _buttonPosition = const Offset(20, 100);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Add default greeting message
    _messages.add(
      ChatMessage(
        message:
            widget.greetingMessage ?? "👋 Hi there! How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });

    if (_isChatOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    setState(() {
      _messages.add(
        ChatMessage(message: message, isUser: true, timestamp: DateTime.now()),
      );
    });

    _messageController.clear();

    // Call the callback function if provided
    if (widget.onMessageSent != null) {
      widget.onMessageSent!(message);
    }

    // Simulate bot response after 1 second (optional - remove if not needed)
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              message: _generateBotResponse(message),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    });
  }

  String _generateBotResponse(String userMessage) {
    // Simple bot responses for demo - customize or remove this method
    final responses = [
      "Thanks for your message! How can I help you further?",
      "I understand. Let me connect you with our support team.",
      "That's a great question! I'll get you the information you need.",
      "I'm here to help! What specific information are you looking for?",
      "Thank you for reaching out. Our team will get back to you soon.",
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  // Method to add bot responses from external sources
  void addBotMessage(String message) {
    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(
            message: message,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define green theme colors
    final Color greenPrimary = widget.primaryColor ?? const Color(0xFF388E3C);
    final Color greenBackground =
        widget.backgroundColor ?? const Color(0xFFE8F5E9);
    final Color greenAccent = const Color(0xFF66BB6A);
    final Color chatBubbleUser = greenPrimary;
    final Color chatBubbleBot = greenAccent.withOpacity(0.2);

    return Stack(
      children: [
        // Chat Bottom Sheet Overlay
        if (_isChatOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleChat,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

        // Sliding Chat Panel (Green themed)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: _isChatOpen ? 0 : -500,
          left: 0,
          right: 0,
          height: 500,
          child: Material(
            color: greenBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            elevation: 18,
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: greenPrimary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.chatIcon ?? Icons.chat_bubble,
                        color: Colors.white,
                        size: 36, // increased icon size
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'AgriBot Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleChat,
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),

                // Messages List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(
                          message, chatBubbleUser, chatBubbleBot);
                    },
                  ),
                ),

                // Message Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(color: greenAccent.withOpacity(0.2))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: greenBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _sendMessage,
                        backgroundColor: greenPrimary,
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Draggable Floating Chat Button
        Positioned(
          left: _buttonPosition.dx,
          bottom: _buttonPosition.dy,
          child: Draggable(
            feedback: _buildChatButton(greenPrimary),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              setState(() {
                _buttonPosition = Offset(
                  details.offset.dx,
                  MediaQuery.of(context).size.height - details.offset.dy - 100,
                );
              });
            },
            child: _buildChatButton(greenPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton(Color greenPrimary) {
    return GestureDetector(
      onTap: _toggleChat,
      child: Container(
        width: widget.chatButtonSize ?? 72,
        height: widget.chatButtonSize ?? 72,
        decoration: BoxDecoration(
          color: greenPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: greenPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          _isChatOpen ? Icons.close : (widget.chatIcon ?? Icons.support_agent),
          color: Colors.white,
          size: 38, // increased size
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, Color userColor, Color botColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: message.isUser ? userColor : botColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            message.message,
            style: TextStyle(
              color: message.isUser ? Colors.white : userColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
