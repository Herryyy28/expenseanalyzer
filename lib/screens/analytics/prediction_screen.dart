import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/prediction_provider.dart';
import '../../models/expense_model.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final predictionProvider = Provider.of<PredictionProvider>(context);

    // Initial fetch for insights
    void fetchInsightsOnce(List<ExpenseModel> expenses) {
      if (!predictionProvider.isLoadingInsights &&
          predictionProvider.aiInsights == 'Predicting...') {
        predictionProvider.fetchAiInsights(expenses);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Financial Prediction"),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              // Manual refresh of AI insights
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: expenseProvider.expenses,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!;
          // Senior Logic: Update numeric prediction silently
          predictionProvider.updatePrediction(expenses);

          // Trigger AI insights fetch (debounced/once)
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => fetchInsightsOnce(expenses),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPredictionCard(
                  context,
                  predictionProvider.predictedAmount,
                ),
                const SizedBox(height: 24),
                _buildInsightsHeader(context),
                const SizedBox(height: 12),
                _buildInsightsCard(context, predictionProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, double amount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            const Text(
              "Next Month Estimate",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "₹${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Based on your latest 10 transactions",
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.lightbulb_outline, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text("Smart Insights", style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildInsightsCard(BuildContext context, PredictionProvider provider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.isLoadingInsights)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Text(
                provider.aiInsights,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Recalculate"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
