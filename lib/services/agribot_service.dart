// lib/services/agribot_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// TODO: replace with your actual backend URL (or import from globals.dart)
const String _defaultBaseUrl = 'http://127.0.0.1:8001';

class AgribotException implements Exception {
  final String message;
  AgribotException(this.message);

  @override
  String toString() => 'AgribotException: $message';
}

class AgribotHistoryMessage {
  final String content;
  final bool isUser;

  AgribotHistoryMessage({
    required this.content,
    required this.isUser,
  });
}

class AgribotResponse {
  final String response;
  final DateTime timestamp;

  AgribotResponse({
    required this.response,
    required this.timestamp,
  });
}

class AgribotService {
  final String baseUrl;

  AgribotService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl;

  /// Check backend health via GET /agribot/health
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/agribot/health');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));

      return resp.statusCode == 200;
    } catch (_) {
      // On any error, treat backend as down
      return false;
    }
  }

  /// Send a new user message via POST /agribot/message
  Future<AgribotResponse> sendMessage(
    String message, {
    int days = 14,
  }) async {
    final uri = Uri.parse('$baseUrl/agribot/message');
    final body = jsonEncode({
      'message': message,
      'days': days,
    });

    http.Response resp;
    try {
      resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw AgribotException(
        'Failed to contact Agribot backend. Please check your connection.',
      );
    }

    if (resp.statusCode != 200) {
      throw AgribotException(
        'Backend error (${resp.statusCode}): ${resp.body}',
      );
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw AgribotException('Invalid response format from Agribot.');
    }

    final respText = decoded['response'];
    final tsRaw = decoded['timestamp'];

    if (respText is! String || tsRaw is! String) {
      throw AgribotException('Missing fields in Agribot response.');
    }

    final ts = DateTime.tryParse(tsRaw) ?? DateTime.now();

    return AgribotResponse(
      response: respText,
      timestamp: ts,
    );
  }

  /// For now, backend doesn't store history, so return empty.
  Future<List<AgribotHistoryMessage>> getConversationHistory() async {
    // If later you add a real history endpoint, implement it here.
    return <AgribotHistoryMessage>[];
  }

  /// Call DELETE /agribot/history (our backend just returns {"status":"cleared"})
  Future<bool> clearConversation() async {
    try {
      final uri = Uri.parse('$baseUrl/agribot/history');
      final resp = await http.delete(uri).timeout(const Duration(seconds: 5));

      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    // Nothing to dispose yet, but here for future streams/controllers.
  }
}
