// lib/services/yolo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class YoloService {
  final String baseUrl;

  YoloService(this.baseUrl);

  Future<List<dynamic>> predict(XFile image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict/'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('file', image.path),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } else {
      throw Exception('Failed to get prediction');
    }
  }
}
