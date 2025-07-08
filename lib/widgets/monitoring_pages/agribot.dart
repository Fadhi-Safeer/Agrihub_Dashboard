// File: lib/widgets/floating_chat_widget.dart
import 'package:flutter/material.dart';

class FloatingChatWidget extends StatefulWidget {
  final Function(String)? onMessageSent;
  final Color? primaryColor;
  final Color? backgroundColor;
  final String? greetingMessage;
  final double? chatButtonSize;
  final IconData? chatIcon;

  const FloatingChatWidget({
    Key? key,
    this.onMessageSent,
    this.primaryColor,
    this.backgroundColor,
    this.greetingMessage,
    this.chatButtonSize,
    this.chatIcon,
  }) : super(key: key);

  @override
  State<FloatingChatWidget> createState() => _FloatingChatWidgetState();
}

class _FloatingChatWidgetState extends State<FloatingChatWidget>
    with TickerProviderStateMixin {
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

        // Sliding Chat Panel
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          bottom: _isChatOpen ? 0 : -500,
          left: 0,
          right: 0,
          height: 500,
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.primaryColor ?? Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(widget.chatIcon ?? Icons.chat, color: Colors.white),
                      const SizedBox(width: 12),
                      const Text(
                        'Chat Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleChat,
                        child: const Icon(Icons.close, color: Colors.white),
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
                      return _buildMessageBubble(message);
                    },
                  ),
                ),

                // Message Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
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
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _sendMessage,
                        backgroundColor: widget.primaryColor ?? Colors.blue,
                        child: const Icon(Icons.send, color: Colors.white),
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
            feedback: _buildChatButton(),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              setState(() {
                _buttonPosition = Offset(
                  details.offset.dx,
                  MediaQuery.of(context).size.height - details.offset.dy - 100,
                );
              });
            },
            child: _buildChatButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton() {
    return GestureDetector(
      onTap: _toggleChat,
      child: Container(
        width: widget.chatButtonSize ?? 60,
        height: widget.chatButtonSize ?? 60,
        decoration: BoxDecoration(
          color: widget.primaryColor ?? Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _isChatOpen ? Icons.close : (widget.chatIcon ?? Icons.chat),
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: message.isUser
                ? (widget.primaryColor ?? Colors.blue)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.message,
            style: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
              fontSize: 16,
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
