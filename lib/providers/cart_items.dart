import 'package:flutter/material.dart';

class CartItemCounter with ChangeNotifier {
  int _itmNo = 0;

  int get itmNo => _itmNo;

  void addTotal(int no) {
    _itmNo = _itmNo + no;
    notifyListeners();
  }

  void minusTotal(int no) {
    _itmNo = _itmNo - no;
    notifyListeners();
  }

  void setTotal(int no) {
    _itmNo = no;
    notifyListeners();
  }
}
