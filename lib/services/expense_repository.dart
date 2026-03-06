import '../models/expense_model.dart';
import 'firestore_service.dart';
import 'local_db_service.dart';

class ExpenseRepository {
  final FirestoreService _remoteService = FirestoreService();
  final LocalDBService _localService = LocalDBService();

  /// Single Source of Truth: Streams from Firestore
  Stream<List<ExpenseModel>> getExpenses() {
    return _remoteService.getExpenses();
  }

  Future<void> addExpense(String title, double amount, String category) async {
    final expense = ExpenseModel(
      id: '',
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
    );

    // Senior level: Optimistic UI or Sync strategy
    // 1. Save to local for offline support (simplified for now)
    // 2. Save to remote
    await _remoteService.addExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _remoteService.deleteExpense(id);
  }
}
