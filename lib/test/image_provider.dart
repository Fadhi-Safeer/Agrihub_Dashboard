import 'package:flutter/material.dart';
import 'image_repository.dart';
import 'image_item.dart';

class ImageGalleryProvider with ChangeNotifier {
  final ImageRepository _repository = ImageRepository();
  List<ImageItem> images = [];
  bool isLoading = true;
  String errorMessage = "";

  Future<void> loadImages(String camNum) async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      images = await _repository.fetchImages(camNum);
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
