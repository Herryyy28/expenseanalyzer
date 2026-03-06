import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _expensesCollection => _firestore.collection('expenses');
  CollectionReference get _budgetsCollection => _firestore.collection('budgets');

  // ==================== USER OPERATIONS ====================

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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _usersCollection.doc(userId).set(
        userData,
        SetOptions(merge: true),
      );

      debugPrint('✅ User document created/updated: $userId');
    } catch (e) {
      debugPrint('❌ Error creating/updating user: $e');
      rethrow;
    }
  }

  /// Get user document
  Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user: $e');
      rethrow;
    }
  }

  /// Update user document
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(userId).update(data);
      debugPrint('✅ User updated: $userId');
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      rethrow;
    }
  }

  /// Delete user document
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
      debugPrint('✅ User deleted: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      rethrow;
    }
  }

  // ==================== EXPENSE OPERATIONS ====================

  /// Create expense
  Future<String> createExpense(Map<String, dynamic> expenseData) async {
    try {
      expenseData['createdAt'] = FieldValue.serverTimestamp();
      expenseData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _expensesCollection.add(expenseData);
      debugPrint('✅ Expense created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating expense: $e');
      rethrow;
    }
  }

  /// Get all expenses for a user
  Stream<QuerySnapshot> getUserExpenses(String userId) {
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Get expenses by date range
  Stream<QuerySnapshot> getExpensesByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where('date', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Get expenses by category
  Stream<QuerySnapshot> getExpensesByCategory({
    required String userId,
    required String category,
  }) {
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots();
  }

  /// Update expense
  Future<void> updateExpense(String expenseId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
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

  /// Get total expenses for a user
  Future<double> getTotalExpenses(String userId) async {
    try {
      final snapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] as num?)?.toDouble() ?? 0;
      }

      return total;
    } catch (e) {
      debugPrint('❌ Error getting total expenses: $e');
      return 0;
    }
  }

  /// Get expenses grouped by category
  Future<Map<String, double>> getExpensesByCategories(String userId) async {
    try {
      final snapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String? ?? 'Other';
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;

        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      debugPrint('❌ Error getting expenses by categories: $e');
      return {};
    }
  }

  // ==================== BUDGET OPERATIONS ====================

  /// Create budget
  Future<String> createBudget(Map<String, dynamic> budgetData) async {
    try {
      budgetData['createdAt'] = FieldValue.serverTimestamp();
      budgetData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _budgetsCollection.add(budgetData);
      debugPrint('✅ Budget created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating budget: $e');
      rethrow;
    }
  }

  /// Get all budgets for a user
  Stream<QuerySnapshot> getUserBudgets(String userId) {
    return _budgetsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('startDate', descending: true)
        .snapshots();
  }

  /// Get active budgets
  Stream<QuerySnapshot> getActiveBudgets(String userId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _budgetsCollection
        .where('userId', isEqualTo: userId)
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .snapshots();
  }

  /// Update budget
  Future<void> updateBudget(String budgetId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _budgetsCollection.doc(budgetId).update(data);
      debugPrint('✅ Budget updated: $budgetId');
    } catch (e) {
      debugPrint('❌ Error updating budget: $e');
      rethrow;
    }
  }

  /// Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _budgetsCollection.doc(budgetId).delete();
      debugPrint('✅ Budget deleted: $budgetId');
    } catch (e) {
      debugPrint('❌ Error deleting budget: $e');
      rethrow;
    }
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch write expenses (for offline sync)
  Future<void> batchWriteExpenses(List<Map<String, dynamic>> expenses) async {
    try {
      final batch = _firestore.batch();

      for (var expense in expenses) {
        final docRef = _expensesCollection.doc();
        expense['createdAt'] = FieldValue.serverTimestamp();
        expense['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(docRef, expense);
      }

      await batch.commit();
      debugPrint('✅ Batch write completed: ${expenses.length} expenses');
    } catch (e) {
      debugPrint('❌ Error in batch write: $e');
      rethrow;
    }
  }

  /// Delete all user data (for account deletion)
  Future<void> deleteAllUserData(String userId) async {
    try {
      // Delete expenses
      final expensesSnapshot = await _expensesCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in expensesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete budgets
      final budgetsSnapshot = await _budgetsCollection
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in budgetsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await deleteUser(userId);

      debugPrint('✅ All user data deleted: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user data: $e');
      rethrow;
    }
  }
}