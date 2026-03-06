import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/prediction_provider.dart';

class PredictionScreen extends StatelessWidget {
  const PredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final predictionProvider =
    Provider.of<PredictionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Prediction")),
      body: StreamBuilder(
        stream: expenseProvider.expenses,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trigger prediction update in the provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            predictionProvider.updatePrediction(snapshot.data!);
          });

          return Center(
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Predicted Next Month Expense",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "₹${predictionProvider.predictedAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Based on your past spending trend",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
