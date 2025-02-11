import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../services/yolo_service.dart';
import 'bounding_box_painter.dart';

class CameraFeed extends StatefulWidget {
  final int cameraId;

  const CameraFeed({Key? key, required this.cameraId}) : super(key: key);

  @override
  _CameraFeedState createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final WebSocketChannel _channel = YOLOService.connect();
  List<List<int>> _boundingBoxes = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    YOLOService.listen(
      _channel,
      onData: (data) {
        setState(() {
          _boundingBoxes = _parseBoundingBoxData(data);
        });
      },
      onError: (error) {
        print('WebSocket error: $error');
        _reconnectWebSocket();
      },
      onDone: () {
        print('WebSocket connection closed');
        _reconnectWebSocket();
      },
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![widget.cameraId],
        ResolutionPreset.medium,
      );
      await _controller?.initialize();
      if (mounted) {
        setState(() {});
      }

      _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
        if (_controller != null && _controller!.value.isInitialized) {
          final image = await _controller!.takePicture();
          final bytes = await image.readAsBytes();
          YOLOService.sendImage(_channel, bytes);
        }
      });
    }
  }

  void _reconnectWebSocket() {
    // Implement reconnection logic here
  }

  List<List<int>> _parseBoundingBoxData(String data) {
    try {
      final parsed = jsonDecode(data);
      return List<List<int>>.from(parsed.map((x) => List<int>.from(x)));
    } catch (e) {
      print('Error parsing bounding box data: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    YOLOService.close(_channel);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final cameraAspectRatio = _controller!.value.aspectRatio;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: AspectRatio(
            aspectRatio: cameraAspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: BoundingBoxPainter(
              boundingBoxes: _boundingBoxes,
              cameraAspectRatio: cameraAspectRatio,
              previewSize: _controller!.value.previewSize!,
            ),
          ),
        ),
      ],
    );
  }
}
