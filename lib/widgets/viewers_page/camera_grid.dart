import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'camera_feed.dart';

class CameraGrid extends StatelessWidget {
  final List<String> availableCameras;

  const CameraGrid({Key? key, required this.availableCameras})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalGridCount = 10; // Set total grid slots (adjustable)

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(), // Disable scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columns
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1.0, // Keeps square aspect ratio
      ),
      itemCount: totalGridCount, // Fixed number of slots
      itemBuilder: (context, index) {
        if (index < availableCameras.length) {
          // Display camera feed if available
          return Container(
            decoration: BoxDecoration(
              color: AppColors.cameraBG,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: CameraFeed(cameraUrl: availableCameras[index]),
            ),
          );
        } else {
          // Show a placeholder if no camera is present
          return Container(
            decoration: BoxDecoration(
              color: AppColors.cameraBG,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset('assets/No Camera.png'),
              ),
            ),
          );
        }
      },
    );
  }
}
