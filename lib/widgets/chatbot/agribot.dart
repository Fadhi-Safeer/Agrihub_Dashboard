import 'package:flutter/material.dart';
import '../../services/agribot_service.dart';

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

  // Backend service instance
  final AgribotService _agribotService = AgribotService();
  bool _isLoading = false;
  bool _isBackendHealthy = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Check backend health and load conversation history
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Check backend health
    _isBackendHealthy = await _agribotService.checkHealth();

    if (_isBackendHealthy) {
      // Load conversation history
      final history = await _agribotService.getConversationHistory();

      setState(() {
        // Convert backend messages to local ChatMessage format
        _messages.addAll(history.map((msg) => ChatMessage(
              message: msg.content,
              isUser: msg.isUser,
              timestamp: DateTime.now(),
            )));
      });
    }

    // Add greeting message if no history or backend is down
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          message: _isBackendHealthy
              ? (widget.greetingMessage ??
                  "👋 Hi there! How can I help you with agriculture today?")
              : "🚫 Backend is currently unavailable. Please try again later.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _agribotService.dispose();
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    setState(() {
      _messages.add(
        ChatMessage(message: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();

    // Call the callback function if provided
    if (widget.onMessageSent != null) {
      widget.onMessageSent!(message);
    }

    // Send message to backend
    try {
      if (_isBackendHealthy) {
        final response = await _agribotService.sendMessage(message);

        if (mounted) {
          setState(() {
            _messages.add(
              ChatMessage(
                message: response.response,
                isUser: false,
                timestamp: response.timestamp,
              ),
            );
            _isLoading = false;
          });
        }
      } else {
        // Fallback to local response if backend is down
        _addErrorMessage(
            "Backend is currently unavailable. Please check your connection and try again.");
      }
    } catch (e) {
      if (mounted) {
        String errorMessage =
            "Sorry, I couldn't process your request right now.";

        if (e is AgribotException) {
          errorMessage = e.message;
        }

        _addErrorMessage(errorMessage);
      }
    }
  }

  void _addErrorMessage(String errorMessage) {
    setState(() {
      _messages.add(
        ChatMessage(
          message: errorMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
    });
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

  // Method to clear conversation
  Future<void> _clearConversation() async {
    try {
      final success = await _agribotService.clearConversation();
      if (success) {
        setState(() {
          _messages.clear();
          _messages.add(
            ChatMessage(
              message: widget.greetingMessage ??
                  "👋 Hi there! How can I help you with agriculture today?",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error clearing conversation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define enhanced green theme colors
    final Color greenPrimary = widget.primaryColor ?? const Color(0xFF2E7D32);
    final Color greenBackground =
        widget.backgroundColor ?? const Color(0xFFE8F5E9);
    final Color greenAccent = const Color(0xFF4CAF50);
    final Color chatBubbleUser = greenPrimary;
    final Color chatBubbleBot = greenAccent.withOpacity(0.15);

    return Stack(
      children: [
        // Chat Bottom Sheet Overlay
        if (_isChatOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleChat,
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),

        // Sliding Chat Panel (Enhanced Green themed)
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
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            elevation: 20,
            child: Column(
              children: [
                // Chat Header with enhanced styling
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: greenPrimary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: greenPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Custom AgriBot icon with enhanced styling
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/agribot.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                widget.chatIcon ?? Icons.agriculture,
                                color: Colors.white,
                                size: 28,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AgriBot Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isBackendHealthy
                                ? 'Always here to help'
                                : 'Offline',
                            style: TextStyle(
                              color: _isBackendHealthy
                                  ? Colors.white70
                                  : Colors.red.shade200,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Clear conversation button
                      GestureDetector(
                        onTap: _clearConversation,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleChat,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Messages List with enhanced styling
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return _buildLoadingIndicator();
                      }

                      final message = _messages[index];
                      return _buildMessageBubble(
                          message, chatBubbleUser, chatBubbleBot);
                    },
                  ),
                ),

                // Message Input with enhanced styling
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        top: BorderSide(color: greenAccent.withOpacity(0.2))),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: _isBackendHealthy
                                ? 'Ask me anything about agriculture...'
                                : 'Backend unavailable...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: greenBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: _isLoading ? Colors.grey : greenPrimary,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: (_isLoading ? Colors.grey : greenPrimary)
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          mini: true,
                          onPressed: _isLoading ? null : _sendMessage,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Enhanced Draggable Floating Chat Button with increased size
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

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
              bottomLeft: Radius.circular(6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: widget.primaryColor ?? const Color(0xFF2E7D32),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'AgriBot is thinking...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatButton(Color greenPrimary) {
    final double buttonSize = widget.chatButtonSize ?? 90;

    return GestureDetector(
      onTap: _toggleChat,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: greenPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: greenPrimary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: greenPrimary.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: _isChatOpen
                  ? Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: buttonSize * 0.5,
                    )
                  : ClipOval(
                      child: Image.asset(
                        'assets/agribot.png',
                        width: buttonSize * 0.7,
                        height: buttonSize * 0.7,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            widget.chatIcon ?? Icons.agriculture,
                            color: Colors.white,
                            size: buttonSize * 0.5,
                          );
                        },
                      ),
                    ),
            ),
            // Status indicator
            if (!_isBackendHealthy)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      ChatMessage message, Color userColor, Color botColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: message.isUser ? userColor : botColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(24),
              topRight: const Radius.circular(24),
              bottomLeft: message.isUser
                  ? const Radius.circular(24)
                  : const Radius.circular(6),
              bottomRight: message.isUser
                  ? const Radius.circular(6)
                  : const Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.message,
            style: TextStyle(
              color: message.isUser ? Colors.white : userColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
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
