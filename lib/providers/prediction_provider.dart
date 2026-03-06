import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/ml_service.dart';

class PredictionProvider extends ChangeNotifier {
  double _predictedAmount = 0;

  double get predictedAmount => _predictedAmount;

  void calculatePrediction(List<ExpenseModel> expenses) {
    _predictedAmount = MLService.predictNextMonth(expenses);
    notifyListeners();
  }
}
