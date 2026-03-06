import '../models/expense_model.dart';

class MLService {
  /// Moving Average Prediction (Simple Time-Series)
  static double predictNextMonth(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return 0;

    // Sort by date descending (though they should be already from Firestore)
    final sortedExpenses = List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Simple prediction: average of the last few entries
    final recentExpenses = sortedExpenses.take(10).toList();
    final total = recentExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    return total / recentExpenses.length;
  }

  static String predictCategory(String title) {
    final text = title.toLowerCase();

    if (text.contains('pizza') ||
        text.contains('burger') ||
        text.contains('food') ||
        text.contains('cafe') ||
        text.contains('restaurant') ||
        text.contains('grocery')) {
      return 'Food';
    }

    if (text.contains('uber') ||
        text.contains('ola') ||
        text.contains('bus') ||
        text.contains('train') ||
        text.contains('fuel') ||
        text.contains('petrol')) {
      return 'Travel';
    }

    if (text.contains('amazon') ||
        text.contains('flipkart') ||
        text.contains('shopping') ||
        text.contains('clothes')) {
      return 'Shopping';
    }

    if (text.contains('rent') || text.contains('bill') || text.contains('electricity')) {
      return 'Bills';
    }

    if (text.contains('movie') || text.contains('netflix') || text.contains('game')) {
      return 'Entertainment';
    }

    return 'Other';
  }
}
