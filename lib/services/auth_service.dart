import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  bool login(String username, String password) {
    if (username == 'thuynt' && password == 't2208e') {
      _isAuthenticated = true;
      notifyListeners();
      return true; // Return true if login is successful
    } else {
      return false; // Return false if login fails
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
