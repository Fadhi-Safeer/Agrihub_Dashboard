import 'package:flutter/material.dart';
import 'camera_feed.dart';

class CameraGrid extends StatelessWidget {
  final int availableCameras;

  const CameraGrid({Key? key, required this.availableCameras})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columns
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
      ),
      itemCount: 10, // 10 cameras or placeholders
      itemBuilder: (context, index) {
        if (index < availableCameras) {
          return CameraFeed(cameraId: index);
        } else {
          return Center(
            child: Text(
              'No Camera',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
}
