import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class YOLOProvider with ChangeNotifier {
  final WebSocketChannel _channel;
  List<String> _cameraQueue = [];
  String? _currentCameraUrl;
  bool _isProcessing = false;
  Duration _interRequestDelay = const Duration(seconds: 1);

  List<Map<String, dynamic>> _boundingBoxes = [];
  List<Map<String, dynamic>> _classificationResults = [];
  String _latestFrameUrl = '';

  YOLOProvider({required String websocketUrl})
      : _channel = WebSocketChannel.connect(Uri.parse(websocketUrl)) {
    print("WebSocket connected to $websocketUrl");
    _initializeWebSocketListener();
    print("initializedWebSocketListener worked");
  }

  // Getters
  List<Map<String, dynamic>> get boundingBoxes => _boundingBoxes;
  List<Map<String, dynamic>> get classificationResults =>
      _classificationResults;
  String get latestFrameUrl => _latestFrameUrl;
  bool get isProcessing => _isProcessing;

// Initialize WebSocket listener
  void _initializeWebSocketListener() {
    _channel.stream.listen((event) {
      print("WebSocket message received: $event");
      try {
        final data = jsonDecode(event);
        if (data is List && data.isNotEmpty) {
          if (data[0].containsKey("classification")) {
            print("Classification data detected");
            _handleClassificationResponse(data);
          } else {
            print("Detection data detected");
            _handleDetectionResponse(data);
          }
        } else {
          print("Empty or non-list data received");
          _handleProcessingComplete();
        }
      } catch (e) {
        debugPrint("Error processing WebSocket message: $e");
        _handleProcessingError();
      }
    }, onError: (error) {
      debugPrint("WebSocket error: $error");
      _handleProcessingError();
    });
  }

  // Camera queue management
  void registerCamera(String cameraUrl) {
    print("Registering camera: $cameraUrl");
    if (!_cameraQueue.contains(cameraUrl)) {
      _cameraQueue.add(cameraUrl);
      if (!_isProcessing) {
        _processNextCamera();
      }
    }
  }

  void unregisterCamera(String cameraUrl) {
    print("Unregistering camera: $cameraUrl");
    _cameraQueue.remove(cameraUrl);
    if (_currentCameraUrl == cameraUrl) {
      _handleProcessingComplete();
    }
  }

  // Main processing chain
  void _processNextCamera() {
    if (_cameraQueue.isEmpty || _isProcessing) {
      print("Queue empty or already processing");
      return;
    }

    _isProcessing = true;
    _currentCameraUrl = _cameraQueue.first;
    _latestFrameUrl = _currentCameraUrl!;
    print("Processing camera: $_currentCameraUrl");
    notifyListeners();

    _sendDetectionRequest(_currentCameraUrl!);
  }

  void _sendDetectionRequest(String url) {
    try {
      print("Sending detection request for: $url");
      _channel.sink.add(jsonEncode({'url': url}));
    } catch (e) {
      debugPrint("Error sending detection request: $e");
      _handleProcessingError();
    }
  }

  void _sendCroppingRequest() {
    if (_boundingBoxes.isEmpty) {
      print("No bounding boxes found, skipping cropping request");
      _handleProcessingComplete();
      return;
    }

    print("Sending cropping request...");
    Future.delayed(_interRequestDelay, () {
      try {
        _channel.sink.add(jsonEncode(
            {'url': _currentCameraUrl, 'bounding_boxes': _boundingBoxes}));
      } catch (e) {
        debugPrint("Error sending cropping request: $e");
        _handleProcessingError();
      }
    });
  }

  // Response handlers
  void _handleDetectionResponse(List<dynamic> data) {
    print("Handling detection response with ${data.length} bounding boxes");
    _boundingBoxes = List<Map<String, dynamic>>.from(data);
    notifyListeners();
    _sendCroppingRequest();
  }

  void _handleClassificationResponse(List<dynamic> data) {
    print("Handling classification response with ${data.length} items");
    _classificationResults = List<Map<String, dynamic>>.from(data);
    notifyListeners();
    _handleProcessingComplete();
  }

  // Completion/error handling
  void _handleProcessingComplete() {
    print("Processing complete for $_currentCameraUrl");
    Future.delayed(_interRequestDelay, () {
      _isProcessing = false;
      _currentCameraUrl = null;
      _boundingBoxes.clear();
      notifyListeners();

      if (_cameraQueue.isNotEmpty) {
        _cameraQueue.add(_cameraQueue.removeAt(0));
        _processNextCamera();
      }
    });
  }

  void _handleProcessingError() {
    print("Handling error during processing");
    _isProcessing = false;
    _currentCameraUrl = null;
    notifyListeners();

    if (_cameraQueue.isNotEmpty) {
      Future.delayed(_interRequestDelay * 2, _processNextCamera);
    }
  }

  @override
  void dispose() {
    print("Closing WebSocket connection");
    _channel.sink.close();
    super.dispose();
  }
}
