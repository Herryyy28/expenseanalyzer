import 'package:flutter/material.dart';
import 'prediction_screen.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text("Expense Prediction"),
              subtitle: const Text("View next month prediction"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PredictionScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
