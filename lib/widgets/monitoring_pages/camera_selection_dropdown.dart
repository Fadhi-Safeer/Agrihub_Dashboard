import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/available_cameras.dart';
import '../../providers/cameraSelectionDropdown_provider.dart';

class CameraSelectionDropdown extends StatelessWidget {
  const CameraSelectionDropdown({super.key});

  /// Helper function to extract camera numbers from URLs
  List<String> extractCameraNumbers(List<String> links) {
    return links.map((link) => link.split('/').last.split('.').first).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> cameraLinks =
        getAvailableCameras(); // Get list of camera links
    final List<String> cameraNumbers = extractCameraNumbers(cameraLinks);

    // Use the provider to get the selected camera and the setter to update it
    final selectedCamera =
        Provider.of<CameraSelectionDropdownProvider>(context).selectedCamera;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: AppColors.sidebarGradientStart,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        value: cameraNumbers.contains(selectedCamera)
            ? selectedCamera
            : null, // Set the selected camera
        onChanged: (newCamera) {
          if (newCamera != null) {
            // Update the selected camera in the provider
            Provider.of<CameraSelectionDropdownProvider>(context, listen: false)
                .selectedCamera = newCamera;
          }
        },
        hint: const Text('Select Camera'), // Shown when nothing is selected
        items: cameraNumbers.map<DropdownMenuItem<String>>((String camera) {
          return DropdownMenuItem<String>(
            value: camera,
            child: Text(
              camera,
              style: TextStyle(
                color: AppColors.sidebarGradientStart,
              ),
            ),
          );
        }).toList(),
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
