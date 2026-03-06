import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _expensesCollection => _firestore.collection('expenses');

  // ==================== EXPENSE OPERATIONS ====================

  /// Add expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _expensesCollection.add(expense.toMap());
      debugPrint('✅ Expense added to Firestore');
    } catch (e) {
      debugPrint('❌ Error adding expense: $e');
      rethrow;
    }
  }

  /// Get all expenses as a stream of lists
  Stream<List<ExpenseModel>> getExpenses() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
    });
  }

  /// Update expense
  Future<void> updateExpense(String expenseId, Map<String, dynamic> data) async {
    try {
      await _expensesCollection.doc(expenseId).update(data);
      debugPrint('✅ Expense updated: $expenseId');
    } catch (e) {
      debugPrint('❌ Error updating expense: $e');
      rethrow;
    }
  }

  /// Delete expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expensesCollection.doc(expenseId).delete();
      debugPrint('✅ Expense deleted: $expenseId');
    } catch (e) {
      debugPrint('❌ Error deleting expense: $e');
      rethrow;
    }
  }

  /// Create or update user document
  Future<void> createOrUpdateUser({
    required String userId,
    required String email,
    String? name,
  }) async {
    try {
      final userData = {
        'email': email,
        'name': name ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).set(
        userData,
        SetOptions(merge: true),
      );

      debugPrint('✅ User document created/updated: $userId');
    } catch (e) {
      debugPrint('❌ Error creating/updating user: $e');
      rethrow;
    }
  }
}
