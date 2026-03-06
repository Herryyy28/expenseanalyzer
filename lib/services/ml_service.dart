import '../models/expense_model.dart';

extension ExpensePrediction on MLService {
  /// Moving Average Prediction (Simple Time-Series)
  static double predictNextMonth(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return 0;

    final lastMonths = expenses.take(6).toList();
    final total = lastMonths.fold<double>(
        0, (sum, e) => sum + e.amount);

    return total / lastMonths.length;
  }
}



class MLService {
  static String predictCategory(String title) {
    final text = title.toLowerCase();

    if (text.contains('pizza') ||
        text.contains('burger') ||
        text.contains('food') ||
        text.contains('cafe')) {
      return 'Food';
    }

    if (text.contains('uber') ||
        text.contains('bus') ||
        text.contains('train')) {
      return 'Travel';
    }

    if (text.contains('amazon') ||
        text.contains('flipkart') ||
        text.contains('shopping')) {
      return 'Shopping';
    }

    if (text.contains('rent')) {
      return 'Rent';
    }

    return 'Other';
  }
}
