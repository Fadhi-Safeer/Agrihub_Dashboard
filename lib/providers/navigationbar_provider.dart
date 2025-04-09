import 'package:flutter/material.dart';

class NavigationBarProvider with ChangeNotifier {
  // Tracks the currently selected menu
  String _selectedMenu = 'HOME';

  // Getter to access the selected menu
  String get selectedMenu => _selectedMenu;

  // Updates the selected menu and notifies listeners
  void updateSelectedMenu(String menu) {
    _selectedMenu = menu;
    notifyListeners(); // Notify any widgets listening to this provider
  }
}
