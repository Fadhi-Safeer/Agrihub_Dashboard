import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/image_item.dart';

class ImageRepository {
  final String baseUrl;
  final http.Client client;

  ImageRepository({
    this.baseUrl = "http://localhost:8001",
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<List<ImageItem>> fetchImages(String camNum) async {
    debugPrint("Fetching images for camera: $camNum");
    final url = Uri.parse("$baseUrl/images/?cam_num=$camNum");
    debugPrint("URL: $url");

    try {
      debugPrint("Making GET request to $url");
      final response = await client.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      debugPrint("Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint("Received ${data.length} images");

        return data.entries
            .map((entry) => ImageItem.fromJson(entry.value))
            .toList();
      } else if (response.statusCode == 404) {
        throw CameraNotFoundException("Camera '$camNum' not found");
      } else {
        throw ApiException(
            "Server responded with status ${response.statusCode}");
      }
    } on http.ClientException catch (e) {
      debugPrint("Network error: $e");
      throw NetworkException("Couldn't connect to server");
    } on TimeoutException {
      debugPrint("Request timed out");
      throw NetworkException("Connection timed out");
    } on FormatException catch (e) {
      debugPrint("JSON parsing error: $e");
      throw DataParsingException("Invalid server response");
    } catch (e) {
      debugPrint("Unexpected error: $e");
      throw Exception("Failed to load images");
    }
  }
}

// Custom exceptions for better error handling
class CameraNotFoundException implements Exception {
  final String message;
  CameraNotFoundException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);
  @override
  String toString() => message;
}
