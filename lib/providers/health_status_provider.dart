import 'package:flutter/material.dart';

import '../models/image_item.dart';

class HealthStatusProvider extends ChangeNotifier {
  bool _allFullyNutritional = false;

  bool get allFullyNutritional => _allFullyNutritional;

  void updateStatus(List<ImageItem> images) {
    final newStatus = images.isNotEmpty &&
        images.every(
            (image) => image.health.toLowerCase() == "fully nutritional");

    if (_allFullyNutritional != newStatus) {
      _allFullyNutritional = newStatus;
      notifyListeners();
    }
  }
}
