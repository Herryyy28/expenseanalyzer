import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../services/ml_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  /// Get expenses stream
  Stream<List<ExpenseModel>> get expenses => _firestoreService.getExpenses();

  /// Add a new expense
  Future<void> addExpense(String title, double amount) async {
    final category = MLService.predictCategory(title);

    final expense = ExpenseModel(
      id: '', // Firestore will generate the ID
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
    );

    try {
      await _firestoreService.addExpense(expense);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  /// Update an existing expense
  Future<void> updateExpense(String id, String title, double amount) async {
    final category = MLService.predictCategory(title);
    
    try {
      await _firestoreService.updateExpense(id, {
        'title': title,
        'amount': amount,
        'category': category,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    try {
      await _firestoreService.deleteExpense(id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }
}
