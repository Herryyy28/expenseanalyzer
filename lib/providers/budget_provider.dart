import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/expense_model.dart';
import '../services/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository = BudgetRepository();
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  /// Fetch and listen to budgets
  void init(String userId) {
    _isLoading = true;
    _repository.getBudgets(userId).listen((data) {
      _budgets = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Add or Update budget
  Future<void> setBudget(BudgetModel budget) async {
    await _repository.saveBudget(budget);
  }

  /// Delete budget
  Future<void> removeBudget(String id) async {
    await _repository.deleteBudget(id);
  }

  /// Calculate spent amount for a specific budget
  double getSpentAmount(BudgetModel budget, List<ExpenseModel> expenses) {
    return expenses
        .where(
          (e) =>
              (budget.category == 'All' || e.category == budget.category) &&
              e.date.isAfter(budget.startDate) &&
              e.date.isBefore(budget.endDate.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get percentage of budget used
  double getProgress(BudgetModel budget, List<ExpenseModel> expenses) {
    if (budget.limitAmount == 0) return 0;
    final spent = getSpentAmount(budget, expenses);
    return (spent / budget.limitAmount).clamp(0.0, 1.0);
  }

  /// Check if a budget is exceeded
  bool isExceeded(BudgetModel budget, List<ExpenseModel> expenses) {
    return getSpentAmount(budget, expenses) > budget.limitAmount;
  }
}
