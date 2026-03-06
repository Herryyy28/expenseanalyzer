import 'package:flutter/material.dart';

class BudgetProvider extends ChangeNotifier {
  double _budget = 0;

  double get budget => _budget;

  void setBudget(double value) {
    _budget = value;
    notifyListeners();
  }
}
