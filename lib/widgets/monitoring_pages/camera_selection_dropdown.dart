import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/available_cameras.dart';

class CameraSelectionDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;

  const CameraSelectionDropdown({
    super.key,
    this.value, // Accept null to indicate no selection
    this.onChanged,
  });

  /// Helper function to extract camera numbers from URLs
  List<String> extractCameraNumbers(List<String> links) {
    return links.map((link) => link.split('/').last.split('.').first).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> cameraLinks = getAvailableCameras(); // Get list
    final List<String> cameraNumbers = extractCameraNumbers(cameraLinks);

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
        value: cameraNumbers.contains(value) ? value : null, // default null
        onChanged: onChanged,
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
