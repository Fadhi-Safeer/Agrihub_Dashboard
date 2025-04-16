import 'package:flutter/material.dart';

class CameraSelectionDropdownProvider with ChangeNotifier {
  // This will hold the currently selected camera
  String? _selectedCamera;

  // Getter for the selected camera
  String? get selectedCamera => _selectedCamera;

  // Setter to change the selected camera
  set selectedCamera(String? newCamera) {
    if (_selectedCamera != newCamera) {
      _selectedCamera = newCamera;
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Optionally, you can initialize with a default camera if needed
  CameraSelectionDropdownProvider({String? initialCamera}) {
    _selectedCamera = initialCamera;
  }
}
