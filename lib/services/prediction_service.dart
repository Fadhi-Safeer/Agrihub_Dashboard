import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionService {
  final String baseUrl;
  const PredictionService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchDefaults() async {
    final uri = Uri.parse('$baseUrl/config/prediction-defaults');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
          'Fetch defaults failed (${resp.statusCode}): ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid defaults response: ${resp.body}');
    }
    return data;
  }

  Future<void> updateDefaults({
    required int growthDay,
    required int n,
    required int p,
    required int k,
  }) async {
    final uri = Uri.parse('$baseUrl/config/prediction-defaults');
    final payload = {
      "growth_day": growthDay,
      "npk": {"Nitrogen": n, "Phosphorus": p, "Potassium": k},
    };

    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception(
          'Update defaults failed (${resp.statusCode}): ${resp.body}');
    }
  }

  Future<double> predictYield({
    required int growthDay,
    required int n,
    required int p,
    required int k,
  }) async {
    final uri = Uri.parse('$baseUrl/predict/yield');
    final payload = {
      "growth_day": growthDay,
      "npk": {"Nitrogen": n, "Phosphorus": p, "Potassium": k},
    };

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      throw Exception('Predict failed (${resp.statusCode}): ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid predict response: ${resp.body}');
    }

    final v = data['fresh_mass_g'];
    if (v is! num) {
      throw Exception("Response missing numeric 'fresh_mass_g': ${resp.body}");
    }
    return v.toDouble();
  }
}
