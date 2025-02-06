import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraFeed extends StatefulWidget {
  final int cameraId;

  const CameraFeed({Key? key, required this.cameraId}) : super(key: key);

  @override
  _CameraFeedState createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![widget.cameraId],
        ResolutionPreset.medium,
      );
      await _controller?.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _controller!.value.previewSize!.width,
          height: _controller!.value.previewSize!.height,
          child: CameraPreview(_controller!),
        ),
      ),
    );
  }
}
