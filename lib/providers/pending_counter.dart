import 'package:flutter/material.dart';

class PendingCounter with ChangeNotifier {
  int _reqNo = 0;

  int get reqNo => _reqNo;

  void addTotal(int no) {
    _reqNo = _reqNo + no;
    notifyListeners();
  }

  void minusTotal(int no) {
    _reqNo = _reqNo - no;
    notifyListeners();
  }

  void setTotal(int no) {
    _reqNo = no;
    notifyListeners();
  }
}
