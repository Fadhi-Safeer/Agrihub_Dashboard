import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../services/yolo_service.dart';
import 'bounding_box_painter.dart';

class CameraFeed extends StatefulWidget {
  final String cameraUrl;

  const CameraFeed({Key? key, required this.cameraUrl}) : super(key: key);

  @override
  _CameraFeedState createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  late VideoPlayerController _controller;
  late WebSocketChannel _channel;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _boundingBoxes = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.cameraUrl);
    _channel = YOLOService.connect(widget.cameraUrl);
    _initializeController();
    _listenToYOLOService();
    _startSendingURLPeriodically();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.play();
      setState(() {
        _isLoading = false;
      });
      debugPrint("Video player initialized and playing.");
      debugPrint("Video size: ${_controller.value.size}");
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video: $e';
        _isLoading = false;
      });
      debugPrint("Error initializing video player: $e");
    }
  }

  void _listenToYOLOService() {
    YOLOService.listen(
      _channel,
      onData: (data) {
        try {
          final parsedData = jsonDecode(data);
          debugPrint('Received data: $parsedData');
          if (parsedData is List) {
            setState(() {
              _boundingBoxes = List<Map<String, dynamic>>.from(parsedData);
            });
            debugPrint('Bounding boxes updated: $_boundingBoxes');
          } else {
            setState(() {
              _errorMessage = 'Invalid data format';
            });
            debugPrint('Invalid data format received: $parsedData');
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to parse bounding box data: $e';
          });
          debugPrint('Error parsing bounding box data: $e');
        }
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
      },
    );
  }

  void _startSendingURLPeriodically() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      YOLOService.sendURL(_channel, widget.cameraUrl);
      debugPrint('URL sent to backend: ${widget.cameraUrl}');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    YOLOService.close(widget.cameraUrl);
    _timer?.cancel();
    super.dispose();
    debugPrint('Disposed CameraFeed widget.');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building CameraFeed widget.');
    return Stack(
      children: [
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
        if (_boundingBoxes.isNotEmpty &&
            _controller.value.isInitialized &&
            _controller.value.size.width > 0 &&
            _controller.value.size.height > 0)
          Positioned.fill(
            // Ensure bounding boxes cover the video
            child: CustomPaint(
              painter: BoundingBoxPainter(
                boundingBoxes: _boundingBoxes,
                cameraAspectRatio: _controller.value.aspectRatio,
                previewSize: _controller.value.size,
              ),
            ),
          ),
      ],
    );
  }
}
