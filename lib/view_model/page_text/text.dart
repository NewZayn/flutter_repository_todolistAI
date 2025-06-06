import 'package:flutter/material.dart';

class TextViewModel extends ChangeNotifier {
  String localLenguage = 'en';

  TextViewModel({
    required this.localLenguage,
  });

  void updateLanguage(String newLanguage) {
    localLenguage = newLanguage;
    notifyListeners();
  }

  String getLanguage() {
    return localLenguage;
  }

  void resetLanguage() {
    localLenguage = '';
    notifyListeners();
  }
}
