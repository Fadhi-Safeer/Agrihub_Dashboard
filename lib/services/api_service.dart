import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchData(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchAgrivisionSummary({
    int days = 30,
    int? cameraId,
    String? day, // "YYYY-MM-DD"
  }) async {
    final query = <String, String>{
      'days': days.toString(),
    };
    if (cameraId != null) query['camera_id'] = cameraId.toString();
    if (day != null && day.isNotEmpty) query['day'] = day;

    final uri = Uri.parse('$baseUrl/agrivision/summary').replace(
      queryParameters: query,
    );

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('API error ${res.statusCode}: ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
