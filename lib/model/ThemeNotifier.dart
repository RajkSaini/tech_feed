import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    _currentTheme =
    _currentTheme.brightness == Brightness.light ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }
}