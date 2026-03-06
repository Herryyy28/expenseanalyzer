import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/ml_service.dart';

class PredictionProvider extends ChangeNotifier {
  double _predictedAmount = 0;
  String _aiInsights = 'Predicting...';
  bool _isLoadingInsights = false;

  double get predictedAmount => _predictedAmount;
  String get aiInsights => _aiInsights;
  bool get isLoadingInsights => _isLoadingInsights;

  /// Calculates prediction without notifying listeners immediately
  void updatePrediction(List<ExpenseModel> expenses) {
    final newPrediction = MLService.predictNextMonth(expenses);
    if (_predictedAmount != newPrediction) {
      _predictedAmount = newPrediction;
      Future.microtask(() => notifyListeners());
    }
  }

  /// Senior Layer: Fetch Advanced AI Insights
  Future<void> fetchAiInsights(List<ExpenseModel> expenses) async {
    if (expenses.isEmpty) {
      _aiInsights = 'Add some expenses to get AI-powered financial advice.';
      notifyListeners();
      return;
    }

    _isLoadingInsights = true;
    notifyListeners();

    try {
      _aiInsights = await MLService.getSmartInsights(expenses);
    } catch (e) {
      _aiInsights = 'AI analysis temporarily unavailable.';
    } finally {
      _isLoadingInsights = false;
      notifyListeners();
    }
  }
}
