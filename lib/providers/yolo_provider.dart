import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class YOLOProvider with ChangeNotifier {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://127.0.0.1:8000'),
  );

  List<Map<String, dynamic>> _boundingBoxes = [];
  List<Map<String, dynamic>> _classificationResults = [];
  String _latestFrameURL = '';

  List<Map<String, dynamic>> get boundingBoxes => _boundingBoxes;
  List<Map<String, dynamic>> get classificationResults =>
      _classificationResults;
  String get latestFrameURL => _latestFrameURL;

  YOLOProvider() {
    _channel.stream.listen((event) {
      try {
        final data = jsonDecode(event);

        if (data is List && data.isNotEmpty && data[0] is Map) {
          if (data[0].containsKey("classification")) {
            // Append new classification results at the top
            _classificationResults.insertAll(
                0, List<Map<String, dynamic>>.from(data));
          } else {
            // Replace bounding boxes with new data
            _boundingBoxes = List<Map<String, dynamic>>.from(data);
          }
          notifyListeners();
        }
      } catch (e) {
        print("Error parsing YOLO response: $e");
      }
    });
  }

  void sendDetectionRequest(String url) {
    if (url.isNotEmpty) {
      _latestFrameURL = url;
      final payload = jsonEncode({'url': url});
      _channel.sink.add(payload);
      notifyListeners();
    }
  }

  void sendCroppingRequest(
      String url, List<Map<String, dynamic>> boundingBoxes) {
    if (url.isNotEmpty && boundingBoxes.isNotEmpty) {
      _latestFrameURL = url;
      final payload = jsonEncode({'url': url, 'bounding_boxes': boundingBoxes});
      _channel.sink.add(payload);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
