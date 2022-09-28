import 'package:flutter/material.dart';

class DownloadStat with ChangeNotifier {
  String _cap = 'Preparing Download...';

  void changeCap(String data) {
    _cap = data;
    notifyListeners();
  }

  String get cap => _cap;
}
