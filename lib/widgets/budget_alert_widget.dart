import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';

class BudgetAlertWidget extends StatelessWidget {
  const BudgetAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = Provider.of<BudgetProvider>(context).budget;
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return StreamBuilder(
      stream: expenseProvider.expenses,
      builder: (context, snapshot) {
        if (!snapshot.hasData || budget == 0) return const SizedBox();

        final total = snapshot.data!
            .fold<double>(0, (sum, e) => sum + e.amount);

        if (total > budget) {
          return Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "⚠ Budget exceeded!",
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
