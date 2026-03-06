import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense_model.dart';

class BudgetAlertWidget extends StatelessWidget {
  const BudgetAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return StreamBuilder<List<ExpenseModel>>(
      stream: expenseProvider.expenses,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final expenses = snapshot.data!;
        final exceededBudgets = budgetProvider.budgets.where((b) {
          return budgetProvider.isExceeded(b, expenses);
        }).toList();

        if (exceededBudgets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: exceededBudgets.map((budget) {
            final spent = budgetProvider.getSpentAmount(budget, expenses);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Budget exceeded: ${budget.category}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Spent: ₹${spent.toStringAsFixed(2)} / ₹${budget.limitAmount.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.red.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
