import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProvider extends ChangeNotifier {
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;

  void setUser(GoogleSignInAccount? account) {
    _user = account;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
