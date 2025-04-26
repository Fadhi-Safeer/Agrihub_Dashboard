import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/available_cameras.dart';
import '../../providers/cameraSelectionDropdown_provider.dart';

class CameraSelectionDropdown extends StatelessWidget {
  final Function(String)? onCameraChanged; // New callback parameter

  const CameraSelectionDropdown({
    super.key,
    this.onCameraChanged, // Optional callback
  });

  /// Helper function to extract camera numbers from URLs
  List<String> extractCameraNumbers(List<String> links) {
    return links.map((link) => link.split('/').last.split('.').first).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> cameraLinks = getAvailableCameras();
    final List<String> cameraNumbers = extractCameraNumbers(cameraLinks);
    final dropdownProvider =
        Provider.of<CameraSelectionDropdownProvider>(context);

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
        value: cameraNumbers.contains(dropdownProvider.selectedCamera)
            ? dropdownProvider.selectedCamera
            : null,
        onChanged: (newCamera) {
          if (newCamera != null) {
            // Update the selected camera in the provider
            Provider.of<CameraSelectionDropdownProvider>(context, listen: false)
                .selectedCamera = newCamera;

            // Invoke the callback if provided
            onCameraChanged?.call(newCamera);
          }
        },
        hint: const Text('Select Camera'),
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
