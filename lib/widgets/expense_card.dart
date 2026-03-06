import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(expense.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(expense.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("₹${expense.amount}"),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                provider.deleteExpense(expense.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
