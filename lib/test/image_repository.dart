import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'image_item.dart';

class ImageRepository {
  final String baseUrl = "http://10.101.127.35:8001";

  Future<List<ImageItem>> fetchImages(String camNum) async {
    debugPrint("Fetching images for camera: $camNum");
    final url = Uri.parse("$baseUrl/images/$camNum");
    debugPrint("URL: $url");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      debugPrint("Response data: $data");
      return data.map((json) => ImageItem.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load images");
    }
  }
}
