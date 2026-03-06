import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../services/ml_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<ExpenseModel>> get expenses =>
      _firestoreService.getExpenses();

  Future<void> addExpense(String title, double amount) async {
    final category = MLService.predictCategory(title);

    final expense = ExpenseModel(
      id: '',
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
    );

    await _firestoreService.addExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _firestoreService.deleteExpense(id);
  }
}
