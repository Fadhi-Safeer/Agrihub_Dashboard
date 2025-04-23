import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'bounding_box_painter.dart';
import '../../providers/yolo_provider.dart';

class CameraFeed extends StatefulWidget {
  final String cameraUrl;

  const CameraFeed({
    Key? key,
    required this.cameraUrl,
  }) : super(key: key);

  @override
  _CameraFeedState createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.cameraUrl);
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.play();

      // Register camera with YOLO provider after successful init
      final yoloProvider = Provider.of<YOLOProvider>(context, listen: false);
      yoloProvider.registerCamera(widget.cameraUrl);

      setState(() {
        _isLoading = false;
        _hasInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint("Error initializing camera feed: ${e.toString()}");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitialized) {
      // Re-register camera if provider changes
      final yoloProvider = Provider.of<YOLOProvider>(context, listen: false);
      yoloProvider.registerCamera(widget.cameraUrl);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Unregister camera when disposed
    final yoloProvider = Provider.of<YOLOProvider>(context, listen: false);
    yoloProvider.unregisterCamera(widget.cameraUrl);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YOLOProvider>(
      builder: (context, yoloProvider, child) {
        return Stack(
          children: [
            // Video Feed or Loading/Error State
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),

            // Bounding Box Overlay (only when this camera is active)
            if (yoloProvider.latestFrameUrl == widget.cameraUrl &&
                yoloProvider.boundingBoxes.isNotEmpty &&
                _controller.value.isInitialized)
              Positioned.fill(
                child: CustomPaint(
                  painter: BoundingBoxPainter(
                    boundingBoxes: yoloProvider.boundingBoxes,
                    cameraAspectRatio: _controller.value.aspectRatio,
                    previewSize: _controller.value.size,
                  ),
                ),
              ),

            // Classification Results Indicator
            if (yoloProvider.latestFrameUrl == widget.cameraUrl &&
                yoloProvider.classificationResults.isNotEmpty)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Results: ${yoloProvider.classificationResults.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
