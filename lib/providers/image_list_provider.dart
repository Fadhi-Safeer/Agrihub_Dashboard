import 'package:flutter/material.dart';

import '../repository/image_repository.dart';
import '../models/image_item.dart';

class ImageListProvider with ChangeNotifier {
  final ImageRepository _repository;
  List<ImageItem> _images = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String? _currentCamera;

  ImageListProvider({ImageRepository? repository})
      : _repository = repository ?? ImageRepository();

  List<ImageItem> get images => _images;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get currentCamera => _currentCamera;

  Future<void> loadImages(String camNum, {bool camera_view = false}) async {
    if (_isLoading || _currentCamera == camNum) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _images = await _repository.fetchImages(camNum, camera_view: camera_view);
      _currentCamera = camNum;
    } on CameraNotFoundException catch (e) {
      _errorMessage = 'Camera not found: ${e.message}';
      _images = [];
    } on NetworkException catch (e) {
      _errorMessage = 'Network error: ${e.message}';
    } on DataParsingException catch (e) {
      _errorMessage = 'Data error: ${e.message}';
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _images = [];
    _errorMessage = '';
    _currentCamera = null;
    notifyListeners();
  }
}
