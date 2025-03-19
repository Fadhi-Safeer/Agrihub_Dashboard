import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:screenshot/screenshot.dart';
import 'package:agrihub_dashboard/services/yolo_service.dart';
import 'bounding_box_painter.dart';

class CameraFeed extends StatefulWidget {
  final String cameraUrl;

  const CameraFeed({Key? key, required this.cameraUrl}) : super(key: key);

  @override
  _CameraFeedState createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _timer;
  WebSocketChannel? _channel;
  ScreenshotController _screenshotController = ScreenshotController();
  List<List<int>> _boundingBoxes = [];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.cameraUrl);
    _initializeController();
    _channel = YOLOService.connect();
    YOLOService.listen(
      _channel!,
      onData: (data) {
        setState(() {
          _boundingBoxes = (jsonDecode(data) as List)
              .map((box) => (box as List).map((e) => e as int).toList())
              .toList();
        });
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.play();
      setState(() {
        _isLoading = false;
      });
      _startFrameCapture();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video: $e';
        _isLoading = false;
      });
      print('Error initializing controller: $e');
    }
  }

  void _startFrameCapture() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_controller.value.isInitialized) {
        final frame = await _captureFrame();
        if (frame != null) {
          print('Frame captured successfully. Sending to backend...');
          YOLOService.sendImage(_channel!, frame);
        } else {
          print('Failed to capture frame.');
        }
      } else {
        print('Controller is not initialized.');
      }
    });
  }

  Future<Uint8List?> _captureFrame() async {
    try {
      final image = await _screenshotController.capture();
      print('Screenshot captured.');

      // Save the screenshot locally for verification
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/frame_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(image!);
      print('Screenshot saved to $path');

      return image;
    } catch (e) {
      print('Error capturing frame: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _channel?.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : _errorMessage.isNotEmpty
            ? Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              )
            : Stack(
                children: [
                  Screenshot(
                    controller: _screenshotController,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  CustomPaint(
                    painter: BoundingBoxPainter(
                      boundingBoxes: _boundingBoxes,
                      cameraAspectRatio: _controller.value.aspectRatio,
                      previewSize: Size(
                        _controller.value.size.width,
                        _controller.value.size.height,
                      ),
                    ),
                  ),
                ],
              );
  }
}
