import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
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
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
  }
}
