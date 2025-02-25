import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'camera_feed.dart';

class CameraGrid extends StatelessWidget {
  final List<int> availableCameras;

  const CameraGrid({Key? key, required this.availableCameras})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(), // Disable scrolling
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columns
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1.0, // Adjusted aspect ratio for taller boxes
      ),
      itemCount: 10, // 10 cameras or placeholders
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cameraBG, // Background color from app theme
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: index < availableCameras.length
                ? CameraFeed(cameraId: availableCameras[index])
                : FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      'assets/No Camera.png',
                    ),
                  ),
          ),
        );
      },
    );
  }
}
