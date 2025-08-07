import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'camera_feed.dart';

class CameraGrid extends StatefulWidget {
  final List<String> availableCameras;

  const CameraGrid({Key? key, required this.availableCameras})
      : super(key: key);

  @override
  _CameraGridState createState() => _CameraGridState();
}

class _CameraGridState extends State<CameraGrid> {
  String? selectedCameraUrl;

  void _toggleCamera(String url) {
    setState(() {
      if (selectedCameraUrl == url) {
        selectedCameraUrl = null; // Deselect to return to grid view
      } else {
        selectedCameraUrl = url; // Maximize this camera
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCameraUrl != null) {
      // Single camera view (maximized)
      return GestureDetector(
        onTap: () => _toggleCamera(selectedCameraUrl!),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.cameraBG,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: CameraFeed(cameraUrl: selectedCameraUrl!),
        ),
      );
    }

    // Normal 5x2 grid view
    int totalGridCount = 10;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columns
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1.0, // Square grid cells
      ),
      itemCount: totalGridCount,
      itemBuilder: (context, index) {
        if (index < widget.availableCameras.length) {
          final url = widget.availableCameras[index];
          return GestureDetector(
            onTap: () => _toggleCamera(url),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cameraBG,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: CameraFeed(cameraUrl: url),
              ),
            ),
          );
        } else {
          // Placeholder for unused grid slots
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
