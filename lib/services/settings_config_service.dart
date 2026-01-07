// model_config_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ModelConfigService {
  final String baseUrl;
  const ModelConfigService({required this.baseUrl});

  // =========================
  // MODELS CONFIG
  // =========================
  Future<Map<String, dynamic>> fetchModelConfig() async {
    final uri = Uri.parse("$baseUrl/config/models");
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          "GET /config/models failed (${resp.statusCode}): ${resp.body}");
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format from /config/models");
    }

    for (final key in [
      "Detection",
      "Growth",
      "Health",
      "Disease",
      "Prediction"
    ]) {
      final m = decoded[key];
      if (m is! Map<String, dynamic>) {
        throw Exception("Missing or invalid model section: $key");
      }
      if (m["path"] is! String) {
        throw Exception("$key.path missing/invalid");
      }
      if (m["confidence"] is! num) {
        throw Exception("$key.confidence missing/invalid");
      }
    }

    return decoded;
  }

  Future<void> updateModelConfig(Map<String, dynamic> payload) async {
    final uri = Uri.parse("$baseUrl/config/models");
    final resp = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          "PUT /config/models failed (${resp.statusCode}): ${resp.body}");
    }
  }

  // =========================
  // MODEL UPLOAD
  // =========================
  Future<String> uploadModel({
    required String modelType,
    required String fileName,
    required List<int> bytes,
  }) async {
    final uri = Uri.parse("$baseUrl/upload-model?type=$modelType");

    final request = http.MultipartRequest("POST", uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          "file",
          bytes,
          filename: fileName,
        ),
      );

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200) {
      throw Exception(
          "POST /upload-model failed (${resp.statusCode}): ${resp.body}");
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format from /upload-model");
    }

    final path = decoded["path"];
    if (path == null || path is! String || path.trim().isEmpty) {
      throw Exception("Backend did not return a valid 'path'");
    }

    return path;
  }

  // =========================
  // IMAGE FOLDER CONFIG
  // =========================
  Future<String> fetchImageFolderPath() async {
    final uri = Uri.parse("$baseUrl/config/image-folder");
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          "GET /config/image-folder failed (${resp.statusCode}): ${resp.body}");
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format from /config/image-folder");
    }

    final path = decoded["path"];
    if (path == null || path is! String || path.trim().isEmpty) {
      throw Exception("Backend returned invalid image folder path");
    }

    return path;
  }

  Future<void> updateImageFolderPath(String path) async {
    final uri = Uri.parse("$baseUrl/config/image-folder");
    final resp = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"path": path}),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          "PUT /config/image-folder failed (${resp.statusCode}): ${resp.body}");
    }
  }

  // =========================
  // ALERT EMAIL IDS CONFIG
  // =========================
  // Backend must provide:
  // GET  /config/alert-emails  -> { "emails": ["a@x.com","b@y.com"] }
  // PUT  /config/alert-emails  (body) { "emails": ["a@x.com","b@y.com"] }

  Future<List<String>> fetchAlertEmails() async {
    final uri = Uri.parse("$baseUrl/config/alert-emails");
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          "GET /config/alert-emails failed (${resp.statusCode}): ${resp.body}");
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception("Invalid response format from /config/alert-emails");
    }

    final emails = decoded["emails"];
    if (emails is! List) {
      throw Exception("Backend returned invalid 'emails' (expected List)");
    }

    // Keep only valid strings, trim, remove empties
    return emails
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> updateAlertEmails(List<String> emails) async {
    final uri = Uri.parse("$baseUrl/config/alert-emails");

    final clean =
        emails.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final resp = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"emails": clean}),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          "PUT /config/alert-emails failed (${resp.statusCode}): ${resp.body}");
    }
  }

  // =========================
  // NEW: ALERT TIMES CONFIG
  // =========================
  // Backend must provide:
  // GET /config/alert-time  -> { "time": ["09:00","15:00"] }
  // PUT /config/alert-time  -> body { "time": ["09:00","15:00"] }

  Future<List<String>> fetchAlertTimes() async {
    final res = await http.get(Uri.parse('$baseUrl/config/alert-time'));
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch alert times: ${res.body}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['time'] as List<dynamic>).cast<String>();
    return list;
  }

  Future<void> updateAlertTimes(List<String> times) async {
    final res = await http.put(
      Uri.parse('$baseUrl/config/alert-time'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'time': times}), // 👈 MUST be "time", not "times"
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update alert times: ${res.body}');
    }
  }
}
