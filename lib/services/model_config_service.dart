import 'dart:convert';
import 'package:http/http.dart' as http;

class ModelConfigService {
  final String baseUrl;
  const ModelConfigService({required this.baseUrl});

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
}
