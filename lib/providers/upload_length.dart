import 'package:flutter/material.dart';

class UploadLength with ChangeNotifier {
  int _itmNo = 0;

  int get itmNo => _itmNo;

  void setTotal(int no) {
    _itmNo = no;
    notifyListeners();
  }

  void addTotal(int no) {
    _itmNo = _itmNo + no;
    notifyListeners();
  }

  void minusTotal(int no) {
    _itmNo = _itmNo + no;
    notifyListeners();
  }
}
