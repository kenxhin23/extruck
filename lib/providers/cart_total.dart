import 'package:flutter/material.dart';

class CartTotalCounter with ChangeNotifier {
  double _totalAmt = 0.00;

  double get totalAmt => _totalAmt;

  void addTotal(double amt) {
    _totalAmt = _totalAmt + amt;
    notifyListeners();
  }

  void minusTotal(double amt) {
    _totalAmt = _totalAmt - amt;
    notifyListeners();
  }

  void setTotal(double amt) {
    _totalAmt = amt;
    notifyListeners();
  }
}
