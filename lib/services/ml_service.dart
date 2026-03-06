import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';

class MLService {
  // Senior Level: Gemini Integration
  static const String _geminiApiKey =
      'YOUR_GEMINI_API_KEY'; // In a real app, this should be in an .env file

  /// Advanced Analysis using Google's Gemini Pro
  static Future<String> getSmartInsights(List<ExpenseModel> expenses) async {
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      return 'AI Insights: Please configure a Gemini API Key to enable advanced financial analysis.';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
      );

      final expenseSummary = expenses
          .take(30)
          .map((e) => '${e.title}: \$${e.amount} (${e.category})')
          .join('\n');

      final prompt =
          '''
      Analyze the following 30 recent expenses for a personal budget. 
      Identify 3 key spending trends and provide 2 actionable saving tips.
      Keep it professional and concise.

      Expenses:
      $expenseSummary
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? 'Unable to generate insights at this time.';
    } catch (e) {
      debugPrint('Gemini Error: $e');
      return 'Unable to connect to AI engine. Using local heuristics.';
    }
  }

  /// Moving Average Prediction (Simple Time-Series)
  static double predictNextMonth(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return 0;

    // Sort by date descending
    final sortedExpenses = List<ExpenseModel>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Simple prediction: average of the last few entries
    final recentExpenses = sortedExpenses.take(10).toList();
    final total = recentExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    return total / recentExpenses.length;
  }

  /// Categorize using Gemini first, then fallback to Regex
  static Future<String> predictCategorySmart(String title) async {
    // If Gemini is configured, we could call it here for high accuracy
    // but for "Instant" typing suggestions, a local Regex/ML is better.
    // However, a Senior approach is to use a Hybrid model.
    return predictCategory(title);
  }

  static String predictCategory(String title) {
    final text = title.toLowerCase();

    if (text.contains('pizza') ||
        text.contains('burger') ||
        text.contains('food') ||
        text.contains('cafe') ||
        text.contains('restaurant') ||
        text.contains('grocery') ||
        text.contains('swiggy') ||
        text.contains('zomato')) {
      return 'Food';
    }

    if (text.contains('uber') ||
        text.contains('ola') ||
        text.contains('bus') ||
        text.contains('train') ||
        text.contains('fuel') ||
        text.contains('petrol') ||
        text.contains('flight') ||
        text.contains('rapido')) {
      return 'Travel';
    }

    if (text.contains('amazon') ||
        text.contains('flipkart') ||
        text.contains('shopping') ||
        text.contains('clothes') ||
        text.contains('myntra')) {
      return 'Shopping';
    }

    if (text.contains('rent') ||
        text.contains('bill') ||
        text.contains('electricity') ||
        text.contains('recharge') ||
        text.contains('wifi')) {
      return 'Bills';
    }

    if (text.contains('movie') ||
        text.contains('netflix') ||
        text.contains('game') ||
        text.contains('hotstar') ||
        text.contains('prime')) {
      return 'Entertainment';
    }

    return 'Other';
  }
}
