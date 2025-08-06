import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AgribotService {
  // Backend URL - change this to your actual backend URL
  static const String _baseUrl =
      'http://localhost:8075'; // For local development
  // static const String _baseUrl = 'https://your-backend-domain.com';  // For production

  static const Duration _timeout = Duration(seconds: 30);

  // Singleton pattern
  static final AgribotService _instance = AgribotService._internal();
  factory AgribotService() => _instance;
  AgribotService._internal();

  final http.Client _client = http.Client();
  String? _sessionId;

  // Generate or get session ID
  String get sessionId {
    _sessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    return _sessionId!;
  }

  // Send message to backend and get response
  Future<AgribotResponse> sendMessage(String message, {String? userId}) async {
    try {
      final url = Uri.parse('$_baseUrl/chat');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode({
        'message': message,
        'user_id': userId,
        'session_id': sessionId,
      });

      debugPrint('Sending message to AgriBot: $message');

      final response = await _client
          .post(url, headers: headers, body: body)
          .timeout(_timeout);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AgribotResponse.fromJson(data);
      } else {
        throw AgribotException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on SocketException {
      throw AgribotException(
        'No internet connection. Please check your network.',
        0,
      );
    } on HttpException {
      throw AgribotException(
        'Network error. Please try again.',
        0,
      );
    } on FormatException {
      throw AgribotException(
        'Invalid response format from server.',
        0,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw AgribotException(
        'Failed to send message: ${e.toString()}',
        0,
      );
    }
  }

  // Check if backend is healthy
  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$_baseUrl/');
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  // Get conversation history
  Future<List<ChatMessage>> getConversationHistory() async {
    try {
      final url = Uri.parse('$_baseUrl/chat/history/$sessionId');
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> messages = data['messages'];
          return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting conversation history: $e');
      return [];
    }
  }

  // Clear conversation history
  Future<bool> clearConversation() async {
    try {
      final url = Uri.parse('$_baseUrl/chat/clear');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'session_id': sessionId});

      final response = await _client
          .post(url, headers: headers, body: body)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing conversation: $e');
      return false;
    }
  }

  // Get backend status
  Future<BackendStatus> getStatus() async {
    try {
      final url = Uri.parse('$_baseUrl/status');
      final response = await _client.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BackendStatus.fromJson(data);
      }
      throw AgribotException('Failed to get status', response.statusCode);
    } catch (e) {
      debugPrint('Error getting status: $e');
      rethrow;
    }
  }

  // Reset session (creates new session ID)
  void resetSession() {
    _sessionId = null;
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}

// Data models
class AgribotResponse {
  final String response;
  final DateTime timestamp;
  final bool success;
  final String? error;

  AgribotResponse({
    required this.response,
    required this.timestamp,
    required this.success,
    this.error,
  });

  factory AgribotResponse.fromJson(Map<String, dynamic> json) {
    return AgribotResponse(
      response: json['response'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'] ?? false,
      error: json['error'],
    );
  }
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

class BackendStatus {
  final String status;
  final bool openaiConfigured;
  final int activeSessions;
  final DateTime timestamp;

  BackendStatus({
    required this.status,
    required this.openaiConfigured,
    required this.activeSessions,
    required this.timestamp,
  });

  factory BackendStatus.fromJson(Map<String, dynamic> json) {
    return BackendStatus(
      status: json['status'] ?? '',
      openaiConfigured: json['openai_configured'] ?? false,
      activeSessions: json['active_sessions'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class AgribotException implements Exception {
  final String message;
  final int statusCode;

  AgribotException(this.message, this.statusCode);

  @override
  String toString() => 'AgribotException: $message (Status: $statusCode)';
}
