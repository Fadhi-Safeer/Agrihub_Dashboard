// lib/widgets/camera_feed.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'bounding_box_painter.dart';
import '../providers/yolo_provider.dart';

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
  Timer? _detectionTimer;
  Timer? _croppingTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.cameraUrl);
    _initializeController();
    _startDetectionTimer();
    _startCroppingTimer();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.play();
      setState(() {
        _isLoading = false;
      });
      debugPrint("Video player initialized for ${widget.cameraUrl}");
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video: $e';
        _isLoading = false;
      });
      debugPrint("Error initializing video player: $e");
    }
  }

  // Timer for sending detection requests (Step 1)
  void _startDetectionTimer() {
    final yoloProvider = Provider.of<YOLOProvider>(context, listen: false);
    _detectionTimer = Timer.periodic(Duration(seconds: 6), (timer) {
      yoloProvider.sendDetectionRequest(widget.cameraUrl);
      debugPrint('Sent detection request for ${widget.cameraUrl}');
    });
  }

  // Timer for sending cropping & classification requests (Step 2)
  void _startCroppingTimer() {
    final yoloProvider = Provider.of<YOLOProvider>(context, listen: false);
    _croppingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      // Only send cropping request if bounding boxes are available
      if (yoloProvider.boundingBoxes.isNotEmpty) {
        yoloProvider.sendCroppingRequest(
            widget.cameraUrl, yoloProvider.boundingBoxes);
        debugPrint(
            'Sent cropping & classification request for ${widget.cameraUrl}');
      } else {
        debugPrint('No bounding boxes available for cropping request.');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _detectionTimer?.cancel();
    _croppingTimer?.cancel();
    super.dispose();
    debugPrint('Disposed CameraFeed for ${widget.cameraUrl}');
  }

  @override
  Widget build(BuildContext context) {
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
        // Overlay bounding boxes from YOLOProvider
        Consumer<YOLOProvider>(
          builder: (context, yoloProvider, child) {
            if (yoloProvider.boundingBoxes.isNotEmpty &&
                _controller.value.isInitialized &&
                _controller.value.size.width > 0 &&
                _controller.value.size.height > 0) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: BoundingBoxPainter(
                    boundingBoxes: yoloProvider.boundingBoxes,
                    cameraAspectRatio: _controller.value.aspectRatio,
                    previewSize: _controller.value.size,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
