import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_repository.dart';
import '../services/ml_service.dart';
import '../core/ui_state.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();

  UiState<List<ExpenseModel>> _state = const Initial();
  UiState<List<ExpenseModel>> get state => _state;

  ExpenseProvider() {
    _init();
  }

  Stream<List<ExpenseModel>> get expenses => _repository.getExpenses();

  void _init() {
    _state = const Loading();
    _repository.getExpenses().listen(
      (expenses) {
        _state = Success(expenses);
        notifyListeners();
      },
      onError: (error) {
        _state = Failure(error.toString());
        notifyListeners();
      },
    );
  }

  Future<void> addExpense(String title, double amount) async {
    try {
      final category = MLService.predictCategory(title);
      await _repository.addExpense(title, amount, category);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateExpense(String id, String title, double amount) async {
    try {
      final category = MLService.predictCategory(title);
      await _repository.updateExpense(id, title, amount, category);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
    } catch (e) {
      rethrow;
    }
  }
}
