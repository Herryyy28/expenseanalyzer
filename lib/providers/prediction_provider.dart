import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/ml_service.dart';

class PredictionProvider extends ChangeNotifier {
  double _predictedAmount = 0;

  double get predictedAmount => _predictedAmount;

  /// Calculates prediction without notifying listeners immediately 
  /// to avoid rebuild errors during build phase.
  void updatePrediction(List<ExpenseModel> expenses) {
    final newPrediction = MLService.predictNextMonth(expenses);
    if (_predictedAmount != newPrediction) {
      _predictedAmount = newPrediction;
      // We use microtask to notify listeners after the current build frame
      Future.microtask(() => notifyListeners());
    }
  }
}
