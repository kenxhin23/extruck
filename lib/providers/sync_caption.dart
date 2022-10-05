import 'package:flutter/material.dart';

class SyncCaption with ChangeNotifier {
  String _cap = 'Updating...';

  void changeCap(String data) {
    _cap = data;
    notifyListeners();
  }

  String get cap => _cap;
}
