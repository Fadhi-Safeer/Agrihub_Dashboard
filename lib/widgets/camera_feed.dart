import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../globals.dart'; // Import the globals.dart file

class CameraFeed extends StatefulWidget {
  final int cameraId;

  const CameraFeed({Key? key, required this.cameraId}) : super(key: key);

  @override
  _CameraFeedState createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  Timer? _timer;
  String _prediction = "";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _fetchPrediction();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrediction() async {
    try {
      // Create a multipart request
      var request =
          http.MultipartRequest('POST', Uri.parse('$backendUrl/predict'));
      // Add a sample image file to the request
      request.files.add(await http.MultipartFile.fromPath(
          'file', 'path_to_your_sample_image.jpg'));

      var response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        setState(() {
          _prediction = json.decode(responseBody);
        });
      } else {
        throw Exception('Failed to load prediction');
      }
    } catch (e) {
      print('Error fetching prediction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.network(
            '$backendUrl/stream',
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(height: 8),
                    Text('Failed to load image'),
                  ],
                ),
              );
            },
          ),
        ),
        Text('Prediction: $_prediction'),
      ],
    );
  }
}
