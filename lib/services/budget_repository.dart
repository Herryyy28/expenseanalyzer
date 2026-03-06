import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'budgets';

  /// Save or update a budget
  Future<void> saveBudget(BudgetModel budget) async {
    await _firestore
        .collection(_collection)
        .doc(budget.id.isEmpty ? null : budget.id)
        .set(budget.toMap(), SetOptions(merge: true));
  }

  /// Get budgets for a specific user
  Stream<List<BudgetModel>> getBudgets(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BudgetModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  /// Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    await _firestore.collection(_collection).doc(budgetId).delete();
  }
}
