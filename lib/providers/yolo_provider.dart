import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class YOLOProvider with ChangeNotifier {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://127.0.0.1:8000'),
  );

  List<Map<String, dynamic>> _boundingBoxes = [];
  List<dynamic> _classificationResults = [];
  String _latestFrameURL = '';

  List<Map<String, dynamic>> get boundingBoxes => _boundingBoxes;
  List<dynamic> get classificationResults => _classificationResults;
  String get latestFrameURL => _latestFrameURL;

  YOLOProvider() {
    _channel.stream.listen((event) {
      try {
        final data = jsonDecode(event);
        // Determine response type by checking for a specific key
        if (data is List &&
            data.isNotEmpty &&
            data[0] is Map &&
            data[0].containsKey("bounding_box")) {
          // Received cropping & classification result
          _classificationResults = data;
          notifyListeners();
        } else if (data is List) {
          // Received detection bounding boxes
          _boundingBoxes = List<Map<String, dynamic>>.from(data);
          notifyListeners();
        }
      } catch (e) {
        print("Error parsing YOLO response: $e");
      }
    });
  }

  // Send detection request (Step 1: Only URL)
  void sendDetectionRequest(String url) {
    _latestFrameURL = url;
    final payload = jsonEncode({'url': url});
    _channel.sink.add(payload);
    notifyListeners();
  }

  // Send cropping & classification request (Step 2: URL and bounding boxes)
  void sendCroppingRequest(
      String url, List<Map<String, dynamic>> boundingBoxes) {
    _latestFrameURL = url;
    final payload = jsonEncode({
      'url': url,
      'bounding_boxes': boundingBoxes,
    });
    _channel.sink.add(payload);
    notifyListeners();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
