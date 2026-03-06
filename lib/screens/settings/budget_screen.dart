import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    _ctrl = TextEditingController(text: provider.budget.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Set Budget")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set your monthly spending limit",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Monthly Budget",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text("Save Budget"),
                onPressed: () {
                  final amount = double.tryParse(_ctrl.text);
                  if (amount != null && amount >= 0) {
                    provider.setBudget(amount);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Budget updated successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
